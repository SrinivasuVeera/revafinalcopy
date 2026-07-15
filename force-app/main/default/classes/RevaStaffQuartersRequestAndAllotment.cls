public Without sharing class RevaStaffQuartersRequestAndAllotment {
    
    public static final Set<String> staffReqCompleted = new Set<String>{'Room Allotted', 'Vacation Initiated'};
        
        @AuraEnabled
        public static Map<String, String> quarterRequestProcess(String roomType,Date joiningDate) {
            System.debug('roomType'+ roomType);
            System.debug('joiningDate'+ joiningDate);
            Map<String, String> retMap = new Map<String, String>();
            try {
                // Check if there are available quarters of the specified type
                List<Staff_Quarters_Room__c> quartersAvl = availableQuarters(roomType);
                System.debug('quartersAvl'+ quartersAvl);
                if (quartersAvl.isEmpty()) {
                    retMap.put('isError', 'true');
                    retMap.put('errorMessage', 'No Staff Quarters Available.');
                    return retMap;
                }
                // Create the quarters request without checking for existing requests
                String userType = getUserType();
                system.debug('userType'+userType);
                // String userType = 'Professor';
                Staff_Quarters_Request__c objReq = createQuartersReq(Userinfo.getUserId(), roomType, userType, joiningDate);
                // Staff_Quarters_Request__c  newQuarterReq = [SELECT Id, Name,Quarter_Request_For__c FROM Staff_Quarters_Request__c WHERE Room_Request_For__c = :Userinfo.getUserId()  ORDER BY CreatedDate DESC LIMIT 1];
                if(objReq != null){
                    system.debug('objReq:'+objReq);
                    
                    
                    Map<String, String> getUpdatedStatus = updateExixtingQuarterReq(objReq.Id,objReq.Quarter_Request_For__c);
                    system.debug('getUpdatedStatus: 11'+getUpdatedStatus);
                    if(!getUpdatedStatus.isEmpty() && !getUpdatedStatus.containsKey('isInsert')){
                        system.debug('getUpdatedStatus:'+getUpdatedStatus);
                        if(getUpdatedStatus.get('isUpdate') == 'true'){
                            system.debug('getUpdatedStatus succe:');
                            retMap.put('isSuccess', 'true');
                            retMap.put('successMessage', 'Your new Quarter Request successfully submitted.');
                        }
                        else if(getUpdatedStatus.get('isError') == 'true') {
                            system.debug('getUpdatedStatus fail:');
                            //delete newQuarterReq;
                            retMap.put('isError', 'true');
                            retMap.put('errorMessage', 'your re apply request failed contact your Salesforce Admin');
                            retMap.put('successMessage', 'Your new Quarter Request successfully submitted.');
                        }
                        
                    }
                    else if(getUpdatedStatus.get('isInsert') == 'true') {
                        system.debug('Insert New:');
                        retMap.put('isSuccess', 'true');
                        retMap.put('successMessage', 'Request for Quarters successfully submitted.');
                    }
                }
                
            } catch (Exception ex) {
                system.debug('getUpdatedStatus: 11'+ ex);
                retMap.put('isError', 'true');
                retMap.put('errorMessage', 'An error occurred while processing the request.');
            }
            return retMap;
        }
    
    public static List<Staff_Quarters_Room__c> availableQuarters(String roomType) {
        List<Staff_Quarters_Room__c> quartersAvl = new List<Staff_Quarters_Room__c>();
        try {
            if (String.isNotBlank(roomType)) {
                quartersAvl = [SELECT Id FROM Staff_Quarters_Room__c WHERE Type__c = :roomType];
            } else {
                quartersAvl = [SELECT Id FROM Staff_Quarters_Room__c];
            }
        } catch (Exception ex) {
            // Log or handle the exception
            System.debug('Exception in availableQuarters: ' + ex.getMessage());
        }
        return quartersAvl;
    }
    /* public static List<Staff_Quarters_Room__c> availableQuarters(String roomType) {
List<Staff_Quarters_Room__c> quartersAvl = new List<Staff_Quarters_Room__c >();
try {
quartersAvl = [SELECT Id FROM Staff_Quarters_Room__c WHERE Type__c =: roomType];
} catch (Exception ex) {

}
return quartersAvl;
}*/
    public static String getUserType() {
        String profileName;
        List<User> userList = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('userList==> '+userList);
        if (!userList.isEmpty()) {
            profileName = userList[0].Profile.Name;
        } else {
            return 'Unknown';
        }
        
        // Fetch all records from the custom setting ProfileMapping__c
        Map<String, String> profileMap = new Map<String, String>();
        
        for (Eligible_Profiles_For_Staff_Quarters__c mapping : [SELECT Profile_Name__c, Return_Value__c FROM Eligible_Profiles_For_Staff_Quarters__c]) {
            profileMap.put(mapping.Profile_Name__c, mapping.Return_Value__c);
        }
        
        // Return the corresponding value if found; otherwise, return 'Unknown'
        return profileMap.containsKey(profileName) ? profileMap.get(profileName) : 'Unknown';
    }
    /* public static String getUserType() {
String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

if ('Professor'.equals(profileName)) {
return 'TeachingStaff';
} else if ('Non Teaching Profile'.equals(profileName)) {
return 'NonTeachingStaff';
} else {
return 'Unknown';
}
}*/
    @AuraEnabled
    public static Staff_Quarters_Request__c fetchExistingQuartersReq(Id userId) {
        Contact con = getUserRelatedContactByEmail(userId);
        Staff_Quarters_Request__c  quartersReq;
        try {
            quartersReq = [
                SELECT Id, Name, Is_Re_Joined__c,Status__c, Type__c,Quarter_Request_For__c, Room_Request_For__c,Staff_Quarters_Joining_Date__c,Staff_Quarters_Room__r.Name,HCM_Approval_Status__c, 
                (SELECT Id, Initiated_Date__c, Status__c 
                 FROM Staff_Quarter_Vacation_Requests__r 
                 ORDER BY Initiated_Date__c DESC LIMIT 1) 
                FROM Staff_Quarters_Request__c 
                WHERE Quarter_Request_For__c =: con.Id OR Room_Request_For__c  =: userId 
                ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception ex) {
            
        }
        return quartersReq;
    }
    
    
    public static contact getUserRelatedContactByEmail(Id userId) {
        User u =[SELECT Id ,Name, Email FROM user WHERE Id =: userId];
        
        contact  con;
        try {
            con = [SELECT Id, Name, Email FROM Contact WHERE Email =: u.Email LIMIT 1];
        } catch (Exception ex) {
            
        }
        return con;
    }
    
    @AuraEnabled
    public static Staff_Quarters_Request__c fetchExistingQuartersDetails(Id userId) {
        Contact con = getUserRelatedContactByEmail(userId);
        Staff_Quarters_Request__c  quartersReq;
        try {
            quartersReq = [
                SELECT Id, Name, Status__c, Type__c, Room_Request_For__c,Staff_Quarters_Joining_Date__c,Staff_Quarters_Room__r.Name,Vacation_Date__c 
                FROM Staff_Quarters_Request__c 
                WHERE (Quarter_Request_For__c = :con.Id OR Room_Request_For__c  =: userId) AND Status__c != 'Re-Joined' 
                ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception ex) {
            
        }
        return quartersReq;
    }
    
    public static Staff_Quarters_Request__c createQuartersReq(Id userId, String roomType, String userType,Date joiningDate) {
        Staff_Quarters_Request__c quarterReq = fetchExistingQuartersReq(userId);
        // if(quarterReq == null){
        System.debug('quarterReq'+quarterReq);
        User UserInfo = [SELECT Id, Email FROM User WHERE Id = :userId];
        System.debug('Current User Info: ' + UserInfo.Id);
        System.debug('Current User Info: ' + UserInfo.Email);
        Contact teachingContact = [SELECT Id, FirstName, LastName, Name,Email, MobilePhone,hed__Gender__c,RecordType.Name
                                   FROM Contact 
                                   WHERE Email = :UserInfo.Email];
        string requestForId = teachingContact.Id;
        
        
        
        //AddedbyRajashekar17thsept2024
        System.debug('roomType==> ' + roomType);
        List<SLCM_Employee_Rent_Detail__c> empRent = [SELECT Monthly_Deduction_Amount__c, Request_Type__c, Room_Type__c FROM SLCM_Employee_Rent_Detail__c Where Room_Type__c =: roomType  AND Request_Type__c = 'Quarter' Limit 1];
        system.debug('empRent'+empRent);       
        Staff_Quarters_Request__c objReq = new Staff_Quarters_Request__c(Quarter_Request_For__c = requestForId, Room_Request_For__c = userId, Type__c = roomType, Quarters_Request_Type__c = userType, Staff_Quarters_Joining_Date__c = joiningDate,HCM_Approval_Status__c = 'Deduction Request Initiated',Employee_Salary__c = empRent[0].Monthly_Deduction_Amount__c,Salary_Last_Revised_Date__c = system.today(),Status__c = 'Request Submitted');
        insert objReq;
        return objReq;
        // }else{
        //    return quarterReq;
        //}
    }
    @AuraEnabled
    public static Map<String, String> initiateVacation(Id userId) {
        Map<String, String> retMap = new Map<String, String>();
        try {
            Staff_Quarters_Request__c quartersReq = fetchExistingQuartersReq(Userinfo.getUserId());
            if (quartersReq != null) {
                Staff_Quarter_Vacation_Request__c vacReq;
                vacReq = fetchExistVacationReq(quartersReq.Id);
                if (vacReq != null) {
                    vacReq.Initiated_Date__c = Date.today();
                    vacReq.Status__c = 'Initiated';
                } else {
                    vacReq = new Staff_Quarter_Vacation_Request__c(Staff_Quarters_Request__c  = quartersReq.Id, Initiated_Date__c  = Date.today());
                }
                insert vacReq;
                quartersReq.Status__c = 'Vacation Initiated';
                update quartersReq;
                retMap.put('isSuccess', 'true');
                retMap.put('successMessage', 'Staff Vacation Initiated');
            }
        } catch (Exception ex) {
            retMap.put('isError', 'true');
            retMap.put('errorMessage', 'Staff Vacation Initiation Failed. Try again');
        }
        return retMap;
    }
    public static Staff_Quarter_Vacation_Request__c fetchExistVacationReq(Id staffQuarterId) {
        Staff_Quarter_Vacation_Request__c vacReq;
        try {
            vacReq = [SELECT Id, Status__c FROM Staff_Quarter_Vacation_Request__c WHERE Staff_Quarters_Request__c =: staffQuarterId ORDER BY Initiated_Date__c DESC LIMIT 1];
        } catch (Exception ex) {
            
        }
        return vacReq;
    }
    @AuraEnabled
    public static Map<String, String> fetchInitialInfo(Id userId) {
        Map<String, String> retMap = new Map<String, String>();
        try {
            Staff_Quarters_Request__c quartersReq = fetchExistingQuartersReq(Userinfo.getUserId());
            system.debug('quartersReqExist=='+quartersReq);
            if (quartersReq != null && quartersReq.Status__c != null) {
                if (quartersReq.Status__c == 'Request Submitted' || quartersReq.Status__c == 'Booked') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You have already applied for staff quarters. Please wait for the required approvals to get processed');                    
                } else if (quartersReq.Status__c == 'Room Allotted') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You already have room allotted for you. Initiate vacation process if you want to vacate');    
                } else if (quartersReq.Status__c == 'Approved') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'Quarter request already approved. Wait for room to get allotted');  
                } else if (quartersReq.Status__c == 'Rejected') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'Quarter request already rejected. Create new quarter request');  
                } else if (quartersReq.Status__c == 'Vacation Initiated') {
                    //ModifiedbyRajashekar 25sept2024
                    system.debug('vacationintiatedstatus=='+quartersReq.Status__c + 'childlistsize==>'+ quartersReq.Staff_Quarter_Vacation_Requests__r.size());
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'Quarter request vacation initiated. Complete it first'); 
                    /*if (quartersReq.Staff_Quarter_Vacation_Requests__r != null && !quartersReq.Staff_Quarter_Vacation_Requests__r.isEmpty()) {
Staff_Quarter_Vacation_Request__c vacReq = quartersReq.Staff_Quarter_Vacation_Requests__r.get(0);
system.debug('vacReq=='+vacReq);
if (vacReq.Status__c != null && vacReq.Status__c == 'Initiated') {
retMap.put('isWarning', 'true');
retMap.put('warningMessage', 'Quarter request vacation initiated. Complete it first'); 
} else if (vacReq.Status__c != null && vacReq.Status__c == 'Completed') {
retMap.put('isWarning', 'true');
retMap.put('warningMessage', 'Quarter request vacation initiated. Complete it first'); 
}
}*/
                }else if (quartersReq.Status__c == 'Vacation Approved') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You vacating request has been Approved. Vacate the room on or before Vacating date.'); 
                } else if (quartersReq.Status__c == 'Vacation Completed') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'You have vacated a room recently. Book a new one'); 
                }
                else if (quartersReq.Status__c == 'Vacation Rejected') {
                    retMap.put('isWarning', 'true');
                    retMap.put('warningMessage', 'Your Vacte Roome request Rejected By HR . re-Request for Vacate'); 
                }
                //endshere
            }
        } catch (Exception ex) {
            retMap.put('isError', 'true');
            retMap.put('errorMessage', 'Staff Vacation Initiation Failed. Try again');
        }
        
        return retMap;
    }
    @AuraEnabled
    public static list<Staff_Quarters_Request__c> fetchExistingQuartersUserDetails(String roomType) {
        list<Staff_Quarters_Request__c>  UserquartersReq;
        try {
            UserquartersReq = [SELECT Id, Name, Status__c, Type__c, Room_Request_For__c FROM Staff_Quarters_Request__c WHERE Type__c =: roomType];
        } catch (Exception ex) {
            
        }
        return UserquartersReq;
    }
    //if any approval is rejected ,Update the exixting request with user new input while re-applying
    @AuraEnabled
    public static Map<String, String> updateRejectedQuaterReq(String roomType,Date joiningDate,String requestId) {
        System.debug('roomType'+ roomType);
        System.debug('joiningDate'+ joiningDate);
        System.debug('joiningDate'+ requestId);
        Map<String, String> retMap = new Map<String, String>();
        Staff_Quarters_Request__c  quartersReq1;
        List<Staff_Quarters_Request__c> updateQuarterReq = new List<Staff_Quarters_Request__c>();
        try {
            
            quartersReq1 = [
                SELECT Id, Status__c, Type__c, 
                Staff_Quarters_Joining_Date__c,
                HCM_Approval_Status__c,Reporting_Manager__c,Approved_by_ReportingManager__c,
                Approved_by_AdminDirector__c,Admin_Director__c,HR_Lead__c,Approved_by_HR_Lead__c,
                Hostel_Officer__c,Approved_by_Hostel_Office__c
                FROM Staff_Quarters_Request__c WHERE Id  =: requestId AND Status__c ='Rejected'  LIMIT 1];
            
            System.debug('quartersAvl'+ quartersReq1);
            if (quartersReq1 == null) {
                System.debug('nulllllllll');
                retMap.put('isError', 'true');
                retMap.put('errorMessage', 'No existing Rejected Staff Quarters Available.');
                return retMap;
            } else {
                Staff_Quarters_Request__c quartersReq = new Staff_Quarters_Request__c();
                System.debug('Inside else');
                quartersReq.Id = requestId;
                quartersReq.Type__c = roomType;
                quartersReq.Staff_Quarters_Joining_Date__c = joiningDate;
                quartersReq.HCM_Approval_Status__c = 'Deduction Request Initiated';
                quartersReq.Reporting_Manager__c = null;
                quartersReq.Approved_by_ReportingManager__c = false;
                quartersReq.Approved_by_AdminDirector__c = false;
                quartersReq.Admin_Director__c = null;
                quartersReq.HR_Lead__c = null;
                quartersReq.Approved_by_HR_Lead__c = false;
                quartersReq.Hostel_Officer__c = null;
                quartersReq.Status__c ='Request Submitted';
                quartersReq.Approved_by_Hostel_Office__c = false;
                updateQuarterReq.add(quartersReq);
            }
            
            if(!updateQuarterReq.isempty()){
                System.debug('Inside  update');
                update updateQuarterReq;
                System.enqueueJob(new SLCM_HCMAPIQueueableHandler.QuarterRequestApprovalHierarchyAPIQueueable(new set<Id>{updateQuarterReq[0].Id}));
                retMap.put('isSuccess', 'true');
                //.put('quartersReq', JSON.serialize(quartersReq));
                retMap.put('successMessage', 'Re-Applying Request for Quarters successfully submitted.');
            }
            
        } catch (Exception ex) {
            retMap.put('isError', 'true');
            retMap.put('errorMessage', 'An error occurred while processing the request.');
        }
        return retMap;
    }
    
    //@AuraEnabled
    public static Map<String, String> updateExixtingQuarterReq(String newReqId, String contactId) {
        System.debug('---updateExixtingQuarterReq---');
        Map<String, String> retMap = new Map<String, String>();
        List<Staff_Quarters_Request__c>  quartersReq;
        
        quartersReq = [SELECT Id, Name, Is_Re_Joined__c,Status__c, Type__c, Room_Request_For__c,Staff_Quarters_Joining_Date__c,Staff_Quarters_Room__r.Name,HCM_Approval_Status__c ,Quarter_Request_For__c
                       FROM Staff_Quarters_Request__c WHERE Quarter_Request_For__c  =: contactId 
                       AND Id != :newReqId ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('quartersReq--'+quartersReq);
        
        try {
            
            if (quartersReq.size() > 0) {
                System.debug('Inside not null');
                quartersReq[0].Status__c ='Re-Joined';
                quartersReq[0].Is_Re_Joined__c = true;
                
                update quartersReq;
                retMap.put('isUpdate', 'true');
                
            }
            else {
                System.debug('inside insert data');
                retMap.put('isInsert', 'true'); 
            }
        } catch (Exception ex) {
            System.debug('Inside Catch');
            retMap.put('isError', 'true');
        }
        return retMap;
    }
}