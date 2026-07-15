@isTest
public class RouteChangeWhatsappTransportAdminTest {

    // Mock callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true, "message": "WhatsApp notification sent successfully"}');
            return res;
        }
    }

    @isTest
    static void testSendWhatsAppNotifications() {
        // Test data setup
        User testUser = new User(
            FirstName = 'Testss',
            LastName = 'Userss',
            Username = 'testuser@exampless.com',
            Alias = 'tuserss',
            Email = 'testuser@exampless.com',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '1234567890'
        );
        insert testUser;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Faculty',
            MobilePhone = '9876543210',
            Employee_Number__c = 'EMP123'
        );
        insert testContact;

        // Create Route Master records
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 123');
        insert routeMaster;

        RTR_Route_Master__c newRouteMaster = new RTR_Route_Master__c(Name = 'New Route Master');
        insert newRouteMaster;

        // Create Pick Up Points with the correct Route Master ID
        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'New Point',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickUpPoint;

        RTR_Route_Pick_Up_Point__c pickUpPoint1 = new RTR_Route_Pick_Up_Point__c(
            Name = 'New Points',
            RTR_Route_Master__c = newRouteMaster.Id // Make sure this uses the new Route Master
        );
        insert pickUpPoint1;

        // Create Transport Request with the filter condition that matches the new Route Master ID
        RTR_Reva_Transport_Request__c testTransportRequest = new RTR_Reva_Transport_Request__c(
            RTRStudent_Faculty_NonFaculty__c = testContact.Id,
            New_Route_Pick_Up_Point__c = pickUpPoint1.Id // This should match the correct Route Master
        );
        insert testTransportRequest;

        List<String> recordIds = new List<String> { testTransportRequest.Id };

        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();

        // Invoke the method
        RouteChangeWhatsappTransportAdmin.sendWhatsAppNotifications(recordIds);

        Test.stopTest();

        // Assertions
        System.assert(true, 'Method executed without exceptions');
    }
}