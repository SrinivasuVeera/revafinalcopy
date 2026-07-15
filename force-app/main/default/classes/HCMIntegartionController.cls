public class HCMIntegartionController {   
 // HCM Access Token 
 @AuraEnabled
    public static String getAccessToken(string employeeNumber,string Type){
        system.debug('employeeNumber'+employeeNumber);
        system.debug('type>>>>'+type);
        string clientId;
        string ClientSecret;
        string userName;
        string Password;
        string endPoint;
        string grantType ='password';
        
        HCM_Credential__mdt[] HCMmetadataRecords = [SELECT Id, client_id__c, client_secret__c, username__c, password__c, End_Point__c, DeveloperName, Label FROM HCM_Credential__mdt where Label='HCM Integartion'];
    	
        for (HCM_Credential__mdt HCMdata : HCMmetadataRecords) {
    			clientId = HCMdata.client_id__c;
                ClientSecret = HCMdata.client_secret__c;
                userName = HCMdata.username__c;
                Password = HCMdata.password__c;
            	endPoint = HCMdata.End_Point__c;
            }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(endPoint);
        req.setBody('username='+userName+
            '&password='+Password+
            '&grant_type='+grantType+
            '&client_id='+clientId+
            '&client_secret='+ClientSecret);
        
        Http http = new Http();        
        HttpResponse Res = http.send(req);
       	system.debug('Response'+ Res.getBody());
        	String jsonBody = Res.getBody();
        //deserialize
        HCMWrapper wrapData = (HCMWrapper)JSON.deserialize(jsonBody,HCMWrapper.class );
        System.debug('wrapData-->> '+wrapData.access_token); 
        getSalaryRange(wrapData.access_token,employeeNumber,type);
        return wrapData.access_token;
}
    public class HCMWrapper{
        string access_token;
        string type;
        public HCMWrapper(string access_token,String Type){
            this.access_token = access_token;
            this.type  = type;
        }
}
    @AuraEnabled
    public static Decimal getSalaryRange(String accessToken,string employeeNumber,String Type){
        HCM_Credential__mdt[] SalaryRecords = [SELECT Id,End_Point__c, DeveloperName, Label FROM HCM_Credential__mdt where Label ='SalaryRangeApi'];
        system.debug('SalaryRecords'+SalaryRecords);
        string endpoint = SalaryRecords[0].End_Point__c+employeeNumber+'&Type='+Type;
        system.debug('endpoint '+ endpoint);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndPoint(endpoint);
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer '+ accessToken);
        
         Http http = new Http();        
        HttpResponse Res = http.send(req);
       	system.debug('Response'+ Res.getBody());
        
        
    // Deserialize the response
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    if (responseMap != null && responseMap.containsKey('Salary_Range')) {
       
        Decimal salaryRange = (Decimal) responseMap.get('Salary_Range');
        system.debug('Salary Range for ' + employeeNumber + ': ' + salaryRange);

        
        Decimal employeeSalaryRange = salaryRange;
        system.debug('employeeSalaryRange'+employeeSalaryRange);
       return employeeSalaryRange;
    } else {
        system.debug('Salary range not found in the response.');
        return null;
    }
  
       
    }
}