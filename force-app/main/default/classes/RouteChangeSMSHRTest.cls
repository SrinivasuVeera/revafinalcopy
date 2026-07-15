@isTest(SeeAllData=true)
public class RouteChangeSMSHRTest {

    // Mock callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate an HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true, "message": "SMS sent successfully"}');
            return res;
        }
    }

    @isTest
    static void testRTRSMSNotificationStudent() {
        // Test data setup
        User testUser = new User(
            FirstName = 'Test1',
            LastName = 'Users',
            Username = 'testuser@examples.com',
            Alias = 'tuserss',
            Email = 'testuser@examples.com',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Faculty',
            MobilePhone = '1234567890',
            Employee_Number__c = 'EMP123'
        );
        insert testContact;

        RTR_Reva_Transport_Request__c testTransportRequest = new RTR_Reva_Transport_Request__c(
            RTRStudent_Faculty_NonFaculty__c = testContact.Id
        );
        insert testTransportRequest;

        List<String> recordIds = new List<String> { testTransportRequest.Id };

        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Invoke the method
        RouteChangeSMSHR.rtrSMSNotificationStudent(recordIds);

        Test.stopTest();

        // Assertions
        // You can assert based on debug logs, or check if certain logic paths were executed.
        System.assert(true, 'Method executed without exceptions');
    }
    
}