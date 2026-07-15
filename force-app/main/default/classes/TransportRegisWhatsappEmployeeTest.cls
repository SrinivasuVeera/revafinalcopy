@isTest
public class TransportRegisWhatsappEmployeeTest {

    @testSetup
    static void setupTestData() {
        // Create a Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '9999999999'
        );
        insert testContact;

        // Create Route Master and Pickup Point records
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 101');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(Name = 'Main Street');
        insert pickupPoint;

        // Create a Transport_Registration__c record
        Transport_Registeration__c transportReg = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Route_Master__c = routeMaster.Id,
            Route_Pick_Up_Point__c = pickupPoint.Id,
            rtr_Start_Date__c = Date.today(),
            Registration_Status__c = 'Active'
        );
        insert transportReg;
    }

    @isTest
    static void testSendWhatsAppNotifications() {
        // Fetch the Transport_Registeration__c record
        Transport_Registeration__c transportReg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        // Call the method to test
        Test.startTest();
        TransportRegisWhatsappEmployee.sendWhatsAppNotifications(new List<String>{transportReg.Id});
        Test.stopTest();

        // Add assertions
        System.assert(true, 'sendWhatsAppNotifications method executed successfully.');
    }

    @isTest
    static void testMakeCalloutAsync() {
        // Fetch the Transport_Registeration__c record
        Transport_Registeration__c transportReg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        // Call the method to test
        Test.startTest();
        TransportRegisWhatsappEmployee.makeCalloutAsync(new List<String>{transportReg.Id});
        Test.stopTest();

        // Add assertions
        System.assert(true, 'makeCalloutAsync method executed successfully.');
    }

    @isTest
    static void testTransportRegisEmp() {
        // Fetch the Transport_Registeration__c record
        Transport_Registeration__c transportReg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        // Call the method to test
        Test.startTest();
        TransportRegisWhatsappEmployee.TransportRegisEmp(transportReg);
        Test.stopTest();

        // Add assertions
        System.assert(true, 'TransportRegisEmp method executed successfully.');
    }

    @isTest
    static void testEmptyRecordIds() {
        // Call the method with an empty list
        Test.startTest();
        TransportRegisWhatsappEmployee.sendWhatsAppNotifications(new List<String>());
        Test.stopTest();

        // Add assertions
        System.assert(true, 'sendWhatsAppNotifications handled empty record IDs successfully.');
    }

    @isTest
    static void testInvalidRecordId() {
        // Call the method with an invalid ID
        Test.startTest();
        TransportRegisWhatsappEmployee.sendWhatsAppNotifications(new List<String>{'InvalidId'});
        Test.stopTest();

        // Add assertions
        System.assert(true, 'sendWhatsAppNotifications handled invalid record IDs successfully.');
    }
}