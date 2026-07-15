@isTest
private class Yellow_AI_UtilityTest {

    @isTest
    static void testSendWhatsAppNotifications() {
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'your_template_id';
        notification.params = new Map<String, String>{ 'param1' => 'value1', 'param2' => 'value2' };

        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        phoneNumbersToNotifications.put('recipient_phone_number', new List<Yellow_AI_Utility.WhatsAppNotification>{ notification });

        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{"status":"success"}');
        mockResponse.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        HttpResponse result = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
        Test.stopTest();

        // Perform assertions on the result if needed
       // System.assertEquals(200, result.getStatusCode());
        // Add more assertions based on the expected behavior of your code
    }

    @isTest
    static void testGenerateWhatsAppJSON() {
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'your_template_id';
        notification.params = new Map<String, String>{ 'param1' => 'value1', 'param2' => 'value2' };

        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        phoneNumbersToNotifications.put('recipient_phone_number', new List<Yellow_AI_Utility.WhatsAppNotification>{ notification });

        String result = Yellow_AI_Utility.generateWhatsAppJSON(phoneNumbersToNotifications);

        // Perform assertions on the result if needed
       // System.assertNotEquals(null, result);
        // Add more assertions based on the expected behavior of your code
    }
    
    // Mock HTTP callout class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
    
    
}