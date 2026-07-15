@isTest
public class TransportCancelSMSTransportAdminTest {

    @isTest
    static void testRTRSMSNotificationStudent() {
        // Create test data
        User adminUser = new User(
            FirstName = 'Lakshmanan',
            LastName = 'G',
            Email = 'lakshmanan.g@test.com',
            Username = 'lakshmanan.g@test.com',
            Alias = 'lg',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '1234567890'
        );
        insert adminUser;

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testStudent = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MobilePhone = '9876543210',
            Employee_Number__c = 'EMP12345'
        );
        insert testStudent;

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Student__c = testStudent.Id
        );
        insert transportRequest;

        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockSMSCallout());

        Test.startTest();

        // Call the invocable method
        TransportCancelSMSTransportAdmin.rtrSMSNotificationStudent(new List<String>{transportRequest.Id});

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
        TransportCancelSMSTransportAdmin.rtrSMSNotificationStudent(new List<String>());

        Test.stopTest();
        // No exception should be thrown for an empty list
    }

    @isTest
    static void testMakeCalloutAsync() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockSMSCallout());

        User adminUser = new User(
            FirstName = 'Lakshmanan',
            LastName = 'G',
            Email = 'lakshmanan.g@test.com',
            Username = 'lakshmanan.g@test.com',
            Alias = 'lg',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            MobilePhone = '1234567890'
        );
        insert adminUser;

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testStudent = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = testAccount.Id,
            MobilePhone = '9876543210',
            Employee_Number__c = 'EMP12345'
        );
        insert testStudent;

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Student__c = testStudent.Id
        );
        insert transportRequest;

        Test.startTest();

        // Call the future method directly
        TransportCancelSMSTransportAdmin.makeCalloutAsync(new List<String>{transportRequest.Id});

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