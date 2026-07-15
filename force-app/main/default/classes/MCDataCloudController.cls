/**
 * MCDataCloudController
 * ---------------------------------------------------------------------------
 * Generic Data Cloud reader for SFMC-synced DLOs/DMOs. Resolves ids/email/mobile
 * from the recordId (preferring IndividualApplication values),
 * queries Data Cloud, and returns a normalized timeline.
 *
 * Channel modes:
 *   dloName = '<actual DLO API name>'  → single-channel query
 *   dloName = 'ALL'                    → fan-out to Email + SMS + WhatsApp
 *                                        DLOs and merge the results
 *
 * Per-row schema handling:
 *   1. Map metadata: Data Cloud sends a map keyed by column name with
 *      placeInOrder; we sort by placeInOrder.
 *   2. Per-row Map<String, Object> from cells.
 *   3. UNPIVOT: SFMC email DEs are "one row per send with sent/open/click/
 *      bounce date columns". Each non-null date column → one EngagementRow.
 *   4. Fall back to single-event mapping for SMS/WhatsApp DLOs (one row =
 *      one event with EventType + EventDate columns).
 */
public with sharing class MCDataCloudController {

    private static final Pattern IDENTIFIER_RE =
        Pattern.compile('^[A-Za-z0-9_]{1,80}$');

    private static final List<String> SENT_DATE_COLS = new List<String>{
        'sentdate__c', 'SentDate__c', 'sent_date__c',
        'sentdateutc__c', 'SentDateUtc__c'};
    private static final List<String> DELIVERED_DATE_COLS = new List<String>{
        'delivereddate__c', 'DeliveredDate__c', 'delivered_date__c',
        'delivereddateutc__c', 'DeliveredDateUtc__c'};
    private static final List<String> OPEN_DATE_COLS = new List<String>{
        'opendate__c', 'OpenDate__c', 'open_date__c',
        'readdateutc__c', 'ReadDateUtc__c'};
    private static final List<String> CLICK_DATE_COLS = new List<String>{
        'clickdate__c', 'ClickDate__c', 'click_date__c'};
    private static final List<String> BOUNCE_DATE_COLS = new List<String>{
        'bouncedate__c', 'BounceDate__c', 'bounce_date__c'};
    private static final List<String> UNSUB_DATE_COLS = new List<String>{
        'unsubscribedate__c', 'UnsubscribeDate__c', 'unsub_date__c'};
    // WhatsApp/OTT failure timestamps. Mapped to a 'Failed' event so a failed
    // message is not mis-rendered as merely 'Sent' once its dates parse.
    private static final List<String> FAILED_DATE_COLS = new List<String>{
        'faileddateutc__c', 'FailedDateUtc__c', 'failed_date__c',
        'undelivereddateutc__c', 'UndeliveredDateUtc__c'};

    /** Channel descriptor — used by the All Channels fan-out. */
    private class ChannelDef {
        String channel;
        String dlo;
        String filterCol;
        String identifierType;
        String orderBy;
        ChannelDef(String c, String d, String f, String it, String ob) {
            channel = c; dlo = d; filterCol = f; identifierType = it; orderBy = ob;
        }
    }

    private static final List<ChannelDef> ALL_CHANNELS = new List<ChannelDef>{
        new ChannelDef('Email',    'SFMC_Email_Analytics_DE__dlm',    'emailaddress__c', 'email',  'sentdate__c'),
        new ChannelDef('SMS',      'SFMC_SMS_Analytics_DE__dlm',      'mobile__c',       'mobile', 'actiondatetime__c'),
        new ChannelDef('WhatsApp', 'SFMC_Whatsapp_Analytics_DE__dlm', 'mobilenumber__c', 'mobile', 'lasteventdateutc__c')
    };

    @TestVisible private static String mockResponseJson;

    public class EngagementRow {
        @AuraEnabled public String   recipient;
        @AuraEnabled public Datetime eventDate;
        @AuraEnabled public String   eventType;
        @AuraEnabled public String   channel;
        @AuraEnabled public String   messageName;
        @AuraEnabled public String   subjectLine;
        @AuraEnabled public String   journeyName;
        @AuraEnabled public String   bounceReason;
        @AuraEnabled public String   smtpBounceReason;
        @AuraEnabled public String   channelId;
        @AuraEnabled public String   mobileNumber;
        @AuraEnabled public String   channelName;
        @AuraEnabled public String   sendType;
    }

    public class Column {
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        public Column(String n, String t) { name = n; type = t; }
    }

    public class Response {
        @AuraEnabled public String   identifier;
        @AuraEnabled public String   identifierType;
        @AuraEnabled public String   dloName;
        @AuraEnabled public String   dateRange;
        @AuraEnabled public Integer  total;
        @AuraEnabled public List<EngagementRow>      events;
        @AuraEnabled public List<Column>             columns;
        @AuraEnabled public List<Map<String, Object>> rows;
        public Response() {
            events  = new List<EngagementRow>();
            columns = new List<Column>();
            rows    = new List<Map<String, Object>>();
            total   = 0;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Response query(
        Id recordId, String dloName, String filterColumn,
        String identifierType, String orderByColumn, Integer rowLimit,
        String dateRange
    ) {
        try {
            if (recordId == null) {
                throw new MCEngagementException('recordId is required.');
            }
            if (rowLimit == null || rowLimit <= 0 || rowLimit > 1000) rowLimit = 200;

            // All-Channels fan-out
            if (String.isNotBlank(dloName) && dloName.equalsIgnoreCase('ALL')) {
                return runAllChannels(recordId, rowLimit, dateRange);
            }

            // Single channel
            if (String.isBlank(dloName))         dloName        = 'SFMC_Email_Analytics_DE__dlm';
            if (String.isBlank(filterColumn))    filterColumn   = 'emailaddress__c';
            if (String.isBlank(identifierType))  identifierType = 'email';
            if (String.isBlank(orderByColumn))   orderByColumn  = 'sentdate__c';

            return runSingleChannel(recordId, null, null, dloName, filterColumn,
                identifierType, orderByColumn, rowLimit, dateRange);
        } catch (MCEngagementException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'MCDataCloudController.query: '
                + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException(
                'Data Cloud query failed: ' + e.getMessage());
        }
    }

    private static Response runAllChannels(
        Id recordId, Integer rowLimit, String dateRange
    ) {
        Response combined = new Response();
        combined.dloName = 'ALL';
        combined.dateRange = dateRange;

        ContactSelector.RecordKeys keys = ContactSelector.getKeys(recordId);
        if (!hasAnyIdentifier(keys)) {
            return combined;
        }
        combined.identifier = displayIdentifier(keys, 'mixed');
        combined.identifierType = 'mixed';

        for (ChannelDef ch : ALL_CHANNELS) {
            try {
                Response r = runSingleChannel(recordId, keys, ch.channel,
                    ch.dlo, ch.filterCol, ch.identifierType, ch.orderBy,
                    rowLimit, dateRange);
                combined.events.addAll(r.events);
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, 'All-channels: ' + ch.channel
                    + ' failed: ' + e.getMessage());
            }
        }
        combined.events = sortByDateDesc(combined.events);
        combined.total = combined.events.size();
        return combined;
    }

    private static Response runSingleChannel(
        Id recordId, ContactSelector.RecordKeys providedKeys, String channelLabel,
        String dloName, String filterColumn, String identifierType,
        String orderByColumn, Integer rowLimit, String dateRange
    ) {
        Response resp = new Response();
        if (!IDENTIFIER_RE.matcher(dloName).matches()) {
            throw new MCEngagementException('Invalid dloName: ' + dloName);
        }
        if (!IDENTIFIER_RE.matcher(filterColumn).matches()) {
            throw new MCEngagementException('Invalid filterColumn: ' + filterColumn);
        }
        if (String.isNotBlank(orderByColumn)
                && !IDENTIFIER_RE.matcher(orderByColumn).matches()) {
            throw new MCEngagementException('Invalid orderByColumn: ' + orderByColumn);
        }

        ContactSelector.RecordKeys keys = providedKeys == null
            ? ContactSelector.getKeys(recordId)
            : providedKeys;
        List<String> filters = buildIdentityFilters(keys, dloName, filterColumn, identifierType);
        String identifier = displayIdentifier(keys, identifierType);
        if (filters.isEmpty()) {
            resp.identifierType = identifierType;
            resp.dloName = dloName;
            return resp;
        }
        resp.identifier     = identifier;
        resp.identifierType = identifierType;
        resp.dloName        = dloName;
        resp.dateRange      = dateRange;

        String sql = 'SELECT * FROM ' + dloName
            + ' WHERE (' + String.join(filters, ' OR ') + ')';

        // Date range filter
        Integer days = parseDateRangeDays(dateRange);
        if (days != null && String.isNotBlank(orderByColumn)) {
            Datetime cutoff = Datetime.now().addDays(-days);
            sql += ' AND ' + orderByColumn + ' >= \''
                + cutoff.formatGmt('yyyy-MM-dd HH:mm:ss') + '\'';
        }

        if (String.isNotBlank(orderByColumn)) {
            sql += ' ORDER BY ' + orderByColumn + ' DESC';
        }
        sql += ' LIMIT ' + rowLimit;

        String payload;
        if (Test.isRunningTest() && String.isNotBlank(mockResponseJson)) {
            payload = mockResponseJson;
        } else {
            ConnectApi.CdpQueryInput input = new ConnectApi.CdpQueryInput();
            input.sql = sql;
            ConnectApi.CdpQueryOutputV2 out =
                ConnectApi.CdpQuery.queryAnsiSqlV2(input);
            payload = JSON.serialize(out);
        }
        populate(resp, payload, channelLabel);
        resp.events = sortByDateDesc(resp.events);
        resp.total  = resp.events.size();
        return resp;
    }

    /**
     * Return mobile-number formats to match against in Data Cloud. The canonical
     * value is digits-only, but SFMC/Data Cloud may store local, country-coded,
     * plus-prefixed, or contact-key-composite values.
     */
    @TestVisible
    private static Set<String> mobileVariants(String mobile) {
        Set<String> out = new Set<String>();
        if (String.isBlank(mobile)) return out;
        String digits = mobile.replaceAll('[^0-9]', '');
        if (String.isBlank(digits)) return out;

        out.add(mobile);
        out.add(digits);
        out.add('+' + digits);
        out.add('00' + digits);

        if (digits.length() == 12 && digits.startsWith('91')) {
            String local = digits.substring(2);
            out.add(local);
            out.add('0' + local);
            out.add('+91' + local);
            out.add('+91-' + local);
            out.add('+91 ' + local);
            out.add('91-' + local);
            out.add('91 ' + local);
        } else if (digits.length() == 10) {
            out.add(digits);
            out.add('0' + digits);
            out.add('91' + digits);
            out.add('+91' + digits);
            out.add('+91-' + digits);
            out.add('+91 ' + digits);
            out.add('91-' + digits);
            out.add('91 ' + digits);
        }

        if (digits.length() > 10) {
            for (Integer ccLen = 1; ccLen <= 3; ccLen++) {
                if (digits.length() <= ccLen + 5) continue;
                String cc = digits.substring(0, ccLen);
                String local = digits.substring(ccLen);
                out.add('+' + cc + local);
                out.add('+' + cc + '-' + local);
                out.add('+' + cc + ' ' + local);
                out.add(cc + '-' + local);
                out.add(cc + ' ' + local);
                out.add('00' + cc + local);
                if (local.length() == 10) {
                    out.add('+' + cc + '-' + local.substring(0, 3) + '-' +
                        local.substring(3, 6) + '-' + local.substring(6));
                    out.add(cc + '-' + local.substring(0, 3) + '-' +
                        local.substring(3, 6) + '-' + local.substring(6));
                }
            }
        }
        return out;
    }

    private static Boolean hasAnyIdentifier(ContactSelector.RecordKeys keys) {
        return keys != null
            && (String.isNotBlank(keys.applicationId)
                || String.isNotBlank(keys.leadId)
                || String.isNotBlank(keys.email)
                || String.isNotBlank(keys.mobile));
    }

    @TestVisible
    private static List<String> buildIdentityFilters(
        ContactSelector.RecordKeys keys,
        String dloName,
        String filterColumn,
        String identifierType
    ) {
        List<String> filters = new List<String>();
        if (keys == null) return filters;

        if (identifierType == 'mobile') {
            addMobileFilters(filters, filterColumn, keys.mobile);
            addSmsSubscriberFallback(filters, dloName, keys.mobile);
            addWhatsappContactKeyFallback(filters, dloName, keys.mobile);
            return filters;
        }

        String appColumn = applicationIdColumn(dloName);
        if (String.isNotBlank(keys.applicationId) && String.isNotBlank(appColumn)) {
            filters.add(equalsIgnoreCase(appColumn, keys.applicationId));
        }

        String leadColumn = leadIdColumn(dloName);
        if (String.isNotBlank(keys.leadId) && String.isNotBlank(leadColumn)) {
            filters.add(equalsIgnoreCase(leadColumn, keys.leadId));
        }

        addEmailFilters(filters, filterColumn, keys.email);
        if (dloName == 'SFMC_Email_Analytics_DE__dlm') {
            addEmailSubscriberFallback(filters, keys);
        }

        return filters;
    }

    private static void addEmailFilters(List<String> filters, String columnName, String email) {
        if (String.isBlank(email)) return;
        filters.add(equalsIgnoreCase(columnName, email));
    }

    private static void addEmailSubscriberFallback(
        List<String> filters,
        ContactSelector.RecordKeys keys
    ) {
        if (keys == null) return;
        Set<String> exactSubscriberKeys = new Set<String>();
        if (String.isNotBlank(keys.applicationId)) {
            exactSubscriberKeys.add(keys.applicationId);
        }
        if (String.isNotBlank(keys.leadId)) {
            exactSubscriberKeys.add(keys.leadId);
        }
        if (String.isNotBlank(keys.email)) {
            exactSubscriberKeys.add(keys.email);
            filters.add(containsIgnoreCase('subscriberkey__c', keys.email));
        }
        if (!exactSubscriberKeys.isEmpty()) {
            filters.add(inIgnoreCase('subscriberkey__c', exactSubscriberKeys));
        }
    }

    private static void addMobileFilters(List<String> filters, String columnName, String mobile) {
        Set<String> variants = mobileVariants(mobile);
        if (!variants.isEmpty()) {
            filters.add(inIgnoreCase(columnName, variants));
        }
        addMobileLikeFilters(filters, columnName, mobile);
    }

    private static void addSmsSubscriberFallback(
        List<String> filters,
        String dloName,
        String mobile
    ) {
        if (dloName != 'SFMC_SMS_Analytics_DE__dlm') return;
        Set<String> variants = mobileVariants(mobile);
        if (!variants.isEmpty()) {
            filters.add(inIgnoreCase('subscriberkey__c', variants));
            for (String variant : variants) {
                filters.add(containsIgnoreCase('subscriberkey__c', variant));
            }
        }
    }

    private static void addWhatsappContactKeyFallback(
        List<String> filters,
        String dloName,
        String mobile
    ) {
        if (dloName != 'SFMC_Whatsapp_Analytics_DE__dlm') return;
        Set<String> variants = mobileVariants(mobile);
        if (!variants.isEmpty()) {
            filters.add(inIgnoreCase('contactkey__c', variants));
            for (String variant : variants) {
                filters.add(containsIgnoreCase('contactkey__c', variant));
            }
        }
    }

    private static void addMobileLikeFilters(
        List<String> filters,
        String columnName,
        String mobile
    ) {
        String fullPattern = phoneLikePattern(mobile, false);
        if (String.isNotBlank(fullPattern)) {
            filters.add('LOWER(' + columnName + ') LIKE \'' + sqlLiteral(fullPattern.toLowerCase()) + '\'');
        }
        String localPattern = phoneLikePattern(mobile, true);
        if (String.isNotBlank(localPattern) && localPattern != fullPattern) {
            filters.add('LOWER(' + columnName + ') LIKE \'' + sqlLiteral(localPattern.toLowerCase()) + '\'');
        }
    }

    private static String phoneLikePattern(String mobile, Boolean useLocalTenDigits) {
        String digits = String.isBlank(mobile) ? '' : mobile.replaceAll('[^0-9]', '');
        if (useLocalTenDigits && digits.length() > 10) {
            digits = digits.substring(digits.length() - 10);
        }
        if (digits.length() < 7) {
            return null;
        }
        String pattern = '%';
        for (Integer i = 0; i < digits.length(); i++) {
            pattern += digits.substring(i, i + 1) + '%';
        }
        return pattern;
    }

    private static String applicationIdColumn(String dloName) {
        if (dloName == 'SFMC_Email_Analytics_DE__dlm'
                || dloName == 'SFMC_SMS_Analytics_DE__dlm') {
            return 'ApplicationId__c';
        }
        if (dloName == 'SFMC_Whatsapp_Analytics_DE__dlm') {
            return 'applicationid__c';
        }
        return null;
    }

    private static String leadIdColumn(String dloName) {
        if (dloName == 'SFMC_Email_Analytics_DE__dlm'
                || dloName == 'SFMC_SMS_Analytics_DE__dlm') {
            return 'LeadId__c';
        }
        if (dloName == 'SFMC_Whatsapp_Analytics_DE__dlm') {
            return 'leadid__c';
        }
        return null;
    }

    private static String displayIdentifier(
        ContactSelector.RecordKeys keys,
        String identifierType
    ) {
        if (keys == null) return null;
        if (identifierType == 'mobile' && String.isNotBlank(keys.mobile)) {
            return keys.mobile;
        }
        if (String.isNotBlank(keys.email)) return keys.email;
        if (String.isNotBlank(keys.mobile)) return keys.mobile;
        if (String.isNotBlank(keys.applicationId)) return keys.applicationId;
        if (String.isNotBlank(keys.leadId)) return keys.leadId;
        return keys.recordId;
    }

    private static String equalsIgnoreCase(String columnName, String value) {
        return 'LOWER(' + columnName + ') = \'' + sqlLiteral(value.toLowerCase()) + '\'';
    }

    private static String inIgnoreCase(String columnName, Set<String> values) {
        List<String> quoted = new List<String>();
        for (String value : values) {
            if (String.isNotBlank(value)) {
                quoted.add('\'' + sqlLiteral(value.toLowerCase()) + '\'');
            }
        }
        return 'LOWER(' + columnName + ') IN (' + String.join(quoted, ',') + ')';
    }

    private static String containsIgnoreCase(String columnName, String value) {
        return 'LOWER(' + columnName + ') LIKE \'%' + sqlLiteral(value.toLowerCase()) + '%\'';
    }

    private static String sqlLiteral(String value) {
        return String.escapeSingleQuotes(value == null ? '' : value);
    }

    private static Integer parseDateRangeDays(String r) {
        if (String.isBlank(r)) return null;
        if (r == 'all' || r == 'All') return null;
        if (r == '7d')   return 7;
        if (r == '30d')  return 30;
        if (r == '90d')  return 90;
        if (r == '180d') return 180;
        if (r == '365d') return 365;
        // numeric prefix support: "14d" → 14
        if (r.endsWith('d')) {
            try { return Integer.valueOf(r.substring(0, r.length() - 1)); }
            catch (Exception e) { return null; }
        }
        return null;
    }

    @TestVisible
    private static void populate(Response resp, String payload, String channelLabel) {
        if (String.isBlank(payload)) return;
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(payload);
        Object metaObj = root.get('metadata');
        List<Object> data = (List<Object>) root.get('data');

        Map<Integer, String> nameByIdx = new Map<Integer, String>();
        if (metaObj instanceof Map<String, Object>) {
            Map<String, Object> metaMap = (Map<String, Object>) metaObj;
            for (String name : metaMap.keySet()) {
                Map<String, Object> col = (Map<String, Object>) metaMap.get(name);
                Integer place = toIntSafe(col.get('placeInOrder'));
                if (place == null) place = nameByIdx.size();
                nameByIdx.put(place, name);
                resp.columns.add(new Column(name, String.valueOf(col.get('type'))));
            }
        } else if (metaObj instanceof List<Object>) {
            List<Object> metaList = (List<Object>) metaObj;
            for (Integer i = 0; i < metaList.size(); i++) {
                Map<String, Object> col = (Map<String, Object>) metaList[i];
                String name = (String) col.get('name');
                nameByIdx.put(i, name);
                resp.columns.add(new Column(name, String.valueOf(col.get('type'))));
            }
        }

        if (data == null) return;

        for (Object rowObj : data) {
            List<Object> cells = (List<Object>) rowObj;
            Map<String, Object> rowMap = new Map<String, Object>();
            for (Integer i = 0; i < cells.size(); i++) {
                String n = nameByIdx.get(i);
                if (n != null) rowMap.put(n, cells[i]);
            }
            resp.rows.add(rowMap);

            Integer before = resp.events.size();
            addEventIfDate(resp.events, rowMap, channelLabel, 'Sent',        SENT_DATE_COLS);
            addEventIfDate(resp.events, rowMap, channelLabel, 'Delivered',   DELIVERED_DATE_COLS);
            addEventIfDate(resp.events, rowMap, channelLabel, 'Open',        OPEN_DATE_COLS);
            addEventIfDate(resp.events, rowMap, channelLabel, 'Click',       CLICK_DATE_COLS);
            addEventIfDate(resp.events, rowMap, channelLabel, 'Bounce',      BOUNCE_DATE_COLS);
            addEventIfDate(resp.events, rowMap, channelLabel, 'Failed',      FAILED_DATE_COLS);
            addEventIfDate(resp.events, rowMap, channelLabel, 'Unsubscribe', UNSUB_DATE_COLS);

            if (resp.events.size() == before) {
                EngagementRow er = buildSingleEvent(rowMap, channelLabel);
                if (er != null) resp.events.add(er);
            }
        }
    }

    private static void addEventIfDate(List<EngagementRow> events,
            Map<String, Object> rowMap, String channelLabel,
            String type, List<String> dateCols) {
        Datetime evt = parseDt(getOne(rowMap, dateCols));
        if (evt == null) return;
        EngagementRow er = baseRow(rowMap, channelLabel);
        er.eventType = type;
        er.eventDate = evt;
        events.add(er);
    }

    private static EngagementRow buildSingleEvent(
            Map<String, Object> rowMap, String channelLabel) {
        EngagementRow er = baseRow(rowMap, channelLabel);
        er.eventType = stringOf(getOne(rowMap, new List<String>{
            'eventtype__c', 'EventType__c', 'EventType',
            'status__c', 'Status__c',
            'deliverystatus__c', 'DeliveryStatus__c',
            'messagestatus__c', 'MessageStatus__c'}));
        er.eventDate = parseDt(getOne(rowMap, new List<String>{
            'eventdate__c', 'EventDate__c', 'EventDate',
            'eventdatetime__c', 'eventdateutc__c', 'EventDateUtc__c',
            'actiondatetime__c', 'ActionDateTime__c',
            'lasteventdateutc__c', 'LastEventDateUTC__c',
            'createddate', 'CreatedDate', 'lastupdateddate__c'}));
        if (er.eventType == null && er.eventDate == null) return null;
        return er;
    }

    private static EngagementRow baseRow(
            Map<String, Object> rowMap, String channelLabel) {
        EngagementRow er = new EngagementRow();
        er.channel = channelLabel;
        er.mobileNumber = stringOf(getOne(rowMap, new List<String>{
            'mobilenumber__c', 'MobileNumber__c', 'MobileNumber'}));
        er.channelId = stringOf(getOne(rowMap, new List<String>{
            'channelid__c', 'ChannelID__c', 'ChannelId__c'}));
        er.channelName = stringOf(getOne(rowMap, new List<String>{
            'channelname__c', 'ChannelName__c'}));
        er.sendType = stringOf(getOne(rowMap, new List<String>{
            'sendtype__c', 'SendType__c'}));
        er.recipient   = stringOf(getOne(rowMap, new List<String>{
            'emailaddress__c', 'EmailAddress__c', 'EmailAddress',
            'mobilenumber__c', 'MobileNumber__c', 'MobileNumber',
            'mobile__c', 'Mobile__c',
            'phone__c', 'Phone__c', 'email__c', 'Email__c',
            'contactkey__c', 'ContactKey__c'}));
        er.messageName = stringOf(getOne(rowMap, new List<String>{
            'activityname__c', 'ActivityName__c',
            'messagename__c', 'MessageName__c',
            'emailname__c', 'EmailName__c', 'EmailName',
            'campaignname__c', 'CampaignName__c',
            'templatename__c', 'TemplateName__c'}));
        er.subjectLine = stringOf(getOne(rowMap, new List<String>{
            'subjectline__c', 'SubjectLine__c',
            'subject__c', 'Subject__c', 'Subject',
            'messagecontent__c', 'MessageContent__c',
            'messagetext__c', 'MessageText__c',
            'description__c', 'Description__c'}));
        er.journeyName = stringOf(getOne(rowMap, new List<String>{
            'journeyname__c', 'JourneyName__c', 'journey__c', 'Journey__c'}));
        er.bounceReason = stringOf(getOne(rowMap, new List<String>{
            'bouncereason__c', 'BounceReason__c',
            'reason__c', 'Reason__c',
            'bouncecategory__c', 'BounceCategory__c',
            'failurereason__c', 'FailureReason__c'}));
        er.smtpBounceReason = stringOf(getOne(rowMap, new List<String>{
            'SMTPBounceReason__c', 'smtpbouncereason__c', 'SmtpBounceReason__c'}));
        return er;
    }

    private static Object getOne(Map<String, Object> row, List<String> candidates) {
        if (row == null) return null;
        for (String c : candidates) {
            if (row.containsKey(c) && row.get(c) != null) return row.get(c);
        }
        return null;
    }

    private static String stringOf(Object v) {
        if (v == null) return null;
        String s = String.valueOf(v);
        return String.isBlank(s) ? null : s;
    }

    private static Integer toIntSafe(Object v) {
        if (v == null) return null;
        if (v instanceof Integer) return (Integer) v;
        if (v instanceof Decimal) return ((Decimal) v).intValue();
        try { return Integer.valueOf(String.valueOf(v)); } catch (Exception e) { return null; }
    }

    /**
     * Parse a Data Cloud date value into a Datetime, locale-independently.
     * SFMC DLOs are inconsistent: Email/SMS store ISO ("2026-04-24 05:09:36.670
     * UTC"), while WhatsApp stores US-style strings ("5/29/2026 2:32:56 PM").
     * The previous implementation only handled ISO and fell back to
     * Datetime.parse(), which THROWS for the US format in non-US locales (e.g.
     * en_IN) — so every WhatsApp date silently became null. All shapes are
     * treated as UTC because the source columns are *DateUtc fields.
     */
    @TestVisible
    private static Datetime parseDt(Object v) {
        if (v == null) return null;
        String s = String.valueOf(v).trim();
        if (s.length() == 0) return null;

        // Strip common SFMC / Data Cloud zone suffixes (values are UTC).
        if (s.endsWithIgnoreCase(' UTC')) s = s.substring(0, s.length() - 4).trim();
        if (s.endsWithIgnoreCase('Z'))    s = s.substring(0, s.length() - 1).trim();

        // ISO style: yyyy-MM-dd[ T]HH:mm:ss[.SSS]  (Email/SMS DLOs)
        if (s.length() >= 10 && s.substring(0, 4).isNumeric()
                && s.substring(4, 5) == '-') {
            String iso = s.contains('T') ? s.replace('T', ' ') : s;
            if (iso.contains('.')) iso = iso.substring(0, iso.indexOf('.'));
            if (!iso.contains(' ')) iso += ' 00:00:00';
            try { return Datetime.valueOfGmt(iso); } catch (Exception e) {}
        }

        // US style: M/d/yyyy[ h:mm[:ss] AM/PM]  (WhatsApp DLO). Parsed without
        // relying on the running user's locale.
        Datetime us = parseUsDateTime(s);
        if (us != null) return us;

        // Last resort: let the platform try, for any other shape.
        try { return Datetime.valueOfGmt(s); } catch (Exception e) {}
        try { return Datetime.parse(s); } catch (Exception e) {}
        return null;
    }

    /**
     * Parse "M/d/yyyy", "M/d/yyyy h:mm:ss a", or "M/d/yyyy HH:mm:ss" as UTC,
     * locale-independently. Returns null if the value is not a slash-style date
     * or any component is out of range.
     */
    @TestVisible
    private static Datetime parseUsDateTime(String value) {
        if (String.isBlank(value) || !value.contains('/')) return null;
        try {
            String datePart = value;
            String timePart = '';
            Integer sp = value.indexOf(' ');
            if (sp > 0) {
                datePart = value.substring(0, sp);
                timePart = value.substring(sp + 1).trim();
            }
            List<String> dmy = datePart.split('/');
            if (dmy.size() != 3) return null;
            Integer month = Integer.valueOf(dmy[0].trim());
            Integer day   = Integer.valueOf(dmy[1].trim());
            Integer year  = Integer.valueOf(dmy[2].trim());
            if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900) {
                return null;
            }

            Integer hh = 0, mm = 0, ss = 0;
            if (String.isNotBlank(timePart)) {
                String tp = timePart.toUpperCase();
                String ampm = '';
                if (tp.endsWith('AM') || tp.endsWith('PM')) {
                    ampm = tp.substring(tp.length() - 2);
                    tp = tp.substring(0, tp.length() - 2).trim();
                }
                List<String> hms = tp.split(':');
                if (hms.size() >= 1 && String.isNotBlank(hms[0])) hh = Integer.valueOf(hms[0].trim());
                if (hms.size() >= 2 && String.isNotBlank(hms[1])) mm = Integer.valueOf(hms[1].trim());
                if (hms.size() >= 3 && String.isNotBlank(hms[2])) ss = Integer.valueOf(hms[2].trim());
                if (ampm == 'PM' && hh < 12) hh += 12;
                if (ampm == 'AM' && hh == 12) hh = 0;
            }
            if (hh < 0 || hh > 23 || mm < 0 || mm > 59 || ss < 0 || ss > 59) {
                return null;
            }
            return Datetime.newInstanceGmt(year, month, day, hh, mm, ss);
        } catch (Exception e) {
            return null;
        }
    }

    private class DescByDate implements Comparable {
        public EngagementRow r;
        public DescByDate(EngagementRow r) { this.r = r; }
        public Integer compareTo(Object other) {
            EngagementRow o = ((DescByDate) other).r;
            if (r.eventDate == null && o.eventDate == null) return 0;
            if (r.eventDate == null) return 1;
            if (o.eventDate == null) return -1;
            if (r.eventDate > o.eventDate) return -1;
            if (r.eventDate < o.eventDate) return 1;
            return 0;
        }
    }

    private static List<EngagementRow> sortByDateDesc(List<EngagementRow> events) {
        List<DescByDate> wrapped = new List<DescByDate>();
        for (EngagementRow er : events) wrapped.add(new DescByDate(er));
        wrapped.sort();
        List<EngagementRow> out = new List<EngagementRow>();
        for (DescByDate w : wrapped) out.add(w.r);
        return out;
    }
}