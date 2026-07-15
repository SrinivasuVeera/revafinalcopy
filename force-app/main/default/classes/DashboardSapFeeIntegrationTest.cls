@IsTest
public class DashboardSapFeeIntegrationTest {
    @IsTest
    static void testGetDashboardData() {
        // Set up a mock for the callout
        Test.setMock(HttpCalloutMock.class, new SLCMDashboardMock());

        // Call the method and verify the result
        List<String> result = DashboardSapFeeIntegration.getDashboardData();

        // Assert that the result is not null and contains data
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.isEmpty(), 'Result should not be empty');
    }

    // Mock class for HTTP callout
    private class SLCMDashboardMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            // Example JSON response body
            String responseBody = '{"ResponseData":[' +
                '{"Period":"2024-Q1","Amount":10000,"FromDate":"2024-01-01","ToDate":"2024-03-31"},' +
                '{"Period":"2024-Q2","Amount":15000,"FromDate":"2024-04-01","ToDate":"2024-06-30"}' +
                ']}';

            res.setBody(responseBody);
            return res;
        }
    }

    @IsTest
    static void testErrorResponse() {
        // Set up a mock for the callout that returns an error status code
        Test.setMock(HttpCalloutMock.class, new ErrorHttpMock());

        try {
            // Call the method expecting it to throw an exception
            DashboardSapFeeIntegration.getDashboardData();
            System.assert(false, 'Expected CalloutException but did not get one');
        } catch (CalloutException e) {
            // Assert that the exception message contains the expected error text
            System.assert(e.getMessage().contains('Failed to get a successful response'));
        }
    }

    // Mock class for error response
    private class ErrorHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"StatusCode":500,"StatusMessage":"Internal Server Error"}');
            return res;
        }
    }
}