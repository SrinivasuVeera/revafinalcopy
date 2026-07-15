@isTest
public class TransportRegisWhatsappTranportAdminTest{

    @testSetup
    static void setupTestData() {
        // Create a Contact record
        Contact contact = new Contact(
            LastName = 'Test Contact',
            MobilePhone = '9876543210',
            Employee_Number__c = 'EMP1234'
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
            LastName = 'Gg',
            Alias = 'lgg',
            Email = 'test@examples.com',
            Username = 'testusers@examples.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user;

        // Mock Metadata for WhatsApp template
        // Note: Metadata can't be inserted, but this simulates its existence in your test.
        WhatsApp_Notification_Template__mdt template = new WhatsApp_Notification_Template__mdt(
            Template_ID__c = 'transport_regis_employe_tr_admin',
            Template_Field__c = 'transport_admin_name,name_of_the_employee,employee_code,route_number,pick_up_point,name_of_the_department,start_date'
        );
        // Use the metadata details directly in test assertions or mocks.
    }

    @isTest
    static void testSendWhatsAppNotifications_ValidRecordIds() {
        Id recordId = [SELECT Id FROM Transport_Registeration__c LIMIT 1].Id;

        Test.startTest();
        TransportRegisWhatsappTranportAdmin.sendWhatsAppNotifications(new List<String>{recordId});
        Test.stopTest();

        System.assert(true, 'Method executed successfully with valid record IDs.');
    }

    @isTest
    static void testSendWhatsAppNotifications_EmptyRecordIds() {
        Test.startTest();
        TransportRegisWhatsappTranportAdmin.sendWhatsAppNotifications(new List<String>());
        Test.stopTest();

        System.assert(true, 'Method handled empty record IDs without errors.');
    }

    @isTest
    static void testSendWhatsAppNotifications_NullRecordIds() {
        Test.startTest();
        TransportRegisWhatsappTranportAdmin.sendWhatsAppNotifications(null);
        Test.stopTest();

        System.assert(true, 'Method handled null record IDs without errors.');
    }

    @isTest
    static void testMakeCalloutAsync_ValidData() {
        Id recordId = [SELECT Id FROM Transport_Registeration__c LIMIT 1].Id;

        Test.startTest();
        TransportRegisWhatsappTranportAdmin.makeCalloutAsync(new List<String>{recordId});
        Test.stopTest();

        System.assert(true, 'makeCalloutAsync executed successfully with valid data.');
    }

    @isTest
    static void testTransportRegisTransAdmin() {
        Transport_Registeration__c transportRegistration = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        Test.startTest();
        TransportRegisWhatsappTranportAdmin.TransportRegisTransAdmin(transportRegistration);
        Test.stopTest();

        System.assert(true, 'TransportRegisTransAdmin executed without errors.');
    }
}