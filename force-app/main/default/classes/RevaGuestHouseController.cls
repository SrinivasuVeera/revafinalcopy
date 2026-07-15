public without sharing class RevaGuestHouseController {
    public static final String PROFESSOR = 'Professor'; 
    public static final String STUDENT  = 'Student'; 
    public static final String NONTEACING = 'Non Teaching Profile'; 
    public static final String TEACHING = 'Teaching Profile'; 
    private static final String FEE_TYPE_APPLICATION = 'Application Fee';
    
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> saveGuestHouseRequest(
        // String name,
        
        String guestType,
        String guestUserName,
        Id selectedContactId,
        String deptName,
        Integer noOfGuests,
        String citizenshipName,
        String passportNumber,
        String address,
        String email,
        String phoneNumber,
        String roomsNumber,
        String roomType,
        String sharingType,
        DateTime startDate,
        DateTime endDate,
        Boolean PrivateVisit,
        Boolean PersonalVisit,
        String purposeOfVisit,
        String coOrdinatorName,
        String coOrdinatorMobile,
        String coOrdinatorEmail,   
        String base64Data,
        String guestDescription,
        Id selectedCoordinatorId,
        string visaNumber,
        Date visaDate,
        List<GuestPersonWrapper> guestList
    ) {
        // Fetch the current user's profile name
        User user = [Select Id, Name, ContactId,Department From User where Id = :UserInfo.getUserId() limit 1];
        system.debug('Hello:'+user);
        system.debug('Hello:'+user.ContactId);
        system.debug('Hello:'+selectedContactId);
        system.debug('Hello:'+selectedCoordinatorId);
        Reva_Guest_House_Booking__c newRequest = new Reva_Guest_House_Booking__c();
        newRequest.Room_Type__c = roomType;
        newRequest.Type_of_Guest__c = guestType;
        newRequest.Guest_Description__c = guestDescription;
        newRequest.Private__c = PrivateVisit;
        newRequest.Official__c = PersonalVisit;
        newRequest.Purpose_of_Visit__c = purposeOfVisit;
        // newRequest.Age__c = age;
        if(selectedContactId != null ){
            newRequest.ContactLookUp__c = selectedContactId;
        }else{
            newRequest.ContactLookUp__c = user.ContactId; 
        }
        newRequest.Start_Time__c = startDate;
        newRequest.End_Time__c = endDate;
        newRequest.Sharing_Type__c = sharingType;
        newRequest.No_of_Rooms__c = roomsNumber;
        newRequest.No_of_Guest__c = noOfGuests;
        if(selectedCoordinatorId != null){
            newRequest.contact__c = selectedCoordinatorId;
        }
        else {
            newRequest.contact__c = user.ContactId;
        }
        newRequest.Citizenship__c = citizenshipName;
        newRequest.Address__c = address;
        newRequest.Email__c = email;
        newRequest.Status__c = 'Initiated';
        newRequest.Mobile_Number__c = phoneNumber;
        newRequest.Passport_Number__c =  passportNumber != null ? passportNumber :'';
        newRequest.Name_of_Dept_School__c =  deptName != null ? deptName :'';
        newRequest.Co_Ordinator_Name__c =  coOrdinatorName != null ? coOrdinatorName :'';
        newRequest.Co_Ordinator_Mobile_Number__c =  coOrdinatorMobile != null ? coOrdinatorMobile :'';
        newRequest.Co_Ordinator_Email__c = coOrdinatorEmail != null ? coOrdinatorEmail :'';
        newRequest.Visa_Number__c = visaNumber != null ? visaNumber :'';
        newRequest.Visa_Expired__c = visaDate != null ? visaDate : null;
        List<User> generalAdmins = [
            SELECT Id, Name, UserRole.Name,Email,CommunityNickname, Department, Profile.Name
            FROM User 
            WHERE (Email='ramalingareddy@reva.edu.in' OR Name = 'Y Ramalinga Reddy' OR CommunityNickname='Y Ramalinga')
            //WHERE Name = 'Y Ramalinga Reddy' 
            OR ((Department = :user.Department OR Department =: deptName ) AND Profile.Name = 'School director')
        ];
        system.debug('generalAdmins:'+generalAdmins);
        if (!generalAdmins.isEmpty()) {
            for (User admin : generalAdmins) { 
                system.debug('adminNAme:'+admin);
                if (admin.UserRole != null && admin.UserRole.Name != null) {
                    if (admin.Email == 'ramalingareddy@reva.edu.in' || admin.CommunityNickname == 'Y Ramalinga') { 
                        system.debug('insideadminNAme:'+admin.Name);
                        newRequest.General_Admin__c = admin.Id;
                    } else if (admin.Profile.Name == 'School director' ) { 
                        system.debug('adminProfileNAme:'+admin.Profile.Name);
                        newRequest.Department_Head__c = admin.Id;
                        
                    }
                }
            }
        }
        
            insert newRequest;
           
        
        System.debug('newRequest-----'+newRequest);
        Map<String, String> result = new Map<String, String>();
        List<Guest_Person__c> guestRecords = new List<Guest_Person__c>();
        
        for (GuestPersonWrapper guest : guestList) {
            System.debug('guest-----'+guest);
            Guest_Person__c gp = new Guest_Person__c();
            gp.REVA_Guest_House_Booking__c  = newRequest.Id; 
            gp.Age__c = guest.age; 
            gp.Gender__c = guest.gender;
            gp.Guest_Name__c = guest.guestname;
            guestRecords.add(gp);
        }
        try {
            // insert newRequest;
            insert guestRecords;
            
            Reva_Guest_House_Booking__c insertedRecord = [SELECT Name FROM Reva_Guest_House_Booking__c WHERE Id = :newRequest.Id];
            result.put('Id', newRequest.Id);
            result.put('AutoNumber', insertedRecord.Name); // Assuming the auto-generated number field is named 'Name'
            //Addedby Rajashekar 23sept2024
            System.debug('insertedRecord-----'+insertedRecord);
            //to make guesthousenotificationflow work we need this update before it fired on creation of record but unable to fetch guest details immedietly so in update we are firing the flow.
            update newRequest;
            //endshere
            return result;
            
        } catch (Exception ex) {
            // Log and throw exception 
            System.debug('Error occurred while saving guest house request: ' + ex.getMessage());
            throw new AuraHandledException('Error occurred while saving guest house request: ' + ex.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void attachFileToGuestHouseRequest(Id guestHouseRequestId, String fileName, String base64Data) {
        Attachment attachment = new Attachment();
        attachment.Name = fileName;
        attachment.Body = EncodingUtil.base64Decode(base64Data);
        attachment.ContentType = 'application/octet-stream';
        attachment.ParentId = guestHouseRequestId;
        
        try {
            // Insert the attachment
            insert attachment;
        } catch(Exception ex) {
            // Log and throw exception 
            System.debug('Error occurred while attaching file to guest house request: ' + ex.getMessage());
            throw new AuraHandledException('Error occurred while attaching file to guest house request: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> searchContacts(String searchKey) {
        Id userId = UserInfo.getUserId();
        User user = [Select id,Name,ContactId,MobilePhone,Contact.Record_Type_Name__c,Profile.Name From User WHERE Id = :userId AND Contact.Record_Type_Name__c != NULL LIMIT 1 ];
        
        If(user.Profile.Name == 'Guest House Manager'){
            return [
                SELECT Id, Name, Email,MobilePhone,SRN_Number__c
                FROM Contact
                WHERE Email LIKE :('%' + searchKey + '%') AND (Record_Type_Name__c = 'Non Teaching' OR
                                                              Record_Type_Name__c = 'Student' OR Record_Type_Name__c = 'Professor' OR Record_Type_Name__c = 'Alumni') Limit 100
            ];
        }Else{
            return [
                SELECT Id, Name, Email,MobilePhone,SRN_Number__c
                FROM Contact
                WHERE Record_Type_Name__c =: user.Contact.Record_Type_Name__c
                AND Email LIKE :('%' + searchKey + '%') Limit 100
            ];
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getGuestCoordinator(String searchcon) {
        
       return [ SELECT Id, Name, Email,MobilePhone,SRN_Number__c
                FROM Contact
                WHERE Email LIKE :('%' + searchcon + '%') AND (Record_Type_Name__c = 'Non Teaching' OR Record_Type_Name__c = 'Professor') Limit 100
              ];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getUsersBasedOnProfile() {
        
        user us = [SELECT Id, Name FROM User WHERE id =:UserInfo.getUserId() ORDER BY Name ASC limit 1];
        
        return us.Name;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static String getLoggedInUserProfile() {
        Id userId = UserInfo.getUserId();
        User user = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        return user.Profile.Name;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean RoomAvailibility(String occupancy, String roomType, DateTime startDate, DateTime endDate,Decimal roomsNumber) {
        System.debug('Hello'+occupancy);
        System.debug('Hello'+roomType);
        System.debug('Hello'+startDate);
        System.debug('Hello'+endDate);
         System.debug('Hello'+roomsNumber);
        List<REVA_Guest_House_Room__c> allRooms = [
            SELECT Id, Room_Type__c, Name, Maximum_Occupancy__c, Available__c 
            FROM REVA_Guest_House_Room__c
            WHERE Maximum_Occupancy__c = :occupancy 
            AND Room_Type__c = :roomType 
            AND Available__c = True
        ];
        System.debug('Hello'+allRooms);    
        // Query bookings that overlap with the specified time range
        List<Reva_Guest_House_Booking__c> overlappingBookings = [
            SELECT Id, Name,Status__c, Start_Time__c, End_Time__c, Room_Type__c, No_of_Rooms__c,Sharing_Type__c, Guest_House_Room__c 
            FROM Reva_Guest_House_Booking__c  
            WHERE (No_of_Rooms__c != Null OR No_of_Rooms__c = NULL)
            AND Sharing_Type__c = :occupancy 
            AND Room_Type__c = :roomType
            AND Status__c != 'Cancelled'
            AND ((Start_Time__c <= :endDate AND End_Time__c >= :startDate) OR
                 (Start_Time__c >= :startDate AND End_Time__c <= :endDate) OR
                 (Start_Time__c <= :startDate AND End_Time__c >= :endDate) OR
                 (Start_Time__c >= :startDate AND End_Time__c <= :endDate))
        ];
        
        Decimal totalBookedRooms = 0;
        for (Reva_Guest_House_Booking__c booking : overlappingBookings) {
            if (booking.No_of_Rooms__c != null) {
                totalBookedRooms += Decimal.valueOf(booking.No_of_Rooms__c);
            }
        }
        
        System.debug('Hello'+overlappingBookings);
        System.debug('Hello'+allRooms.size());
        System.debug('Hello'+totalBookedRooms );
        System.debug('Hello'+ roomsNumber);
        System.debug('Hello'+(totalBookedRooms + roomsNumber));
        return allRooms.size() >=  (totalBookedRooms + roomsNumber);
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<Reva_Guest_House_Booking__c> getGuestHouserequests(){
        User currentUser = [SELECT ContactId,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('currentUser==:'+currentUser + 'contact==>' + currentUser.ContactId);  
        
        //ModifiedbyRajashekar 24sept2024 because for professor user there are no contacts being connected in backend
       /* if (currentUser.ContactId == null ) { //&&(currentUser.Profile.Name != 'Professor' || currentUser.Profile.Name != 'Hostel Profile')
            system.debug('Inside null==>'); 
            return new List<Reva_Guest_House_Booking__c>();
        } */
        Id contactId = currentUser.ContactId;
        system.debug('currentUser Contact==>:'+contactId); 
        
        if(currentUser.Profile.Name == 'Professor' || currentUser.Profile.Name == 'Hostel Profile'){
            system.debug('Inside profess and hostel office==>'); 
              return [SELECT Id, Name, Status__c, Start_Time__c, End_Time__c, Room_Type__c, Sharing_Type__c, Guest_House_Room__c, Type_of_Guest__c
                FROM Reva_Guest_House_Booking__c  
                WHERE OwnerId =: currentUser.Id ORDER BY Name DESC];
        }
        else if (contactId !=null){
            return [SELECT Id, Name, Status__c, Start_Time__c, End_Time__c, Room_Type__c, Sharing_Type__c, Guest_House_Room__c, Type_of_Guest__c
            FROM Reva_Guest_House_Booking__c  
            WHERE ContactLookUp__c = :contactId ORDER BY Name DESC];
        }
        else {
            return new List<Reva_Guest_House_Booking__c>();
        }
       
        
        
    }
    
    @AuraEnabled
    public static void cancelGuestHouseRequest(Id guestHouseRequestId) {
        Reva_Guest_House_Booking__c booking = [SELECT Id, Status__c FROM Reva_Guest_House_Booking__c WHERE Id = :guestHouseRequestId LIMIT 1];
        if (booking != null) {
            booking.Status__c = 'Cancelled';
            update booking;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCitizenshipPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Reva_Guest_House_Booking__c.Citizenship__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getRoomTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Reva_Guest_House_Booking__c.Room_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSharingTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Reva_Guest_House_Booking__c.Sharing_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getGuestTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Reva_Guest_House_Booking__c.Type_of_Guest__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getRoomPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Reva_Guest_House_Booking__c.No_of_Rooms__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getLabel());
        }
        
        return picklistValues;
    }
    
   /***********************working one************************************/ 
   /* @AuraEnabled(cacheable=true)
    public static List<String> getDistinctSchoolNames() {
        // Query all relevant records
        List<Fee_Master__c> feeMasterRecords = [
            SELECT School_Name__c 
            FROM Fee_Master__c 
            WHERE Fee_Type__c = :FEE_TYPE_APPLICATION 
            AND IsActive__c = true 
            AND (
                (Program_Batch__r.Name LIKE '%2022%' OR Application_Number_Prefix__c LIKE '24%') 
                OR (Program_Batch__r.Name LIKE '%2023%' OR Application_Number_Prefix__c LIKE '24%')
                OR Program_Batch__r.Name != null 
                OR Application_Number_Prefix__c != null
            )
        ];
        
        // Use a Set to store unique school names
        Set<String> schoolNamesSet = new Set<String>();
        for (Fee_Master__c record : feeMasterRecords) {
            if (record.School_Name__c != null) {
                schoolNamesSet.add(record.School_Name__c);
            }
        }
        
        // Convert the Set to a List and sort it
        List<String> schoolNames = new List<String>(schoolNamesSet);
        schoolNames.sort();
        system.debug('schoolNames:'+schoolNames);
        return schoolNames;
    }*/
    @AuraEnabled(cacheable=true)
public static List<String> getDistinctSchoolNames() {
    // Query all relevant Account records with RecordType 'University Department'
    List<Account> accountRecords = [
        SELECT Name 
        FROM Account 
        WHERE RecordType.Name = 'University Department'
    ];
    
    // Use a Set to store unique school names
    Set<String> schoolNamesSet = new Set<String>();
    for (Account account : accountRecords) {
        if (account.Name != null) {
            schoolNamesSet.add(account.Name);
        }
    }
    
    // Convert the Set to a List and sort it
    List<String> schoolNames = new List<String>(schoolNamesSet);
    schoolNames.sort();
    System.debug('School Names: ' + schoolNames);
    
    return schoolNames;
}

    /*********************ended here***********************************/
    
    @AuraEnabled(cacheable=true)
    public static List<Guest_Person__c> getChildRecords(Id guestHouseRequestId) {
        return [SELECT Id, Guest_Name__c, Age__c, Gender__c FROM Guest_Person__c WHERE REVA_Guest_House_Booking__c = :guestHouseRequestId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Fee_Master__c> getChangeSchoolPrograms() {
        
        return [select School_Name__c, Program_Name_Display__c, Program_Type__c, Program_Name__c 
                from Fee_Master__c
                where Fee_Type__c = :FEE_TYPE_APPLICATION and IsActive__c = true and ((Program_Batch__r.name like '%2022%' or Application_Number_Prefix__c like '24%') or (Program_Batch__r.name like '%2023%' or Application_Number_Prefix__c like '24%')OR Program_Batch__r.Name != null
                                                                                      OR Application_Number_Prefix__c != null)
                order by School_Name__c, Program_Name_Display__c, Application_Number_Prefix__c desc];
    }    
    public class GuestPersonWrapper{
        @AuraEnabled Public string guestname {get;set;}
        @AuraEnabled Public string age {get;set;}
        @AuraEnabled Public string gender {get;set;}
        @AuraEnabled Public string id {get;set;}
        
    }
    
    
     @AuraEnabled(cacheable=true)
    public static Boolean checkIfGuestHouseManager() {
        // Example of checking if the user has a specific permission set
        return [SELECT Id FROM User WHERE Profile.Name='Guest House Manager' AND Id=:UserInfo.getUserId()].size()>0;
    }
    
    
    
    
}