public without sharing class RevaHostelCaseTriggerHandler {
    public static void updateStudentContact(List<Case> newList) {
       // Case caseToUpdate = new Case;
        for (Case newcase : newList) {
            System.debug('newcase contactid: '+ newcase.ContactId);
            Case casetoupdate = new Case();
            casetoupdate.id = newcase.id; // Instantiate Case object
            casetoupdate.Student_Contact_For_Updates__c = newcase.ContactId;
            casetoupdate.Student_UserId__c = newcase.OwnerId;
            System.debug('casetoupdate conid: '+ casetoupdate.Student_Contact_For_Updates__c);
            update casetoupdate;
        }
    }
    public static void notifyStudentOnCaseCreation(List<Case> newTrigger){
        List<Case> caseList = new List<Case>();
        Set<String> contactIds = new Set<String>();
        Set<String> ownerIds = new Set<String>();
        for(Case eachCase : newTrigger){
            System.debug('Record Type ' + eachCase.Record_Type_Name__c);
            if(eachCase.Record_Type_Name__c	 == 'REVA Hostel Support Request'){
                caseList.add(eachCase);
                contactIds.add(eachCase.ContactId);
                ownerIds.add(eachCase.OwnerId);
            }
        }
        System.debug('Case List ' + caseList);
        Map<String, String> smsMapToStudent = new Map<String,String>();
        Map<String, String> smsMapToIncharge = new Map<String,String>();
        if(!caseList.isEmpty()){
            
            Map<String, User> userIdMapsPhoneNumber = new Map<String, User>([Select Id,Name, Phone From User Where Id In:ownerIds ]);
            String CasePhone;
                Map<String, Reva_Hostel_Request__c> contactIdMapsHostelReq = new Map<String, Reva_Hostel_Request__c>();
            for(Reva_Hostel_Request__c eachHostelReq : [Select Room_Number__c,Block__c, Hostel_Room_Request_For__c From Reva_Hostel_Request__c Where Hostel_Room_Request_For__c IN :contactIds]){
                contactIdMapsHostelReq.put(eachHostelReq.Hostel_Room_Request_For__c, eachHostelReq);
            }
            System.debug('Map ' + contactIdMapsHostelReq);
            for(Case eachCase : caseList){
                System.debug(eachCase);
                System.debug(eachCase.Contact_Mobile_Number__c);
                System.debug(eachCase.ownerId);
                System.debug(userIdMapsPhoneNumber.get(eachCase.OwnerId)?.Phone);
                DateTime createdDate = eachCase.CreatedDate;
                String formattedCreatedDate = createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
                if(eachCase.Contact_Mobile_Number__c!=NULL){
                    String messageToStudent = 'Dear '+eachCase.Case_Contact_Name__c +'\n\nYour complaint has been created and is currently under review. We will be addressing it promptly. Rest assured for resolution to your satisfaction.\n\nComplaint type: '+eachCase.Hostel_Category__c+'\nComplaint No: '+eachCase.CaseNumber+'\nComplaint date: '+ formattedCreatedDate +'\nComplaint description: '+eachCase.Description+'\n\nRegards\nHostel office\nREVA University';
                    if(eachCase.Contact_Mobile_Number__c != null){
                    String plusRemoved = eachCase.Contact_Mobile_Number__c.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    CasePhone = correctedWhatsappNumber;
                }
                  
                    smsMapToStudent.put(CasePhone, messageToStudent);                
                }
               
            }
        }
        System.debug('SMS '+smsMapToStudent);
        System.debug('SMSincharge '+smsMapToIncharge);
        if(!smsMapToStudent.isEmpty()){
            try{
                Rpl_UtilityClass.sendSMSAsync('Complaint Creation (Student)', smsMapToStudent);
            }catch(Exception e){
                ErrorLogUtility.logError(e);
            }
        } if(!smsMapToIncharge.isEmpty()){
            try{
               // Rpl_UtilityClass.sendSMSAsync('Complaint In charge', smsMapToIncharge);
            }catch(Exception e){
                ErrorLogUtility.logError(e);
            }
        }
    }
    
    
    public static void handleOwnerChangeContact(List<Case> newCases, Map<Id, Case> oldMap) {
       List<Case> CaseIds = new List<Case>();
         System.debug('Hello');
        for (Case con : newCases) {  
               if (con.OwnerId != oldMap.get(con.Id).OwnerId) {
                   CaseIds.add(con); 
                    System.debug('Hello');
                     System.debug('new id'+con.Ownerid);
                     System.debug('old id'+oldMap.get(con.Id).Ownerid);
            }       
        }
           If(!CaseIds.Isempty()){
                System.debug('Hello');
               notifyInchargeOnCaseCreation(CaseIds);
           }
           
       }
    
    public static void notifyInchargeOnCaseCreation(List<Case> newTrigger){
        List<Case> caseList = new List<Case>();
        Set<String> contactIds = new Set<String>();
        Set<String> ownerIds = new Set<String>();
        for(Case eachCase : newTrigger){
            if(eachCase.Record_Type_Name__c == 'REVA Hostel Support Request'){
                caseList.add(eachCase);
                System.debug('eachcase.Student_Contact_For_Updates__c: '+ eachCase.Student_Contact_For_Updates__c);
                contactIds.add(eachCase.Student_Contact_For_Updates__c);
                ownerIds.add(eachCase.Student_UserId__c);
            }
        }
        Map<String, String> smsMapToIncharge = new Map<String,String>();
        if(!caseList.isEmpty()){
            Map<String, User> userIdMapsPhoneNumber = new Map<String, User>([Select Id,Name, Phone From User Where Id In: ownerIds ]);
                Map<String, Reva_Hostel_Request__c> contactIdMapsHostelReq = new Map<String, Reva_Hostel_Request__c>();
            String Block;
            string RoomNo;
            for(Reva_Hostel_Request__c eachHostelReq : [Select Room_Number__c,Block__c, Hostel_Room_Request_For__c From Reva_Hostel_Request__c Where Hostel_Room_Request_For__c IN :contactIds]){
               
                Block = eachHostelReq.Block__c;
                RoomNo = eachHostelReq.Room_Number__c;
                System.debug('Block'+Block);
                System.debug('RoomNo'+RoomNo);
            }
            for(Case eachCase : caseList){
                System.debug('case contact number: '+ eachCase.Contact_Mobile_Number__c);
                DateTime createdDate = eachCase.CreatedDate;
                String formattedCreatedDate = createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
               
                User Owner = [SELECT Name, MobilePhone FROM User WHERE Id = :eachCase.ownerid LIMIT 1];
                System.debug('student contact id: '+ eachCase.Student_Contact_For_Updates__c);
                String StudentName = eachCase.Case_Contact_Name__c	;
                System.debug('support type: '+ eachCase.Hostel_Category__c);
                System.debug('student name: '+ StudentName);
                String message = 'Dear '+ Owner.Name +'\n\nThis is to inform you that a complaint has been assigned to you and requires action from your end.\n\nStudent name: '+ StudentName +'\nApp No: '+eachCase.CaseNumber+'\nComplaint type: '+ eachCase.Hostel_Category__c +'\nComplaint No:'+eachCase.CaseNumber+'\nComplaint date: '+ formattedCreatedDate +'\nDescription: '+eachCase.Description+'\nBlock: '+ Block +'\nRoom No: '+ RoomNo +'\n\nRegards\nHostel office\nREVA University';
                smsMapToIncharge.put(Owner.MobilePhone, message);
                System.debug('Owner.MobilePhone'+Owner.MobilePhone);
                 System.debug('Owner.NAme'+ Owner.Name);
                System.debug('message'+message);

            }
        }
        
       if(!smsMapToIncharge.isEmpty()){
            try{
                Rpl_UtilityClass.sendSMSAsync('Complaint In charge', smsMapToIncharge);
                 System.debug('Trymethod');
            }catch(Exception e){
                ErrorLogUtility.logError(e);
            }
        }
    
    }
    public static void notifyStudentOnStatusChange(List<Case> newTrigger, Map<Id, Case> oldMap){
        List<Case> caseList = new List<Case>();
        for(Case eachCase : newTrigger){
            if(eachCase.Status != oldMap.get(eachCase.Id).Status && eachCase.Record_Type_Name__c == 'REVA Hostel Support Request'){
                caseList.add(eachCase);
            }
        }
        Map<String, String> smsMapToStudent = new Map<String,String>();
         string CasePhone;
        String ownerCasePhone;
        if(!caseList.isEmpty()){
            for(Case eachCase : caseList){
                System.debug('case contact number: '+ eachCase.Contact_Mobile_Number__c);
                if(eachCase.Contact_Mobile_Number__c != NULL){
                    DateTime createdDate = eachCase.CreatedDate;
                    String formattedCreatedDate = createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
                    String message = 'Dear '+eachCase.Case_Contact_Name__c +'\n\nWe wanted to provide you with an update regarding the complaint you have raised. The team is currently working on and reviewing your case.\n\nComplaint type: '+eachCase.Hostel_Category__c+'\nComplaint No: '+eachCase.CaseNumber+'\nComplaint date: '+ formattedCreatedDate +'\nDescription: '+eachCase.Description+'\nStatus: '+eachCase.Status+'\n\nRegards\nHostel office\nREVA University';
                 if(eachCase.Contact_Mobile_Number__c != null){
                    String plusRemoved = eachCase.Contact_Mobile_Number__c.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    CasePhone = correctedWhatsappNumber;
                }
                    smsMapToStudent.put(CasePhone, message);
                    System.debug('message: '+ message);
                }else{
                    DateTime createdDate = eachCase.CreatedDate;
                    String formattedCreatedDate = createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
                    String message = 'Dear '+eachCase.Case_Contact_Name__c +'\n\nWe wanted to provide you with an update regarding the complaint you have raised. The team is currently working on and reviewing your case.\n\nComplaint type: '+eachCase.Hostel_Category__c+'\nComplaint No: '+eachCase.CaseNumber+'\nComplaint date: '+ formattedCreatedDate +'\nDescription: '+eachCase.Description+'\nStatus: '+eachCase.Status+'\n\nRegards\nHostel office\nREVA University';
                    System.debug('message: ' + message);
                    User Owner = [SELECT ContactId FROM User WHERE Id = :eachCase.CreatedById LIMIT 1];
                     if(Owner.MobilePhone != null){
                    String plusRemoved = Owner.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    ownerCasePhone = correctedWhatsappNumber;
                }
                  
                    smsMapToStudent.put(ownerCasePhone, message);
                    System.debug('debug of map'+ smsMapToStudent);
                }
            }
        }
        if(!smsMapToStudent.isEmpty()){
            try{
                System.debug('smsmap'+ smsMapToStudent);
                Rpl_UtilityClass.sendSMSAsync('Complaint update (Student)', smsMapToStudent);
            }catch(Exception e){
                System.debug('not sent');
                ErrorLogUtility.logError(e);
            }
        }
    }
    
/********************New Changes For Apex sharing************************************/
public static void shareCasesAfterOwnershipChange(List<Case> newCases, Map<Id, Case> oldMap) {
    Set<Id> caseIds = new Set<Id>();
 
    // Retrieve RecordType and Profile names
    Map<Id, String> recordTypeNames = new Map<Id, String>();
    Id revaRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('REVA Hostel Support Request')?.getRecordTypeId();   
 
    Map<Id, String> userProfileNames = new Map<Id, String>();
    Set<Id> userIds = new Set<Id>();
    for (Case c : oldMap.values()) {
        userIds.add(c.CreatedById);
    }
    system.debug('user list==='+userids);
    system.debug('user list size==='+userids.size());
    for (User u : [SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]) {
        userProfileNames.put(u.Id, u.Profile.Name);
    }
 
    for (Case c : newCases) {
        //String recordTypeName = revaRecordTypeId.get(c.RecordTypeId);
        String createdByProfileName = userProfileNames.get(oldMap.get(c.Id).CreatedById);
 
        //system.debug('++++c.RecordType++++' + recordTypeName);
        system.debug('++++c.Id++++' + c.Id);
        system.debug('++++oldMap.get(c.Id).CreatedBy.Profile++++' + createdByProfileName);
        system.debug('++++oldMap.get(c.Id).OwnerId++++' + oldMap.get(c.Id).OwnerId);
        system.debug('++++oldMap.get(c.Id).OwnerId++++' + c.OwnerId);
        // Check if the case ownership has changed
        if (c.OwnerId != oldMap.get(c.Id).OwnerId && c.RecordTypeId == revaRecordTypeId && createdByProfileName == 'Student Profile') {
            caseIds.add(c.Id);
        }
    }
    system.debug('++++caseIds++++' + caseIds);
 
    if (!caseIds.isEmpty()) {
        String caseAccessLevel = 'Edit';
        List<CaseShare> caseShares = new List<CaseShare>();
         List<Case> cases = [SELECT Id, CreatedById FROM Case WHERE Id IN :caseIds];
        for (case c : cases) {            
            CaseShare caseShare = new CaseShare();
            caseShare.CaseId = c.Id;
            caseShare.UserOrGroupId = c.CreatedById;
            caseShare.CaseAccessLevel = caseAccessLevel;
            caseShare.RowCause = Schema.CaseShare.RowCause.Manual;
            caseShares.add(caseShare);
        }
 
        if (!caseShares.isEmpty()) {
            system.debug('+++++caseShares+++++' + caseShares);
            insert caseShares;
        }
 
        // RevaHostelSupportCaseService.updateOwnershipAndShareCases(caseIds, newCases[0].OwnerId, 'REVA Hostel Support Request', 'Student Profile', 'Non Teaching Profile', 'Edit');
    }
}
}