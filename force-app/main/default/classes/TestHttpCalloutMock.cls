@isTest
public class TestHttpCalloutMock implements HttpCalloutMock {	
    public HttpResponse respond(HttpRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}'); // Set appropriate mock response
        res.setStatusCode(200);
        return res;
    }
}