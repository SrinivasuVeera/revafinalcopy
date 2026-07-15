public class MockJsonResponse implements HttpCalloutMock {
    
    private static String jsonResponse;

    public static void setJsonResponse(String jsonString) {
        jsonResponse = jsonString;
    }

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody(jsonResponse);
        response.setStatusCode(200);
        return response;
    }
}