public without sharing class NewLeadCreation {

    public static final String REVA_UNIVERSITY = 'REVA University';
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
    private static final String APPLICATION_PORTAL_NAME = 'Application_Portal_Name';

    public static String getPortalName() {
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :APPLICATION_PORTAL_NAME limit 1].Text_Value__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getSiteURL() {
        String portalName = getPortalName();
        Site mySite = [select Id from Site where Name =:portalName];
        SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId=:mySite.Id];
        system.debug(mySiteDetail);
        if(mySiteDetail.SecureURL.endswith('/')){
            return mySiteDetail.SecureURL.removeEnd('/');
        }
        return mySiteDetail.SecureUrl;
    }

    @AuraEnabled
    public static Id submitApplication(Map<String, Object> studentData) {
        
        String leadId = (String)studentData.get('leadId');
        
        
        if (String.isBlank(leadId)) {
            
            String email = (String)studentData.get('email');
            String source = (String)studentData.get('source');
            String mobile = (String)studentData.get('mobileNumber');
            Date fromDate = getDuplicateCheckDate();
            
            String result = checkDuplicate(email, mobile);

            if (result != 'OK') {
                throw new AuraHandledException(result);
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
            newLead.LeadSource = source;
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
    private static Date getDuplicateCheckDate() {
    String yearStr = [
        SELECT Text_Value__c 
        FROM General_Setting__mdt 
        WHERE DeveloperName = :ENROLMENT_YEAR_CMDT_NAME 
        LIMIT 1
    ].Text_Value__c;

    Integer enrolYear = Integer.valueOf(yearStr);

    return Date.newInstance(enrolYear, 1, 1).addMonths(-2);
}
public static String checkDuplicate(String email, String mobile) {

    Date fromDate = getDuplicateCheckDate();

    Boolean emailExists = false;
    Boolean mobileExists = false;

    // 🔹 CONTACT CHECK
    List<Contact> contacts = [
        SELECT Id, Email, Phone
        FROM Contact
        WHERE (Email = :email OR Phone = :mobile)
        AND CreatedDate >= :fromDate
    ];

    for (Contact c : contacts) {
        if (c.Email == email) emailExists = true;
        if (c.Phone == mobile) mobileExists = true;
    }

    // 🔹 LEAD CHECK
    List<Lead> leads = [
        SELECT Id, Email, Phone
        FROM Lead
        WHERE (Email = :email OR Phone = :mobile)
        AND IsConverted = false
        AND CreatedDate >= :fromDate
    ];

    for (Lead l : leads) {
        if (l.Email == email) emailExists = true;
        if (l.Phone == mobile) mobileExists = true;
    }

    // 🔥 RESULT
    if (emailExists && mobileExists) return 'EMAIL_MOBILE_EXISTS';
    if (emailExists) return 'EMAIL_EXISTS';
    if (mobileExists) return 'MOBILE_EXISTS';

    return 'OK';
}
  @AuraEnabled
public static String validateLead(String email, String mobileNumber, String phoneCode) {
    return checkDuplicate(email, mobileNumber);
}
    public static List<UtilityResponse> convertLead(String leadId, String fmID){
        
        UtilityResponse uResp = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        Lead tempLead = [select LastName, Application_Number__c,OwnerId, FirstName, Salutation, 
                         MiddleName,Country_Code__c, Category__c, Program_Name_Display__c,Description1__c 
                         from Lead where Id=:leadId];
        
        Id applicantRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account tempAccount = new Account(Name = tempLead.Application_Number__c+' - '+ tempLead.FirstName
                                          +' '+ tempLead.LastName, RecordTypeId = houseHoldRecordTypeId);
        insert tempAccount;
        
        /*Site admissionsSite = [Select Id, GuestRecordDefaultOwnerId from Site where Name=:getPortalName()];
		tempLead.OwnerId = admissionsSite.GuestRecordDefaultOwnerId;
		update tempLead; */

        Contact tempContact = new Contact(LastName = tempLead.LastName, FirstName= tempLead.firstName, OwnerId = tempLead.OwnerId, Description1__c = tempLead.Description1__c,
                                          middleName = tempLead.middleName, Salutation = tempLead.Salutation, RecordTypeId = applicantRecordTypeID, AccountId = tempAccount.Id, Country_Code__c = tempLead.Country_Code__C);
        insert tempContact;
        
        LeadStatus convertStatus = [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        Database.LeadConvert leadToBeConverted = new Database.LeadConvert();
        leadToBeConverted.setLeadId(leadId);
        leadToBeConverted.setConvertedStatus(convertStatus.MasterLabel);
        leadToBeConverted.setDoNotCreateOpportunity(true);
        leadToBeConverted.setContactId(tempContact.Id);
        leadToBeConverted.setAccountId(tempAccount.Id);
        Database.LeadConvertResult lcr=Database.convertLead(leadToBeConverted);
        
        ID contactId = lcr.getContactId(); //Default recordType for Guest User is given as Applicant
        Contact contact = [Select Program_Batch__c, Primary_Academic_Program__c,Program_Batch__r.hed__Account__r.Name, Application_Number__c,FirstName, LastName, 
                           Program_Batch__r.hed__Account__c,Program_Batch__r.hed__Account__r.ParentId, Program_Batch__r.Name, Assigned_Users__c
                           from contact where id =:contactId];
        
        contact.Primary_Academic_Program__c = contact.Program_Batch__r.hed__Account__c;
        contact.School__c = contact.Program_Batch__r.hed__Account__r.ParentId;
        
        if(contact.Assigned_Users__C != null){
            contact.OwnerId = contact.Assigned_Users__C?.right(18);
            contact.Assigned__c = true; 
        } 
        
        update contact;
        uResp.applicantContactId = contact.Id;
        
        hed__Application__c app = new hed__Application__c();
        app.hed__Applicant__c = contactId;
        app.hed__Initial_Creation_Date__c = Date.today(); //Date time the application is initially created.
        app.hed__Application_Status__c = 'Started';
        app.hed__Applying_To__c = contact.Primary_Academic_Program__c;
        app.Application_Number__c = contact.Application_Number__C;
        system.debug(app.Application_Number__c);
        insert app;
        Fee_Payment_Criteria__c fpc = new Fee_Payment_Criteria__c();
        List<Fee_payment_Criteria__c> fpcs = [select id from fee_payment_criteria__c where Name ='Application Fee - Full Payment'];
        if(fpcs.size() != 1){
            //handle error
        }else{
            fpc = fpcs[0];
        }
        
        Fee_Master__c fm;
        
        if(fmID != ''){
          fm =[select Fee_Amount__c,Application_Number_Prefix__c from Fee_Master__c  where id=:fmID];
        }else{
            if(tempLead.Category__c == 'Karnataka' || tempLead.Category__c == 'Non-Karnataka' 
               || tempLead.Category__c == 'SAARC' ){
                fm = [SELECT Fee_Amount__c,Application_Number_Prefix__c
                      FROM Fee_Master__c
                      WHERE Applicant_Category__c = 'Indian (SAARC)'
                          AND IsActive__c  = true
                     	  AND Program_Name_Display__c =: tempLead.Program_Name_Display__c
                     	  AND Fee_Type__c = 'Application Fee'];
                   
               }else if(tempLead.Category__c == 'Non-Resident Indian(NRI)'){
                   fm = [SELECT Fee_Amount__c,Application_Number_Prefix__c
                      FROM Fee_Master__c
                      WHERE Applicant_Category__c = 'Non-Resident Indian(NRI)'
                        AND IsActive__c  = true
                        AND Program_Name_Display__c =: tempLead.Program_Name_Display__c
                         AND Fee_Type__c = 'Application Fee'];
                   
               }else{
                   fm = [SELECT Fee_Amount__c,Application_Number_Prefix__c
                      FROM Fee_Master__c
                      WHERE Applicant_Category__c = 'Foreign Nationals'
                        AND IsActive__c  = true
                        AND Program_Name_Display__c =: tempLead.Program_Name_Display__c
                        AND Fee_Type__c = 'Application Fee'];
               }
        }       
        //Creation of Student Fee Record -- set description fields also
        Student_Fee__c studentFee = new Student_Fee__c();
        studentFee.Name = 'Application Fee - '+ fm.Application_Number_Prefix__c + ' - '+contact.FirstName;
        studentFee.Fee_Type__c = 'Application Fee';
        studentFee.Session__c = '1st Year';
        studentFee.Actual_Program_Fee__c = fm.Fee_Amount__c;
        studentFee.Contact__c = contactId;
        studentFee.Description__c = 'Application Fee For ' + contact.Program_Batch__r.hed__Account__r.Name;
        studentFee.Fee_Payment_Criteria__c = fpc.id;
        studentFee.Fee_Master__c = String.isNotBlank(fmID) ? (Id)fmID : null;
        studentFee.Number_of_Installments__c =1;
        studentFee.Due_Date__c = Date.Today() +365; //Sreeguru suggested to have it. Few automations are based on this field check inthe exisitng code
        studentFee.Amount__c = fm.Fee_Amount__c;
        studentFee.Amount_Paid__c =0;
        studentFee.Amount_Pending__c = fm.Fee_Amount__c;
        insert studentFee;
        
        uResponses.add(uResp);
        return uResponses;
        
    }  
     @AuraEnabled
    public static Id recsubmitApplication(Map<String, Object> studentData) {
      String leadId = (String)studentData.get('leadId');
        
        
        if (String.isBlank(leadId)) {
            
            String email = (String)studentData.get('email');
            String source = (String)studentData.get('source');
            String mobile = (String)studentData.get('mobileNumber');
            Date fromDate = getDuplicateCheckDate();
            
            String result = checkDuplicate(email, mobile);

            if (result != 'OK') {
                throw new AuraHandledException(result);
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
            Site admissionsSite = [Select Id, GuestRecordDefaultOwnerId from Site where Name=:getPortalName()];
            newLead.Status = 'Unverified';
            newLead.LeadSource = source;
            newLead.Company = 'Self';
            newLead.OwnerId = admissionsSite.GuestRecordDefaultOwnerId;
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
        List<RegistrationFormUtility.UtilityResponse> resp = RegistrationFormUtility.convertLead(leadId, fmID);
            LeadAssignmentTriggerHandler.assignCounselor( new Set<Id>{ leadToUpdate.Id });
        
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
    @AuraEnabled
    public static List<UtilityResponse> recconvertLead(String leadId, String fmID){
        
        UtilityResponse uResp = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        Lead tempLead = [select LastName, Application_Number__c,OwnerId, FirstName, Salutation, 
                         MiddleName,Country_Code__c, Category__c, Program_Name_Display__c,Description1__c 
                         from Lead where Id=:leadId];
        
        Id applicantRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account tempAccount = new Account(Name = tempLead.Application_Number__c+' - '+ tempLead.FirstName
                                          +' '+ tempLead.LastName, RecordTypeId = houseHoldRecordTypeId);
        insert tempAccount;
        
        /*Site admissionsSite = [Select Id, GuestRecordDefaultOwnerId from Site where Name=:getPortalName()];
		tempLead.OwnerId = admissionsSite.GuestRecordDefaultOwnerId;
		update tempLead; */

        Contact tempContact = new Contact(LastName = tempLead.LastName, FirstName= tempLead.firstName, OwnerId = tempLead.OwnerId, Description1__c = tempLead.Description1__c,
                                          middleName = tempLead.middleName, Salutation = tempLead.Salutation, RecordTypeId = applicantRecordTypeID, AccountId = tempAccount.Id, Country_Code__c = tempLead.Country_Code__C);
        insert tempContact;
        
        LeadStatus convertStatus = [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        Database.LeadConvert leadToBeConverted = new Database.LeadConvert();
        leadToBeConverted.setLeadId(leadId);
        leadToBeConverted.setConvertedStatus(convertStatus.MasterLabel);
        leadToBeConverted.setDoNotCreateOpportunity(true);
        leadToBeConverted.setContactId(tempContact.Id);
        leadToBeConverted.setAccountId(tempAccount.Id);
        Database.LeadConvertResult lcr=Database.convertLead(leadToBeConverted);
        
        ID contactId = lcr.getContactId(); //Default recordType for Guest User is given as Applicant
        Contact contact = [Select Program_Batch__c, Primary_Academic_Program__c,Program_Batch__r.hed__Account__r.Name, Application_Number__c,FirstName, LastName, 
                           Program_Batch__r.hed__Account__c,Program_Batch__r.hed__Account__r.ParentId, Program_Batch__r.Name, Assigned_Users__c
                           from contact where id =:contactId];
        
        contact.Primary_Academic_Program__c = contact.Program_Batch__r.hed__Account__c;
        contact.School__c = contact.Program_Batch__r.hed__Account__r.ParentId;
        
        if(contact.Assigned_Users__C != null){
            contact.OwnerId = contact.Assigned_Users__C?.right(18);
            contact.Assigned__c = true; 
        } 
        
        update contact;
        uResp.applicantContactId = contact.Id;
        
        hed__Application__c app = new hed__Application__c();
        app.hed__Applicant__c = contactId;
        app.hed__Initial_Creation_Date__c = Date.today(); //Date time the application is initially created.
        app.hed__Application_Status__c = 'Started';
        app.hed__Applying_To__c = contact.Primary_Academic_Program__c;
        app.Application_Number__c = contact.Application_Number__C;
        system.debug(app.Application_Number__c);
        insert app;
        Fee_Payment_Criteria__c fpc = new Fee_Payment_Criteria__c();
        List<Fee_payment_Criteria__c> fpcs = [select id from fee_payment_criteria__c where Name ='Application Fee - Full Payment'];
        if(fpcs.size() != 1){
            //handle error
        }else{
            fpc = fpcs[0];
        }
        
        Fee_Master__c fm;
        
        if(fmID != ''){
          fm =[select Fee_Amount__c,Application_Number_Prefix__c from Fee_Master__c  where id=:fmID];
        }else{
            if(tempLead.Category__c == 'Karnataka' || tempLead.Category__c == 'Non-Karnataka' 
               || tempLead.Category__c == 'SAARC' ){
                fm = [SELECT Fee_Amount__c,Application_Number_Prefix__c
                      FROM Fee_Master__c
                      WHERE Applicant_Category__c = 'Indian (SAARC)'
                          AND IsActive__c  = true
                     	  AND Program_Name_Display__c =: tempLead.Program_Name_Display__c
                     	  AND Fee_Type__c = 'Application Fee'];
                   
               }else if(tempLead.Category__c == 'Non-Resident Indian(NRI)'){
                   fm = [SELECT Fee_Amount__c,Application_Number_Prefix__c
                      FROM Fee_Master__c
                      WHERE Applicant_Category__c = 'Non-Resident Indian(NRI)'
                        AND IsActive__c  = true
                        AND Program_Name_Display__c =: tempLead.Program_Name_Display__c
                         AND Fee_Type__c = 'Application Fee'];
                   
               }else{
                   fm = [SELECT Fee_Amount__c,Application_Number_Prefix__c
                      FROM Fee_Master__c
                      WHERE Applicant_Category__c = 'Foreign Nationals'
                        AND IsActive__c  = true
                        AND Program_Name_Display__c =: tempLead.Program_Name_Display__c
                        AND Fee_Type__c = 'Application Fee'];
               }
        }       
        //Creation of Student Fee Record -- set description fields also
        Student_Fee__c studentFee = new Student_Fee__c();
        studentFee.Name = 'Application Fee - '+ fm.Application_Number_Prefix__c + ' - '+contact.FirstName;
        studentFee.Fee_Type__c = 'Application Fee';
        studentFee.Session__c = '1st Year';
        studentFee.Actual_Program_Fee__c = fm.Fee_Amount__c;
        studentFee.Contact__c = contactId;
        studentFee.Description__c = 'Application Fee For ' + contact.Program_Batch__r.hed__Account__r.Name;
        studentFee.Fee_Payment_Criteria__c = fpc.id;
        studentFee.Fee_Master__c = String.isNotBlank(fmID) ? (Id)fmID : null;
        studentFee.Number_of_Installments__c =1;
        studentFee.Due_Date__c = Date.Today() +365; //Sreeguru suggested to have it. Few automations are based on this field check inthe exisitng code
        studentFee.Amount__c = fm.Fee_Amount__c;
        studentFee.Amount_Paid__c =0;
        studentFee.Amount_Pending__c = fm.Fee_Amount__c;
        insert studentFee;
        
        uResponses.add(uResp);
        return uResponses;
        
    }
    @AuraEnabled
public static void updateAndSendMobileOtp(Id leadId, String phoneCode, String mobileNumber, String email) {
    // 1. Update the Lead with the latest mobile number from the UI
    Lead l = new Lead(Id = leadId);
    l.Country_Code__c = phoneCode;
    l.MobilePhone = mobileNumber; 
    update l;

    // 2. Now call the existing OTP method - it will now match the DB
    StudentAdmissionSinglePageController.sendOtp(leadId, phoneCode, mobileNumber, email);
}
@AuraEnabled
public static void updateLeadBeforeOTP(Id leadId, String phoneCode, String mobileNumber) {
    try {
        Lead l = new Lead(
            Id = leadId,
            Country_Code__c = phoneCode,
            MobilePhone = mobileNumber
        );
        update l;
    } catch (Exception e) {
        throw new AuraHandledException('Update failed: ' + e.getMessage());
    }
}
@AuraEnabled
public static Map<String, String> sendEmailOtp(String email, String firstName, String lastName, String leadId) {
    Map<String, String> result = new Map<String, String>();

    Lead targetLead;

    // If we already have a LeadId from the first "Submit", use it
    if (String.isNotBlank(leadId)) {
        targetLead = [SELECT Id, Email FROM Lead WHERE Id = :leadId LIMIT 1];
        // Update the email if the user changed it in the UI before clicking Verify
        targetLead.Email = email;
    } else {
        // Fallback: Check if email already exists (Safety check)
        List<Lead> existing = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];
        if (!existing.isEmpty()) {
            targetLead = existing[0];
        } else {
            throw new AuraHandledException('Please click Submit first to create the Lead.');
        }
    }

    // Generate OTP using your utility
    List<RegistrationFormUtility.UtilityResponse> resp = RegistrationFormUtility.generateOTP();
    String otp = (resp.size() > 0) ? resp[0].generatedOTP : '123456'; // Default if utility fails
    
    targetLead.Email_OTP_Code__c = otp;
    targetLead.Email_OTP_Expiration__c = System.now().addMinutes(10);
    update targetLead;

    // Send OTP email
    RegistrationFormUtility.sendEmailOtpLead(targetLead.Id);

    result.put('leadId', targetLead.Id);
    result.put('otp', otp);
    return result;
}
 @AuraEnabled
    public static Map<String, String> recsendEmailOtp(String email, String firstName, String lastName) {
    Map<String, String> result = new Map<String, String>();

    // ✅ 1. Check existing Contact first
    List<Contact> contacts = [
        SELECT Id, Email 
        FROM Contact 
        WHERE Email = :email 
        LIMIT 1
    ];

    if (!contacts.isEmpty()) {
        throw new AuraHandledException('EMAIL_EXISTS');
       /* Contact existingContact = contacts[0];
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
        return result; */
    }

    // ✅ 2. Check if a Lead with this email already exists
    List<Lead> leads = [
        SELECT Id 
        FROM Lead 
        WHERE Email = :email 
        LIMIT 1
    ];

    if (!leads.isEmpty()) {
        throw new AuraHandledException('EMAIL_EXISTS');
        /*Lead existingLead = leads[0];
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
        return result; */
    }
    Site admissionsSite = [Select Id, GuestRecordDefaultOwnerId from Site where Name=:getPortalName()];

    // ✅ 3. If no existing Contact or Lead → Create a brand new Lead
    Lead newLead = new Lead();
    newLead.FirstName = firstName;
    newLead.LastName = (String.isNotBlank(lastName)) ? lastName : (String.isNotBlank(firstName) ? firstName : 'Student');
    newLead.Email = email;
    newLead.Status = 'Unverified';
    newLead.LeadSource = 'Walk-In';
    newLead.Primary_Source__c = 'Walk-In';
    newLead.Company = 'Self';
    newLead.OwnerId = admissionsSite.GuestRecordDefaultOwnerId;
    
    List<RegistrationFormUtility.UtilityResponse> respNew = RegistrationFormUtility.generateOTP();
    String otpNew = (respNew.size() > 0) ? respNew[0].generatedOTP : null;
    DateTime otpValidTillNew = System.now().addMinutes(10);

    newLead.Email_OTP_Code__c = otpNew;
    newLead.Email_OTP_Expiration__c = otpValidTillNew;

    insert newLead;

    // Send OTP email to new lead
    RegistrationFormUtility.sendEmailOtpLead(newLead.Id);

    result.put('leadId', newLead.Id);
    result.put('otp', otpNew);
    return result;
} 

    public class UtilityResponse {
        @AuraEnabled public Id applicantContactId;
    } 

}