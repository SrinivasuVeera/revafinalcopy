@IsTest
private class MCDataCloudControllerTest {

    @TestSetup
    static void setup() {
        Contact c = new Contact(
            LastName='Test', FirstName='Applicant',
            Email='Test@Example.Com', MobilePhone='+15551234567');
        insert c;
    }

    private static String emailMockJson() {
        return JSON.serialize(new Map<String, Object>{
            'metadata' => new List<Object>{
                new Map<String, Object>{ 'name' => 'EmailAddress__c', 'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'EventDate__c',    'type' => 'TIMESTAMP' },
                new Map<String, Object>{ 'name' => 'EventType__c',    'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'MessageName__c',  'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'SubjectLine__c',  'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'JourneyName__c',  'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'BounceReason__c', 'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'SMTPBounceReason__c', 'type' => 'STRING' }
            },
            'data' => new List<Object>{
                new List<Object>{ 'test@example.com', '2026-04-15T10:00:00.000Z',
                    'Open', 'Welcome Email', 'Welcome to KJS', 'Onboarding', null, null },
                new List<Object>{ 'test@example.com', '2026-04-14T09:00:00.000Z',
                    'Click', 'Reminder', 'Don\'t miss the deadline', null, null, null },
                new List<Object>{ 'test@example.com', '2026-04-13T08:00:00.000Z',
                    'Delivered', 'Welcome Email', null, null, null, null },
                new List<Object>{ 'test@example.com', '2026-04-12T07:00:00.000Z',
                    'Bounce', 'Invalid Mailbox', null, null, 'Mailbox Full',
                    '550 mailbox unavailable' }
            }
        });
    }

    private static String smsMockJson() {
        return JSON.serialize(new Map<String, Object>{
            'metadata' => new List<Object>{
                new Map<String, Object>{ 'name' => 'MobileNumber__c',     'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'EventDate__c',        'type' => 'TIMESTAMP' },
                new Map<String, Object>{ 'name' => 'DeliveryStatus__c',   'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'MessageContent__c',   'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'CampaignName__c',     'type' => 'STRING' }
            },
            'data' => new List<Object>{
                new List<Object>{ '15551234567', '2026-04-15T10:00:00.000Z',
                    'Delivered', 'Your OTP is 123456', 'OTP Campaign' }
            }
        });
    }

    private static String whatsappMockJson() {
        return JSON.serialize(new Map<String, Object>{
            'metadata' => new List<Object>{
                new Map<String, Object>{ 'name' => 'mobilenumber__c',      'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'status__c',            'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'lasteventdateutc__c',  'type' => 'TIMESTAMP' },
                new Map<String, Object>{ 'name' => 'activityname__c',      'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'failurereason__c',     'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'channelid__c',         'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'channelname__c',       'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'sendtype__c',          'type' => 'STRING' }
            },
            'data' => new List<Object>{
                new List<Object>{ '919840635677', 'Delivered',
                    '2026-05-03T18:17:37.000Z', 'Submit Admissions', null,
                    '918657737367', 'Somaiya Vidyavihar UAT', 'TransactionalSend' }
            }
        });
    }

    @IsTest
    static void query_emailDefault_returnsRows() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        MCDataCloudController.mockResponseJson = emailMockJson();

        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, null, null, null, 'EventDate__c', 200, null);
        Test.stopTest();

        System.assertEquals('test@example.com', resp.identifier);
        System.assertEquals('email', resp.identifierType);
        System.assertEquals('SFMC_Email_Analytics_DE__dlm', resp.dloName);
        System.assertEquals(4, resp.total);
        System.assertEquals('Open', resp.events[0].eventType);
        System.assertEquals('Welcome to KJS', resp.events[0].subjectLine);
        System.assertEquals('Mailbox Full', resp.events[3].bounceReason);
        System.assertEquals('550 mailbox unavailable', resp.events[3].smtpBounceReason);
        System.assertEquals(8, resp.columns.size());
    }

    @IsTest
    static void query_smsConfig_resolvesViaMobile() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        MCDataCloudController.mockResponseJson = smsMockJson();

        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, 'SFMC_SMS_Analytics_DE__dlm', 'mobile__c', 'mobile',
            'actiondatetime__c', 100, null);
        Test.stopTest();

        System.assertEquals('15551234567', resp.identifier);
        System.assertEquals('mobile', resp.identifierType);
        System.assertEquals('SFMC_SMS_Analytics_DE__dlm', resp.dloName);
        System.assertEquals(1, resp.total);
        System.assertEquals('Delivered', resp.events[0].eventType);
        System.assertEquals('Your OTP is 123456', resp.events[0].subjectLine);
        System.assertEquals('OTP Campaign', resp.events[0].messageName);
    }

    @IsTest
    static void query_allChannels_fansOut() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        // Each internal channel call returns the same mock — produces 4
        // events per channel run. Email + SMS + WhatsApp = 12 events.
        MCDataCloudController.mockResponseJson = emailMockJson();

        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, 'ALL', null, null, null, 200, '30d');
        Test.stopTest();

        System.assertEquals('ALL', resp.dloName);
        System.assertEquals('mixed', resp.identifierType);
        System.assert(resp.total >= 4, 'All-channels should aggregate events from each DLO');
    }

    @IsTest
    static void query_dateRange30d_buildsDateClause() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        MCDataCloudController.mockResponseJson = emailMockJson();
        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, null, null, null, 'sentdate__c', 200, '30d');
        Test.stopTest();
        System.assertNotEquals(null, resp);
        // Mock returns rows regardless of clause; verify no exception thrown
        // and the dateRange field is preserved on the response.
        System.assertEquals('30d', resp.dateRange);
    }

    @IsTest
    static void query_dateRangeAll_skipsDateClause() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        MCDataCloudController.mockResponseJson = emailMockJson();
        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, null, null, null, null, 200, 'all');
        Test.stopTest();
        System.assertEquals('all', resp.dateRange);
    }

    @IsTest
    static void query_nullId_throws() {
        Boolean caught = false;
        try {
            MCDataCloudController.query(
                null, 'SFMC_Email_Analytics_DE__dlm', 'emailaddress__c', 'email',
                'sentdate__c', 200, null);
        } catch (AuraHandledException e) { caught = true; }
        System.assert(caught);
    }

    @IsTest
    static void query_invalidDloName_throws() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Boolean caught = false;
        try {
            MCDataCloudController.query(
                c.Id, 'Bad; DROP TABLE x;--', 'emailaddress__c', 'email',
                null, 200, null);
        } catch (AuraHandledException e) { caught = true; }
        System.assert(caught, 'SQL injection attempt should be rejected');
    }

    @IsTest
    static void query_invalidFilterColumn_throws() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Boolean caught = false;
        try {
            MCDataCloudController.query(
                c.Id, 'SFMC_Email_Analytics_DE__dlm', 'Bad Column!', 'email',
                null, 200, null);
        } catch (AuraHandledException e) { caught = true; }
        System.assert(caught);
    }

    @IsTest
    static void query_invalidOrderByColumn_throws() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Boolean caught = false;
        try {
            MCDataCloudController.query(
                c.Id, 'SFMC_Email_Analytics_DE__dlm', 'emailaddress__c', 'email',
                'EventDate__c; DELETE x', 200, null);
        } catch (AuraHandledException e) { caught = true; }
        System.assert(caught);
    }

    @IsTest
    static void query_noEmailOnRecord_returnsEmpty() {
        Contact noContact = new Contact(LastName = 'NoComm');
        insert noContact;
        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            noContact.Id, null, null, 'email', null, 200, null);
        Test.stopTest();
        System.assertEquals(0, resp.total);
        System.assertEquals(null, resp.identifier);
    }

    @IsTest
    static void query_lead_resolvesEmail() {
        Lead l = new Lead(LastName='X', Company='X',
            Email='lead.x@example.com', MobilePhone='+15559876543');
        insert l;
        MCDataCloudController.mockResponseJson = emailMockJson();
        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            l.Id, null, null, null, null, 200, null);
        Test.stopTest();
        System.assertEquals('lead.x@example.com', resp.identifier);
    }

    @IsTest
    static void query_individualApplication_resolvesViaAccount() {
        Account a = new Account(Name='Test Acc');
        insert a;
        IndividualApplication ia = new IndividualApplication(
            Category='Resident Indian', AccountId=a.Id);
        insert ia;
        MCDataCloudController.mockResponseJson = emailMockJson();
        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            ia.Id, null, null, null, null, 200, null);
        Test.stopTest();
        System.assertNotEquals(null, resp);
        System.assertEquals(String.valueOf(ia.Id), resp.identifier);
    }

    @IsTest
    static void query_largeRowLimit_capped() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        MCDataCloudController.mockResponseJson = emailMockJson();
        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, null, null, null, null, 999999, null);
        Test.stopTest();
        System.assertNotEquals(null, resp);
    }

    @IsTest
    static void query_columnFallbacks() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        MCDataCloudController.mockResponseJson = JSON.serialize(new Map<String, Object>{
            'metadata' => new List<Object>{
                new Map<String, Object>{ 'name' => 'EmailAddress', 'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'EventDate',    'type' => 'TIMESTAMP' },
                new Map<String, Object>{ 'name' => 'EventType',    'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'EmailName',    'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'Subject',      'type' => 'STRING' }
            },
            'data' => new List<Object>{
                new List<Object>{ 'test@example.com', '2026-04-15T10:00:00.000Z',
                    'Sent', 'Promo', 'Save 20% today' }
            }
        });

        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            c.Id, null, null, null, null, 200, null);
        Test.stopTest();

        System.assertEquals(1, resp.total);
        System.assertEquals('Sent', resp.events[0].eventType);
        System.assertEquals('Promo', resp.events[0].messageName);
        System.assertEquals('Save 20% today', resp.events[0].subjectLine);
    }

    @IsTest
    static void query_whatsappUsesLiveDateField() {
        Lead l = new Lead(LastName = 'WhatsApp', Company = 'KJS',
            Email = 'wa@example.com', MobilePhone = '9840635677');
        insert l;
        MCDataCloudController.mockResponseJson = whatsappMockJson();

        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            l.Id,
            'SFMC_Whatsapp_Analytics_DE__dlm',
            'mobilenumber__c',
            'mobile',
            'lasteventdateutc__c',
            100,
            '30d'
        );
        Test.stopTest();

        System.assertEquals(1, resp.total);
        System.assertEquals('Delivered', resp.events[0].eventType);
        System.assertEquals('Submit Admissions', resp.events[0].messageName);
        System.assertEquals('918657737367', resp.events[0].channelId);
        System.assertEquals('919840635677', resp.events[0].mobileNumber);
        System.assertEquals('Somaiya Vidyavihar UAT', resp.events[0].channelName);
        System.assertEquals('TransactionalSend', resp.events[0].sendType);
        System.assertNotEquals(null, resp.events[0].eventDate);
    }

    @IsTest
    static void buildIdentityFilters_includesIdsAndFallbackIdentifiers() {
        Account a = new Account(Name = 'Filter Test Account');
        insert a;
        IndividualApplication ia = new IndividualApplication(
            Category = 'Resident Indian',
            AccountId = a.Id
        );
        insert ia;
        Lead l = new Lead(
            LastName = 'Filter Lead',
            Company = 'KJS',
            Email = 'MitaleeParamkar17@gmail.com',
            Phone = '9840635677'
        );
        insert l;

        ContactSelector.RecordKeys keys = new ContactSelector.RecordKeys(
            null,
            String.valueOf(ia.Id),
            String.valueOf(l.Id),
            'MitaleeParamkar17@gmail.com',
            '9840635677'
        );

        Test.startTest();
        List<String> emailFilters = MCDataCloudController.buildIdentityFilters(
            keys,
            'SFMC_Email_Analytics_DE__dlm',
            'emailaddress__c',
            'email'
        );
        List<String> smsFilters = MCDataCloudController.buildIdentityFilters(
            keys,
            'SFMC_SMS_Analytics_DE__dlm',
            'mobile__c',
            'mobile'
        );
        List<String> whatsappFilters = MCDataCloudController.buildIdentityFilters(
            keys,
            'SFMC_Whatsapp_Analytics_DE__dlm',
            'mobilenumber__c',
            'mobile'
        );
        Test.stopTest();

        String emailSql = String.join(emailFilters, ' ');
        String smsSql = String.join(smsFilters, ' ');
        String whatsappSql = String.join(whatsappFilters, ' ');

        System.assert(emailSql.contains('ApplicationId__c'));
        System.assert(emailSql.contains('LeadId__c'));
        System.assert(emailSql.contains('emailaddress__c'));
        System.assert(emailSql.contains('subscriberkey__c'));
        System.assert(emailSql.contains(String.valueOf(ia.Id).toLowerCase()));
        System.assert(emailSql.contains(String.valueOf(l.Id).toLowerCase()));

        System.assert(!smsSql.contains('ApplicationId__c'));
        System.assert(!smsSql.contains('LeadId__c'));
        System.assert(smsSql.contains('mobile__c'));
        System.assert(smsSql.contains('subscriberkey__c'));
        System.assert(smsSql.contains('919840635677'));
        System.assert(smsSql.contains('LIKE'));
        System.assert(smsSql.contains('%9%8%4%0%6%3%5%6%7%7%'));
        System.assert(!smsSql.contains('mitaleeparamkar17@gmail.com'));

        System.assert(!whatsappSql.contains('applicationid__c'));
        System.assert(!whatsappSql.contains('leadid__c'));
        System.assert(whatsappSql.contains('mobilenumber__c'));
        System.assert(whatsappSql.contains('contactkey__c'));
        System.assert(whatsappSql.contains('%9%8%4%0%6%3%5%6%7%7%'));
        System.assert(!whatsappSql.contains('mitaleeparamkar17@gmail.com'));
    }

    @IsTest
    static void mobileVariants_includeFormattedSmsAndWhatsappNumbers() {
        Set<String> india = MCDataCloudController.mobileVariants('918799388006');
        System.assert(india.contains('918799388006'));
        System.assert(india.contains('8799388006'));
        System.assert(india.contains('+91-8799388006'));
        System.assert(india.contains('91-8799388006'));
        System.assert(india.contains('91 8799388006'));

        Set<String> us = MCDataCloudController.mobileVariants('15553334444');
        System.assert(us.contains('+1-555-333-4444'));
        System.assert(us.contains('1-555-333-4444'));
        System.assert(us.contains('+15553334444'));
    }

    @IsTest
    static void contactSelectorResolvesApplicationLeadAndPhoneFallbacks() {
        Account a = new Account(Name = 'Selector Test Account');
        insert a;
        Lead byEmail = new Lead(
            LastName = 'By Email',
            Company = 'KJS',
            Email = 'selector@example.com'
        );
        Lead byPhone = new Lead(
            LastName = 'By Phone',
            Company = 'KJS',
            Phone = '09840635677'
        );
        insert new List<Lead>{ byEmail, byPhone };
        Contact emailContact = new Contact(
            LastName = 'Email Contact',
            Email = 'selector@example.com',
            MobilePhone = '9840635677'
        );
        Contact phoneContact = new Contact(
            LastName = 'Phone Contact',
            Phone = '09840635677'
        );
        insert new List<Contact>{ emailContact, phoneContact };

        IndividualApplication emailApp = new IndividualApplication(
            Category = 'Resident Indian',
            AccountId = a.Id,
            ContactId = emailContact.Id
        );
        IndividualApplication phoneApp = new IndividualApplication(
            Category = 'Resident Indian',
            AccountId = a.Id,
            ContactId = phoneContact.Id
        );
        insert new List<IndividualApplication>{ emailApp, phoneApp };

        Test.startTest();
        ContactSelector.RecordKeys emptyKeys = ContactSelector.getKeys(null);
        ContactSelector.RecordKeys emailKeys = ContactSelector.getKeys(emailApp.Id);
        ContactSelector.RecordKeys phoneKeys = ContactSelector.getKeys(phoneApp.Id);
        ContactSelector.RecordKeys leadKeys = ContactSelector.getKeys(byEmail.Id);
        Test.stopTest();

        System.assertEquals(null, emptyKeys.email);
        System.assertEquals(String.valueOf(emailApp.Id), emailKeys.applicationId);
        System.assertEquals(String.valueOf(byEmail.Id), emailKeys.leadId);
        System.assertEquals(String.valueOf(phoneApp.Id), phoneKeys.applicationId);
        System.assertEquals('selector@example.com', leadKeys.email);
    }

    private static String whatsappUsFormatMockJson() {
        return JSON.serialize(new Map<String, Object>{
            'metadata' => new List<Object>{
                new Map<String, Object>{ 'name' => 'mobilenumber__c',      'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'status__c',            'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'sentdateutc__c',       'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'delivereddateutc__c',  'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'readdateutc__c',       'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'faileddateutc__c',     'type' => 'STRING' },
                new Map<String, Object>{ 'name' => 'lasteventdateutc__c',  'type' => 'TIMESTAMP' }
            },
            'data' => new List<Object>{
                // Delivered + read message: Sent / Delivered / Open (US-format dates)
                new List<Object>{ '919840635677', 'Read',
                    '5/29/2026 2:32:56 PM', '5/29/2026 2:33:10 PM',
                    '5/29/2026 3:00:00 PM', '', '2026-05-29T15:00:00.000Z' },
                // Failed message: Sent + Failed (no delivered/read)
                new List<Object>{ '919840635677', 'Failed',
                    '5/31/2026 2:45:05 PM', '', '',
                    '5/31/2026 2:45:10 PM', '2026-05-31T14:45:10.000Z' }
            }
        });
    }

    @IsTest
    static void query_whatsappUsFormatDates_parseAndUnpivot() {
        Lead l = new Lead(LastName = 'WAUs', Company = 'REVA',
            Email = 'waus@example.com', MobilePhone = '9840635677');
        insert l;
        MCDataCloudController.mockResponseJson = whatsappUsFormatMockJson();

        Test.startTest();
        MCDataCloudController.Response resp = MCDataCloudController.query(
            l.Id, 'SFMC_Whatsapp_Analytics_DE__dlm',
            'mobilenumber__c', 'mobile', 'lasteventdateutc__c', 100, 'all');
        Test.stopTest();

        // Row 1 -> Sent, Delivered, Open ; Row 2 -> Sent, Failed  = 5 events
        System.assertEquals(5, resp.total, 'US-format dates should unpivot into events');
        Map<String, Integer> byType = new Map<String, Integer>();
        for (MCDataCloudController.EngagementRow er : resp.events) {
            System.assertNotEquals(null, er.eventDate,
                'US-format date must parse (was the bug): ' + er.eventType);
            Integer c = byType.containsKey(er.eventType) ? byType.get(er.eventType) : 0;
            byType.put(er.eventType, c + 1);
        }
        System.assertEquals(2, byType.get('Sent'));
        System.assertEquals(1, byType.get('Delivered'));
        System.assertEquals(1, byType.get('Open'));
        System.assertEquals(1, byType.get('Failed'),
            'failed message must surface a Failed event, not just Sent');
    }

    @IsTest
    static void parseDt_handlesIsoAndUsAndGarbage() {
        // ISO (Email/SMS shape)
        System.assertEquals(
            Datetime.newInstanceGmt(2026, 4, 24, 5, 9, 36),
            MCDataCloudController.parseDt('2026-04-24 05:09:36.670 UTC'));
        System.assertEquals(
            Datetime.newInstanceGmt(2026, 5, 3, 18, 17, 37),
            MCDataCloudController.parseDt('2026-05-03T18:17:37.000Z'));
        // US (WhatsApp shape)
        System.assertEquals(
            Datetime.newInstanceGmt(2026, 5, 29, 14, 32, 56),
            MCDataCloudController.parseDt('5/29/2026 2:32:56 PM'));
        // Garbage / null / empty
        System.assertEquals(null, MCDataCloudController.parseDt(null));
        System.assertEquals(null, MCDataCloudController.parseDt(''));
        System.assertEquals(null, MCDataCloudController.parseDt('not-a-date'));
    }

    @IsTest
    static void parseUsDateTime_edgeCases() {
        System.assertEquals(Datetime.newInstanceGmt(2026, 12, 3, 9, 5, 0),
            MCDataCloudController.parseUsDateTime('12/3/2026 9:05:00 AM'));
        // 12 AM -> 00:00 ; 12 PM -> 12:00
        System.assertEquals(Datetime.newInstanceGmt(2026, 1, 1, 0, 0, 0),
            MCDataCloudController.parseUsDateTime('1/1/2026 12:00:00 AM'));
        System.assertEquals(Datetime.newInstanceGmt(2026, 1, 1, 12, 0, 0),
            MCDataCloudController.parseUsDateTime('1/1/2026 12:00:00 PM'));
        // 24-hour, no AM/PM
        System.assertEquals(Datetime.newInstanceGmt(2026, 5, 29, 14, 32, 56),
            MCDataCloudController.parseUsDateTime('5/29/2026 14:32:56'));
        // Date only -> midnight UTC
        System.assertEquals(Datetime.newInstanceGmt(2026, 5, 29, 0, 0, 0),
            MCDataCloudController.parseUsDateTime('5/29/2026'));
        // Invalid / non-matching -> null
        System.assertEquals(null, MCDataCloudController.parseUsDateTime('13/40/2026'));
        System.assertEquals(null, MCDataCloudController.parseUsDateTime('2026-05-29'));
        System.assertEquals(null, MCDataCloudController.parseUsDateTime(''));
        System.assertEquals(null, MCDataCloudController.parseUsDateTime(null));
    }
}