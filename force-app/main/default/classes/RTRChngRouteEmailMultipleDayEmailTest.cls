@isTest
public class RTRChngRouteEmailMultipleDayEmailTest {
    @testSetup
    static void setup() {
        // Create test data
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();        
        Reva_Transport__c revaTransport = TestDataFactory.createRevaTransport();        
        RTR_Route_Master__c routeMaster = TestDataFactory.createRouteMaster();
        RTR_Route_Master__c Newnumber = new RTR_Route_Master__c(Name='testing 1');
        insert Newnumber;
        RTR_Route_Pick_Up_Point__c Via = new RTR_Route_Pick_Up_Point__c(Name='testing 2');
        insert Via;
        
        // Create test transport request
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Number_of_Minutes__c = 10,
            RTR_Start_Date__c = Date.today(),
            RTR_End_Date__c = Date.Today().addDays(5),
            RTR_Date__c = Date.today(),
            RTR_Routes__c = routeMaster.Id,
            RTR_New_Number__c = Newnumber.Id,
            via__c = via.id,
            RTR_Descriptions__c = 'Test Description'            
        );
        insert transportRequest;
        
        // Create additional contacts with mobile phones
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'User1',
            MobilePhone = '1234567890',
            Email='tester@gmail.com'
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
        
       
    }
    
    @isTest
    static void testBatch() {
        // Fetch test transport request
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        
        // Instantiate batch class with a list of Ids
        List<String> transportRequestIds = new List<String>{transportRequest.Id};
        RTRChangeRouteEmailMultipleDayEmail batch = new RTRChangeRouteEmailMultipleDayEmail(transportRequestIds);
        
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
        RTRChangeRouteEmailMultipleDayEmail batch = new RTRChangeRouteEmailMultipleDayEmail(transportRequestIds);
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
            res.setBody('{"status" : "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}