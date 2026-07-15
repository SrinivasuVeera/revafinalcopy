public class SMS_MockCallout implements HttpCalloutMock
{
    private Integer rspCode;
    private String rspBody;
    private String rspStatus;
    
    public SMS_MockCallout(Integer rspCode1, String rspBody1, String rspStatus1) 
    {
        rspCode = rspCode1;
        rspBody = rspBody1;
        rspStatus = rspStatus1;
    }
    public HttpResponse respond(HttpRequest req) 
    {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(rspCode);
        resp.setStatus(rspStatus);
        resp.setBody(rspBody);
        return resp;
    } 
}