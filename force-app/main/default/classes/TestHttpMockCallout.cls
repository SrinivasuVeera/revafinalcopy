@isTest
global class TestHttpMockCallout implements HttpCalloutMock
{
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    
    public TestHttpMockCallout(Integer code, String status, String body) 
    {
      this.code = code;
      this.status = status;
      this.bodyAsString = body;
    }
    
  global HTTPResponse respond(HTTPRequest req)
    {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        resp.setBody(bodyAsString);
        return resp;
    }
}