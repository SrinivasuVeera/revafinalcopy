@isTest
public class RevaHostelHCM_AccessTokenRequestTest {

    @isTest
    static void testGetAccessTokenWithMockedSuccessData() {
        
        Test.setMock(HttpCalloutMock.class, new MockAccessTokenResponse());
        
        Test.startTest();
        String accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
        Test.stopTest();
        
        System.assertNotEquals(null, accessToken, 'Access token should not be null.');
        System.assertEquals('mockAccessToken123', accessToken, 'Access token should match the mock response.');
    }
    
    @isTest
    static void testGetAccessTokenWithMockedFailureData() {
        
        Test.setMock(HttpCalloutMock.class, new MockAccessTokenResponseFailure());
        
        Test.startTest();
        String accessToken = RevaHostelHCM_AccessTokenRequest.getAccessToken();
        Test.stopTest();
        
        System.assertEquals(null, accessToken, 'Access token as null.');
    }
    
    

    private class MockAccessTokenResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mockAccessToken123"}');
            return res;
        }
    }
    
     private class MockAccessTokenResponseFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"access_token": ""}');
            return res;
        }
    }
}