@RestResource(urlMapping='/checkApplicant')
global with sharing class YAI_CheckApplicant {
    
    
    @HttpPost
    global static YAI_Wrapper.APIResponse checkApplicant() {
        
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response; 
        YAI_Wrapper.APIResponse apiResponse = new YAI_Wrapper.APIResponse();
        YAI_Wrapper.APIRequest apiRequest = new YAI_Wrapper.APIRequest();
        
        String jsonException;
        String SobjectType;
        String applicationStatus;
        
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
        String inputEmail = apiRequest.email;
        //there are so many contacts without email they are being fetched for null and invalid JSON format should be removed while giving it to yellow AI team.
        if(apiRequest.email==null){
            inputEmail='testemail@YAI.com';
        }
       
        
        
        List<Sobject> existingObject = new List<Sobject>();
        //do the stuff - Find for Lead/Contact. send RevisitOTP by email. IF Unverified Send OTP by mobile/email based on CountryCode
        try{
            try{
                
                contact existingContact = [Select Id, Name, Application_Fee_Paid__c,record_type_name__c From contact 
                               				Where Email = : inputEmail Limit 1];
               
                existingObject.add(existingContact);
               
              
                system.debug(existingContact);
                if(existingContact.Application_Fee_Paid__c == false){
                    applicationStatus = 'Application Fee Not Paid';
                }
               /* else if(existingContact.Application_Fee_Paid__c == true) {
                    applicationStatus = 'Application Fee Paid';
                }*/
                else if(existingContact.record_type_name__c  =='Applicant'){
                     hed__Application__c application =[select hed__Application_Status__c from 
                                                      hed__Application__c where hed__Applicant__c =:existingContact.Id]; 
                     applicationStatus = application.hed__Application_Status__c ;
                     system.debug('application====>'+applicationStatus);
                }
                    
                System.debug('Contact'+existingObject);
            }
            catch (Exception ex){
                system.debug(ex.getMessage());
            }
            if(existingObject.isEmpty()){
                
                lead existingLead = [Select Id, Name, Status From Lead 
                             Where Email = : inputEmail Limit 1];
                existingObject.add(existingLead);
                System.debug('Lead'+existingObject);
                applicationStatus = existingLead.Status;
            }else{
                system.debug('Not Found');
                
            }
            
        }
        catch (Exception ex){
            system.debug(ex.getMessage());
        }
        
        //set the apiResponse before sending
        if(existingObject.size()>0){
            apiResponse.found = true;//only if found. if not false
            apiResponse.leadOrContactId = existingObject[0].id;
            /*if(String.valueOf(existingObject[0].id.getsobjecttype())=='Lead'){
                 RegistrationFormUtility.sendEmailRevisitOtpLead(existingObject[0].id);
            }
            else if(String.valueOf(existingObject[0].id.getsobjecttype())=='Contact'){
                RegistrationFormUtility.sendEmailRevisitOtpContact(existingObject[0].id);
            }*/
            apiResponse.status = applicationStatus;
            SobjectType = String.valueOf(existingObject[0].id.getsobjecttype());
            restResponse.statusCode = 200;
            return apiResponse;
        }
        
        else if(jsonException=='System.JSONException'){
            restResponse.statusCode = 400;
            apiResponse.errorDescription = 'Invalid Argument';
            return apiResponse;
        }
        else {
            apiResponse.found = false;//only if found. if not false
            apiResponse.leadOrContactId = null;
            restResponse.statusCode = 400;
            apiResponse.errorDescription = 'Not Found';
            return apiResponse;
        }
        
    }
}