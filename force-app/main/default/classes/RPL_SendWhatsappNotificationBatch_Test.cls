@isTest
private class RPL_SendWhatsappNotificationBatch_Test {
    
    private class WhatsappNotificationMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new WhatsappNotificationMockCallout());
        
        Map<String, Map<String, String>> testData = new Map<String, Map<String, String>>();
        Map<String, String> innerMap = new Map<String, String>();
        innerMap.put('whatsAppType', 'TestType'); // Ensure 'whatsAppType' is set in the inner map
        innerMap.put('Key2', 'Value2');
        testData.put('7824954829', innerMap);
        
        Test.startTest();
        Database.executeBatch(new RPL_SendWhatsappNotificationBatch(testData), 100);
        Test.stopTest();
    }
}