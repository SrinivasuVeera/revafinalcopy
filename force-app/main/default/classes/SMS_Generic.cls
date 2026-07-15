public with sharing class SMS_Generic {
    public static final String SMS_APISETUP_RECORD ='SMS_Applicant';
    public static String sendNumber;
    public static HttpResponse sendSMS (String smsType, String sendToNumber, List<String> dynamicVars) {
        System.debug('inside sms generic sendsms');
        //Cross check for country code in the number and then send the sms
        if(sendToNumber.contains('-')){
            sendToNumber = sendToNumber.remove('-');
        }
        else{
            sendToNumber = sendToNumber;
        }
        System.debug('smsType --> '+smsType);
        System.debug('sendToNumber --> '+sendToNumber);
        System.debug('dynamicVars --> '+dynamicVars);
        //authorizing username and password from metadata
        SMS_API_Setup__mdt auth = [SELECT Username__c, Password__c, URL__c FROM SMS_API_Setup__mdt WHERE DeveloperName =:SMS_APISETUP_RECORD];
        String username=auth.Username__c;
        String password=auth.Password__c;
        String strURL=auth.URL__c;
        String unicode='False';
        //featching data from org 
        SMS_Types__mdt smsTypeAPI = [SELECT Dlt_Content_Id__c, Sender__c, Unicode__c, SMS_Template__c, SMS_Template_long__c FROM SMS_Types__mdt WHERE DeveloperName =:smsType];
        String varSMSTemplate = smsTypeAPI.SMS_Template__c;
        String varSMSTemplateLong = smsTypeAPI.SMS_Template_long__c;
        // system.debug('varSMSTemplate '+varSMSTemplate);
        // system.debug('varSMSTemplateLong'+varSMSTemplateLong);
        String sender=smsTypeAPI.Sender__c;
        if(smsTypeAPI.Unicode__c== False){
            unicode= 'False';
            // system.debug('false');
        }
        else if (smsTypeAPI.Unicode__c== True){
            unicode= 'True';
            // system.debug('true');
       	}
        String dltContentId=smsTypeAPI.Dlt_Content_Id__c;
        String smsText = '';
        
        // checking the condition for smsType 
        if(smsType == 'Application_Number'){
            //Dynamically passes the variable to sms template text
      
            Integer applicationSearchFrom = 0;
            Integer applicationIdx = 0;
            Integer applicationOpenBracePos = varSMSTemplate.indexOf('{', applicationSearchFrom);
            while (applicationOpenBracePos != -1) {
                smsText+= varSMSTemplate.substring(applicationSearchFrom, applicationOpenBracePos) + dynamicVars[applicationIdx];
                applicationSearchFrom = varSMSTemplate.indexOf('}', applicationSearchFrom)+1;
                applicationOpenBracePos = varSMSTemplate.indexOf('{', applicationSearchFrom);
                //add increment here also it shouldnt matter much
                
            }   
            smsText+= varSMSTemplate.substring(applicationSearchFrom);   
            // system.debug('inside if '+smsText);     
        } else if(smsType == 'Reset_Password_for_Application_Portal' || smsType == 'Admission_Payment_Link' || smsType == 'Payment_Confirmation' || smsType == 'Partial_Payment_Confirmation'){   
            //Dynamically passes the variable to sms template text
            System.debug('inside constructing variables into the template text');
            Integer searchFrom = 0;
            // system.debug(smsText);
            Integer idx = 0;
            Integer openBracePos = varSMSTemplateLong.indexOf('{', searchFrom);
            while (openBracePos != -1) {
                smsText+= varSMSTemplateLong.substring(searchFrom, openBracePos) + dynamicVars[idx];
                searchFrom = varSMSTemplateLong.indexOf('}', searchFrom) + 1;
                openBracePos = varSMSTemplateLong.indexOf('{', searchFrom);
                idx++;
            }   
            smsText+= varSMSTemplateLong.substring(searchFrom);
            // system.debug('inside else if form fee confirmation '+smsText);
        } else {   
            
          
            //Dynamically passes the variable to sms template text
            Integer searchFrom = 0;
            
            Integer idx = 0;
            Integer openBracePos = varSMSTemplate.indexOf('{', searchFrom);
            while (openBracePos != -1) {
                smsText+= varSMSTemplate.substring(searchFrom, openBracePos) + dynamicVars[idx];
                searchFrom = varSMSTemplate.indexOf('}', searchFrom) + 1;
                openBracePos = varSMSTemplate.indexOf('{', searchFrom);
                idx++;
            }   
            smsText+= varSMSTemplate.substring(searchFrom);
            // system.debug('inside final else '+smsText);
        } 
        //String encodedSMS = smsText.escapeHtml4();
        
        
        if(smsText.Contains(string.ValueOf('/r'))==true){           
            string regExp = string.ValueOf('/r');
            string replacement = '\r\n' ;

             smsText = smsText.replaceAll(regExp, replacement);
            system.debug(smsText);
        }
        // else{
        //     smsText=smsText;
            // system.debug('inside smstext '+smsText);
        // } 
        
       
        
        idSMSWrapper idSMSwrap = new idSMSWrapper();
        idSMSwrap.dltContentId = dltContentId;
        
        textWrapper textSMSWrap = new textWrapper();
        // system.debug('before updating smstext is'+smsText);
        textSMSWrap.text = smsText;
        // system.debug('after updating smstext is'+textSMSWrap.text);
        textSMSWrap.recipient=sendToNumber;
        
        mainSMSWrapper mSMSWrap = new mainSMSWrapper();
        mSMSWrap.sender = sender;

        mSMSWrap.unicode = unicode;
        mSMSWrap.extra =idSMSwrap;
        mSMSWrap.message =textSMSWrap;
        // system.debug('inside final sms text is '+mSMSWrap.message);
        // system.debug('mSMSWrap'+mSMSWrap);
        String js = JSON.serialize(mSMSWrap);
        system.debug(js);
        // encoding password 
        Blob headerValue = Blob.valueOf(username+ ':' +password);
        String authHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        
        Http http = new Http();
        HttpRequest httpreq = new HttpRequest();
        HttpResponse httpres = new HttpResponse();
        httpreq.setHeader('authorization', authHeader);
        httpreq.setHeader('Content-Type', 'application/json');
        httpreq.setHeader('Accept', 'application/json');
        httpreq.setEndPoint(strURL);
        httpreq.setBody(js);
        httpreq.setMethod('POST');
        httpres = http.send(httpreq);
        System.debug('Response Body POST=='+httpRes);
        System.debug('Response Body POST=='+httpRes.getBody());
        System.debug('Response Code POST=='+httpRes.getStatusCode());
        System.debug('Response Status POST=='+httpRes.getStatus()); 
        
        return httpres;
        
    }
    Public class mainSMSWrapper{
        Public string sender;
        Public string unicode;
        Public idSMSWrapper extra;
        Public textWrapper message;
        
    }
    Public class idSMSWrapper{
        Public String templateId;
        Public String dltContentId;
        Public string corelationId;
    }
    Public class textWrapper{
        Public string recipient;
        Public string text;
    }    
}