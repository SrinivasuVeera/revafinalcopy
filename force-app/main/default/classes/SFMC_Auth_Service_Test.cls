@isTest
public class SFMC_Auth_Service_Test {
  
    @testSetup
    static void setupData() {
       
    }
    
    class AuthMockSuccess implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
       
        if(req.getEndpoint().contains('/v2/token')) {
            System.assertEquals('POST', req.getMethod());
            
            res.setStatusCode(200);
            res.setBody('{' +
                '"access_token": "test_token_123",' +
                '"expires_in": 1080' +
            '}');
        }        
        else if(req.getEndpoint().contains('/data/v1/customobjectdata')) {
            System.assertEquals('GET', req.getMethod());
            
            res.setStatusCode(200);
            res.setBody('{"items": []}');
        }
        
        return res;
    }
}
    
    class AuthMockFailure implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error": "invalid_client"}');
            
            return res;
        }
    }
    
    @isTest
    static void testGetAccessToken_Success() {
        
        Test.setMock(HttpCalloutMock.class, new AuthMockSuccess());
        
        Test.startTest();
        String token = SFMC_Auth_Service.getAccessToken();
        Test.stopTest();
        
        System.assertNotEquals(null, token);
        System.assertEquals('test_token_123', token);
    }
    @isTest
    static void testGetAccessToken_Failure() {
        
        Test.setMock(HttpCalloutMock.class, new AuthMockFailure());
        
        Test.startTest();
        String token = SFMC_Auth_Service.getAccessToken();
        Test.stopTest();
        
        System.assertEquals(null, token);
    }
    @isTest
    static void testQueueable() {
        
        insert new Contact(
            LastName = 'Test',
            Email = 'test@gmail.com'
        );
        
        Test.setMock(HttpCalloutMock.class, new AuthMockSuccess());
        
        Test.startTest();
        System.enqueueJob(new SFMC_Email_Service());
        Test.stopTest();
        
        List<SFMC_Analytics__c> recs = [SELECT Id FROM SFMC_Analytics__c];
        System.assertEquals(0, recs.size());
    }
    
    
}