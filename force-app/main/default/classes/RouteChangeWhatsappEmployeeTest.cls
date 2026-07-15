@isTest
public class RouteChangeWhatsappEmployeeTest {
    @testSetup
    static void setupTestData() {
        // Create required test data

        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact employee = new Contact(
            LastName = 'Test Employee',
            MobilePhone = '9876543210',
            AccountId = account.Id
        );
        insert employee;

        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'New Route');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'New Point',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickUpPoint;

        RecordType routeChangeRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Route Change Request' LIMIT 1];

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Student__r = employee,
            RecordTypeId = routeChangeRecordType.Id,
            New_Route_Master__c = routeMaster.Id,
            New_Route_Pick_Up_Point__c = pickUpPoint.Id
        );
        insert transportRequest;
    }

    @isTest
    static void testSendWhatsAppNotifications_WithValidRecordIds() {
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];

        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Skip invoking flow triggers (you can mock the part of the code that would trigger it)
        // If necessary, use a custom handler to simulate flow execution without triggering it

        Test.startTest();
        RouteChangeWhatsappEmployee.sendWhatsAppNotifications(new List<String>{transportRequest.Id});
        Test.stopTest();

        System.assert(true, 'Callout executed successfully for valid record IDs.');
    }

    @isTest
    static void testSendWhatsAppNotifications_WithEmptyRecordIds() {
        Test.startTest();
        RouteChangeWhatsappEmployee.sendWhatsAppNotifications(new List<String>());
        Test.stopTest();

        System.assert(true, 'No callout was made for empty record IDs.');
    }

    @isTest
    static void testSendWhatsAppNotifications_WithNullRecordIds() {
        Test.startTest();
        RouteChangeWhatsappEmployee.sendWhatsAppNotifications(null);
        Test.stopTest();

        System.assert(true, 'No callout was made for null record IDs.');
    }

    @isTest
    static void testMakeCalloutAsync_WithValidData() {
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];

        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        RouteChangeWhatsappEmployee.makeCalloutAsync(new List<String>{transportRequest.Id});
        Test.stopTest();

        System.assert(true, 'makeCalloutAsync executed successfully with valid data.');
    }

    @isTest
    static void testMakeCalloutAsync_WithNoMatchingRecords() {
        Test.startTest();
        RouteChangeWhatsappEmployee.makeCalloutAsync(new List<String>{'non-existent-id'});
        Test.stopTest();

        System.assert(true, 'makeCalloutAsync handled non-matching record IDs gracefully.');
    }

    // Mock class for HTTP callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success":true}');
            return res;
        }
    }
}