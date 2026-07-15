public without sharing class SpocContactController {
    
    @AuraEnabled(cacheable=true)
    public static List<hed__Application__c> getContacts() {
        
        Id userId = UserInfo.getUserId();
        
        User u = [
            SELECT Department, Is_SPOC__c 
            FROM User 
            WHERE Id = :userId
        ];
        
        // No department → no data
        if (String.isBlank(u.Department)) {
            return new List<hed__Application__c>();
        }
        
        Boolean isHead = [
            SELECT Id 
            FROM Account 
            WHERE School_Head__c = :userId
            LIMIT 1
        ].size() > 0;
        
        // SPOC → ALL SCHOOL RECORDS
        if (u.Is_SPOC__c) {
            return [
                SELECT hed__Applicant__c, hed__Applicant__r.Name, hed__Applicant__r.Disposition__c, hed__Applicant__r.Description1__c,
                hed__Applicant__r.Connect_with_Academics__c, hed__Applicant__r.MobilePhone, hed__Applicant__r.Email,
                hed__Applicant__r.Owner.Name,hed__Applicant__r.Application_Fee_Paid__c,
                hed__Applicant__r.Assigned_User__c,
                hed__Applicant__r.Assigned_User__r.Name,hed__Applicant__r.Applying_For_REVA_CET__c,hed__Application_Status__c ,
                hed__Applicant__r.School_Disposition__c, hed__Applicant__r.School_Description__c,hed__Applicant__r.Student_Status__c,hed__Applicant__r.Record_Type_Name__c,
                hed__Applicant__r.School__r.Name,hed__Applicant__r.state__c,hed__Applicant__r.School_Name__c, hed__Applicant__r.Primary_Academic_Program_Name__c, hed__Applicant__r.Program_Batch_Name__c,hed__Applicant__r.Quota__c, hed__Applicant__r.Application_Number__c, hed__Applicant__r.LeadSource
                FROM hed__Application__c 
                WHERE hed__Applicant__r.School__r.Name = :u.Department                
                AND hed__Applicant__r.Connect_with_Academics__c = TRUE
            ];
        }
        if (isHead) {
            return [
                SELECT hed__Applicant__c, hed__Applicant__r.Name, hed__Applicant__r.Disposition__c, hed__Applicant__r.Description1__c,
                hed__Applicant__r.Connect_with_Academics__c, hed__Applicant__r.MobilePhone, hed__Applicant__r.Email,
                hed__Applicant__r.Owner.Name,hed__Applicant__r.Application_Fee_Paid__c,
                hed__Applicant__r.Assigned_User__c,
                hed__Applicant__r.Assigned_User__r.Name,hed__Applicant__r.Applying_For_REVA_CET__c,hed__Application_Status__c ,
                hed__Applicant__r.School_Disposition__c, hed__Applicant__r.School_Description__c,hed__Applicant__r.Student_Status__c,hed__Applicant__r.Record_Type_Name__c,
                hed__Applicant__r.School__r.Name,hed__Applicant__r.state__c,hed__Applicant__r.School_Name__c, hed__Applicant__r.Primary_Academic_Program_Name__c, hed__Applicant__r.Program_Batch_Name__c,hed__Applicant__r.Quota__c, hed__Applicant__r.Application_Number__c, hed__Applicant__r.LeadSource
                FROM hed__Application__c
                WHERE hed__Applicant__r.School__r.School_Head__c = :userId AND hed__Applicant__r.School__r.Name = :u.Department
                AND hed__Applicant__r.Connect_with_Academics__c = TRUE
            ];
        } 
        // NON-SPOC → ONLY ASSIGNED RECORDS
        return [
            SELECT hed__Applicant__c, hed__Applicant__r.Name, hed__Applicant__r.Disposition__c, hed__Applicant__r.Description1__c,
                hed__Applicant__r.Connect_with_Academics__c, hed__Applicant__r.MobilePhone, hed__Applicant__r.Email,
                hed__Applicant__r.Owner.Name,hed__Applicant__r.Application_Fee_Paid__c,
                hed__Applicant__r.Assigned_User__c,
                hed__Applicant__r.Assigned_User__r.Name,hed__Applicant__r.Applying_For_REVA_CET__c,hed__Application_Status__c,
                hed__Applicant__r.School_Disposition__c, hed__Applicant__r.School_Description__c,hed__Applicant__r.Student_Status__c,hed__Applicant__r.Record_Type_Name__c,
                hed__Applicant__r.School__r.Name,hed__Applicant__r.state__c,hed__Applicant__r.School_Name__c, hed__Applicant__r.Primary_Academic_Program_Name__c, hed__Applicant__r.Program_Batch_Name__c,hed__Applicant__r.Quota__c, hed__Applicant__r.Application_Number__c, hed__Applicant__r.LeadSource
                FROM hed__Application__c
                WHERE hed__Applicant__r.Assigned_User__c = :userId         
                AND hed__Applicant__r.Connect_with_Academics__c = TRUE
        ];
    }
    
    @AuraEnabled
    public static void updateContact(Contact con) {
        update con;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchKey) {
        User u = [
            SELECT Department 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ];
        return [
            SELECT Id, Name
            FROM User
            WHERE Name LIKE :('%' + searchKey + '%')
            AND IsActive = true
            AND Department = :u.Department AND Id != :UserInfo.getUserId() ORDER BY NAME         
        ];
    }
    
    @AuraEnabled
    public static void assignUsers(List<Id> contactIds, List<Id> userIds) {
        
        if(contactIds.isEmpty() || userIds.isEmpty()) return;
        
        List<Contact> conList = new List<Contact>();
        
        for(Id cId : contactIds){
            conList.add(new Contact(
                Id = cId,
                Assigned_User__c = userIds[0] // primary user
            ));
        }
        
        update conList;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isSpocUser() {
        return [
            SELECT Is_SPOC__c 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ].Is_SPOC__c;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isSchoolHead() {
        return [
            SELECT Id 
            FROM Account 
            WHERE School_Head__c = :UserInfo.getUserId()
            LIMIT 1
        ].size() > 0;
    }
}