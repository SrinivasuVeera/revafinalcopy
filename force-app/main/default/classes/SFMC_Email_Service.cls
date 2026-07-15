public class SFMC_Email_Service implements Queueable, Database.AllowsCallouts {
    
    private Integer page;
    private Set<String> foundJourneys; 
    @TestVisible private static List<String> testJourneys; 
    
    public SFMC_Email_Service() {
        this.page = 1;
        this.foundJourneys = new Set<String>();
    }

    public SFMC_Email_Service(Integer nextPage, Set<String> existingJourneys) {
        this.page = nextPage;
        this.foundJourneys = existingJourneys;
    }

    public void execute(QueueableContext context) {
        String token = SFMC_Auth_Service.getAccessToken();
        if(String.isBlank(token)) return;

        SFMC_Config__c config = SFMC_Config__c.getOrgDefaults();
        Datetime lastSyncTime = (config != null) ? config.Last_Sync_Time__c : null;

        Set<String> allowedJourneys = new Set<String>();
        if(Test.isRunningTest() && testJourneys != null) {
            allowedJourneys.addAll(testJourneys);
        } else {
            for(SFMC_Journey_Config__mdt rec : [SELECT Journey_Name__c FROM SFMC_Journey_Config__mdt WHERE Is_Active__c = true]){
                allowedJourneys.add(rec.Journey_Name__c);
            }
        }

        Http http = new Http();
        Boolean hasMore = true;
        Integer pagesProcessedInThisChunk = 0;
        List<Map<String, Object>> allItems = new List<Map<String, Object>>();
        Set<String> emailSet = new Set<String>();

        while(hasMore && pagesProcessedInThisChunk < 10) {
            if (Limits.getCpuTime() > 7000) { break; }
            if (allItems.size() > 7000) {
                System.debug('Approaching DML limit. Size: ' + allItems.size());
                break;
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SFMC_REST/data/v1/customobjectdata/key/email_analytics_de/rowset?$page=' + this.page);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setTimeout(120000);
            
            HttpResponse res = http.send(req);
            if(res.getStatusCode() != 200) { hasMore = false; break; }

            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> items = (List<Object>) response.get('items');
            
            if(items == null || items.isEmpty()) {
                hasMore = false;
            } else {
                for(Object obj : items) {
                    Map<String, Object> row = (Map<String, Object>) obj;
                    Map<String, Object> values = (Map<String, Object>) row.get('values');
                    String journeyName = (String) values.get('journeyname');
                    
                    if(String.isNotBlank(journeyName)) {
                        this.foundJourneys.add(journeyName);
                    }

                    Datetime sfmcUpdatedDate = parseDate(values.get('lastupdateddate'));
                    if(!allowedJourneys.isEmpty()) {
                        if(!allowedJourneys.contains(journeyName)) continue; 
                    } else if(lastSyncTime != null && sfmcUpdatedDate != null && sfmcUpdatedDate <= lastSyncTime) {
                        continue; 
                    }

                    allItems.add(row);
                    if(values.get('emailaddress') != null) emailSet.add((String) values.get('emailaddress'));
                }
                this.page++;
                pagesProcessedInThisChunk++;
            }
        }

        if(!allItems.isEmpty()) processAndUpsert(allItems, emailSet);

        if(hasMore && !Test.isRunningTest()) {
            System.enqueueJob(new SFMC_Email_Service(this.page, this.foundJourneys));
        }  
        
        if(!hasMore || Test.isRunningTest()) {
            //createDebugLog(this.foundJourneys);
            if(config == null) config = new SFMC_Config__c();
            config.Name = 'Default'; 
            config.Last_Sync_Time__c = System.now().addMinutes(-5);
            upsert config;
        }
    }

    /*private void createDebugLog(Set<String> journeys) {
        try {
            Debug_Log__c log = new Debug_Log__c();
            log.Class_Name__c = 'SFMC Sync Journey List - ' + System.today().format();
            String journeyList = String.join(new List<String>(journeys), ', ');
            if(journeyList.length() > 131072) {
                journeyList = journeyList.substring(0, 131000) + '... (truncated)';
            }
            log.Request__c = journeyList; 
            insert log;
        } catch (Exception e) {
            System.debug('Log Error: ' + e.getMessage());
        }
    } */

    private void processAndUpsert(List<Map<String, Object>> allItems, Set<String> emailSet) {
        Map<String, Id> emailToContactId = new Map<String, Id>();
        Map<String, Id> emailToLeadId = new Map<String, Id>();
        for(Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :emailSet AND Email != null]) {
            emailToContactId.put(c.Email, c.Id);
        }
        for(Lead l : [SELECT Id, Email FROM Lead WHERE Email IN :emailSet AND Email != null AND IsConverted = false]) {
            emailToLeadId.put(l.Email, l.Id);
        }

        List<SFMC_Analytics__c> records = new List<SFMC_Analytics__c>();
        for(Map<String, Object> row : allItems) {
            Map<String, Object> values = (Map<String, Object>) row.get('values');
            Map<String, Object> keys = (Map<String, Object>) row.get('keys');
            String email = (String) values.get('emailaddress');
            SFMC_Analytics__c rec = new SFMC_Analytics__c();
            rec.External_Id__c = (String)keys.get('subscriberkey') + '_' + (String)keys.get('jobid') + '_' + (String)keys.get('batchid');
            rec.Email__c = email;
            rec.Journey_Name__c = (String) values.get('journeyname');
            rec.Activity_Name__c = (String) values.get('activityname');
            rec.Subscriber_Key__c = (String) keys.get('subscriberkey');
            rec.Channel__c = 'Email';
            rec.Sent__c = values.get('sentflag') == 'Yes';
            rec.Open__c = values.get('openflag') == 'Yes';
            rec.Click__c = values.get('clickflag') == 'Yes';
            rec.Bounce__c = values.get('bounceflag') == 'Yes';
            rec.Sent_Date__c = parseDate(values.get('sentdate'));
            rec.Open_Date__c = parseDate(values.get('opendate'));
            rec.Click_Date__c = parseDate(values.get('clickdate'));
            rec.Bounce_Date__c = parseDate(values.get('bouncedate'));
            rec.Last_Updated__c = parseDate(values.get('lastupdateddate'));
            if(emailToContactId.containsKey(email)) rec.Contact__c = emailToContactId.get(email);
            else if(emailToLeadId.containsKey(email)) rec.Lead__c = emailToLeadId.get(email);
            records.add(rec);
        }
        if(!records.isEmpty()) upsert records External_Id__c;
    }

    public static Datetime parseDate(Object val){
        if(val == null || String.valueOf(val).trim() == '') return null;
        try {
            String dtStr = String.valueOf(val);
            List<String> parts = dtStr.split(' ');
            List<String> dateSplit = parts[0].split('/');
            List<String> timeSplit = parts[1].split(':');
            Integer hour = Integer.valueOf(timeSplit[0]);
            if(parts[2] == 'PM' && hour != 12) hour += 12;
            if(parts[2] == 'AM' && hour == 12) hour = 0;
            return Datetime.newInstance(Integer.valueOf(dateSplit[2]), Integer.valueOf(dateSplit[0]), Integer.valueOf(dateSplit[1]), hour, Integer.valueOf(timeSplit[1]), Integer.valueOf(timeSplit[2]));
        } catch (Exception e) { return null; }
    }
}