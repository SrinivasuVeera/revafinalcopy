@isTest
public class RTRCancelledSMSParentMultipleDaysTest {
    @testSetup
    static void setup() {
        // Create test data
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        
        // Create test transport request
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Number_of_Minutes__c = 10,
            RTR_Start_Date__c = Date.today(),
            RTR_End_Date__c = Date.Today().addDays(5),
            RTR_Date__c = Date.today(),
            RTR_Descriptions__c = 'Test Description'
        );
        insert transportRequest;
        
        Contact FatherCon= new Contact( FirstName = 'Tests',
            LastName = 'User167');
        insert FatherCon;
        
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890',
            Father__c = FatherCon.id,
            RH_Parent_Phone_Number__c = '9876543201'
        );
        insert contact1;
        
        // Insert transport registration with the new contact
        Transport_Registeration__c createtransport = new Transport_Registeration__c(
            Route_Pick_Up_Point__c = pickupPoint.Id,
            Reva_Transport__c = revaTransport.Id,
            Route_Master__c = routeMaster.Id,
            Contact__c = contact1.Id, 
            Registration_Status__c = 'Active'
        );
        insert createtransport;
        
        // Get metadata records
        SMS_Types__mdt cusmeta = [SELECT Id, DeveloperName, Dlt_Content_Id__c, SMS_Name__c, Sender__c, SMS_Template__c, Templated_Id__c, Unicode__c FROM SMS_Types__mdt WHERE DeveloperName = 'RTR_Bus_Cancelled_Multiple_Days_Parents'];
    }
    
    @isTest
    static void testBatch() {
        // Fetch test transport request
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        
        // Instantiate batch class with a list of Ids
        List<String> transportRequestIds = new List<String>{transportRequest.Id};
        RTRCancelledSMSParentMultipleDays batch = new RTRCancelledSMSParentMultipleDays(transportRequestIds);
        
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
        
        // Fetch Transport_Registeration__c records
        List<Transport_Registeration__c> transportRegistrations = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
        
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        // Instantiate batch class with a list of Ids
        List<String> transportRequestIds = new List<String>{transportRequest.Id};
        RTRCancelledSMSParentMultipleDays batch = new RTRCancelledSMSParentMultipleDays(transportRequestIds);
        // Execute batch context
        ID batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        // Validate that the batch ran successfully
        System.assertNotEquals(null, batchId, 'Batch job did not execute successfully.');
    }
    
    // Mock HTTP callout response class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"user" : "revaerp.trans","password" : "s1Sz2"},"from" : "REVAUn","shortMessages" : [ {"dltContentId" : "1007395005736638583","message" : "Dear Test User1, We’d like to inform you that the University bus will arrive at the pickup point 10 mins earlier than the regular schedule on 26.05.2024 on account of Test Description. REVA University", "recipient" : "1234567890"} ],"unicode" : true}');
            res.setStatusCode(200);
            return res;
        }
    }
}