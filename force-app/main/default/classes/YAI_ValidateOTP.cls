@RestResource(urlMapping='/validateOtp')
global with sharing class YAI_ValidateOTP {
    
    @HttpPost
    global static YAI_Wrapper.APIResponse validateOtp() {
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response; 
        YAI_Wrapper.APIResponse apiResponse = new YAI_Wrapper.APIResponse();
        YAI_Wrapper.APIRequest apiRequest = new YAI_Wrapper.APIRequest();
        
        String jsonException;
        String SobjectType;
        
        //retrieve the requestBody and deserialize the json
        String jsonString = restRequest.requestBody.toString();
        try{
            apiRequest = (YAI_Wrapper.APIRequest) JSON.deserialize(jsonString, YAI_Wrapper.APIRequest.class);
        }
        catch(exception ex){
            jsonException = String.valueOf(ex.getTypeName());
            
        }        
        system.debug(apiRequest);
        //fetch all the values from the deserialized json.
        Id leadOrContactId    = apiRequest.leadOrContactId;
        string otpText = apiRequest.otpText;
        String validationType = apiRequest.validationType;
        system.debug('leadOrContactId' +leadOrContactId);
        List<Sobject> existingObject = new List<Sobject>();
       
		// Find Lead/Contact Record. 
       try{
            try{
                
                	contact con = [Select Id, Name, Revisit_OTP_Expiration__c, Revisit_OTP_Code__c from contact where Id=:leadOrContactId Limit 1];
                	System.debug('Contact'+con);
               		existingObject.add(con);
               
            	}
            	catch (Exception ex){
                	system.debug(ex.getMessage());
           		}
            if(existingObject.isEmpty()){
                
                Lead lead = [Select id,status,Country_Code__c,Mobile_OTP_Code__c,Mobile_OTP_Expiration__c,Revisit_OTP_Expiration__c,Revisit_OTP_Code__c,Email_OTP_Code__c,Email_OTP_Expiration__c from Lead where Id=:leadOrContactId Limit 1];
                existingObject.add(lead);
                System.debug('Lead'+lead);
            }           
            
        }
        catch (Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            system.debug(ex.getTypeName());
        } 
        
        if(existingObject.size()>0){
            if(String.valueOf(existingObject[0].id.getsobjecttype())=='Contact' && validationType=='Revisit'){
                
                dateTime expirationDateTime = (dateTime)[select Id,Revisit_OTP_Expiration__c from contact where Id =:existingObject[0].id].Revisit_OTP_Expiration__c;
                
                if(existingObject[0].get('Revisit_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime>System.now()){
                    apiResponse.status='valid';
                } else if(existingObject[0].get('Revisit_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime<System.now()){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'expired';
                }else if(existingObject[0].get('Revisit_OTP_Code__c') !=  apiRequest.otpText){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'mismatch';
                }
                
            }
            else if(String.valueOf(existingObject[0].id.getsobjecttype())=='Lead' && validationType=='Revisit'){
                
                dateTime expirationDateTime = (dateTime)[select Id,Revisit_OTP_Expiration__c from lead where Id =:existingObject[0].id].Revisit_OTP_Expiration__c;
         
                if(existingObject[0].get('Revisit_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime>System.now() ){
                    apiResponse.status='valid';
                } else if(existingObject[0].get('Revisit_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime<System.now()){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'expired';
                }else if(existingObject[0].get('Revisit_OTP_Code__c') !=  apiRequest.otpText){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'mismatch';
                }
                
            }
            else if(String.valueOf(existingObject[0].id.getsobjecttype())=='Lead' && validationType=='New'&& existingObject[0].get('Country_Code__c')=='India (+91)'){
                                
                dateTime expirationDateTime = (dateTime)[select Id,Mobile_OTP_Expiration__c from lead where Id =:existingObject[0].id].Mobile_OTP_Expiration__c;

                if(existingObject[0].get('Mobile_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime>System.now()){
                    apiResponse.status='valid';
                } else if(existingObject[0].get('Mobile_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime<System.now()){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'expired';
                }else if(existingObject[0].get('Mobile_OTP_Code__c') !=  apiRequest.otpText){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'mismatch';
                }
                
            }
            else if(String.valueOf(existingObject[0].id.getsobjecttype())=='Lead' && validationType=='New'&& existingObject[0].get('Country_Code__c')!='India (+91)'){
              
                dateTime expirationDateTime = (dateTime)[select Id,Email_OTP_Expiration__c from lead where Id =:existingObject[0].id].Email_OTP_Expiration__c;
                
                if(existingObject[0].get('Email_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime>System.now()){
                    apiResponse.status='valid';
                } else if(existingObject[0].get('Email_OTP_Code__c') ==  apiRequest.otpText && expirationDateTime<System.now()){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'expired';
                }else if(existingObject[0].get('Email_OTP_Code__c') !=  apiRequest.otpText){
                    apiResponse.status = 'invalid';
                    apiResponse.reason = 'mismatch';
                }
                
            }
            
            restResponse.statusCode = 200;
        }
        
        
        else if (jsonException == 'System.JSONException') {
            
            restResponse.statusCode = 400;
            apiResponse.errorDescription ='Invalid Argument';
        }
        
        return apiResponse;
    }
}