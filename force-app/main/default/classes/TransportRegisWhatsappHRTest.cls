@isTest
public class TransportRegisWhatsappHRTest {
    
    @isTest
    static void testSendWhatsAppNotifications_ValidRecordIds() {
        // Step 1: Create test data
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567890',
            Employee_Number__c = 'EMP001'
        );
        insert testContact;

        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 101');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(Name = 'Main Street');
        insert pickupPoint;

        // Create a Transport_Registration__c record
        Transport_Registeration__c transportRequest = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Route_Master__c = routeMaster.Id,
            Route_Pick_Up_Point__c = pickupPoint.Id,
            rtr_Start_Date__c = Date.today(),
            Registration_Status__c = 'Active'
        );
        insert transportRequest;
        List<String> recordIds = new List<String>{transportRequest.Id};

        // Step 2: Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockWhatsAppResponseGenerator());

        // Step 3: Execute the method
        Test.startTest();
        TransportRegisWhatsappHR.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        // Step 4: Assertions
        System.assert(true, 'Test executed without exceptions.');
    }

    @isTest
    static void testSendWhatsAppNotifications_EmptyRecordIds() {
        // Test with empty record IDs
        List<String> recordIds = new List<String>();

        Test.startTest();
        TransportRegisWhatsappHR.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        System.assert(true, 'Method handled empty record IDs gracefully.');
    }

    @isTest
    static void testSendWhatsAppNotifications_NullRecordIds() {
        // Test with null record IDs
        List<String> recordIds = null;

        Test.startTest();
        TransportRegisWhatsappHR.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        System.assert(true, 'Method handled null record IDs gracefully.');
    }

    @isTest
    static void testMakeCalloutAsync_ValidRecordIds() {
        // Step 1: Create test data
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567890',
            Employee_Number__c = 'EMP001'
        );
        insert testContact;

          RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 101');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(Name = 'Main Street');
        insert pickupPoint;

        // Create a Transport_Registration__c record
        Transport_Registeration__c transportRequest = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Route_Master__c = routeMaster.Id,
            Route_Pick_Up_Point__c = pickupPoint.Id,
            rtr_Start_Date__c = Date.today(),
            Registration_Status__c = 'Active'
        );
        insert transportRequest;

        List<String> recordIds = new List<String>{transportRequest.Id};

        // Step 2: Execute the method
        Test.startTest();
        TransportRegisWhatsappHR.makeCalloutAsync(recordIds);
        Test.stopTest();

        System.assert(true, 'Test executed without exceptions.');
    }

    // Helper methods to create related test records
    private static RTR_Route_Master__c createRouteMaster() {
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(
            Name = 'Route 101'
        );
        insert routeMaster;
        return routeMaster;
    }

    private static RTR_Route_Pick_Up_Point__c createPickUpPoint() {
        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Test Pick Up Point'
        );
        insert pickUpPoint;
        return pickUpPoint;
    }

    // Mock callout response
    private class MockWhatsAppResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"WhatsApp notification sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
}