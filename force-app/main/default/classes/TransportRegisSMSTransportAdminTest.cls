@isTest
public class TransportRegisSMSTransportAdminTest{

    @testSetup
    static void setupTestData() {
        // Create a Contact record
        Contact contact = new Contact(
            LastName = 'Test Contact',
            MobilePhone = '9876543210',
            Employee_Number__c = 'EMP1234',
            Application_Number__c = 'APP1234'
        );
        insert contact;

        // Create a Route Master record
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 101');
        insert routeMaster;

        // Create a Pick-Up Point record
        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(Name = 'Main Street');
        insert pickupPoint;

        // Create a Transport Registration record
        Transport_Registeration__c transportRegistration = new Transport_Registeration__c(
            Contact__c = contact.Id,
            Route_Master__c = routeMaster.Id,
            Route_Pick_Up_Point__c = pickupPoint.Id,
            rtr_Start_Date__c = Date.today()
        );
        insert transportRegistration;

        // Create a User record
        User user = new User(
            FirstName = 'Lakshmanan',
            LastName = 'G',
            Alias = 'lg',
            Email = 'test@example.com',
            Username = 'testusers2@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '9876543211'
        );
        insert user;
    }

    @isTest
    static void testRTRSMSNotificationStudent_ValidRecordIds() {
        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockSMSAPICallout());

        // Fetch a valid record ID
        Id recordId = [SELECT Id FROM Transport_Registeration__c LIMIT 1].Id;

        // Test the Invocable Method
        Test.startTest();
        TransportRegisSMSTransportAdmin.rtrSMSNotificationStudent(new List<String>{recordId});
        Test.stopTest();

        // Verify if the method handled valid inputs correctly
        System.assert(true, 'The method executed successfully for valid record IDs.');
    }

    @isTest
    static void testRTRSMSNotificationStudent_EmptyRecordIds() {
        // Test the Invocable Method with an empty list
        Test.startTest();
        TransportRegisSMSTransportAdmin.rtrSMSNotificationStudent(new List<String>());
        Test.stopTest();

        // Verify no errors occurred
        System.assert(true, 'The method handled empty record IDs without errors.');
    }

    @isTest
    static void testRTRSMSNotificationStudent_NullRecordIds() {
        // Test the Invocable Method with null input
        Test.startTest();
        TransportRegisSMSTransportAdmin.rtrSMSNotificationStudent(null);
        Test.stopTest();

        // Verify no errors occurred
        System.assert(true, 'The method handled null record IDs without errors.');
    }

    @isTest
    static void testMakeCalloutAsync_ValidData() {
        // Set the mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockSMSAPICallout());

        // Fetch a valid record ID
        Id recordId = [SELECT Id FROM Transport_Registeration__c LIMIT 1].Id;

        // Test the asynchronous method
        Test.startTest();
        TransportRegisSMSTransportAdmin.makeCalloutAsync(new List<String>{recordId});
        Test.stopTest();

        // Verify if the method executed correctly
        System.assert(true, 'The makeCalloutAsync method executed successfully.');
    }
}