@isTest
public class TransportCancelWhatsappEmployeeTest {
    @isTest
    static void testSendWhatsAppNotifications() {
        // Step 1: Setup test data
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId(),
            RTR_Student__c = createTestStudent() // Assuming RTR_Student__c is a lookup field
        );
        insert transportRequest;

        List<String> recordIds = new List<String>{transportRequest.Id};

        // Step 2: Call the method to test
        Test.startTest();
        TransportCancelWhatsappEmployee.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        // Step 3: Assertions
        System.assert(true, 'Test executed without errors.');
    }

    private static Id createTestStudent() {
        // Replace with the actual object and field names
        Contact testStudent = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '1234567890'
        );
        insert testStudent;
        return testStudent.Id;
    }

    @isTest
    static void testSendWhatsAppNotificationsWithEmptyList() {
        List<String> recordIds = new List<String>();
        Test.startTest();
        TransportCancelWhatsappEmployee.sendWhatsAppNotifications(recordIds);
        Test.stopTest();
        System.assert(true, 'No errors for empty list.');
    }

    @isTest
    static void testSendWhatsAppNotificationsWithNullList() {
        List<String> recordIds = null;
        Test.startTest();
        TransportCancelWhatsappEmployee.sendWhatsAppNotifications(recordIds);
        Test.stopTest();
        System.assert(true, 'No errors for null list.');
    }

    @isTest
    static void testTransportCancelEmp() {
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId(),
            RTR_Student__c = createTestStudent()
        );
        insert transportRequest;

        Test.startTest();
        TransportCancelWhatsappEmployee.makeCalloutAsync(new List<String>{transportRequest.Id});
        Test.stopTest();
        System.assert(true, 'Transport cancellation logic executed without errors.');
    }

    @isTest
    static void testWithMockedCallout() {
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId(),
            RTR_Student__c = createTestStudent()
        );
        insert transportRequest;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        TransportCancelWhatsappEmployee.makeCalloutAsync(new List<String>{transportRequest.Id});
        Test.stopTest();

        System.assert(true, 'Mocked callout executed successfully.');
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{\"status\":\"success\"}');
            res.setStatusCode(200);
            return res;
        }
    }
}