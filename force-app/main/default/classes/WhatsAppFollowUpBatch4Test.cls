@isTest
public class WhatsAppFollowUpBatch4Test {	
    
    static testMethod void testBatchExecution() {  
        // Test data setup
    	List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            Lead lead = new Lead(FirstName = 'TestFirstName'+i, 
                                 LastName =  'TestSecondName'+i,
                                 Email = 'testmail'+i+'@gmail.com',
                                 LeadSource = 'Walk-in',
                                 Mobilephone = '123456789' + i, 
                                 status = 'Verified');
            leads.add(lead);
        }
        insert leads;
        
     	Test.startTest();
        WhatsAppFollowUpBatch4 batch = new WhatsAppFollowUpBatch4();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testScheduler() {
        // Enqueue job
        Test.startTest();
        String jobId = System.schedule('Test WhatsAppFollowUp Scheduler', '0 0 0 * * ?', new WhatsAppFollowUp_LeadVerified_Scheduler());
        Test.stopTest();

        // Verify job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('Test WhatsAppFollowUp Scheduler', ct.CronJobDetail.Name);
        
        }
    
    // Mock response class for WhatsApp callout
    private class WhatsAppMockResponse implements HttpCalloutMock {
        // This method mocks the response for the HTTP request
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}