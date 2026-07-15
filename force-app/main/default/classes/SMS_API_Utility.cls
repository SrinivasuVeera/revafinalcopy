public class SMS_API_Utility 
{
    public static HttpRequest SendSMSOneToMany(String SMSType, List<shortMessageWrp> shortMessages)
    {
        //Get API Details
        SMS_Types__mdt smsTypeAPI = [SELECT Dlt_Content_Id__c,Unicode__c, SMS_Name__c, Sender__c, SMS_Template_long__c FROM SMS_Types__mdt WHERE MasterLabel =: SMSType];
        
        //Get Auth Details
        //SMS_API_Setup__mdt auth = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt][0];
        SMS_API_Setup__mdt auth = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt where DeveloperName='SMS_API'];
        String jsonData;

        //Generating the JSON
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('credentials');
        gen.writeStartObject();
     /*
       //ModifiedbyRajashekar as testclass is failing if values are null
        if(Test.isRunningTest()){
            if(auth.Username__c != null){
                gen.writeStringField('user', auth.Username__c);
            }
            if(auth.Password__c != null){
                gen.writeStringField('password', auth.Password__c);
            }
            if(smsTypeAPI.Sender__c != null){
                gen.writeStringField('from', smsTypeAPI.Sender__c);
            }
        }
        else{
              gen.writeStringField('user', auth.Username__c);
              gen.writeStringField('password', auth.Password__c);
              gen.writeStringField('from', smsTypeAPI.Sender__c);
        }
        //endshere */
        
        gen.writeStringField('user', auth.Username__c);
        gen.writeStringField('password', auth.Password__c);
        gen.writeEndObject();
        gen.writeStringField('from', smsTypeAPI.Sender__c);
        gen.writeFieldName('shortMessages');
        gen.writeStartArray();
        for(shortMessageWrp objShortMsg :shortMessages)
        {
            gen.writeStartObject();
            gen.writeStringField('dltContentId', smsTypeAPI.Dlt_Content_Id__c);
            gen.writeStringField('message', objShortMsg.message);//EncodingUtil.urlEncode(objShortMsg.message, 'UTF-8'));
           if(objShortMsg.recipient != null){
                gen.writeStringField('recipient', objShortMsg.recipient);
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeBooleanField('unicode', true); //changed to true by Shubham G
        gen.writeEndObject();
        jsonData = gen.getAsString();

        System.debug('jsonData=='+jsonData);
        
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setEndpoint(auth.URL__c);
        httpReq.setMethod('POST');
        //httpReq.setTimeout(120000);
        httpReq.setBody(jsonData);
        //httpRes = http.send(httpReq);

        //changes by astha 28-12-23
        // Send the HTTP request
        httpRes = new Http().send(httpReq);
        
        // Log the response
        System.debug('Response Body: ' + httpRes.getBody());
        System.debug('Response Status: ' + httpRes.getStatus());
        
        //end of changes        

        return httpReq;
    }
        
    public class shortMessageWrp
    {
        public String dltContentId;
        public String message;
        public String recipient;
    }
}