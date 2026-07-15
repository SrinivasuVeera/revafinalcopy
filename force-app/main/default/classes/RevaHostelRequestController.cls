public Without Sharing class RevaHostelRequestController {
    //public  class revaHostelRequestController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentStudentContact() {
        Id studentId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        system.debug('studentId===>'+studentId);
        Contact studentContact = [SELECT Id, FirstName, LastName, Email, hed__WorkEmail__c, Active_Semester__c,
                                  Phone, Birthdate, RH_Current_Pursuing_Year_of_Student__c, Father_Name__c,Is_Final_Year__c,
                                  Father_Mobile_Number__c, MobilePhone, MailingAddress, OtherAddress, Course__c,Primary_Academic_Program__r.Program_Alias__c, 
                                  hed__Gender__c, SRN_Number__c,Program_Batch__c,Program_Batch__r.name,Active_Semester__r.Name, Program_Batch__r.hed__End_Date__c
                                  //(Select Id, Status__c,Reva_Hostel_Room__c FROM Reva_Hostel_Requests__r WHERE Status__c='Approved' AND Reva_Hostel_Room__c != NULL ORDER BY ID DESC Limit 1)
                                  FROM Contact WHERE Id = :studentId];
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        contactDetails.put('Id', studentContact.Id);
        contactDetails.put('FirstName', studentContact.FirstName);
        contactDetails.put('LastName', studentContact.LastName);
        contactDetails.put('Email', studentContact.hed__WorkEmail__c);
        contactDetails.put('MobilePhone', studentContact.MobilePhone);
        contactDetails.put('Birthdate', studentContact.Birthdate);
        contactDetails.put('ParentName', studentContact.Father_Name__c);
        contactDetails.put('ParentContactNumber', studentContact.Father_Mobile_Number__c);
        contactDetails.put('Course', studentContact.Course__c);
        contactDetails.put('OtherAddress', studentContact.OtherAddress);
        contactDetails.put('MailingAddress', studentContact.MailingAddress);
        contactDetails.put('Gender', studentContact.hed__Gender__c);
        contactDetails.put('idCardNumber', studentContact.SRN_Number__c);
        contactDetails.put('CurrentPusuingYear', studentContact.RH_Current_Pursuing_Year_of_Student__c);
        contactDetails.put('StudentBelongsToFinalYear',studentContact.Is_Final_Year__c);
        contactDetails.put('ProgramAlias',studentContact.Primary_Academic_Program__r.Program_Alias__c);
        contactDetails.put('Semester', studentContact.Active_Semester__r.Name);
        contactDetails.put('ProgramBatch', studentContact.Program_Batch__r.Name);
        if(studentContact.Reva_Hostel_Requests__r.size() > 0){
            contactDetails.put('roomAlloted', TRUE);
        } else{
            contactDetails.put('roomAlloted', FALSE);
        }
        
        return contactDetails;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAdvancedRegistration() {
        
        Map<String, Object> AcadamicDetails = new Map<String, Object>();
        Integer nextYear = Date.today().year() + 1;
        String lastTwoDigits = String.valueOf(nextYear).right(2);
        System.debug('Next Year Last Two Digits: ' + lastTwoDigits);
        
        try {
            Id studentId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
            Integer currentYear = Date.today().year();
            Date startOfYear = Date.newInstance(currentYear, 1, 1);
            Date endOfYear = Date.newInstance(currentYear, 12, 31);
            
            Integer lastYear = Date.today().year() - 1;
            Date startOfLastYear = Date.newInstance(lastYear, 1, 1);
            Date endOfLastYear = Date.newInstance(lastYear, 12, 31);
            List<Reva_Hostel_Request__c> HostelReq = [SELECT Id, Name FROM Reva_Hostel_Request__c  WHERE Hostel_Room_Request_For__c =: studentId 
                                             // AND Advanced_Registration__c = true 
                                              AND( (((Reva_Hostel_JoiningDate__c >= :startOfYear AND Reva_Hostel_JoiningDate__c <= :endOfYear) ) 
                                                   OR (Advanced_Registration__c = true  AND (CreatedDate >= :startOfYear AND CreatedDate <= :endOfYear) ) 
                                                   OR ((Reva_Hostel_JoiningDate__c >= :startOfLastYear AND Reva_Hostel_JoiningDate__c <= :endOfLastYear) And (Rejoiner__c = true AND Status__c = 'Rejoin'))) OR Reva_Hostel_JoiningDate__c = Null)limit 1];
            REVA_Hostel_Academic_Year__c NextAcademicYear = New REVA_Hostel_Academic_Year__c();
            
            if( HostelReq.size() == 0){
                NextAcademicYear = [ Select Id, Name,Is_Next_Year_Academic__c From REVA_Hostel_Academic_Year__c Where Is_Next_Year_Academic__c = true];
                system.debug('NextAcademicYear'+NextAcademicYear);
            }
            AcadamicDetails.put('Id', NextAcademicYear.Id);
            AcadamicDetails.put('AdvancedRegistration', NextAcademicYear.Is_Next_Year_Academic__c);
            
        } catch (Exception e) {
            
            System.debug('Error updating request: ' + e.getMessage());
            AcadamicDetails.put('Status', 'Request Failed !');
            
            throw new AuraHandledException('Error updating request: ' + e.getMessage());
        }
        return AcadamicDetails;
    }
    
    @AuraEnabled
    public static void UpdateChecked() {
        User currentUser = [SELECT ContactId,Contact.hed__Gender__c  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        contact con=[SELECT Id,Name,Advanced_Hostel_Registration__c From Contact WHERE ID=: currentUser.ContactId]; 
        con.Advanced_Hostel_Registration__c = true;
        update con;
    }
       @AuraEnabled
    public static void UpdateUnchecked() {
        User currentUser = [SELECT ContactId,Contact.hed__Gender__c  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        contact con=[SELECT Id,Name,Advanced_Hostel_Registration__c From Contact WHERE ID=: currentUser.ContactId]; 
        con.Advanced_Hostel_Registration__c = false;
        update con;
    }
  /*  @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentNonTeachingContact() {
        
        Id userId = UserInfo.getUserId();
       List<Contact> nonTeachingContact = [SELECT Id, FirstName, LastName, Name,Email,Employee_Number__c, MobilePhone,hed__Gender__c,RecordType.Name
                                      FROM Contact 
                                      WHERE Id = :[SELECT ContactId FROM User WHERE Id = :userId].ContactId 
                                      AND RecordType.Name = 'Non Teaching'];
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        if(nonTeachingContact.size()>0){
        contactDetails.put('Id', nonTeachingContact[0].Id);
        contactDetails.put('FirstName', nonTeachingContact[0].FirstName);
        contactDetails.put('LastName', nonTeachingContact[0].LastName);
        contactDetails.put('Email', nonTeachingContact[0].Email);
        contactDetails.put('MobilePhone', nonTeachingContact[0].MobilePhone);
        contactDetails.put('employeeNumber', nonTeachingContact[0].Employee_Number__c);
        contactDetails.put('Gender', nonTeachingContact[0].hed__Gender__c);
        contactDetails.put('RecordTypeName', nonTeachingContact[0].RecordType.Name);
        Boolean createHostelRequest = true;
            return contactDetails;
        }
        //contactDetails.put('idCardNumber', nonTeachingContact.SRN_Number__c);
        //contactDetails.put('CurrentPusuingYear', nonTeachingContact.RH_Current_Pursuing_Year_of_Student__c);
        else{
            return null;
        }
        
    } */
    
    @AuraEnabled
public  static Map<String, String> updateHostelRequest(Id requestId, String roomSharing, Date joiningDate, Boolean isPremium) {
    Map<String, String> roomRequestStatus = new Map<String, String>();
    if (String.isBlank(roomSharing)) {
        throw new AuraHandledException('Sharing Type is required.');
    }
    if (joiningDate == null) {
        throw new AuraHandledException('Joining Date is required.');
    }
    
    try {
        // Query the Hostel Request record
        Reva_Hostel_Request__c hostelRequest = [
            SELECT Id, Type__c, Reva_Hostel_JoiningDate__c, Hostel_Room_Request_For__c,Reva_Hostel_Premium_Room__c, 
                   HR_Lead__c, Admin_Director__c, Reporting_Manager__c, HCM_Approval_Status__c, Status__c,
                   Approved_by_Admin__c, Approved_by_AdminDirector__c, Approved_by_ChiefWarden__c,
                   Approved_by_Hostel_Office__c, Approved_by_HR_Lead__c, Approved_by_ReportingManager__c,
                   Approved_by_warden__c, Is_HCM_Salary_Deduction_Cancelled__c, Is_HCM_Salary_Deduction_CNF__c,
                   Is_Revised_Salary_Push_to_HCM__c, Rejoiner__c
            FROM Reva_Hostel_Request__c  
            WHERE Id = :requestId 
            LIMIT 1
        ];
            
        List<Contact> con =[SELECT Id, hed__Gender__c, RH_Current_Pursuing_Year_of_Student__c,
        Primary_Academic_Program__r.Program_Type__c, Primary_Academic_Program__r.Name,
        Primary_Academic_Program__r.Program_Code__c FROM Contact WHERE Id =: hostelRequest.Hostel_Room_Request_For__c limit 1];
        
        List<Reva_Hostel_Room__c> hostelRooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability(roomSharing,'Staff',con[0],isPremium);
        if (hostelRooms.isEmpty()) {
            roomRequestStatus.put('Status', 'Not Available');
            return roomRequestStatus;
        }

        // Update fields based on provided parameters
       
        hostelRequest.Type__c = roomSharing;
        hostelRequest.Reva_Hostel_JoiningDate__c = joiningDate;
        hostelRequest.Reva_Hostel_Premium_Room__c = isPremium != null ? isPremium : false;
        
        
        // Reset approval-related fields
        hostelRequest.HR_Lead__c = null;
        hostelRequest.Admin_Director__c = null;
        hostelRequest.Reporting_Manager__c = null;
        hostelRequest.HCM_Approval_Status__c = 'Deduction Request Initiated';
        //hostelRequest.Status__c = 'Rejoin';
        hostelRequest.Approved_by_Admin__c = false;
        hostelRequest.Approved_by_AdminDirector__c = false;
        hostelRequest.Approved_by_ChiefWarden__c = false;
        hostelRequest.Approved_by_Hostel_Office__c = false;
        hostelRequest.Approved_by_HR_Lead__c = false;
        hostelRequest.Approved_by_ReportingManager__c = false;
        hostelRequest.Approved_by_warden__c = false;
        hostelRequest.Is_HCM_Salary_Deduction_Cancelled__c = false;
        hostelRequest.Is_HCM_Salary_Deduction_CNF__c = false;
        hostelRequest.Is_Revised_Salary_Push_to_HCM__c = false;
      //  hostelRequest.Rejoiner__c = true;

        // Perform the update
        update hostelRequest;
        roomRequestStatus.put('Status', 'Success');
        roomRequestStatus.put('Id', hostelRequest.Id);

    } catch (Exception e) {
        // Log the error for debugging
        System.debug('Error updating request: ' + e.getMessage());
        roomRequestStatus.put('Status', 'Request Failed !');
        // Throw a user-friendly error message
        throw new AuraHandledException('Error updating request: ' + e.getMessage());
    }
    return roomRequestStatus;
}
 

     @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentTeachingContact() {
        Id userId = UserInfo.getUserId();
        User UserInfo = [SELECt Id, Email FROM User WHERE Id =:userId];
        List<Contact> teachingContact = [SELECT Id, FirstName, LastName, Name,Email, Employee_Number__c ,MobilePhone,hed__Gender__c,RecordType.Name, Birthdate
                                   FROM Contact 
                                   WHERE Email = :USerInfo.Email
                                   AND (RecordType.Name = 'Professor' OR RecordType.Name = 'Non Teaching')];
        System.debug('contact email id ' + teachingContact[0].Email);
        System.debug('Contact id' + teachingContact[0].id);
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        if(teachingContact.size()>0){
        contactDetails.put('Id', teachingContact[0].Id);
        contactDetails.put('FirstName', teachingContact[0].FirstName);
        contactDetails.put('LastName', teachingContact[0].LastName);
        contactDetails.put('Email', teachingContact[0].Email);
        contactDetails.put('MobilePhone', teachingContact[0].MobilePhone);
        contactDetails.put('Birthdate', teachingContact[0].Birthdate);
        contactDetails.put('employeeNumber', teachingContact[0].Employee_Number__c);
        contactDetails.put('Gender', teachingContact[0].hed__Gender__c);
        contactDetails.put('RecordTypeName', teachingContact[0].RecordType.Name);
        Boolean createHostelRequest = true;
        //contactDetails.put('idCardNumber', nonTeachingContact.SRN_Number__c);
        //contactDetails.put('CurrentPusuingYear', nonTeachingContact.RH_Current_Pursuing_Year_of_Student__c);
        
        return contactDetails;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkHostelRequestExists() {
        try {
            // Get the current user's Id
            String userId = UserInfo.getUserId();
            
            // Fetch the user's information
            User userInfo = [SELECT Id, Email FROM User WHERE Id = :userId LIMIT 1];
            
            // Fetch the teaching contact based on the user's email
            Contact teachingContact = [SELECT Id, Email, RecordType.Name
                                       FROM Contact
                                       WHERE Email = :userInfo.Email
                                       LIMIT 1];
            
            // Check if the teaching contact exists
            if (teachingContact != null) {
                // Fetch the hostel request for the teaching contact
                Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :teachingContact.Id LIMIT 1];
                
                // Return true if the hostel request exists for the teaching contact
                return hostelRequest != null;
            } else {
                // Throw a custom exception if the teaching contact is not found
                //throw new AuraHandledException('Teaching contact not found for the current user.');
                System.debug('Teaching contact not found for the current user.');
                return false;
            }
        } catch (Exception ex) {
            // Handle other exceptions and throw an AuraHandledException
            //throw new AuraHandledException('Error checking hostel request: ' + ex.getMessage());
            System.debug('Teaching contact not found for the current user.');
            return false;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static Map<String, String> hostelDetailsCurrentlyLoggedInUser(){
        try {
            Map<String, String> result = new Map<String, String>();
            result.put('IsHostelRequestAvailable', 'No');
            result.put('RoomNumber', 'N/A');
            List<User> currentlyLoggedInUser = [Select Id, ContactId From User Where Id =: UserInfo.getUserId()];
            if(!currentlyLoggedInUser.isEmpty()){
                List<Contact> currentlyLoggedInContact = [Select Id From Contact Where Id =: currentlyLoggedInUser[0].ContactId];
                if(!currentlyLoggedInContact.isEmpty()){
                    List<Reva_Hostel_Request__c> hostelRequest = [SELECT Id, Status__c, Reva_Hostel_Room__r.Name 
                                                                  FROM Reva_Hostel_Request__c 
                                                                  WHERE Hostel_Room_Request_For__c = :currentlyLoggedInContact[0].Id 
                                                                  AND Status__c = 'Room Allotted' LIMIT 1];
                    
                    String isHostelAvailable = hostelRequest.size() != 0 ? 'Yes' : 'No';
                    String roomNumber = hostelRequest.size() != 0 ? hostelRequest[0].Reva_Hostel_Room__r.Name : 'N/A';
                    result.put('IsHostelRequestAvailable', isHostelAvailable);
                    result.put('RoomNumber', roomNumber);
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Reva_Hostel_Request__c> fetchHostelRequestDetails() {
        Id contactId = RevaMealBookingController.fetchContactId();
        List<Reva_Hostel_Request__c> revaHostelRequests = new List<Reva_Hostel_Request__c>();
        try {
            revaHostelRequests = [SELECT Id, Hostel_Room_Request_For__c, Status__c, Type__c,Reva_Hostel_Premium_Room__c, Name, Room_Number__c, Reva_Hostel_Room__c, 
                                  Reva_Hostel_Room__r.Name, Reva_Hostel_Room__r.Dormitory_Type__c, Reva_Hostel_Room__r.Block__c, Reva_Hostel_Room__r.Floor__c                            
                                  FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId];
        } catch (Exception ex) {
            
        } 
        return revaHostelRequests;
    }
    /********************Working one****************************************************/
    /* @AuraEnabled(cacheable=true)
public static List<Reva_Hostel_Request__c> getExistingHostelRequest() {
Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;


return [SELECT Id,Name, Room_Number__c, Type__c,Reva_Hostel_Premium_Room__c,Status__c,Block__c,Reva_Hostel_Room__c
FROM Reva_Hostel_Request__c
WHERE Hostel_Room_Request_For__c = :contactId and Status__c!= 'Rejoin'
//WHERE Hostel_Room_Request_For__c = :contactId
LIMIT 1];            

}*/
    @AuraEnabled(cacheable=true)
    public static List<Reva_Hostel_Request__c> getExistingHostelRequest() {
        // Get the current user's Id and Profile Name
        User currentUser = [SELECT Id, ContactId, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        system.debug('currentUser:'+currentUser.Profile.Name);
        Id contactId;
        //*******************Newly added ***************************************//

        Set<String> eligibleProfile = new Set<String>();

                for (Eligible_Profiles_For_Hostel_Request__c mapping : [SELECT Profile_Name__c FROM Eligible_Profiles_For_Hostel_Request__c]) {

                     eligibleProfile.add(mapping.Profile_Name__c);

                }

        system.debug('eligibleProfile:'+eligibleProfile);

        //**********************ended here *******************************//
        // Check if the user has the Student or Non-Teaching Staff profile
        if (currentUser.Profile.Name == 'Student Profile' || currentUser.Profile.Name == 'Non Teaching Profile' || currentUser.Profile.Name =='Student Portal Profile'  || currentUser.Profile.Name == 'Applicant Profile') {
            contactId = currentUser.ContactId;
       // } else if (currentUser.Profile.Name == 'Professor') { // commented by veera on 23-01-2025
        } else{
            // Fetch the contact based on the email for professor profile
            Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUser.Email LIMIT 1];
            contactId = contact.Id;
        }
        
        // Return the hostel request records
        return [SELECT Id, Name, Room_Number__c, Type__c,Requested_Status__c, Reva_Hostel_JoiningDate__c,Reva_Hostel_Premium_Room__c, Status__c, Block__c, Reva_Hostel_Room__c,RevaHostelVacatingDate__c
                FROM Reva_Hostel_Request__c
                WHERE Hostel_Room_Request_For__c = :contactId AND Status__c != 'Rejoin'
                LIMIT 1];
    }
    
    
    /****************************************************************************/
    
    //Update Record for Rejoin   
    @AuraEnabled
    public static void RejoingRequest(String recordId) {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Reva_Hostel_Request__c RejoinReq = [SELECT Id,Status__c,Rejoiner__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId and Status__c ='Vacated' ];
        RejoinReq.Status__c = 'Rejoin';
        RejoinReq.Rejoiner__c = true;
        update RejoinReq;
    }
    
    //*********************for alloted hostel request srinivasu veera***************************************//
    @AuraEnabled(cacheable=true)
    public static Reva_Hostel_Request__c getExistingRoomAllotedHostelRequest() {
        Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        Reva_Hostel_Request__c existingRoomAllotedRequest;
        
        try {
            existingRoomAllotedRequest = [SELECT Id,Name, Room_Number__c, Type__c,Reva_Hostel_Premium_Room__c,Status__c,Block__c,Reva_Hostel_Room__c,Requested_Status__c
                                          FROM Reva_Hostel_Request__c
                                          WHERE Hostel_Room_Request_For__c = :contactId AND Status__c='Room Allotted'
                                          LIMIT 1];
            if (existingRoomAllotedRequest == null) {
                // Throw a custom exception if no existing hostel request is found
                throw new AuraHandledException('No existing hostel requests found for the user.');
            }
            
        } catch (Exception ex) {
            // Handle exception if needed
        }
        
        return existingRoomAllotedRequest;
    }
    
    
    
    ///*****************updating Enddate for Non-teachingstaff users for hostel vacating********************////
    /*******************************working one********************************************************/
    /*@AuraEnabled
public static void updateVacationDate(String recordId, Date vacationDate) {
system.debug('record id' + recordId);
system.debug('vacation date'+ vacationDate);
try {

Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;

System.debug('Contact ID: ' + contactId);

Reva_Hostel_Request__c[] hostelRequests = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
FROM Reva_Hostel_Request__c 
WHERE Hostel_Room_Request_For__c = :contactId 
AND Id = :recordId 
LIMIT 1];

if (!hostelRequests.isEmpty()) {
Reva_Hostel_Request__c hostelRequest = hostelRequests[0];

hostelRequest.RevaHostelVacatingDate__c = vacationDate;
hostelRequest.Status__c = 'Vacated';
update hostelRequest;
} else {
throw new AuraHandledException('No hostel request record found for the user with the specified ID.');
}
} catch (Exception e) {
throw new AuraHandledException('Error updating vacation date: ' + e.getMessage());
}
}*/
    
    @AuraEnabled
    public static void updateVacationDate(String recordId, Date vacationDate, String cancellationReason) {
        system.debug('record id' + recordId);
        system.debug('vacation date'+ vacationDate);
        try {
            User currentUser = [SELECT Id, ContactId, Email, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
           // Id contactId;
            Id contactId = [SELECT Id FROM Contact WHERE Email = :currentUser.Email LIMIT 1].Id;
           /* if (currentUser.Profile.Name == 'Non Teaching Profile') {
                contactId = currentUser.ContactId;
            } else if (currentUser.Profile.Name == 'Professor') {
                // Fetch the contact based on the email for professor profile
                Contact contact = [SELECT Id FROM Contact WHERE Email = :currentUser.Email LIMIT 1];
                contactId = contact.Id;
            }*/
            
            System.debug('Contact ID: ' + contactId);
            
            Reva_Hostel_Request__c[] hostelRequests = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
                                                       FROM Reva_Hostel_Request__c 
                                                       WHERE Hostel_Room_Request_For__c = :contactId 
                                                       AND Id = :recordId 
                                                       LIMIT 1];
            
            if (!hostelRequests.isEmpty()) {
                Reva_Hostel_Request__c hostelRequest = hostelRequests[0];
                
                hostelRequest.RevaHostelVacatingDate__c = vacationDate;
                hostelRequest.Cancellation_Reason__c = cancellationReason;
                hostelRequest.Cancellation_Request_Date__c = System.Today();
                hostelRequest.Vacating_Request__c = 'Vacating Initiated';
                hostelRequest.Status__c = 'Vacating Initiated';
                update hostelRequest;
            } else {
                throw new AuraHandledException('No hostel request record found for the user with the specified ID.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating vacation date: ' + e.getMessage());
        }
    }
    /***************************************************************************************/
    /********************************************************************/
    @AuraEnabled
    public static void updateStudentVacationDate(String recordId, Date vacationDate){
        system.debug('record id' + recordId);
        system.debug('vacation date'+ vacationDate);
        try {
            // Get the contact ID associated with the logged-in user
            Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
            
            // Debug log to verify contactId
            System.debug('Contact ID: ' + contactId);
            
            // Query for the hostel request record based on the contact ID
            Reva_Hostel_Request__c[] hostelRequests = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
                                                       FROM Reva_Hostel_Request__c 
                                                       WHERE Hostel_Room_Request_For__c = :contactId 
                                                       AND Id = :recordId 
                                                       LIMIT 1];
            
            // Check if any hostel request records were found
            if (!hostelRequests.isEmpty()) {
                Reva_Hostel_Request__c hostelRequest = hostelRequests[0];
                
                // Update the vacation date field
                hostelRequest.RevaHostelVacatingDate__c = vacationDate;
                hostelRequest.Status__c = 'Vacation Initiated';
                update hostelRequest;
            } else {
                throw new AuraHandledException('No hostel request record found for the user with the specified ID.');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating vacation date: ' + e.getMessage());
        }
    }
   
    @AuraEnabled
    public static void updateStudentHostelRequest(Id id, Date programEndDate) {
        system.debug('id'+ id);
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Id = :id];
        system.debug('hostelRequests'+ hostelRequests);
        if (hostelRequests.isEmpty()) {
            throw new AuraHandledException('No hostel request found with the given Id.');
        } else {
            List<Reva_Hostel_Request__c> requestsToUpdate = new List<Reva_Hostel_Request__c>();
            
            for (Reva_Hostel_Request__c hostelRequest : hostelRequests) {
                hostelRequest.Status__c = 'Vacation Initiated';
                hostelRequest.RevaHostelVacatingDate__c = programEndDate;
                requestsToUpdate.add(hostelRequest); 
            }
            update requestsToUpdate; 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Date fetchProgramEndDate() {
        Id studentId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;
        system.debug('studentId===>' + studentId);
        Contact studentContact = [SELECT Id, Program_Batch__r.hed__End_Date__c
                                  FROM Contact
                                  WHERE Id = :studentId];
        return studentContact.Program_Batch__r.hed__End_Date__c;
    }
    
    
    /*Getting loggedinuser profile*/
    @AuraEnabled
    public static String getLoggedInUserProfile() {
        String userId = UserInfo.getUserId();
        User user = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        return user.Profile.Name;
    }
    
    @AuraEnabled(cacheable=true)
    Public Static hed__Application__c ProvisionalFeePaid(){
        User userId = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        String contactId = userId.ContactId;
        list<Student_Payment__c> stufeelist = [SELECT Id, Name, Amount__c 
                                               FROM Student_Payment__c
                                               WHERE Contact__c =:contactId 
                                               AND (Fee_Type__c LIKE '%Tuition Fee%' 
                                                    OR Fee_Type__c LIKE '%University Fee%')
                                               AND Payment_Status__c = 'Success'
                                              ];
        if(!stufeelist.isEmpty()){
            contactId = '';
        }
        hed__Application__c appli=[SELECT id, Name,hed__Applicant__c,Provisional_Admission_Fee_Paid__c FROM hed__Application__c Where hed__Applicant__c = :contactId AND Provisional_Admission_Fee_Paid__c = false];
        return appli;
    }
   
    /**********Commented for the Phase 2 deployment************/
   /* @AuraEnabled
    public static void createStudentHostelAttachment(Id requestId) {
        System.debug('Request ID: ' + requestId);
        Reva_Hostel_Request__c[] StudentVacationRequests = [SELECT Id, Name FROM Reva_Hostel_Request__c WHERE Id = :requestId LIMIT 1];
        if (!StudentVacationRequests.isEmpty()) {
            Reva_Hostel_Request__c StudentVacationRequest = StudentVacationRequests[0];
            PageReference pdfPages = Page.StudentVactionNOC;
            system.debug('StudentVactionNOC:' +pdfPages);
            pdfPages.getParameters().put('Id', StudentVacationRequest.Id);
            Blob pdfBlobs;
            
            if (pdfPages != null) {
                pdfBlobs = pdfPages.getContent();
                System.debug('Entered if block:' + pdfBlobs);
            } else {
                pdfBlobs = Blob.valueOf('Test');
                System.debug('Entered else block');
            }
            Blob myBlob = pdfBlobs; // blob variable
            String blobString = EncodingUtil.base64Encode(myBlob);
            System.debug('Blob Data: ' + blobString);
            // Create a new Attachment record and associate it with the StudentVacationRequest record
            Attachment attachment = new Attachment();
            attachment.ParentId = StudentVacationRequest.Id;
            attachment.Body = pdfBlobs;
            attachment.Name = 'HostelVacationNOC.pdf';
            attachment.ContentType = 'application/pdf';
            insert attachment;
            
            // Fetch the user to whom you want to send the email
            User recipient = [SELECT Id, Email, Name FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name = 'Warden') LIMIT 1];//[SELECT Id, Email FROM User WHERE Name = 'Warden user' LIMIT 1];
            System.debug('recepiet: '+ recipient);
            System.debug('user email: '+ recipient.Email);
            
            // Create a new email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(recipient.Email != null){
                email.setToAddresses(new List<String>{recipient.Email});
            }else{
                email.setToAddresses(new List<String>{'vamshi.udutha@cloudodyssey.co'});
            }
            
            email.setSubject('Student Hostel Vacation NOC');
            email.setPlainTextBody('Please find attached No Objection Certificate');
            
            // Attach the PDF to the email
            Messaging.EmailFileAttachment attachmentToEmail = new Messaging.EmailFileAttachment();
            attachmentToEmail.setFileName('HostelVacationNOC.pdf');
            attachmentToEmail.setBody(pdfBlobs);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachmentToEmail});
            
            // Send the email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            
        } else {
            // Handle the case where no records are found for the given requestId
            System.debug('No matching records found for the provided requestId.');
        }
    }*/
    
    /******************************Newly added by Veera for the filtering the MealBooking in NonTeachingstaff site*************************************************/
   @AuraEnabled
    public static Boolean hasExistingHostelRequest() {
    try {
        User currentUser = [SELECT Id, ContactId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Id contactId;
        
        if (currentUser.Profile.Name == 'Non Teaching Profile' && currentUser.ContactId != null) {
            contactId = currentUser.ContactId;
        } else {
            return false;
        }
        
        List<Reva_Hostel_Request__c> existingRequests = [ 
            SELECT Id 
            FROM Reva_Hostel_Request__c 
            WHERE Hostel_Room_Request_For__c = :contactId AND Status__c != 'Rejoin'
            LIMIT 1
        ];
        
        return !existingRequests.isEmpty();
        
    } catch (Exception e) {
        System.debug('Error in hasExistingHostelRequest: ' + e.getMessage());
        return false;
    }
}

    /***********************************Change request for room Type**********************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean getHostelRoomChangeRequest() {
                /* Boolean checkBox = false;
        List<Hostel_Room_Change_Request__mdt> hrcrList = [Select id,Availabile__c  From Hostel_Room_Change_Request__mdt Where Availabile__c = True limit 1];
        
        if (!hrcrList.isEmpty()) {
        checkBox = true;
        }
        return CheckBox;*/
        try {
            User currentUser = [SELECT Id, ContactId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            Id contactId;
            
            if (currentUser.ContactId != null) {
                contactId = currentUser.ContactId;
            } else {
                return false;
            }
            
            List<Reva_Hostel_Request__c> existingRequests = [ 
                SELECT Id 
                FROM Reva_Hostel_Request__c 
                WHERE Hostel_Room_Request_For__c = :contactId AND Requested_Status__c != 'Sharing type request approval pending' 
                LIMIT 1
            ];
            
            if(!existingRequests.isEmpty()){
              return [ SELECT COUNT() FROM Hostel_Room_Change_Request__mdt WHERE Availabile__c = TRUE ] > 0;
            }else{
               return false; 
            }
              
            
        } catch (Exception e) {
            System.debug('Error in hasExistingHostelRequest: ' + e.getMessage());
            return false;
        }
        
        
    }
    
       @AuraEnabled
    public static void updateHostelRoomChangeRequest(string roomType,Id recordid,string reason, Boolean isPremiumCheck ) {
        Reva_Hostel_Request__c req=[Select id,Name,Requested_Room_Type__c From Reva_Hostel_Request__c where id=: recordid limit 1];
        req.Requested_Room_Type__c = roomType;
        req.Requested_Status__c = 'Sharing type request approval pending';
        req.Request_Reason__c = reason;
        req.Request_Premium__c = isPremiumCheck;
        req.requested_updation_completed__c = true;
        req.Room_Change_Request_Rasied_Date__c = System.Today();
        update req;
    }

    @AuraEnabled(cacheable=true)
public static List<Reva_Hostel_Request__c> getHostelRequests(Id contactId){

    return [
        SELECT Id,
               Name,
              Academic_Year__c,
               Type__c,Student_Fee__c,
               Requested_Room_Type__c
        FROM Reva_Hostel_Request__c
        WHERE Hostel_Room_Request_For__c = :contactId
      ORDER BY Academic_Year__c DESC
    ];
}
}