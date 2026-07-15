@isTest
public class SFMC_Lead_Email_Queueable_Test {

    // MOCK CLASS
    class SFMCMultiMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            // TOKEN
            if(req.getEndpoint().contains('/v2/token')){
                res.setBody('{"access_token":"test_token","expires_in":3600}');
                res.setStatusCode(200);
            }
            // CREATE DEFINITION
            else if(req.getEndpoint().contains('/email/definitions')){
                res.setBody('{"definitionKey":"auto_test"}');
                res.setStatusCode(201);
            }
            // SEND EMAIL
            else if(req.getEndpoint().contains('/email/messages')){
                res.setBody('{"errorcode":0}');
                res.setStatusCode(202);
            }
            else {
                res.setBody('{}');
                res.setStatusCode(200);
            }

            return res;
        }
    }

    // TEST: CREATE + SEND
    @isTest
    static void testCreateDefinitionAndSendEmail(){

        // Create Account (used in config)
        Account acc = new Account(Name = 'B.Tech. in Design Eng');
        insert acc;

        // Config WITHOUT definitionKey (forces creation)
        SFMC_Email_Config__c cfg = new SFMC_Email_Config__c(
            Account__c = acc.Id,
            Customer_Key__c = 'cust_123',
            Active__c = true
        );
        insert cfg;

        // Lead
        Lead l = new Lead(
            LastName = 'Test',
            Company = 'Test',
            Status = 'Unverified',
            Email = 'test@test.com',
            MobilePhone = '9999999999',
            Program_Name_Display__c = acc.Name
        );
        insert l;

        Test.setMock(HttpCalloutMock.class, new SFMCMultiMock());

        Test.startTest();
        System.enqueueJob(new SFMC_Lead_Email_Queueable(new List<Id>{l.Id}));
        Test.stopTest();

        // Verify definitionKey updated
        SFMC_Email_Config__c updatedCfg = [
            SELECT Definition_Key__c FROM SFMC_Email_Config__c WHERE Id = :cfg.Id
        ];

        System.assertNotEquals(null, updatedCfg.Definition_Key__c, 'Definition should be created');
    }

    // TEST: ONLY SEND (definition already exists)
    @isTest
    static void testSendEmailWithExistingDefinition(){

        Account acc = new Account(Name = 'MBA');
        insert acc;

        SFMC_Email_Config__c cfg = new SFMC_Email_Config__c(
            Account__c = acc.Id,
            Customer_Key__c = 'cust_456',
            Definition_Key__c = 'existing_def',
            Active__c = true
        );
        insert cfg;

        Lead l = new Lead(
            LastName = 'Test2',
            Company = 'Test',
            Status = 'Unverified',
            Email = 'test2@test.com',
            MobilePhone = '8888888888',
            Program_Name_Display__c = acc.Name
        );
        insert l;

        Test.setMock(HttpCalloutMock.class, new SFMCMultiMock());

        Test.startTest();
        System.enqueueJob(new SFMC_Lead_Email_Queueable(new List<Id>{l.Id}));
        Test.stopTest();

        // Ensure definition not changed
        SFMC_Email_Config__c updatedCfg = [
            SELECT Definition_Key__c FROM SFMC_Email_Config__c WHERE Id = :cfg.Id
        ];

        System.assertEquals('existing_def', updatedCfg.Definition_Key__c, 'Definition should not change');
    }
}