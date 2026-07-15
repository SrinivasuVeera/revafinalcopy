public  class RevaHostelHCM_AccessTokenRequest {
    public static String getAccessToken() {
        String clientId;
        String ClientSecret;
        String userName;
        String Password;
        String endPoint;
        String grantType = 'password';
        
        REVA_Hostel_HCM_Approval__mdt[] HostelHCMmetadataRecords = [SELECT Id, client_id__c, client_secret__c, username__c, password__c, End_Point__c, DeveloperName, Label FROM REVA_Hostel_HCM_Approval__mdt WHERE Label = 'REVA Hostel HCM Integration'];
        
        for (REVA_Hostel_HCM_Approval__mdt HCMdata : HostelHCMmetadataRecords) {
            clientId = HCMdata.client_id__c;
            ClientSecret = HCMdata.client_secret__c;
            userName = HCMdata.username__c;
            Password = HCMdata.password__c;
            endPoint = HCMdata.End_Point__c;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(endPoint);
        req.setBody('username=' + userName +
                    '&password=' + Password +
                    '&grant_type=' + grantType +
                    '&client_id=' + clientId +
                    '&client_secret=' + ClientSecret);
        System.debug('Request body: ' + req.getBody());
        
        Http http = new Http();        
        HttpResponse res = http.send(req);
        System.debug('Response ACCESS: ' + res.getBody());
        
        if (res.getStatusCode() == 200) {
            try {
                HCMWrapper wrapData = (HCMWrapper)JSON.deserialize(res.getBody(), HCMWrapper.class);
                System.debug('Access token obtained: ' + wrapData.access_token);
                return wrapData.access_token;
            } catch (System.JSONException e) {
                System.debug('JSON Parsing Error: ' + e.getMessage());
                return null;
            }
        } else {
            // Handle error scenario appropriately
            System.debug('Failed to get access token: ' + res.getBody());
            return null;
        }
    }
    
	
	public class HCMWrapper {
        public String access_token;
        public HCMWrapper(String access_token) {
            this.access_token = access_token;
        }
    }
}