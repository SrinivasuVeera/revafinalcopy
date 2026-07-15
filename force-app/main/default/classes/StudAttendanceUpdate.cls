public with sharing class StudAttendanceUpdate {    
    @AuraEnabled(cacheable=true) 
    public static List<hed__Attendance_Event__c> searchAttendanceRecords(List<String> srns, String searchType, Date searchDate, Date toDate, List<String> slots) {
		List<hed__Attendance_Event__c> records;
        if (srns == null || srns.isEmpty() || searchDate == null || toDate == null || slots == null || slots.isEmpty()) {
        	throw new AuraHandledException('SRNs and Date cannot be blank.');
        }else{       
            // Trim whitespace from each SRN
            List<String> trimmedSrns = new List<String>();
            for (String s : srns) {
                if (!String.isBlank(s)) {
                    trimmedSrns.add(s.trim());
                }
            }
            
            // Ensure we only query with non-empty SRNs
            if (trimmedSrns.isEmpty()) {
                throw new AuraHandledException('No valid SRNs provided.');
            }
            if(searchType == 'SRN'){
                 records = [
                 SELECT Id, SRN__c,Application_Number__c,hed__Contact__r.Name, Course_Offering_Section__c, Slot__c,hed__Attendance_Type__c, hed__Reason__c,Course_Offering_Schedule_Date__c,Course_Offering_Schedule__r.hed__Start_Time__c,Course_Offering_Schedule__r.hed__End_Time__c,Course_Offering_From_Schedule__c FROM hed__Attendance_Event__c        
                 WHERE hed__Attendance_Type__c = 'Absent'
                 AND Course_Offering_Schedule_Date__c >=: searchDate
                 AND Course_Offering_Schedule_Date__c <=: toDate   
                 AND SRN__c =: trimmedSrns
                 AND Slot__c =: slots
                 AND activity_based_att_req_dt__c = null 
                 AND activity_based_att_app_dt__c = null];                  
            }
            if(searchType == 'Application'){
                records = [
                 SELECT Id, SRN__c,Application_Number__c,hed__Contact__r.Name, Course_Offering_Section__c, Slot__c,hed__Attendance_Type__c, hed__Reason__c,Course_Offering_Schedule_Date__c,Course_Offering_Schedule__r.hed__Start_Time__c,Course_Offering_Schedule__r.hed__End_Time__c,Course_Offering_From_Schedule__c FROM hed__Attendance_Event__c        
                 WHERE hed__Attendance_Type__c = 'Absent'
                 AND Course_Offering_Schedule_Date__c >=: searchDate
                 AND Course_Offering_Schedule_Date__c <=: toDate   
                 AND Application_Number__c =: trimmedSrns
                 AND Slot__c =: slots
                 AND activity_based_att_req_dt__c = null 
                 AND activity_based_att_app_dt__c = null]; 
            }
            return records;
        }
    }    
    
    @AuraEnabled
    public static void updateAttendanceRecords(List<hed__Attendance_Event__c> recordsToUpdate) {
        try{
         	update recordsToUpdate;        	  
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static void updateAttendanceWithNotify(List<hed__Attendance_Event__c> recordsToUpdate) {
            try{
                update recordsToUpdate;   
                // Send Notifications
                 Id recieverId;        
                // Get Department from logged-in user 
                User loggedInUser = [SELECT Department FROM User WHERE IsActive = true AND Id = :UserInfo.getUserId() LIMIT 1];  //   Id = :UserInfo.getUserId()  Id = '0055j0000071vwgAAA' 
                String userDepartment = loggedInUser.Department;  
                System.debug('1 userDepartment :::: '+userDepartment);
                if(userDepartment != null){                    
                    Account acc = [SELECT School_Head__r.FederationIdentifier FROM Account WHERE Name =: userDepartment LIMIT 1];
                    System.debug('2 Account :::: '+acc);
                   
                    if(acc != null && acc.School_Head__r.FederationIdentifier != null){                        
                        String schoolDirectorFedId = acc.School_Head__r.FederationIdentifier;       
                         System.debug('3 FederationIdentifier :::: '+schoolDirectorFedId);
                        User directorId = [SELECT Id FROM User WHERE FederationIdentifier =: schoolDirectorFedId LIMIT 1];
                        System.debug('4 directorId :::: '+directorId);
                        if (directorId != null) {
                            recieverId = directorId.Id;                            
                        } else {
                            System.debug('No User Id found with the name : ' + schoolDirectorFedId);
                        }
                    }else{
                        System.debug('No Account or School Head found for the department : ' + userDepartment);
                    }
                }else{
                    System.debug('No Department Found for the user Id : ' + UserInfo.getUserId());
                }
                System.debug('5 recordsToUpdate :::: '+recordsToUpdate);
                if(recordsToUpdate != null){    
                   for(hed__Attendance_Event__c att : recordsToUpdate){
                        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_school_director_to_mark_ABA'];
                        Id userId = Userinfo.getUserId();                                 				
                        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
                        customNotificationObj.setBody('Please mark the Activity Based Attendance ');
                        customNotificationObj.setTitle('Mark Attendance');
                        customNotificationObj.setNotificationTypeId(cnType.id);
                        customNotificationObj.setSenderId(userId);                        
                        customNotificationObj.setTargetId(att.Id);
                        customNotificationObj.send(new Set<String> {recieverId});
                    }   
                }    
            }catch(Exception e){
                 // Handle any query issues
                throw new AuraHandledException('Error during querying: ' + e.getMessage());
            }            
    }
    
    // Method to get the picklist values for hed__Reason__c
    @AuraEnabled
    public static List<String> getHedReasonPicklistValues() {
        // Get the describe result for the hed__Attendance_Event__c object
        Schema.DescribeSObjectResult describeResult = Schema.SObjectType.hed__Attendance_Event__c;
        
        // Get the field describe result for hed__Reason__c
        Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get('hed__Reason__c').getDescribe();
        
        // Retrieve the picklist values
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        // Create a list to store the picklist values
        List<String> picklistValues = new List<String>();
        
        // Iterate through the picklist entries and add them to the list
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getValue());
        }
        
        return picklistValues;
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<String> getSchoolProgramData() {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
		List<String> listCodes = new List<String>();
        try {
            // Query 1: Get email from logged-in user
            User loggedInUser = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            String userEmail = loggedInUser.FederationIdentifier;		
            
            // Query 2: Get School Name using user's email
            List<Contact> contactList = [SELECT Account_Name__c FROM Contact WHERE hed__WorkEmail__c = :userEmail LIMIT 1];            
            if (contactList.isEmpty()) {
                listCodes.add('Error in fetching email');
                return listCodes; // Return empty if no contact found
            }
            String schoolName = contactList[0].Account_Name__c;		
            
            // Query 3: Get Accounts by school name
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = :schoolName];
            if (accounts.isEmpty()) {
                 listCodes.add('Error in fetching accounts');
                 return listCodes; // Return empty if no accounts found
            }

            // Query 4: Get Program Codes for the Account IDs found
            List<Id> accountIds = new List<Id>();
            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }
			
            List<Account> programAccounts = [SELECT Id, Name, Program_Code__c FROM Account WHERE ParentId IN :accountIds];
             if (programAccounts.isEmpty()) {
                 listCodes.add('Error in fetching programAccounts');
                 return listCodes; // Return empty if no accounts found
             }
            
             for (Account acc : programAccounts) {
                listCodes.add(acc.Program_Code__c);
             }             

        } catch (Exception e) {
            // Handle any exceptions (for example, no data found)
            listCodes.add('Error no data found');
            return listCodes;
        }
        
        return listCodes;
    }
    
    // Get attendance records pending for approval
    @AuraEnabled(cacheable=true)
    public static List<hed__Attendance_Event__c> getAttendanceRecPendingForApproval() {
        String loggedInUserDept = getLoggedInUserDepartment();
        List<hed__Attendance_Event__c> records = [           
           	 SELECT Id, SRN__c,Application_Number__c,hed__Contact__r.Name, Course_Offering_Section__c, Slot__c,hed__Attendance_Type__c, hed__Reason__c,Course_Offering_Schedule_Date__c,Course_Offering_Schedule__r.hed__Start_Time__c,Course_Offering_Schedule__r.hed__End_Time__c,Course_Offering_From_Schedule__c,activity_based_att_req_dt__c          
             FROM hed__Attendance_Event__c 
             WHERE hed__Attendance_Type__c = 'Absent' 
            	    AND activity_based_att_req_dt__c != null 
            		AND activity_based_att_app_dt__c = null 
            		AND hed__Contact__r.School_Name__c =: loggedInUserDept];
    	//	 This will return an empty list if no records match    		              
             return records; 
    }
    
    // Method to check logged in User Profile
    @AuraEnabled(cacheable=true)    
    public static String getLoggedInUserProfile(){
        String profileName;
         try {
            // Get profile from salesforce logged-in user
            User loggedInUser = [SELECT Profile_Name__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        	profileName = loggedInUser.Profile_Name__c;             
         } catch (Exception e) {
            // Handle any query issues
            throw new AuraHandledException('Error during querying: ' + e.getMessage());
         }
        return profileName;
    }   
    
    @AuraEnabled(cacheable=true) 
    public static String getLoggedInUserDepartment(){
        String department;
         try {
            // Get profile from salesforce logged-in user
            User loggedInUser = [SELECT Department FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        	department = loggedInUser.Department;             
         } catch (Exception e) {
            // Handle any query issues
            throw new AuraHandledException('Error during querying: ' + e.getMessage());
         }
        return department;
    }
   
    // Method to get logged-in user's email and school attendance data
    @AuraEnabled(cacheable=true)
    public static List<hed__Attendance_Event__c> getSchoolAttendanceData() {
        try {
            // Get email from logged-in user
            User loggedInUser = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            String userEmail = loggedInUser.FederationIdentifier;

            // Get School Name using user's email
            List<Contact> contactList = [SELECT Account_Name__c FROM Contact WHERE hed__WorkEmail__c = :userEmail LIMIT 1];
            if (contactList.isEmpty()) {
                throw new CustomException('No contact found for this user\'s email.');
            }
            String schoolName = contactList[0].Account_Name__c;

            // Get Attendance Events related to the School Name
            List<hed__Attendance_Event__c> records = [
                SELECT Id, SRN__c,Application_Number__c,hed__Contact__r.Name, Course_Offering_Section__c, Slot__c,
                       hed__Attendance_Type__c, hed__Reason__c, Course_Offering_Schedule_Date__c,
                       Course_Offering_Schedule__r.hed__Start_Time__c, Course_Offering_Schedule__r.hed__End_Time__c,
                       Course_Offering_From_Schedule__c, activity_based_att_req_dt__c
                FROM hed__Attendance_Event__c
                WHERE hed__Attendance_Type__c = 'Absent'
                  AND activity_based_att_req_dt__c != null
                  AND activity_based_att_app_dt__c = null
                  AND hed__Contact__r.School_Name__c = :schoolName
            ];
            
            // Return the list of records found
            return records;
        } catch (QueryException qe) {
            // Handle any query issues
            throw new CustomException('Error during querying: ' + qe.getMessage());
        } catch (Exception e) {
            // Catch any general exceptions
            throw new CustomException('Unexpected error: ' + e.getMessage());
        }
    }

    // Custom Exception Class for cleaner error messages
    public class CustomException extends Exception {}  
}