@isTest 
public class paytmMock implements HttpCalloutMock {
    private Integer rspCode;
    private String rspBody;
    private String rspHeaderkey;
      private String rspHeaderValue;
    public paytmMock(Integer rspCode1, String rspBody1,String rspHeaderValue1, String rspHeaderkey1){
         rspCode = rspCode1;
        rspBody = rspBody1;
        rspHeaderkey = rspHeaderkey1;
        rspHeaderValue = rspHeaderValue1;
    }
     public HttpResponse respond(HttpRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(rspCode);
        resp.setHeader(rspHeaderkey,rspHeaderValue);
        resp.setBody(rspBody);
        return resp;
    } 
}