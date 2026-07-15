@RestResource(urlMapping='/dynamicPaymentLink')
global class YAI_DynamicPaymentLink {
    
    @HttpPost
    global static YAI_Wrapper.APIResponse getPaymentLink() {
        
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response; 
        
        YAI_Wrapper.APIResponse apiResponse = new YAI_Wrapper.APIResponse();
        YAI_Wrapper.APIRequest apiRequest = new YAI_Wrapper.APIRequest();
        
        String jsonException;
        
        // Deserialize request
        String jsonString = restRequest.requestBody.toString();
        
        try{
            apiRequest = (YAI_Wrapper.APIRequest) JSON.deserialize(jsonString, YAI_Wrapper.APIRequest.class);
        }
        catch(Exception ex){
            jsonException = String.valueOf(ex.getTypeName());
        }
        
        Id leadId = apiRequest.leadOrContactId;
        String email = apiRequest.email;
        
        try{
            
            Lead lead = [SELECT Id, Category__c, School__c, Program_Name_Display__c FROM Lead WHERE Id = :leadId
                LIMIT 1
            ];
            
            RegistrationFormUtility.updateLeadPriorConversion(leadId);
            
            // Determine Fee Master Category
            String feeMasterCategory;
            
            if (lead.Category__c == 'Karnataka' || lead.Category__c == 'Non-Karnataka') {
                feeMasterCategory = 'Indian (SAARC)';
            } 
            else {
                feeMasterCategory = lead.Category__c;
            }
            
            String schoolName = lead.School__c;
            
            // Query Fee Master
            List<Fee_Master__c> feeMasters = [
                SELECT Id
                FROM Fee_Master__c
                WHERE Program_Name_Display__c = :lead.Program_Name_Display__c
                AND School_Name__c LIKE :('%' + schoolName + '%')
                AND Applicant_Category__c = :feeMasterCategory
                AND IsActive__c = true
                AND Fee_Type__c = 'Application Fee'
                ORDER BY Application_Number_Prefix__c DESC
                LIMIT 1
            ];
            
            String feeMasterId = feeMasters.isEmpty() ? null : feeMasters[0].Id;
            
            // Convert Lead
            List<RegistrationFormUtility.UtilityResponse> resp =
                RegistrationFormUtility.convertLead(lead.Id, feeMasterId);
            
            if (resp != null && !resp.isEmpty() && resp[0].applicantContactId != null) {
                
                Id contactId = resp[0].applicantContactId;
                
                // PUC Logic
                General_Setting__mdt pucSetting = [ SELECT Boolean_Value__c FROM General_Setting__mdt WHERE DeveloperName = 'PUC_Drive' LIMIT 1 ];
                
                if (pucSetting != null && pucSetting.Boolean_Value__c == true) {
                    
                    Contact con = [SELECT Id, MobilePhone FROM Contact WHERE Id = :contactId ];
                    
                    List<PUC_Drive_Data__c> pucData = [ SELECT Id FROM PUC_Drive_Data__c WHERE Mobile_Number__c = :con.MobilePhone LIMIT 1 ];
                    
                    if (!pucData.isEmpty()) {
                        RegistrationFormUtility.PUCUpdateRecord(contactId);
                    }
                }
                
                String paymentUrl = RegistrationFormUtility.getSiteURL() + '/s/payment-page?contactId=' + contactId;
                
                apiResponse.status = 'Payment Pending';
                apiResponse.siteUrl = paymentUrl;
                apiResponse.leadOrContactId = contactId;
            }
            
            restResponse.statusCode = 200;
            
        }
        catch(Exception ex){
            
            restResponse.statusCode = 500;
            apiResponse.errorDescription = ex.getMessage();
        }
        
        if (jsonException == 'System.JSONException') {
            
            restResponse.statusCode = 400;
            apiResponse.errorDescription ='Invalid Argument';
        }
        
        return apiResponse;
    }


    public static Boolean isPUCStudenttest(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }


    public static Boolean isPUCStudenttesting(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }


    public static Boolean testingisPUCStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
 public static Boolean testisPUCStudenttesting(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }

    public static Boolean isPUCtestingStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [
            SELECT Boolean_Value__c
            FROM General_Setting__mdt
            WHERE DeveloperName = 'PUC_Drive'
            LIMIT 1
        ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [
            SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
    
       public static Boolean isPUCtestStudent(String mobileNumber) {
        if (String.isBlank(mobileNumber)) return false;

        General_Setting__mdt pucSetting = [SELECT Boolean_Value__c  FROM General_Setting__mdt WHERE DeveloperName = 'PUC_Drive' LIMIT 1 ];

        if (pucSetting == null || pucSetting.Boolean_Value__c == false) {
            return false;
        }

        List<PUC_Drive_Data__c> pucData = [SELECT Id
            FROM PUC_Drive_Data__c
            WHERE Mobile_Number__c = :mobileNumber
            LIMIT 1
        ];

        return !pucData.isEmpty();
    }
}