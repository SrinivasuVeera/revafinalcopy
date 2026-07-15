public class SFMC_Auth_Service {
    
    public static String getAccessToken() {
        
        SFMC_Auth_Config__mdt config = SFMC_Auth_Config__mdt.getInstance('Default');
        
        if(config == null){
            System.debug('SFMC Config missing');
            return null;
        }
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(config.Auth_Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        
        String body = JSON.serialize(new Map<String, String>{
            'grant_type' => 'client_credentials',
            'client_id' => config.Client_Id__c,
            'client_secret' => config.Client_Secret__c,
            'account_id' => config.Account_Id__c
        });
        
        req.setBody(body);
        
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() != 200){
            System.debug('Auth Error: ' + res.getBody());
            return null;
        }
        
        Map<String, Object> response = 
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        return (String) response.get('access_token');
    }
}