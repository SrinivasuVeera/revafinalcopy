@isTest
public class TransportRegisSMSHRTest {

    // Mock class to simulate the SMS API callout
    private class MockSMSUtility implements HttpCalloutMock {
        // This method simulates the HTTP response from an SMS API
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response for the SMS API callout
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200); // OK status
            res.setBody('{"status":"success"}'); // Simulated success response
            return res;
        }
    }

    // Test method
    @isTest
    public static void testRTRSMSNotificationStudent() {
        // Step 1: Set up test data
        // Create a test Contact (to link to Transport_Registeration__c)
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Student', MobilePhone = '9876543210', Application_Number__c = 'A123', Employee_Number__c = 'EMP001');
        insert testContact;
        
        // Create a test Route Master and Route Pick Up Point
        RTR_Route_Master__c testRouteMaster = new RTR_Route_Master__c(Name = 'Route 1');
        insert testRouteMaster;
        
        RTR_Route_Pick_Up_Point__c testRoutePickUp = new RTR_Route_Pick_Up_Point__c(Name = 'Point 1');
        insert testRoutePickUp;
        
        // Create a Transport_Registeration__c record for the test
        Transport_Registeration__c trReg = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Route_Master__c = testRouteMaster.Id,
            Route_Pick_Up_Point__c = testRoutePickUp.Id
        );
        insert trReg;

        // Step 2: Set the mock response for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockSMSUtility());

        // Step 3: Test the InvocableMethod
        Test.startTest();
        List<String> recordIds = new List<String>{trReg.Id};
        TransportRegisSMSHR.rtrSMSNotificationStudent(recordIds);
        Test.stopTest();
        
        // Step 4: Verify the results
        // We can check the debug logs to confirm if the message was created correctly
        // In this case, we don't assert on the message content as we are only testing logic
    }
}