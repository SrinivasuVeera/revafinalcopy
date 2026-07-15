public class SFMC_Send_Email_Service {

    public static void sendEmail(String definitionKey, String email, String mobile, String name){

        String token = SFMC_Auth_Service.getAccessToken();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFMC_REST/messaging/v1/email/messages');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');

        String contactKey = email + '_' + mobile;

        Map<String, Object> body = new Map<String, Object>{
            'definitionKey' => definitionKey,
            'recipients' => new List<Object>{
                new Map<String, Object>{
                    'contactKey' => contactKey,
                    'to' => email,
                    'attributes' => new Map<String, Object>{
                        'Name' => name
                    }
                }
            }
        };

        req.setBody(JSON.serialize(body));

        HttpResponse res = new Http().send(req);

        System.debug('SFMC Response: ' + res.getBody());
    }
}