@isTest
private class SFMC_Email_Service_Test {

    private class SFMCMock implements HttpCalloutMock {
        private Integer callCount = 0;
        private String journeyName;

        public SFMCMock(String validName) {
            this.journeyName = validName;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (req.getEndpoint().contains('token')) {
                res.setBody('{"access_token": "mock_token_123"}');
                res.setStatusCode(200);
            } 
            else {
                if(callCount == 0) {
                    res.setBody('{"items": [' +
                        '{' +
                            '"keys": {"subscriberkey": "sub_con", "jobid": "111", "batchid": "1"},' +
                            '"values": {"emailaddress": "contact@test.com", "journeyname": "' + this.journeyName + '", "activityname": "Email 1", "sentflag": "Yes", "lastupdateddate": "10/25/2025 11:00:00 AM"}' +
                        '}' +
                    ']}');
                    callCount++;
                } else {
                    res.setBody('{"items": []}');
                }
                res.setStatusCode(200);
            }
            return res;
        }
    }

    @testSetup
    static void setup() {
        SFMC_Config__c config = new SFMC_Config__c(
            Name = 'Default', 
            Last_Sync_Time__c = Datetime.newInstance(2020, 1, 1, 0, 0, 0)
        );
        insert config;

        insert new Contact(LastName = 'ContactUser', Email = 'contact@test.com');
    }

    @isTest
    static void testQueueableExecution() {
       
        List<SFMC_Journey_Config__mdt> metadata = [
            SELECT Journey_Name__c 
            FROM SFMC_Journey_Config__mdt 
            WHERE Is_Active__c = true 
            LIMIT 1
        ];
       
        System.assert(!metadata.isEmpty(), 'ERROR: You must create at least one Active SFMC_Journey_Config__mdt record in your Salesforce Org for this test to pass.');

        String actualJourneyName = metadata[0].Journey_Name__c;

        Test.setMock(HttpCalloutMock.class, new SFMCMock(actualJourneyName));
        Test.startTest();
        System.enqueueJob(new SFMC_Email_Service());
        Test.stopTest();

        List<SFMC_Analytics__c> results = [SELECT Id FROM SFMC_Analytics__c];
        System.assert(results.size() > 0, 'processAndUpsert was still not called. Ensure the metadata record is exactly what you expect.');
    }

    @isTest
    static void testDateParser() {
        Datetime dt = SFMC_Email_Service.parseDate('10/25/2023 10:30:05 PM');
        System.assertEquals(22, dt.hour());
    }
}