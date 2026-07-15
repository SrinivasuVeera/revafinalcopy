@isTest
public class RouteChangeSMSEmployeeTest {

    @isTest
    static void testRTRSMSNotificationStudent() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MobilePhone = '9876543210'
        );
        insert testContact;

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTRStudent_Faculty_NonFaculty__c = testContact.Id // Correct field assignment
        );
        insert transportRequest;

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockSMSCallout());

        Test.startTest();

        // Call the invocable method
        RouteChangeSMSEmployee.rtrSMSNotificationStudent(new List<String>{transportRequest.Id});

        Test.stopTest();

        // Assertions
        RTR_Reva_Transport_Request__c retrievedRequest = [
            SELECT Id FROM RTR_Reva_Transport_Request__c WHERE Id = :transportRequest.Id
        ];
        System.assertNotEquals(null, retrievedRequest, 'Transport request should exist.');
    }

    @isTest
    static void testRTRSMSNotificationStudentEmptyList() {
        Test.startTest();

        // Call the invocable method with an empty list
        RouteChangeSMSEmployee.rtrSMSNotificationStudent(new List<String>());

        Test.stopTest();
        // No exception should be thrown for an empty list
    }

    @isTest
    static void testMakeCalloutAsync() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockSMSCallout());

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MobilePhone = '9876543210'
        );
        insert testContact;

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTRStudent_Faculty_NonFaculty__c = testContact.Id // Correct field assignment
        );
        insert transportRequest;

        Test.startTest();

        // Call the future method directly
        RouteChangeSMSEmployee.makeCalloutAsync(new List<String>{transportRequest.Id});

        Test.stopTest();
    }

    // Mock class for SMS API callout
    private class MockSMSCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{\"status\":\"success\"}');
            res.setStatusCode(200);
            return res;
        }
    }
}