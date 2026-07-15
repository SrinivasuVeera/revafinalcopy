/**
*@description: Apex controller for single-page student admission registration. Handles email check, OTP, lead conversion, program/category fetch, application submission, and payment redirection.
* @author: GitHub Copilot
* @group: Admissions
* @version: 1.0
* @Last Modified on: 2025-10-10
* @Last Modified by: GitHub Copilot
**/
public without sharing class StudentAdmissionSinglePageController {
    /**
* @description: Checks if email exists in Contact or Lead. If found in Lead, returns Lead details. If found in Contact, returns Contact found. Otherwise, returns not found.
* @param email: Email string
* @return Map<String, Object> with keys: exists (Boolean), type (Contact/Lead/None), lead (Lead fields if found)
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> checkExistingEmail(String email) {
        Map<String, Object> result = new Map<String, Object>();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
        if (!contacts.isEmpty()) {
            result.put('exists', true);
            result.put('type', 'Contact');
            result.put('Id', contacts[0].Id);
            return result;
        }
        List<Lead> leads = [SELECT Id, FirstName, LastName, Email, Country, Phone, MobilePhone, Country_Code__c FROM Lead WHERE Email = :email LIMIT 1];
        if (!leads.isEmpty()) {
            Lead l = leads[0];
            result.put('exists', true);
            result.put('type', 'Lead');
            Map<String, Object> leadData = new Map<String, Object>{
                'Id' => l.Id,
                    'FirstName' => l.FirstName,
                    'LastName' => l.LastName,
                    'Email' => l.Email,
                    'Country' => l.Country,
                    'Phone' => l.Phone,
                    'MobilePhone' => l.MobilePhone,
                    'Country_Code__c' => l.Country_Code__c
                    };
                        result.put('lead', leadData);
            return result;
        }
        result.put('exists', false);
        result.put('type', 'None');
        return result;
    }
    
    /**
* @description: Creates a Lead, generates OTP, stores OTP on Lead, and sends OTP via SMS or Email.
* @param phoneCode: Country code string
* @param mobileNumber: Mobile number string
* @param email: Email string
* @param name: Student name
* @return Map with keys: leadId, otp (for testing only, remove in prod)
*/
    @AuraEnabled
    public static Map<String, String> sendOtp(String leadId, String phoneCode, String mobileNumber, String email) {
        Map<String, String> result = new Map<String, String>();
        
        Lead l = [SELECT Id, Email, MobilePhone, FirstName, LastName, Phone, Country_Code__c 
                  FROM Lead WHERE Id =:leadId LIMIT 1];
        System.debug('Existing Lead: ' + l);
        
        // 🔹 CASE 1: Lead has no phone — just update and continue
        if (String.isBlank(l.MobilePhone)) {
            List<Lead> duplicateLeads = [
                SELECT Id, Email,MobilePhone,Phone FROM Lead
                WHERE MobilePhone = :mobileNumber AND Id != :leadId
                LIMIT 1
            ];
            system.debug('duplicateLeads'+duplicateLeads);
            if (!duplicateLeads.isEmpty()) {
                // ⚠️ Throw a custom error for LWC to show under field
                AuraHandledException e = new AuraHandledException('DUPLICATE_MOBILE');
                e.setMessage('DUPLICATE_MOBILE');
                throw e;
            }else{
                l.MobilePhone = mobileNumber;
                l.Phone = mobileNumber;
                l.Country = phoneCode;
            }
        } else {
            // 🔹 CASE 2: Lead has same mobile number and same email → send OTP
            if (l.MobilePhone == mobileNumber && l.Email == email) {
                System.debug('Same mobile and same email - proceed');
            }else{
                AuraHandledException e = new AuraHandledException('WRONG_MOBILE');
                e.setMessage('WRONG_MOBILE');
                throw e;
            }
        }
        
        // ✅ If no duplicate — continue to OTP generation
        List<RegistrationFormUtility.UtilityResponse> respNew = RegistrationFormUtility.generateOTP();
        String otpNew = respNew.size() > 0 ? respNew[0].generatedOTP : null;
        DateTime otpValidTillNew = System.now().addMinutes(10);
        
        if (phoneCode == 'India (+91)' || phoneCode == '+91') {
            l.Mobile_OTP_Code__c = otpNew;
            l.Mobile_OTP_Expiration__c = otpValidTillNew;
            l.Mobile_OTP_Verified__c = false;
        } else {
            l.Email_OTP_Code__c = otpNew;
            l.Email_OTP_Expiration__c = otpValidTillNew;
            l.Mobile_OTP_Verified__c = false;
        }
        
        update l;
        
        if (phoneCode == 'India (+91)' || phoneCode == '+91') {
            String expiryTime = otpValidTillNew.format('hh:mm a');
            RegistrationFormUtility.futureSMS(
                'OTP', mobileNumber, new List<String>{l.FirstName, otpNew, expiryTime}
            );
        } else {
            RegistrationFormUtility.sendEmailOtpLead(l.Id);
        }
        
        result.put('leadId', l.Id);
        result.put('otp', otpNew);
        return result;
    }
    
    
    @AuraEnabled
    public static Map<String, String> sendEmailOtp(String email, String firstName, String lastName,
                                                   String utmSource,
                                                   String utmMedium,
                                                   String utmCampaign
                                                   // String utmTerm,
                                                   // String utmContent
                                                  ) {
                                                      Map<String, String> result = new Map<String, String>();
                                                      
                                                      // ✅ 1. Check existing Contact first
                                                      List<Contact> contacts = [
                                                          SELECT Id, Email 
                                                          FROM Contact 
                                                          WHERE Email = :email 
                                                          LIMIT 1
                                                      ];
                                                      
                                                      if (!contacts.isEmpty()) {
                                                          Contact existingContact = contacts[0];
                                                          // Generate OTP
                                                          List<RegistrationFormUtility.UtilityResponse> resp = RegistrationFormUtility.generateOTP();
                                                          String otp = (resp.size() > 0) ? resp[0].generatedOTP : null;
                                                          DateTime otpValidTill = System.now().addMinutes(10);
                                                          
                                                          existingContact.Revisit_OTP_Code__c = otp;
                                                          existingContact.Revisit_OTP_Expiration__c = otpValidTill;
                                                          update existingContact;
                                                          
                                                          // Send OTP email to existing contact
                                                          RegistrationFormUtility.sendEmailRevisitOtpContact(existingContact.Id);
                                                          
                                                          result.put('leadId', existingContact.Id);
                                                          result.put('otp', otp);
                                                          return result;
                                                      }
                                                      
                                                      // ✅ 2. Check if a Lead with this email already exists
                                                      List<Lead> leads = [
                                                          SELECT Id 
                                                          FROM Lead 
                                                          WHERE Email = :email 
                                                          LIMIT 1
                                                      ];
                                                      
                                                      if (!leads.isEmpty()) {
                                                          Lead existingLead = leads[0];
                                                          // Generate new OTP
                                                          List<RegistrationFormUtility.UtilityResponse> resp = RegistrationFormUtility.generateOTP();
                                                          String otp = (resp.size() > 0) ? resp[0].generatedOTP : null;
                                                          DateTime otpValidTill = System.now().addMinutes(10);
                                                          
                                                          existingLead.Revisit_OTP_Code__c = otp;
                                                          existingLead.Revisit_OTP_Expiration__c = otpValidTill;
                                                          update existingLead;
                                                          
                                                          // Send revisit OTP email
                                                          RegistrationFormUtility.sendEmailRevisitOtpLead(existingLead.Id);
                                                          
                                                          result.put('leadId', existingLead.Id);
                                                          result.put('otp', otp);
                                                          return result;
                                                      }
                                                      
                                                      /* // ✅ 3. If no existing Contact or Lead → Create a brand new Lead
Lead newLead = new Lead();
newLead.FirstName = firstName;
newLead.LastName = (String.isNotBlank(lastName)) ? lastName : (String.isNotBlank(firstName) ? firstName : 'Student');
newLead.Email = email;
newLead.Status = 'Unverified';
newLead.LeadSource = 'Web';
newLead.Company = 'Self';

// ✅ UTM fields
newLead.UTM_Source__c   = utmSource;
newLead.UTM_Medium__c   = utmMedium;
newLead.UTM_Campaign__c = utmCampaign;
newLead.Primary_Source__c     = utmSource;
// newLead.UTM_Content__c  = utmContent;

// Generate OTP
List<RegistrationFormUtility.UtilityResponse> respNew = RegistrationFormUtility.generateOTP();
String otpNew = (respNew.size() > 0) ? respNew[0].generatedOTP : null;
DateTime otpValidTillNew = System.now().addMinutes(10);

newLead.Email_OTP_Code__c = otpNew;
newLead.Email_OTP_Expiration__c = otpValidTillNew;

//insert newLead;

// Send OTP email to new lead
RegistrationFormUtility.sendEmailOtpLead(newLead.Id);

result.put('leadId', newLead.Id);
result.put('otp', otpNew);
return result; */
                                                      throw new AuraHandledException('Lead not found. Please submit the form first.');
                                                  }
    
    /**
* @description: Verifies OTP for a Lead and converts to Contact if valid.
* @param leadId: Lead Id
* @param otp: OTP entered by user
* @return Boolean: true if OTP is valid and conversion successful
*/
    @AuraEnabled
    public static Boolean verifyOtp(String leadId, String otp) {
        Lead l = [SELECT Id, Mobile_OTP_Code__c, Mobile_OTP_Expiration__c, Mobile_OTP_Verified__c, Revisit_OTP_Code__c, Revisit_OTP_Expiration__c, Email_OTP_Code__c, Email_OTP_Expiration__c FROM Lead WHERE Id = :leadId LIMIT 1];
        Boolean valid = false;
        Boolean emailValid = false;
        // Check revisit OTP first if present and not expired
        if (l.Revisit_OTP_Code__c != null && l.Revisit_OTP_Expiration__c != null && l.Revisit_OTP_Code__c == otp && l.Revisit_OTP_Expiration__c > System.now()) {
            valid = true;
        } else if (l.Mobile_OTP_Code__c == otp && l.Mobile_OTP_Expiration__c > System.now()) {
            valid = true;
        } 
        
        if (valid) {
            l.Mobile_OTP_Verified__c = true;
            l.Status = 'Verified';
            update l;
            return true;
        }
        
        return false;
    }
    
    
    public class OTPResponse {
        @AuraEnabled public Boolean isVerified;
        @AuraEnabled public String recordType; // 'Lead' or 'Contact'
        @AuraEnabled public Id recordId;
        @AuraEnabled public String mobileNumber;
        @AuraEnabled public String phoneCode;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String school;
        @AuraEnabled public String program;
        @AuraEnabled public String category;
        @AuraEnabled public String state;
        @AuraEnabled public String country;   
        @AuraEnabled public Boolean mobOtpVerified;
        
    }
    
    @AuraEnabled
    public static OTPResponse verifyEmailOtp(Id leadId, String otp) {
        
        OTPResponse response = new OTPResponse();
        response.isVerified = false;
        response.recordType = '';
        response.recordId = leadId;
        response.mobileNumber = '';
        response.phoneCode = '';
        response.firstName = '';
        response.lastName = '';
        response.category = '';
        response.state = '';
        response.country = '';
        response.school = '';
        response.program = '';
        response.mobOtpVerified = false;
        
        SObjectType objType = leadId.getSObjectType();
        
        if(objType == Lead.SObjectType){
            List<Lead> leads = [SELECT Id, FirstName, LastName,Email_OTP_Code__c, Email_OTP_Expiration__c,Country_Code__c, MobilePhone,
                                Email_OTP_Verified__c,Revisit_OTP_Code__c, Revisit_OTP_Expiration__c,School_Name__c, Program_Name_Display__c,
                                Program_Batch__c, Category__c, State__c, Country__c,Mobile_OTP_Verified__c
                                FROM Lead WHERE Id = :leadId LIMIT 1];
            
            if (!leads.isEmpty()) {
                
                Lead l = leads[0];
                
                if (
                    (l.Email_OTP_Code__c == otp && l.Email_OTP_Expiration__c > System.now()) ||
                    (l.Revisit_OTP_Code__c != null &&
                     l.Revisit_OTP_Expiration__c != null &&
                     l.Revisit_OTP_Code__c == otp &&
                     l.Revisit_OTP_Expiration__c > System.now())
                ) {
                    
                    l.Email_OTP_Verified__c = true;
                    update l;
                    
                    response.isVerified = true;
                    response.recordType = 'Lead';
                    response.mobileNumber = l.MobilePhone;
                    response.phoneCode = l.Country_Code__c;
                    response.firstName = l.FirstName;
                    response.lastName = l.LastName;
                    response.school = l.School_Name__c;
                    response.program = l.Program_Name_Display__c;
                    response.category = l.Category__c;
                    response.state = l.State__c;
                    response.country = l.Country__c;
                    response.mobOtpVerified = l.Mobile_OTP_Verified__c;
                    
                    return response;
                }
            }
        }
        
        if(objType == Contact.SObjectType){
            
            List<Contact> contacts = [SELECT Id, FirstName, LastName,Revisit_OTP_Code__c,Revisit_OTP_Expiration__c,Application_Fee_Paid__c
                                      FROM Contact WHERE Id = :leadId LIMIT 1];
            
            if (!contacts.isEmpty()) {
                
                Contact c = contacts[0];
                
                if (c.Revisit_OTP_Code__c == otp &&
                    c.Revisit_OTP_Expiration__c > System.now()) {
                        
                        response.isVerified = true;
                        response.firstName = c.FirstName;
                        response.lastName = c.LastName;
                        
                        if(c.Application_Fee_Paid__c){
                            response.recordType = 'Contact_Paid';
                        }
                        else{
                            response.recordType = 'Contact';
                        }
                        
                        return response;
                    }
            }
        }
        
        return response;
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSchoolProgramCategoryData() {
        Map<String, Object> data = new Map<String, Object>();
        // Use Lead.Category__c picklist for categories
        List<Map<String, String>> categoryOptions = new List<Map<String, String>>();
        Schema.DescribeFieldResult catField = Lead.Category__c.getDescribe();
        for (Schema.PicklistEntry entry : catField.getPicklistValues()) {
            categoryOptions.add(new Map<String, String>{
                'label' => entry.getLabel(),
                    'value' => entry.getValue()
                    });
        }
        data.put('categories', categoryOptions);
        return data;
    }
    
    @AuraEnabled
    public static Id submitApplication(Map<String, Object> studentData) {
        
        String leadId = (String)studentData.get('leadId');
        
        
        if (String.isBlank(leadId)) {
            
            String email = (String)studentData.get('email');
            String mobile = (String)studentData.get('mobileNumber');
            
            String duplicateResult = NewLeadCreation.checkDuplicate(email, mobile);

            if (duplicateResult != 'OK') {
                throw new AuraHandledException(duplicateResult);
            }
            
            Lead newLead = new Lead();
            
            newLead.FirstName = (String)studentData.get('firstName');
            newLead.LastName  = (String)studentData.get('lastName');
            newLead.Email     = email;
            
            if(studentData.containsKey('mobileNumber')){
                newLead.MobilePhone = String.valueOf(studentData.get('mobileNumber'));
                newLead.Phone       = String.valueOf(studentData.get('mobileNumber'));
            }
            
            if(studentData.containsKey('phoneCode')){
                newLead.Country_Code__c = String.valueOf(studentData.get('phoneCode'));
            }
            
            if(studentData.containsKey('category')){
                newLead.Category__c = String.valueOf(studentData.get('category'));
            }
            
            if(studentData.containsKey('state')){
                newLead.State__c = String.valueOf(studentData.get('state'));
            }
            
            if(studentData.containsKey('country')){
                newLead.Country__c = String.valueOf(studentData.get('country'));
            }
            
            if(studentData.containsKey('school')){
                newLead.School__c = String.valueOf(studentData.get('school'));
            }
            
            if(studentData.containsKey('program')){
                newLead.Program_Name_Display__c = String.valueOf(studentData.get('program'));
            }
            
            newLead.Status = 'Unverified';
            newLead.LeadSource = 'Web';
            newLead.Company = 'Self';
            String utmSource   = (String)studentData.get('utmSource');
            String utmMedium   = (String)studentData.get('utmMedium');
            String utmCampaign = (String)studentData.get('utmCampaign');
            
            // Only populate when values exist
            if(String.isNotBlank(utmSource)){
                newLead.UTM_Source__c = utmSource;
                newLead.Primary_Source__c = utmSource;
            }
            
            if(String.isNotBlank(utmMedium)){
                newLead.UTM_Medium__c = utmMedium;
            }
            
            if(String.isNotBlank(utmCampaign)){
                newLead.UTM_Campaign__c = utmCampaign;
            }
            
            insert newLead;
            
            return newLead.Id;
        }
        
        Lead leadCheck = [SELECT Id, IsConverted, ConvertedContactId 
                          FROM Lead 
                          WHERE Id = :leadId 
                          LIMIT 1];
        
        if (leadCheck.IsConverted) {        
            return leadCheck.ConvertedContactId;
        }
        
        Lead leadToUpdate = [
            SELECT Id, Category__c, LeadSource, Country__c, State__c, School__c, 
            Country_Code__c, MobilePhone, Program_Name_Display__c, Program_Batch__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
        
        Boolean changed = false;
        
        if (studentData.containsKey('phoneCode') && studentData.get('phoneCode') != null) {
            leadToUpdate.Country_Code__c = String.valueOf(studentData.get('phoneCode'));
            changed = true;
        }
        
        if (studentData.containsKey('source') && studentData.get('source') != null) {
            leadToUpdate.LeadSource = String.valueOf(studentData.get('source'));
            changed = true;
        }
        
        if (studentData.containsKey('mobileNumber') && studentData.get('mobileNumber') != null) {
            leadToUpdate.MobilePhone = String.valueOf(studentData.get('mobileNumber'));
            changed = true;
        }
        
        if (studentData.containsKey('category') && studentData.get('category') != null) {
            leadToUpdate.Category__c = String.valueOf(studentData.get('category'));
            changed = true;
        }
        
        if (studentData.containsKey('country') && studentData.get('country') != null) {
            leadToUpdate.Country__c = String.valueOf(studentData.get('country'));
            changed = true;
        }
        
        if (studentData.containsKey('state') && studentData.get('state') != null) {
            leadToUpdate.State__c = String.valueOf(studentData.get('state'));
            changed = true;
        }
        
        if (studentData.containsKey('school') && studentData.get('school') != null) {
            leadToUpdate.School__c = String.valueOf(studentData.get('school'));
            changed = true;
        }
        
        if (studentData.containsKey('program') && studentData.get('program') != null) {
            leadToUpdate.Program_Name_Display__c = String.valueOf(studentData.get('program'));
            changed = true;
        }
        
        if (changed) {
            update leadToUpdate;
        }
        
        // Call utility to update Program_Batch__c, Application_Number__c
        RegistrationFormUtility.updateLeadPriorConversion(leadId);
        
        // Determine Fee Master Category
        String feeMasterCategory;
        
        if (leadToUpdate.Category__c == 'Karnataka' || leadToUpdate.Category__c == 'Non-Karnataka') {
            feeMasterCategory = 'Indian (SAARC)';
        } else {
            feeMasterCategory = leadToUpdate.Category__c;
        }
        
        String schoolName = leadToUpdate.School__c;
        
        // Query Fee Master
        List<Fee_Master__c> feeMasters = [
            SELECT Id
            FROM Fee_Master__c
            WHERE Program_Name_Display__c = :leadToUpdate.Program_Name_Display__c
            AND School_Name__c LIKE :('%' + schoolName + '%')
            AND Applicant_Category__c = :feeMasterCategory
            AND IsActive__c = true
            AND (
                (Program_Batch__r.Name LIKE '%2022%' OR Application_Number_Prefix__c LIKE '24%')
                OR (Program_Batch__r.Name LIKE '%2023%' OR Application_Number_Prefix__c LIKE '24%')
                OR Program_Batch__r.Name != null
                OR Application_Number_Prefix__c != null
            )
            AND Fee_Type__c = 'Application Fee'
            ORDER BY Application_Number_Prefix__c DESC
        ];
        
        String fmID = '';
        
        if (!feeMasters.isEmpty()) {
            fmID = feeMasters[0].Id;
        }
        
        // Convert Lead
        List<RegistrationFormUtility.UtilityResponse> resp =
            RegistrationFormUtility.convertLead(leadId, fmID);
        
        if (resp != null && resp.size() > 0 && resp[0].applicantContactId != null) {
            
            Id contactId = resp[0].applicantContactId;
            
            General_Setting__mdt pucSetting = [
                SELECT Boolean_Value__c
                FROM General_Setting__mdt
                WHERE DeveloperName = 'PUC_Drive'
                LIMIT 1
            ];
            
            if (pucSetting != null && pucSetting.Boolean_Value__c == true) {
                
                Contact con = [
                    SELECT Id, MobilePhone
                    FROM Contact
                    WHERE Id = :contactId
                ];
                
                List<PUC_Drive_Data__c> pucData = [
                    SELECT Id
                    FROM PUC_Drive_Data__c
                    WHERE Mobile_Number__c = :con.MobilePhone
                    LIMIT 1
                ];
                
                if (!pucData.isEmpty()) {
                    
                    RegistrationFormUtility.PUCUpdateRecord(contactId);
                    
                }
                
            }
            
            return contactId;
            
        }
        
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isPUCStudent(String mobileNumber) {
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
    @AuraEnabled(cacheable=true)
    public static String pucPageView() {
        // Use RegistrationFormUtility.getSiteURL() or existing logic
        return RegistrationFormUtility.getSiteURL() + '/s/pucViewPage';
    }
    @AuraEnabled(cacheable=true)
    public static String redirectToPaymentPage(Id applicationId) {
        // Use RegistrationFormUtility.getSiteURL() or existing logic
        return RegistrationFormUtility.getSiteURL() + '/s/payment-page?contactId=' + applicationId;
    }
    
    @AuraEnabled(cacheable=true)
    public static String redirectToPaymentPageNew(Id applicationId) {
        // Use RegistrationFormUtility.getSiteURL() or existing logic
        return RegistrationFormUtility.getSiteURLNew() + '/s/payment-page?contactId=' + applicationId;
    }
    
    @AuraEnabled(cacheable=true)
    public static String redirectToApplicantPortal() {
        
        return RegistrationFormUtility.getSiteURL() + '/s/login-new';
    }
    
    /**
* @description: Returns picklist values for Lead.Country_Code__c as an array of { label, value }
*/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCountryCodePicklist() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Lead.Country_Code__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : values) {
            options.add(new Map<String, String>{
                'label' => v.getLabel(),
                    'value' => v.getValue()
                    });
        }
        return options;
    }
    // @description: Returns picklist values for Lead.LeadSource as an array of { label, value } ADDED BY Chaithanya
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getSourcePicklist() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Lead.LeadSource.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : values) {
            options.add(new Map<String, String>{
                'label' => v.getLabel(),
                    'value' => v.getValue()
                    });
        }
        return options;
    }
    
    /**
* @description: Resends OTP by generating a new code and storing in Revisit_OTP_Code__c and Revisit_OTP_Expiration__c
*/
    @AuraEnabled
    public static String resendOtp(String leadId,String phoneCode,String mobileNumber) {
        
        
        String otp;
        DateTime otpValidTill = System.now().addMinutes(10);
        List<RegistrationFormUtility.UtilityResponse> resp = RegistrationFormUtility.generateOTP();
        otp = resp.size() > 0 ? resp[0].generatedOTP : null;
        
        // Check if recordId belongs to a Lead
        List<Lead> leads = [
            SELECT Id, FirstName, MobilePhone, Email, Email_OTP_Code__c, Email_OTP_Expiration__c, 
            Mobile_OTP_Code__c, Mobile_OTP_Expiration__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
        
        if (!leads.isEmpty()) {
            Lead l = leads[0];
            
            // If it's a mobile OTP (India number)
            if ((phoneCode == 'India (+91)' || phoneCode == '+91') && l.MobilePhone != null ) {
                l.Mobile_OTP_Code__c = otp;
                l.Mobile_OTP_Expiration__c = otpValidTill;
                update l;
                
                // Format datetime for SMS
                String expiryTime = otpValidTill.format('hh:mm a');
                
                // Send SMS
                RegistrationFormUtility.futureSMS(
                    'OTP',
                    l.MobilePhone,
                    new List<String>{l.FirstName, otp, expiryTime}
                );
            } else {
                // Otherwise, handle Email OTP
                l.Email_OTP_Code__c = otp;
                l.Email_OTP_Expiration__c = otpValidTill;
                update l;
                
                // Use your existing method to send Email OTP
                RegistrationFormUtility.sendEmailOtpLead(l.Id);
            }
            
            return otp;
        }
        
        // If not a Lead, check if it's a Contact
        List<Contact> contacts = [
            SELECT Id, FirstName, Email, MobilePhone, Revisit_OTP_Code__c, Revisit_OTP_Expiration__c
            FROM Contact
            WHERE Id = :leadId
            LIMIT 1
        ];
        
        if (!contacts.isEmpty()) {
            Contact c = contacts[0];
            
            // Email OTP for Contact (optional, depending on your flow)
            c.Revisit_OTP_Code__c = otp;
            c.Revisit_OTP_Expiration__c = otpValidTill;
            update c;
            
            RegistrationFormUtility.sendEmailRevisitOtpContact(c.Id);
            
            
            return otp;
        }
        return null;
    }
    
    /**
* @description: Returns picklist values for Lead.State__c as an array of { label, value }
*/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getStatePicklist() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Lead.State__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : values) {
            options.add(new Map<String, String>{
                'label' => v.getLabel(),
                    'value' => v.getValue()
                    });
        }
        return options;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCountryPicklist() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = Lead.Country__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry v : values) {
            options.add(new Map<String, String>{
                'label' => v.getLabel(),
                    'value' => v.getValue()
                    });
        }
        return options;
    }
    
    /**
* @description: Returns a small wrapper with contact info needed by the LWC UI
* @param contactId: Contact Id
* @return ContactInfo with programBatchName, schoolName, applicationNumber
*/
    public class ContactInfo {
        @AuraEnabled public String programBatchName;
        @AuraEnabled public String schoolName;
        @AuraEnabled public String applicationNumber;
    }
    
    @AuraEnabled(cacheable=true)
    public static ContactInfo getContactInfo(Id contactId) {
        ContactInfo info = new ContactInfo();
        if (contactId == null) return info;
        try {
            Contact c = [SELECT Id, Application_Number__c, Program_Batch__r.Name, School__r.Name FROM Contact WHERE Id = :contactId LIMIT 1];
            info.programBatchName = (c.Program_Batch__r != null) ? c.Program_Batch__r.Name : null;
            info.schoolName = (c.School__r != null) ? c.School__r.Name : null;
            info.applicationNumber = c.Application_Number__c;
        } catch (Exception ex) {
            // swallow exceptions to avoid breaking client flows; return empty info
            System.debug('getContactInfo error: ' + ex.getMessage());
        }
        return info;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getNameByEmail(String email) {
        Map<String, String> result = new Map<String, String>();
        
        // Check Lead
        List<Lead> leads = [
            SELECT FirstName, LastName
            FROM Lead
            WHERE Email = :email
            LIMIT 1
        ];
        
        if (!leads.isEmpty()) {
            result.put('firstName', leads[0].FirstName);
            result.put('lastName', leads[0].LastName);
            return result;
        }
        
        // Check Contact
        List<Contact> contacts = [
            SELECT FirstName, LastName
            FROM Contact
            WHERE Email = :email
            LIMIT 1
        ];
        
        if (!contacts.isEmpty()) {
            result.put('firstName', contacts[0].FirstName);
            result.put('lastName', contacts[0].LastName);
        }
        
        return result;
    }
    
}