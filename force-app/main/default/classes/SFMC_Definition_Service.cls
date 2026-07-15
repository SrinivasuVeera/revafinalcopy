public class SFMC_Definition_Service {

    public static Boolean createDefinition(String defKey, String customerKey){

        String token = SFMC_Auth_Service.getAccessToken();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFMC_REST/messaging/v1/email/definitions');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> body = new Map<String, Object>{
            'name' => defKey,
            'definitionKey' => defKey,
            'status' => 'Active',
            'content' => new Map<String, Object>{
                'customerKey' => customerKey
            }
        };

        req.setBody(JSON.serialize(body));

        HttpResponse res = new Http().send(req);

        return res.getStatusCode() == 200 || res.getStatusCode() == 201;
    }
}