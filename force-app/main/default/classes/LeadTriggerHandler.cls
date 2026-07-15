public without sharing class LeadTriggerHandler {
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
    public static Boolean bypassDuplicateValidation = false;
    
    public static void updateLeadSource(Map<Id,Lead> oldLeadMap, List<Lead> newLeads){
        
        for (Lead eachLead : newLeads) {
            
            // Making sure that the update is from the sync -- D0nt pass utmsource in the flow. (not for creatio nor for update)
            if (eachLead.pi__last_activity__c != oldLeadMap.get(eachLead.Id).pi__last_activity__c) {
                
                
                if ((eachLead.utm_source__c == '' || eachLead.utm_source__c == null) 
                    && eachLead.pi__first_touch_url__c !='' && (oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == '' || oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == null)) {
                        eachLead.utm_source__c = 'Organic';
                    }
                else if ((eachLead.utm_source__c == '' || eachLead.utm_source__c == null) 
                         && eachLead.pi__first_touch_url__c == '' && (oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == '' || oldLeadMap.get(eachLead.Id).pi__first_touch_url__c == null)) {
                             eachLead.utm_source__c = 'Direct';
                         }
                if (oldLeadMap.get(eachLead.Id).utm_source__c != eachLead.utm_source__c) {
                    PardotSourceUtility.setSourcesOnLead(eachLead, oldLeadMap.get(eachLead.Id)); 
                }
                
            }
        }
    }
    
    public static void updateCCAndMobilePhone(Map<Id,Lead> oldLeadMap, List<Lead> newLeads){
        for(Lead eachLead: newLeads){
            if(eachLead.MobilePhone != null){
                if((eachLead.Country_Code__C != oldLeadMap.get(eachLead.id).Country_Code__C
                    || eachLead.MobilePhone != oldLeadMap.get(eachLead.id).MobilePhone)){
                        if(!eachLead.MobilePhone.contains('-')){
                            eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone;
                        }
                        else{
                            eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone.substringAfter('-');
                        }
                    }
            }
        }
    }
    
    
    public static void insertPrimarySource(List<Lead> newLeads){
        
        Profile counselorProfile = [Select Id, Name from Profile where Name = 'Counselor'];
        List<User> counselorUsers = [Select Id, Name from User where ProfileId =:counselorProfile.Id and isActive = true];
        
        Profile publisherProfile = [Select Id, Name from Profile where Name = 'REVA Publisher'];
        List<User> publisherUsers = [Select Id, Name from User where ProfileId = : publisherProfile.Id and isActive = true];
        
        Profile yellowAiProfile = [Select Id, Name from Profile where Name = 'YellowAISystemUser'];
        List<User> yellowAiUsers = [Select Id, Name from User where ProfileId = : yellowAiProfile.Id and isActive = true];
        
        String portalName = RegistrationFormUtility.getPortalName();
        Site admissionsSite = [Select Id, GuestRecordDefaultOwnerId from Site where Name = : portalName];
        
        
        Set<Id> publisherUserIds = new Set<Id>();
        Set<Id> counselorUserIds = new Set<Id>();
        set<Id> yellowAiUserIds = new Set<Id>();
        
        for(User publisher : publisherUsers){
            publisherUserIds.add(publisher.Id);
        }
        
        for(User yellowAi : yellowAiUsers){
            yellowAiUserIds.add(yellowAi.Id);
        }
        
        for(User counselor: counselorUsers){
            counselorUserIds.add(counselor.Id);
        }
        
        
        for(Lead eachLead : newLeads){
            
            //Common fields to be set : Company, Mobile Phone & UtmSource and Primary Source based on LeadSource 
            eachLead.Company = eachLead.LastName;  //no matter what Counselors enter in the Company Field let company = last name
            
            if(eachLead.Country_Code__c != null && eachLead.MobilePhone !=null){ //MobilePhone to be concatenated with the country code
                eachLead.MobilePhone = eachLead.Country_Code__c.substringBetween('(',')')+'-'+eachLead.MobilePhone;
            }
            //Update utm source and Primary source for Manual leads by counselor or Publisher leads through API or leads through data uplaod
            if(eachLead.OwnerId != admissionsSite.GuestRecordDefaultOwnerId){
                eachLead.utm_source__c = eachLead.LeadSource;
                eachLead.Primary_Source__c = eachLead.LeadSource; 
            }
            
            //Specific field updates For Counselors Leads
            if(counselorUserIds.contains(eachLead.OwnerId)){
                eachLead.Assigned__C = true;
                eachLead.Assigned_Users__C = eachLead.OwnerId;
                eachLead.Last_Assigned_Date__c = system.today();
            }
            
            //Specific field update For Publisher Leads
            else if(publisherUserIds.contains(eachLead.OwnerId)){
                eachLead.Mobile_OTP_Verified__c = true;     
            }
            
            //Specific field update For Yellow AI Leads
            else if(yellowAiUserIds.contains(eachLead.OwnerId)){
                if(eachLead.Country_Code__c == 'India (+91)'){
                    eachLead.Mobile_OTP_Verified__c = true;  
                }
                else{
                    eachLead.Email_OTP_Verified__c = true; 
                }
            }
            
        }
    }
    //**** After Creating Lead Auto populate the Program Batch*****//
    /*public static void populateProgramBatch(List<Lead> newList) {
Set<String> programNames = new Set<String>();

for (Lead ld : newList) {
if (ld.Program_Name_Display__c != null) {
programNames.add(ld.Program_Name_Display__c);
}
}

if (programNames.isEmpty()) return;

Map<String, Fee_Master__c> feeMasterMap = new Map<String, Fee_Master__c>();

for (Fee_Master__c fm : [SELECT Id, Program_Name__c,Program_Batch__c FROM Fee_Master__c 
WHERE Program_Name__c IN :programNames AND IsActive__c = TRUE]) {
feeMasterMap.put(fm.Program_Name__c, fm);
}

for (Lead ld : newList) {
if (ld.Program_Name_Display__c != null && feeMasterMap.containsKey(ld.Program_Name_Display__c)) {
ld.Program_Batch__c = feeMasterMap.get(ld.Program_Name_Display__c).Program_Batch__c;
}
}
} */
    public static void validateDailyLeadLimit(List<Lead> newLeads){
        
        Id currentUserId = UserInfo.getUserId();
        
        Lead__c setting = Lead__c.getInstance(currentUserId);
        
        if(setting == null || setting.Daily_Lead_Limit__c == null){
            return; // Unlimited
        }
        
        Integer maxLimit = Integer.valueOf(setting.Daily_Lead_Limit__c);
        
        // 0 = Block all
        if(maxLimit == 0){
            for(Lead ld : newLeads){
                ld.addError('Lead creation is blocked for today.');
            }
            return;
        }
        
        Integer todayLeadCount = [SELECT COUNT() FROM Lead
                                  WHERE CreatedById = :currentUserId AND CreatedDate = TODAY];
        
        Integer remainingAllowed = maxLimit - todayLeadCount;
        
        // If no remaining
        if(remainingAllowed <= 0){
            for(Lead ld : newLeads){
                ld.addError('Daily Lead limit exceeded. Limit: ' + maxLimit);
            }
            return;
        }
        
        // If trying to insert more than allowed
        if(newLeads.size() > remainingAllowed){
            
            for(Integer i = remainingAllowed; i < newLeads.size(); i++){
                newLeads[i].addError(
                    'Daily Lead limit exceeded. Only ' + remainingAllowed + ' allowed today.'
                );
            }
        }
    }
    public static void handleAfterInsertProgram(List<Lead> newLeads) {
        List<Id> leadIds = new List<Id>();
        for (Lead l : newLeads) {
            if (l.Status == 'Unverified' && l.Program_Name_Display__c != null && l.Email != null) {
                leadIds.add(l.Id);
            }
        }
        if (!leadIds.isEmpty()) {
            System.enqueueJob(new SFMC_Lead_Email_Queueable(leadIds));
        }
    }
    public static void handleAfterUpdateProgram(Map<Id, Lead> oldMap, List<Lead> newLeads) {
        List<Id> leadIds = new List<Id>();
        
        for (Lead l : newLeads) {
            Lead oldLead = oldMap.get(l.Id);
            
            // Trigger ONLY when field is newly populated or changed
            if (l.Program_Name_Display__c != null && l.Email != null && l.Status != oldLead.Status && l.Status == 'Unverified') {
                leadIds.add(l.Id);
            }
        }
        
        if (!leadIds.isEmpty()) {
            System.enqueueJob(new SFMC_Lead_Email_Queueable(leadIds));
        }
    }
    public static void validateDuplicateLeads(Map<Id, Lead> oldMap,List<Lead> newLeads) {
        if (bypassDuplicateValidation) {
            return;
        }
        
        String yearStr = [SELECT Text_Value__c FROM General_Setting__mdt WHERE DeveloperName = :ENROLMENT_YEAR_CMDT_NAME LIMIT 1].Text_Value__c;
        
        Integer enrolYear = Integer.valueOf(yearStr);
        
        Date fromDate = Date.newInstance(enrolYear, 1, 1).addMonths(-2);
        
        Set<String> emails = new Set<String>();
        Set<String> mobiles = new Set<String>();
        Set<Id> leadIds = new Set<Id>();
        
        for (Lead ld : newLeads) {
            
            if(ld.IsConverted){
                continue;
            }
            
            if (!String.isBlank(ld.Email)) {
                emails.add(ld.Email);
            }
            
            if (!String.isBlank(ld.MobilePhone)) {
                mobiles.add(ld.MobilePhone);
            }
            if(ld.Id != null){
                leadIds.add(ld.Id);
            }
        }
        
        Set<String> existingEmails = new Set<String>();
        
        for (Contact c : [SELECT Email FROM Contact WHERE Email IN :emails AND CreatedDate >= :fromDate]) {            
            existingEmails.add(c.Email);
        }
        
        for (Lead l : [SELECT Email FROM Lead WHERE Email IN :emails AND IsConverted = false AND CreatedDate >= :fromDate AND Id NOT IN :leadIds]) {            
            existingEmails.add(l.Email);
        }
        
        Set<String> existingMobiles = new Set<String>();
        
        for (Contact c : [SELECT MobilePhone FROM Contact WHERE MobilePhone IN :mobiles AND CreatedDate >= :fromDate]) {            
            existingMobiles.add(c.MobilePhone);
        }
        
        for (Lead l : [SELECT MobilePhone FROM Lead WHERE MobilePhone IN :mobiles AND IsConverted = false AND CreatedDate >= :fromDate AND Id NOT IN :leadIds]) {            
            existingMobiles.add(l.MobilePhone);
        }        
        for (Lead ld : newLeads) {
            
            if(ld.IsConverted){
                continue;
            }
            
            Boolean emailExists = false;
            Boolean mobileExists = false;
            
            if (!String.isBlank(ld.Email) && existingEmails.contains(ld.Email)) {                    
                    emailExists = true;
                }
            
            if (!String.isBlank(ld.MobilePhone) && existingMobiles.contains(ld.MobilePhone)) {                    
                    mobileExists = true;
                }
            
            if (emailExists && mobileExists) {                
                ld.addError('Email and mobile already registered.');
            }            
            else if (emailExists) {                
                ld.addError('Email is already registered.');
            }            
            else if (mobileExists) {                
                ld.addError('Mobile number already registered.');
            }
        }
    }
    
}