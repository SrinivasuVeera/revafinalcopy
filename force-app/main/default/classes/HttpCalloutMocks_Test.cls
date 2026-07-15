@isTest
public class HttpCalloutMocks_Test implements HttpCalloutMock{
    
    //private String compositeResponse = '{"compositeResponse":[{"body":{"id":"e02xx0000000001AAA","success":true,"errors":[{"statusCode":"OPERATION_ENQUEUED","message":"a67df3f9-a408-4193-aa07-2502308bc3ce","fields":[]}]},"httpHeaders":{"Location":"/services/data/v54.0/sobjects/Integration_Event__e/e02xx0000000001AAA"},"httpStatusCode":201,"referenceId":"event1"},{"body":{"id":"e02xx0000000001AAA","success":true,"errors":[{"statusCode":"OPERATION_ENQUEUED","message":"e8bcd93c-2376-4610-b222-9de73175fa81","fields":[]}]},"httpHeaders":{"Location":"/services/data/v54.0/sobjects/Integration_Event__e/e02xx0000000001AAA"},"httpStatusCode":400,"referenceId":"event2"}]}';
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.oot.bz/api/v1/message', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}');
        res.setStatusCode(200);
        return res;
    }

}