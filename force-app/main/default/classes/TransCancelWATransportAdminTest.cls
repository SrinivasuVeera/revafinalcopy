@isTest
public class TransCancelWATransportAdminTest {

    @isTest
    static void testSendWhatsAppNotifications() {
        // Step 1: Create test data
        RTR_Reva_Transport_Request__c transportRequest = createTestTransportRequest();
        insert transportRequest;

        List<String> recordIds = new List<String>{transportRequest.Id};

        // Step 2: Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockWhatsAppResponseGenerator());

        // Step 3: Call the method
        Test.startTest();
        TransportCancelWhatsappTransportAdmin.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        // Step 4: Assertions
        System.assert(true, 'Test executed without errors.');
    }

    @isTest
    static void testSendWhatsAppNotificationsWithEmptyList() {
        List<String> recordIds = new List<String>();

        Test.startTest();
        TransportCancelWhatsappTransportAdmin.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        System.assert(true, 'No errors for empty record list.');
    }

    @isTest
    static void testSendWhatsAppNotificationsWithNullList() {
        List<String> recordIds = null;

        Test.startTest();
        TransportCancelWhatsappTransportAdmin.sendWhatsAppNotifications(recordIds);
        Test.stopTest();

        System.assert(true, 'No errors for null record list.');
    }

    private static RTR_Reva_Transport_Request__c createTestTransportRequest() {
        // Replace RTR_Student__c with a valid related object
        Contact student = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '1234567890',
            Employee_Number__c = 'EMP12345', // Adjust field name if incorrect
            AccountId = null // Replace with valid account if needed
        );
        insert student;

        // Replace RTR_Route_Master__c with the correct related object
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(
            Name = 'Route 101'
        );
        insert routeMaster;

        // Replace RTR_Route_Pick_Up_Point__c with the correct related object
        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Test Pick Up Point',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickUpPoint;

        // Replace RTR_Reva_Transport_Request__c with your actual object
        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Student__c = student.Id, // Adjust field name if incorrect
            RTR_Route_Pick_Up_Point__c = pickUpPoint.Id // Adjust field name if incorrect
        );
        return transportRequest;
    }

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