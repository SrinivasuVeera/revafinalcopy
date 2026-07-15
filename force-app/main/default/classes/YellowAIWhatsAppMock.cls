@isTest
global class YellowAIWhatsAppMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"Notifications sent successfully."}');
        res.setStatusCode(200);
        return res;
    }
}