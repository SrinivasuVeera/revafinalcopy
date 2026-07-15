@isTest
public class HCMIntegrationControllerTest {
    @isTest
    static void testGetAccessToken() {
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        String accessToken = HCMIntegartionController.getAccessToken('REVA00135', 'transportation');
          System.assertNotEquals(null, accessToken, 'Access Token should not be null');
          System.assertEquals('mockAccessToken123', accessToken, 'Access Token does not match expected value');
    }

    @isTest
    static void testGetSalaryRange() {
        Test.setMock(HttpCalloutMock.class, new HCMHttpMock());

        Decimal salaryRange = HCMIntegartionController.getSalaryRange('mockAccessToken123', 'REVA00135', 'transportation');
        //System.assertNotEquals(null, salaryRange, 'Salary range should not be null');
       // System.assertEquals(3500.00, salaryRange, 'Salary range does not match expected value');
    }

    private class HCMHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();

            if (req.getEndpoint().contains('/token')) {
                // Mocking the token API response
                res.setBody('{"access_token": "mockAccessToken123"}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('/salary')) {
                // Mocking the salary range API response
                res.setBody('{"Type":"transportation","Salary_Range":3500.00,"Employee_Number":"REVA00135","Employee_Name":"Ganesh S J"}');
                res.setStatusCode(200);
            } else {
                // Fallback for unhandled endpoints
                res.setBody('{"error": "Endpoint not recognized"}');
                res.setStatusCode(404);
            }

            return res;
        }
    }
}