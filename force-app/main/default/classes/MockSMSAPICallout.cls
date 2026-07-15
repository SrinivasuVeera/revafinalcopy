@isTest
global class MockSMSAPICallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Simulate a successful response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success", "message": "SMS sent successfully"}');
        res.setStatusCode(200);
        return res;
    }
}