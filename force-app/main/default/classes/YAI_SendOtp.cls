@RestResource(urlMapping='/sendOtp')
global without sharing class YAI_SendOtp {
    
    @HttpPost
    global static YAI_Wrapper.APIResponse sendOtp() {
        
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        YAI_Wrapper.APIResponse apiResponse = new YAI_Wrapper.APIResponse();
        YAI_Wrapper.APIRequest apiRequest = new YAI_Wrapper.APIRequest();
        
        
        String jsonException;
        String jsonString = restRequest.requestBody.toString();
        try {
            apiRequest = (YAI_Wrapper.APIRequest) JSON.deserialize(jsonString, YAI_Wrapper.APIRequest.class);
            
        } catch (exception ex) {
            jsonException = String.valueOf(ex.getTypeName());
            
        }
        Id leadOrContactId    = apiRequest.leadOrContactId;
        string recordId = string.valueOf(leadOrContactId);
        String otpDestination = apiRequest.otpDestination;
        List<Sobject> existingObject = new List<Sobject>();
        // Find for Lead/Contact. send RevisitOTP by email. IF Unverified or verified Send OTP by mobile/email based on CountryCode
        try{
            try{
                
                Contact con = [Select Id, Name from Contact where Id=:leadOrContactId Limit 1];
                existingObject.add(con);
                
                System.debug('Contact'+existingObject);
            }
            catch (Exception ex){
                system.debug(ex.getMessage());
            }
            if(existingObject.isEmpty()){
                
                Lead lead = [Select id,Name,status from Lead where Id=:leadOrContactId Limit 1];
                System.debug('Lead'+lead);
                existingObject.add(lead);
                System.debug('Lead'+existingObject);
            }else{
                system.debug('No Found');
                
            } 
        }
        catch(exception ex){
            system.debug(ex.getMessage());
        }
        
        
        if(existingObject.size()>0){
            
            if(otpDestination == 'mobile'){
                system.debug('GOINGIN');
                Lead newMobileLead = [Select Id,MobilePhone, Mobile_OTP_Code__c, Mobile_OTP_Expiration__c from Lead Where id =: leadOrContactId Limit 1];
                List < RegistrationFormUtility.UtilityResponse > uResponses = RegistrationFormUtility.generateOTP();
                newMobileLead.Mobile_OTP_Code__c = uResponses[0].generatedOTP;
                newMobileLead.Mobile_OTP_Expiration__c = uResponses[0].otpValidTill;
                update newMobileLead;
                string registrationOTPPurpose = (string)[Select Text_Value__c From General_Setting__mdt Where DeveloperName = 'Registration_SMS_OTP_Purpose'
                                                         Limit 1].Text_Value__c;
                List < String > requiredVariables = new List < String > {
                    uResponses[0].generatedOTP,
                        registrationOTPPurpose,
                        String.valueOf(uResponses[0].otpValidTill)
                        };
                            RegistrationFormUtility.futureSMS('OTP', newMobileLead.MobilePhone, requiredVariables);
                
            }
            
            
            else if (otpDestination == 'email' && String.valueOf(existingObject[0].id.getsobjecttype())=='Lead' &&  existingObject[0].get('status')=='UnVerified'){
                Lead newEmailLeadOtp = [Select Id,email, Email_OTP_Code__c, Email_OTP_Expiration__c from Lead Where id =: leadOrContactId Limit 1];
                List < RegistrationFormUtility.UtilityResponse > uResponses = RegistrationFormUtility.generateOTP();
                newEmailLeadOtp.Email_OTP_Code__c = uResponses[0].generatedOTP;
                newEmailLeadOtp.Email_OTP_Expiration__c = uResponses[0].otpValidTill;
                update newEmailLeadOtp;
                //apiResponse.leadRec = newEmailLeadOtp.Id;
                List < Messaging.SingleEmailMessage > emailOtp = new List < Messaging.SingleEmailMessage > ();
                EmailTemplate otpEmailTemplate = [Select id, Subject, Body From EmailTemplate Where DeveloperName = 'OTP_Template'];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(otpEmailTemplate.Id);
                mail.setTargetObjectId(newEmailLeadOtp.Id);
                Id OrgwideEmailAddressId =(id)[select id, Address, DisplayName from OrgWideEmailAddress where DisplayName='REVA Alerts'].id;
                mail.setOrgWideEmailAddressId(OrgwideEmailAddressId);
                emailOtp.add(mail);
                if (!emailOtp.isEmpty()) {
                    Messaging.sendEmail(emailOtp);
                    
                }
            } 
            else if (otpDestination == 'email' && String.valueOf(existingObject[0].id.getsobjecttype())=='Lead') {
                system.debug('GOING IN');
                
                RegistrationFormUtility.sendEmailRevisitOtpLead(recordId);
            }
            
            else if (otpDestination == 'email' && String.valueOf(existingObject[0].id.getsobjecttype())=='Contact'){
                
                RegistrationFormUtility.sendEmailRevisitOtpContact(recordId);
                
            }  
            
            
            apiResponse.status='success';
            restResponse.statusCode=200;
        }
        
        
        
        
        if (jsonException == 'System.JSONException') {
            
            restResponse.statusCode = 400;
            apiResponse.errorDescription = 'Invalid Argument';
            return apiResponse;
        }
        return apiResponse;
    }
    
    
    
}