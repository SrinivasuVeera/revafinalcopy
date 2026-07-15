@IsTest
public class TransportRegisSMSEmployeeTest {
    @TestSetup
    static void setupData() {
        // Create test data for Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Application_Number__c = 'APP12345',
            MobilePhone = '1234567890'
        );
        insert testContact;

        // Create Route Master and Pickup Point records
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 101');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickupPoint = new RTR_Route_Pick_Up_Point__c(Name = 'Main Street');
        insert pickupPoint;

        // Create a Transport_Registration__c record
        Transport_Registeration__c testRegistration = new Transport_Registeration__c(
            Contact__c = testContact.Id,
            Route_Master__c = routeMaster.Id,
            Route_Pick_Up_Point__c = pickupPoint.Id,
            rtr_Start_Date__c = Date.today(),
            Registration_Status__c = 'Active'
            //Registration_Type__c = 'Student' // Ensure this matches the query condition
        );
        insert testRegistration;
    }

    @IsTest
    static void testEmptyRecordIds() {
        Test.startTest();
        TransportRegisSMSEmployee.rtrSMSNotificationStudent(new List<String>());
        Test.stopTest();
    }

    @IsTest
    static void testNoMatchingRecords() {
        Test.startTest();
        TransportRegisSMSEmployee.rtrSMSNotificationStudent(new List<String>{'NonExistentId1', 'NonExistentId2'});
        Test.stopTest();
    }

    @IsTest
    static void testValidRecordIds() {
        // Query the created Transport_Registeration__c records
        Transport_Registeration__c testRegistration = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        // Use a mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new SMSAPIMock());

        // Call the method with valid record IDs
        Test.startTest();
        TransportRegisSMSEmployee.rtrSMSNotificationStudent(new List<String>{testRegistration.Id});
        Test.stopTest();
    }

    // Inner class to mock the SMS API callout
    private class SMSAPIMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Simulate a successful SMS API response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }
}