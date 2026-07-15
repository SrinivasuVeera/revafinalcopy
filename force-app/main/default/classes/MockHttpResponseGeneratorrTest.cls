@IsTest
public class MockHttpResponseGeneratorrTest {
    
    @IsTest
    static void testMockHttpResponseGeneratorr() {
        // Set the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorr());
        
        // Create a dummy HTTP request to trigger the mock
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://dummyurl.com/api/sendSMS');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"phone":"1234567890","message":"Test message"}');
        
        // Make the HTTP callout (it will use the mock response)
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Verify the response
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('application/json', res.getHeader('Content-Type'));
        System.assertEquals('{"status":"success","message":"SMS sent successfully"}', res.getBody());
    }
}