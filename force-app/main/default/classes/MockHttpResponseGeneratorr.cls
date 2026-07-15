@IsTest
global class MockHttpResponseGeneratorr implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"SMS sent successfully"}');
        res.setStatusCode(200);
        return res;
    }
}