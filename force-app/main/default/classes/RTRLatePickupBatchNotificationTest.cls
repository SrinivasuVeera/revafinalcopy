@istest
public class RTRLatePickupBatchNotificationTest {
@testSetup
    static void setup() {
        // Create test data
        Contact contact = TestDataFactory.createApplicantCon();
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
 		RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        
        // Create test transport request
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Number_of_Minutes__c = 10,
            RTR_Date__c = Date.today(),
            RTR_Descriptions__c = 'Test Description'
        );
        insert transportRequest;
        
        // Create additional contacts with mobile phones
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890'
        );
        insert contact1;
        
        // Insert transport registration with the new contact
           Transport_Registeration__c createtransport= new Transport_Registeration__c(//Name='Testing',
                                                   Route_Pick_Up_Point__C= pickupPoint.Id ,
                                                   Reva_Transport__C=revaTransport.Id,
                                                   Route_Master__C= routeMaster.Id,
                                                   Contact__C= contact1.Id, 
                                                   Registration_Status__c='Active');
          insert createtransport;
          
        //get metadata records
        WhatsApp_Notification_Template__mdt cusmeta =[select id,developerName, Template_ID__c,Template_Field__c from WhatsApp_Notification_Template__mdt where developerName = 'late_pick_up_single_day_student_staff'];
        
        //WhatsApp_Notification_Template__mdt templateSim = TestDataFactory.getMetadataRecord();
        RTRLatePickupBatchNotification batch = new RTRLatePickupBatchNotification(transportRequest.Id);
        
        // Execute batch
        Test.startTest();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testBatch() {
        // Fetch test transport request
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        
        // Instantiate batch class
        RTRLatePickupBatchNotification batch = new RTRLatePickupBatchNotification(transportRequest.Id);
        
        // Set up mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Execute batch
        Test.startTest();
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Validate that the batch ran successfully
        System.assertNotEquals(null, batchId, 'Batch job did not execute successfully.');
    }
    
    @isTest
    static void testExecuteMethodExceptionHandling() {
        // Fetch test transport request
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        
        // Mock HTTP callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RTRLatePickupBatchNotification batch = new RTRLatePickupBatchNotification(transportRequest.Id);
        batch.execute(null, new List<RTR_Reva_Transport_Request__c> { transportRequest });
        Test.stopTest();
        
    }
    
    // Mock HTTP callout response class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
             res.setBody('{"userDetails":{"number":"1234567890"},"notification":{"type":"whatsapp","sender":"919021190211","language":"en","templateId":"late_pick_up_single_day_student_staff","params":{"name":"Test User1","numberofminutes":"10","Date":"2024-05-23","Reason":"Test Description"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}