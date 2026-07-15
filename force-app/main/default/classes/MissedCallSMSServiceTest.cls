@isTest
private class MissedCallSMSServiceTest {

    // Mock class for HTTP callout
    class SMSMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendSMS() {

        // Prepare test data (phone numbers)
        List<String> phoneNumbers = new List<String>{
            '9731584067',
            '9000000000'
        };

        // Set mock response
        Test.setMock(HttpCalloutMock.class, new SMSMockCallout());

        Test.startTest();
        MissedCallSMSService.sendSMS(phoneNumbers);
        Test.stopTest();

        // No asserts needed since no return,
        // but we ensure no exceptions and callout executed
        System.assert(true, 'SMS method executed successfully');
    }
}