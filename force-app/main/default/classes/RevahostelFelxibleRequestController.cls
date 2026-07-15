public class RevahostelFelxibleRequestController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getStudentBySRN(String srn) {
        
        Contact studentContact = [
            SELECT Id, FirstName, LastName, hed__WorkEmail__c,
            MobilePhone, hed__Gender__c, Application_Number__c,
            RH_Current_Pursuing_Year_of_Student__c,
            Is_Final_Year__c,
            Program_Batch__r.Name,
            (SELECT Id FROM Reva_Hostel_Requests__r LIMIT 1)
            FROM Contact
            WHERE (Application_Number__c = :srn or SRN_Number__c =:srn) AND Record_Type_Name__c = 'Student'
            LIMIT 1
        ];
        
        Map<String, Object> contactDetails = new Map<String, Object>();
        
        contactDetails.put('Name', studentContact.FirstName + ' ' + studentContact.LastName);
        contactDetails.put('Id', studentContact.Id);
        contactDetails.put('Email', studentContact.hed__WorkEmail__c);
        contactDetails.put('Mobile', studentContact.MobilePhone);
        contactDetails.put('Gender', studentContact.hed__Gender__c);
        contactDetails.put('SRN', studentContact.Application_Number__c);
        contactDetails.put('Year', studentContact.RH_Current_Pursuing_Year_of_Student__c);
        contactDetails.put('ProgramBatch', studentContact.Program_Batch__r.Name);
        contactDetails.put('IsFinalYear', studentContact.Is_Final_Year__c);
        
        return contactDetails;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getAcademicYears() {
        List<String> years = new List<String>();
        
        for (Academic_Year__mdt rec : [ SELECT MasterLabel FROM Academic_Year__mdt
                                      ]) {
                                          years.add(rec.MasterLabel);
                                      }
        
        return years;
    }
    
    @AuraEnabled
    public static Id getLoggedInUserId() {
        return UserInfo.getUserId();
    }
    
    @AuraEnabled
    public static Map<String, String> RevaHostelRoomAllotment(String requestForId, String occupancy, Boolean isPremium, Date joiningDate,String planType, Decimal finalAmount,Decimal concession, String comments) {
        Map<String, String> roomRequestStatus = new Map<String, String>();
        system.debug('this.currentUserContact.Id:'+requestForId);
        system.debug('this. this.sharingType.Id:'+ occupancy);
        // Validate required parameters
        if (String.isBlank(requestForId) || String.isBlank(occupancy)) {
            throw new AuraHandledException('Missing required parameters: Request ID or Occupancy.');
        }
        Contact studentContact = [
            SELECT Id, FirstName, LastName, hed__WorkEmail__c,
            MobilePhone, hed__Gender__c, Application_Number__c,
            RH_Current_Pursuing_Year_of_Student__c,
            Is_Final_Year__c,Employee_Number__c,
            Program_Batch__r.Name,
            (SELECT Id FROM Reva_Hostel_Requests__r LIMIT 1)
            FROM Contact
            WHERE Id=:requestForId
            LIMIT 1
        ];
        try {
            
            String roomType = 'Student';
            
            User u = [
                SELECT Id, Profile.Name
                FROM User
                WHERE ContactId = :studentContact.Id
                LIMIT 1
            ];
            
            // ✅ Directly get profile name
            String profileName = u.Profile.Name;
            
            if (profileName == Constants.StudentPortalProfile || profileName == Constants.ApplicantProfile || profileName == Constants.StudentProfile) {
                roomType = 'Student';
            } 
            else  {
                roomType = 'Staff';           
                Contact teachingContact = [SELECT Id, FirstName, LastName, Name,Email, MobilePhone,hed__Gender__c,RecordType.Name FROM Contact  WHERE Employee_Number__c = :studentContact.Employee_Number__c AND (RecordType.Name = 'Professor' OR RecordType.Name = 'Non Teaching')];
                requestForId = teachingContact.Id;
                 
            }
            String originalRequestForId = requestForId;
            contact con= [ Select Id,Name,Advanced_Hostel_Registration__c From contact Where Id=:requestForId];
            // Fetch contact details and available hostel rooms
            List<Contact> contactDetails = getContactDetails(requestForId);
            If(con.Advanced_Hostel_Registration__c == False){
                List<Reva_Hostel_Room__c> hostelRoomsAvailable = hostelRoomsAvailability(occupancy, roomType, contactDetails[Constants.baseIndex], isPremium);
                
                if (hostelRoomsAvailable.isEmpty()) {
                    roomRequestStatus.put('Status', 'Room not available for the requested category!');
                    return roomRequestStatus;
                }
            }
            // Check if a hostel request already exists
            List<Reva_Hostel_Request__c> existingRequests = [
                SELECT Id, Status__c 
                FROM Reva_Hostel_Request__c 
                WHERE Hostel_Room_Request_For__c = :originalRequestForId 
                AND Status__c != 'Rejoin' AND ((Room_Request_Type__c = 'Professor' OR Room_Request_Type__c = 'Non Teaching'))
            ];
            
            List<Reva_Hostel_Request__c> hostelRequestList = new List<Reva_Hostel_Request__c>();
            Reva_Hostel_Request__c newHostelRequest = new Reva_Hostel_Request__c();
            newHostelRequest.Hostel_Room_Request_For__c = requestForId;
            newHostelRequest.Type__c = occupancy;
            newHostelRequest.Reva_Hostel_Premium_Room__c = isPremium;
            newHostelRequest.Reva_Hostel_JoiningDate__c = joiningDate;
            newHostelRequest.Plan_Type__c = planType;
            newHostelRequest.Flexible_Stay_Amount__c= finalAmount;
            newHostelRequest.Concession__c = concession;
            newHostelRequest.Comments__c = comments;
            // Check for eligible profiles and update additional fields
            Set<String> eligibleProfiles = new Set<String>();
            for (Eligible_Profiles_For_Hostel_Request__c mapping : [SELECT Profile_Name__c FROM Eligible_Profiles_For_Hostel_Request__c]) {
                eligibleProfiles.add(mapping.Profile_Name__c);
            }
            
            if (eligibleProfiles.contains(profileName)) {
                newHostelRequest.HCM_Approval_Status__c = 'Deduction Request Initiated';
                newHostelRequest.Salary_Last_Revised_Date__c = System.today();
            }
            
            // Add new request to the list
            If(con.Advanced_Hostel_Registration__c == true){
                newHostelRequest.Advanced_Registration__c = true;
            }
            hostelRequestList.add(newHostelRequest);
            System.debug('hostelRequestList----'+hostelRequestList);
            
            // Update existing requests if applicable
            if(existingRequests.size()> 0) {
                for (Reva_Hostel_Request__c existingRequest : existingRequests) {
                    existingRequest.Status__c = 'Rejoin';
                    existingRequest.Rejoiner__c = true;
                    hostelRequestList.add(existingRequest);
                }
            }
            
            List<Reva_Hostel_Request__c> StudentexistingRequests = [
                SELECT Id, Status__c 
                FROM Reva_Hostel_Request__c 
                WHERE Hostel_Room_Request_For__c = :originalRequestForId 
                AND Status__c != 'Rejoin' AND  (Hostel_Room_Request_For__r.Advanced_Hostel_Registration__c = true AND Room_Request_Type__c = 'Student')
            ];
            if(StudentexistingRequests.size()> 0) {
                for (Reva_Hostel_Request__c existingRequest : StudentexistingRequests) {
                    existingRequest.Rejoiner__c = true;
                    hostelRequestList.add(existingRequest);
                }
            }
            
            
            if(hostelRequestList.size()>0){
                System.debug('hostelRequestList-size()---'+hostelRequestList.size());
                // Upsert requests
                upsert hostelRequestList;
                System.debug('hostelRequestList---'+hostelRequestList);
                // Update contact record
                Contact contactRecord = new Contact(Id = requestForId, HasHostelRequest__c = true);
                update contactRecord;
                
                roomRequestStatus.put('Status', 'Request Created!');
                roomRequestStatus.put('Id', newHostelRequest.Id);
                
            }
            
        } catch (Exception e) {
            // Log error for debugging and return a user-friendly error
            System.debug('Error in RevaHostelRoomAllotment: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while processing the request: ' + e.getMessage());
        }
        
        return roomRequestStatus;
    }
    
    @AuraEnabled
    public static List<Contact> getContactDetails(String requestForId) {
        //System.debug('isPremium =='+isPremium);
        // Fetch contact details based on the Record Type Name
        return [SELECT Id, hed__Gender__c, RH_Current_Pursuing_Year_of_Student__c,
                Primary_Academic_Program__r.Program_Type__c, Primary_Academic_Program__r.Name,
                Primary_Academic_Program__r.Program_Code__c
                FROM Contact WHERE ID = :requestForId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<Reva_Hostel_Room__c> hostelRoomsAvailability(String occupancy, String roomType, Contact recordDetails, Boolean isPremium) {
        
        System.debug('occupancy =='+occupancy);
        System.debug('roomType =='+roomType);
        System.debug('isPremium == ' + isPremium);
        System.debug('recordDetails == ' + recordDetails);
        
        REVA_Course_Type__c studentCourseDetails = new REVA_Course_Type__c();
        
        //if (roomType == Constants.Student) {/*existing one06-06-2024*/
        if (roomType == Constants.Student || roomType == Constants.Applicant) {
            studentCourseDetails = getCourses(recordDetails.Primary_Academic_Program__r.Program_Code__c);
        }
        
        if (roomType == 'Student' && studentCourseDetails != null && recordDetails.hed__Gender__c == 'Male') {  // Add null check here
            
            String roomCategory = (roomType == 'Staff' || roomType == 'Demo' || roomType == 'Non-Staff') ? 'None - Demo/Staff' :
            (recordDetails.RH_Current_Pursuing_Year_of_Student__c == '1st Year' || recordDetails.RH_Current_Pursuing_Year_of_Student__c == 'Unknown') ? (studentCourseDetails.Engineering__c ? (studentCourseDetails.CS__c ? '1 Eng CS' : '1 Eng Non-CS') : '1 Non-Eng') :
            (studentCourseDetails.Engineering__c ? (studentCourseDetails.CS__c ? 'Eng CS' : 'Eng Non-CS') : 'Non-Eng');   
                system.debug('roomCategory::'+roomCategory);
            List<Reva_Hostel_Room__c> roomRequest = [SELECT Id, Name, Block__c, Floor__c,
                                                     Vacant_Occupancy__c, Occupied_Occupancy__c, Room_Type__c,
                                                     Dormitory_Type__c, Room_Category__c
                                                     FROM Reva_Hostel_Room__c WHERE Vacant_Occupancy__c >= 0 AND Maximum_Occupancy__c = :occupancy AND
                                                     Dormitory_Type__c = :recordDetails.hed__Gender__c == 'Male' ? 'Boys' : 'Girls'  AND Room_Type__c = :roomType AND Is_Premium__c = :isPremium 
                                                     //AND Room_Category__c = :roomCategory 
                                                     ORDER BY Block__c, Name LIMIT 1];
            system.debug('roomCategory::'+occupancy);
            system.debug('roomCategory::'+recordDetails.hed__Gender__c);
            system.debug('roomCategory::'+roomType);
            system.debug('roomCategory::'+isPremium);
            system.debug('roomCategory::'+roomCategory);
            
            return roomRequest;
        }else if ((roomType == 'Non-Staff' || roomType == 'Staff' ) && recordDetails.hed__Gender__c == 'Male') {
            /*from above else if && recordDetails.hed__Gender__c == 'Male'  newly added on 11-092024*/
            System.debug('Handling Non-Staff or Staff room type'+roomType);
            
            String roomCategory = 'None - Demo/Staff';  
            List<Reva_Hostel_Room__c> roomRequest = [SELECT Id, Name, Block__c, Floor__c,
                                                     Vacant_Occupancy__c, Occupied_Occupancy__c, Room_Type__c,
                                                     Dormitory_Type__c, Room_Category__c
                                                     FROM Reva_Hostel_Room__c WHERE Vacant_Occupancy__c >= 0 AND Maximum_Occupancy__c = :occupancy AND
                                                     Dormitory_Type__c = :recordDetails.hed__Gender__c == 'Male' ? 'Boys' : 'Girls'  AND Room_Type__c = :roomType AND Is_Premium__c = :isPremium 
                                                     // AND Room_Category__c = :roomCategory 
                                                     ORDER BY Block__c, Name LIMIT 1];
            System.debug('roomRequest size for Non-Staff/Staff: ' + roomRequest.size());
            return roomRequest;
        }
        else if(recordDetails.hed__Gender__c == 'Female'){
            System.debug(' Check for the Girl Student');
            String dormitaryType = 'Girls';
            String roomCategory;
            String secondaryCategory = null;
            system.debug('Hello'+roomType);
            system.debug('Hello'+studentCourseDetails);
            List<Reva_Hostel_Room__c> roomRequest = new List<Reva_Hostel_Room__c>();
            if (roomType == 'Staff' || roomType == 'Demo' || roomType == 'Non-Staff') {
                //roomCategory = 'None - Demo/Staff';  /*this one commneted below one added on 11-09-2024*/
                roomCategory = 'Demo/Staff';
                roomRequest = [SELECT Id, Name, Block__c, Floor__c,
                               Vacant_Occupancy__c, Occupied_Occupancy__c, Room_Type__c,
                               Dormitory_Type__c, Room_Category__c
                               FROM Reva_Hostel_Room__c WHERE Vacant_Occupancy__c >= 0 AND Maximum_Occupancy__c = :occupancy AND
                               Dormitory_Type__c = :dormitaryType  AND Room_Type__c = :roomType AND Is_Premium__c = :isPremium 
                               //AND Room_Category__c = :roomCategory 
                               ORDER BY Block__c, Name LIMIT 1];        
                return roomRequest;
            }
            else if(roomType == 'Student' && studentCourseDetails != null){
                
                If(occupancy == '2'){
                    roomCategory = 'Non-Eng';  
                }
                else{
                    if (recordDetails.RH_Current_Pursuing_Year_of_Student__c == '1st Year') {
                        if (studentCourseDetails.Engineering__c) {
                            roomCategory = '1 Eng';
                        }
                        else{
                            roomCategory = '1 Non-Eng';                         
                        }
                        
                    }
                    else if(recordDetails.RH_Current_Pursuing_Year_of_Student__c == '2nd Year'){
                        if (studentCourseDetails.Engineering__c) {
                            roomCategory = '2 Eng';
                        }
                        else{
                            roomCategory = '2 Non-Eng';                         
                        }
                        
                    }
                    else if(recordDetails.RH_Current_Pursuing_Year_of_Student__c == '3rd Year'){
                        if (studentCourseDetails.Engineering__c) {
                            roomCategory = '3 Eng';
                        }
                        else{
                            roomCategory = '3 Non-Eng';  
                            secondaryCategory = '3-4 Non-Eng/PG';
                        }
                        
                    }
                    else if(recordDetails.RH_Current_Pursuing_Year_of_Student__c == '4th Year'){
                        if (studentCourseDetails.Engineering__c) {
                            roomCategory = '4 Eng';
                            secondaryCategory = '4 Eng/PG';
                        }
                        else{
                            roomCategory = '4 Non-Eng';
                            secondaryCategory = '3-4 Non-Eng/PG';                         
                        }
                        
                    }
                    else if(studentCourseDetails.PG__c){
                        roomCategory = '4 Eng/PG'; 
                        secondaryCategory = '3-4 Non-Eng/PG';
                        
                    }
                    else if(!studentCourseDetails.Engineering__c){
                        roomCategory = 'Non-Eng'; 
                    }
                    else if(studentCourseDetails.PUC__c){
                        roomCategory = 'PUC';
                    }
                }
                system.debug('Hello'+roomCategory);
                
                roomRequest = [SELECT Id, Name, Block__c, Floor__c,
                               Vacant_Occupancy__c, Occupied_Occupancy__c, Room_Type__c,
                               Dormitory_Type__c, Room_Category__c
                               FROM Reva_Hostel_Room__c WHERE Vacant_Occupancy__c >= 0 AND Maximum_Occupancy__c = :occupancy AND
                               Dormitory_Type__c = :dormitaryType  AND Room_Type__c = :roomType AND Is_Premium__c = :isPremium 
                               //AND Room_Category__c = :roomCategory
                               ORDER BY Block__c, Name LIMIT 1];        
                
                if(roomRequest.size() == 0 && secondaryCategory != null){
                    
                    roomRequest = [SELECT Id, Name, Block__c, Floor__c,Vacant_Occupancy__c, Occupied_Occupancy__c, Room_Type__c, Dormitory_Type__c, Room_Category__c
                                   FROM Reva_Hostel_Room__c WHERE Vacant_Occupancy__c >= 0 AND Maximum_Occupancy__c = :occupancy AND Dormitory_Type__c = :dormitaryType  AND Room_Type__c = :roomType AND Is_Premium__c = :isPremium 
                                   ORDER BY Block__c, Name LIMIT 1];        
                    
                    return roomRequest;
                    
                }
                
                return roomRequest;
                
            }
            
            
            return new List<Reva_Hostel_Room__c>();
            
        }
        else {
            // Handle the case when studentCourseDetails is null
            // You can throw an exception or return an empty list based on your requirement.
            return new List<Reva_Hostel_Room__c>();
        }
    }
    
    @AuraEnabled
    public static REVA_Course_Type__c getCourses(String CourseCode) {
        List<REVA_Course_Type__c> courses = [SELECT Id, Name, Engineering__c, CS__c, Course_Code__c, PG__c,PUC__c
                                             FROM REVA_Course_Type__c WHERE Course_Code__c = :CourseCode LIMIT 1];
        
        if (!courses.isEmpty()) {
            return courses[0];
        } else {
            // Handle the case when no records are found, you can return null or throw an exception.
            return null;
        }
    }
    
    
    //*******************************************************************************************************//
    public class HostelFeeResponse {
        @AuraEnabled
        public Decimal hostelFee { get; set; }
    }
    
    public class RoomPriceResponse {
        @AuraEnabled
        public String roomType { get; set; }
        
        @AuraEnabled
        public Decimal price { get; set; }
    }
    @AuraEnabled(cacheable=true)
    public static HostelFeeResponse calculateHostelFee(String roomType, Boolean isPremium, Boolean isFinalYear, string gender,string planType, string academicYear) {
        HostelFeeResponse response = new HostelFeeResponse();
        String Checkgender ;
        List<Hostel_Fee_Structure__c> hostelSettings = new  List<Hostel_Fee_Structure__c> ();
       // hostelSettings = [SELECT Id,REVA_Hostel_Academic_Year__r.Is_Active_Academic__c,Plan_Type__c, Name,Gender__c, Hostel_Room_Fees__c, Occupancy__c, Is_Final_Year__c, Premium__c FROM Hostel_Fee_Structure__c WHERE REVA_Hostel_Academic_Year__r.Is_Active_Academic__c = TRUE AND Plan_Type__c ='One Semester'];
       if (academicYear != null && academicYear != '') {
         hostelSettings = [SELECT Id,REVA_Hostel_Academic_Year__r.Is_Active_Academic__c,Plan_Type__c, Name,Gender__c, Hostel_Room_Fees__c, Occupancy__c, Is_Final_Year__c, Premium__c FROM Hostel_Fee_Structure__c WHERE REVA_Hostel_Academic_Year__r.name =: academicYear AND Plan_Type__c ='One Semester'];
        }else{
         hostelSettings = [SELECT Id,REVA_Hostel_Academic_Year__r.Is_Active_Academic__c,Plan_Type__c, Name,Gender__c, Hostel_Room_Fees__c, Occupancy__c, Is_Final_Year__c, Premium__c FROM Hostel_Fee_Structure__c WHERE REVA_Hostel_Academic_Year__r.Is_Active_Academic__c = TRUE AND Plan_Type__c ='One Semester'];
        }
        
        if(gender == 'Male'){
            Checkgender = 'Boys';
        }else{
            if(gender == 'Female'){
                Checkgender = 'Girls';
            }
        }
        // Debug log for the size of hostelSettings
        System.debug('Number of Hostel Settings: ' + hostelSettings.size());
        System.debug('Number of Hostel Settings: ' + Checkgender);
        for (Hostel_Fee_Structure__c setting : hostelSettings) {
            
            Boolean settingFinalYear = setting.Is_Final_Year__c == true;
            Boolean settingPremium = setting.Premium__c == true;
            
            if (isFinalYear == true 
                && settingFinalYear == true
                && settingPremium == (isPremium == true)
                && setting.Occupancy__c == roomType 
                && setting.Gender__c == Checkgender 
                && setting.Plan_Type__c == planType) {
                    
                    response.hostelFee = setting.Hostel_Room_Fees__c != null ? setting.Hostel_Room_Fees__c : 0;
                    break;
                } 
            
            else if (isFinalYear == false && settingFinalYear == false  && settingPremium == (isPremium == true) && setting.Occupancy__c == roomType && setting.Gender__c == Checkgender && setting.Plan_Type__c == planType) {
                         
                         response.hostelFee = setting.Hostel_Room_Fees__c != null ? setting.Hostel_Room_Fees__c : 0;
                         break;
                     }
        }
        // If a matching setting is not found, look for a generic setting without considering final year
        if (response.hostelFee == null) {
            for (Hostel_Fee_Structure__c setting : hostelSettings) {
                System.debug('Processing Hostel Setting (Generic): ' + setting);
                System.debug('setting.Premium__c: ' + setting.Premium__c);
                System.debug('setting.Occupancy__c  ' + setting.Occupancy__c );
                System.debug('setting.Gender__c ' + setting.Gender__c);
                System.debug('setting.Plan_Type__c ' + setting.Plan_Type__c);
                
                if (setting.Premium__c == isPremium && setting.Occupancy__c == roomType && setting.Gender__c == Checkgender && setting.Plan_Type__c == planType) {
                    System.debug('Matching Generic Setting Found: ' + setting);
                    response.hostelFee = setting.Hostel_Room_Fees__c != null ? setting.Hostel_Room_Fees__c : 0;
                    break;
                }
            }
        }
        
        // Debug log for the final hostel fee value
        System.debug('Final Hostel Fee: ' + response.hostelFee);
        
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RoomPriceResponse> getAllRoomPrices() {
        List<RoomPriceResponse> roomPrices = new List<RoomPriceResponse>();
        
        List<Hostel_Fee_Structure__c> metadataRecords = [SELECT Id,Name, REVA_Hostel_Academic_Year__r.Is_Active_Academic__c,Hostel_Room_Fees__c, Occupancy__c FROM Hostel_Fee_Structure__c
                                                         WHERE REVA_Hostel_Academic_Year__r.Is_Active_Academic__c = TRUE AND Plan_Type__c ='One Semester' ];
        
        for (Hostel_Fee_Structure__c metadata : metadataRecords) {
            RoomPriceResponse roomPrice = new RoomPriceResponse();
            roomPrice.roomType = metadata.Name;
            roomPrice.price = metadata.Hostel_Room_Fees__c != null ? metadata.Hostel_Room_Fees__c : 0;
            roomPrices.add(roomPrice);
        }
        
        return roomPrices;
    }
    
    @AuraEnabled
    public static Boolean createStudentFeeRecord(String contactId, String paymentType, Boolean isPremium, Decimal totalFee, Id hostelRequestId, string planType, Decimal concession) {
        try {
            // Fetch cautionFeeAmount from Custom Label
            Decimal cautionFeeAmount;
            if(isPremium == true){
                cautionFeeAmount = Decimal.valueOf(Label.Reva_Hostel_Premium_Caution_Fee_Amount);
            }
            else{
                cautionFeeAmount = Decimal.valueOf(Label.Reva_Hostel_Caution_Fee_Amount);
            }
            
            // Retrieve the Contact details
            Contact contactDetails = [SELECT Id, Name, RH_Current_Pursuing_Year_of_Student__c, Personal_Email__c, MobilePhone,Advanced_Hostel_Registration__c, Father_Mobile_Number__c, Mother_Email_ID__c, Mother_Mobile_Number__c,Split_Booking_Fee__c,
                                      (select id,Name,Reva_Hostel_Premium_Room__c from Reva_Hostel_Requests__r) FROM Contact WHERE Id = :contactId LIMIT 1];
            system.debug('contactDetails::'+contactDetails);
            REVA_Hostel_Academic_Year__c academicYear = new REVA_Hostel_Academic_Year__c();
            if(contactDetails.Advanced_Hostel_Registration__c == true){
                academicYear =[SELECT Id,Name,Is_Active_Academic__c From REVA_Hostel_Academic_Year__c WHERE Is_Next_Year_Academic__c = true LIMIT 1];
                system.debug('Heloo');
            }else{
                academicYear =[SELECT Id,Name,Is_Active_Academic__c From REVA_Hostel_Academic_Year__c WHERE Is_Active_Academic__c = true LIMIT 1];
                system.debug('Hiii');
            }
            String yearPart = academicYear.Name.replace('Academic ', '');
            if (contactDetails != null) {
                System.debug('Contact Details: ' + contactDetails);
                
                // Create the Student Fee record
                Student_Fee__c studentFee = new Student_Fee__c();
                //studentFee.Name = contactDetails.Name +' '+contactDetails.RH_Current_Pursuing_Year_of_Student__c+' '+'Hostel Fee';
                //studentFee.Name = 'Hostel Fee - '+Date.today().year();
                studentFee.Name = 'Hostel Fee '+yearPart;
                studentFee.Contact__c = contactDetails.Id; // Set the lookup relationship to the Contact
                studentFee.Student_Personal_Email__c = contactDetails.Personal_Email__c;
                studentFee.Student_Mobile_Number__c = contactDetails.MobilePhone;
                studentFee.Father_Email_ID__c = contactDetails.Mother_Email_ID__c;
                studentFee.Father_Mobile_Number__c = contactDetails.Father_Mobile_Number__c;
                studentFee.Mother_Email_ID__c = contactDetails.Mother_Email_ID__c;
                studentFee.Mother_Mobile_Number__c = contactDetails.Mother_Mobile_Number__c;
                studentFee.Fee_Type__c = 'Hostel Fee';
                if (contactDetails.RH_Current_Pursuing_Year_of_Student__c != 'Unknown') {
                    studentFee.Fee_Year__c = contactDetails.RH_Current_Pursuing_Year_of_Student__c ;
                    studentFee.Session__c = contactDetails.RH_Current_Pursuing_Year_of_Student__c ;
                }
                studentFee.Amount_Pending__c = totalFee;
                studentFee.Amount__c = totalFee;
                studentFee.Actual_Program_Fee__c = totalFee;
                studentFee.Concession__c = concession;
                studentFee.Premium_Room__c = isPremium;
                
                // Set the Fee_Payment_Criteria__c based on the selected payment type for student fee
                if (paymentType.equalsIgnoreCase('Full Payment')) {
                    // Assuming 'Hostel Fee - Full Payment' is the name of the Fee Payment Criteria record
                    List<Fee_Payment_Criteria__c> fullPaymentCriteriaList = [SELECT Id FROM Fee_Payment_Criteria__c WHERE Name = 'Hostel Fee - Full Payment' LIMIT 1];
                    
                    if (!fullPaymentCriteriaList.isEmpty()) {
                        studentFee.Fee_Payment_Criteria__c = fullPaymentCriteriaList[0].Id;
                        studentFee.Number_of_Installments__c = 1;
                        studentFee.Payment_Type__c = 'Full Payment';
                        System.debug('Using Full Payment Criteria: ' + fullPaymentCriteriaList[0]);
                    } else {
                        System.debug('Full Payment Criteria not found');
                        // Handle the case when the Fee Payment Criteria record is not found
                        return false;
                    }
                } else if (paymentType.equalsIgnoreCase('Partial Payment')) {
                    // Assuming 'Hostel Fee - Partial Payment' is the name of the Fee Payment Criteria record
                    List<Fee_Payment_Criteria__c> partialPaymentCriteriaList = [SELECT Id FROM Fee_Payment_Criteria__c WHERE Name = 'Hostel Fee - Full Payment' LIMIT 1];
                    if (!partialPaymentCriteriaList.isEmpty()) {
                        studentFee.Fee_Payment_Criteria__c = partialPaymentCriteriaList[0].Id;
                        studentFee.Number_of_Installments__c = 3;
                        studentFee.Payment_Type__c = 'Partial Payment';
                        System.debug('Using Partial Payment Criteria: ' + partialPaymentCriteriaList[0]);
                    } else {
                        System.debug('Partial Payment Criteria not found');
                        // Handle the case when the Fee Payment Criteria record is not found
                        return false;
                    }
                }
                
                // Insert the Student Fee record
                insert studentFee;
                
                //AddedbyRajashekar31stJuly2024
                list<Student_Fee__c> lstSf = new list<Student_Fee__c>();
                lstSf.add(studentFee);
                
                
                
                string feetype = 'single';
                string discription = '';
                decimal partialAmt;
                string RefId = Utility.generateRandomNumber();
                Set<Id> stuFeeIdSet = new Set<Id>();
                //we are fetching first hostel request directly for premium and nonpremium values.
                if(contactDetails.Reva_Hostel_Requests__r[0].Reva_Hostel_Premium_Room__c == false){
                    partialAmt = Decimal.valueOf(System.Label.WithoutPremium);
                }else if(contactDetails.Reva_Hostel_Requests__r[0].Reva_Hostel_Premium_Room__c == true){
                    partialAmt = Decimal.valueOf(System.Label.WithPremium);
                }
                
                if(contactDetails.Split_Booking_Fee__c == true){
                    // FEE_StudentPayment_Ctrl.BillDeskPayGenratePaymentLink(lstSf,partialAmt,feetype,'');
                    Set<Id> stuFeeIdSetv1 = new Set<Id>();
                    list<Student_Fee_Payment__c> lstSfp = new list<Student_Fee_Payment__c>();
                    
                    //  for(Student_Fee__c objstuFee : lstSf){
                    
                    Student_Payment__c objStuFeePay1 = new Student_Payment__c();
                    objStuFeePay1.Reference_Id__c = RefId;
                    objStuFeePay1.Amount__c = partialAmt;
                    // objStuFeePay1.Billdesk_Url__c = ep;
                    objStuFeePay1.Contact__c = contactId;
                    objStuFeePay1.Payment_Status__c = 'Payment Link Created';
                    objStuFeePay1.Payment_Gateway__c = 'Billdesk';
                    objStuFeePay1.Mode_of_Payment__c = 'Online';
                    objStuFeePay1.Fee_Type__c =  discription + studentFee.Fee_Type__c; 
                    objStuFeePay1.Program_Enrollment__c =  studentFee.Program_Enrollment__c;
                    objStuFeePay1.Split_Validation__c = true;
                    insert objStuFeePay1;
                    system.debug('objStuFeePay1==>'+objStuFeePay1.Name);
                    
                    Student_Fee_Payment__c sfp = new Student_Fee_Payment__c();
                    if(feeType == 'single'){
                        sfp.Amount__c = partialAmt;
                    }
                    else{
                        sfp.Amount__c = studentFee.Amount_Pending__c;
                    }
                    sfp.Mode_of_Payment__c = 'Online';
                    sfp.Reference_Id__c = RefId;
                    sfp.Student_Fee__c =  studentFee.id; 
                    // if(checkForSplitObject != null && !String.isEmpty(checkForSplitObject.Id)){
                    //   sfp.Student_Payment__c = checkForSplitObject.Id;
                    // }else{
                    sfp.Student_Payment__c = objStuFeePay1.id;
                    // }
                    sfp.Line_Item_Payment_Gateway__c = 'Billdesk';                   
                    lstSfp.add(sfp);
                    //  }   
                    
                    if(lstSfp.size() > 0){
                        insert lstSfp;
                    }
                    
                }
                //endshere31stJuly2024
                
                // Update the Hostel Request with the Student Fee record
                if (hostelRequestId != null) {
                    Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c WHERE Id = :hostelRequestId LIMIT 1];
                    hostelRequest.Student_Fee__c = studentFee.Id;
                    update hostelRequest;
                    System.debug('Updated Hostel Request with Student Fee');
                }
                Decimal withoutPremium = Decimal.valueOf(System.Label.WithoutPremium);
                Decimal withPremium = Decimal.valueOf(System.Label.WithPremium);
                
                // Check if the logged-in user belongs to the applicant profile
              /*  String applicantProfileId = [SELECT Id FROM Profile WHERE Name = 'Applicant Profile' LIMIT 1].Id;
                system.debug('UserInfo.getProfileId()'+UserInfo.getProfileId());
                system.debug('applicantProfileId'+applicantProfileId);
                if (UserInfo.getProfileId() == applicantProfileId) {
                    // Create the Student Payment record
                    Student_Payment__c studentPayment = new Student_Payment__c();
                    //studentPayment.Name = contactDetails.Name + ' ' + 'Hostel Payment';
                    studentPayment.Contact__c = contactDetails.Id;
                    if(paymentType.equalsIgnoreCase('Partial Payment')){
                        studentPayment.Amount__c = (isPremium == true) ? withPremium : withoutPremium;       
                    }else{
                        
                        studentPayment.Amount__c = totalFee;
                    }
                    studentPayment.Payment_Status__c = 'Pending';
                    studentPayment.Mode_of_Payment__c = 'Online';
                    studentPayment.Payment_Gateway__c = '';
                    studentPayment.Fee_Type__c = 'Hostel Fee';
                    insert studentPayment;
                    System.debug('Student Payment Record Inserted: ' + studentPayment);
                    
                    // Create the Student Fee Payment record
                    Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c();
                    studentFeePayment.Student_Fee__c = studentFee.Id;
                    studentFeePayment.Student_Payment__c = studentPayment.Id;
                    // studentFeePayment.Line_Item_Payment_Status__c = studentPayment.Payment_Status__c;
                    studentFeePayment.Line_Item_Payment_Status__c = '';
                    studentFeePayment.Mode_of_Payment__c = studentPayment.Mode_of_Payment__c;
                    studentFeePayment.Line_Item_Payment_Gateway__c =  studentPayment.Payment_Gateway__c;
                    studentFeePayment.Amount__c = studentPayment.Amount__c;               
                    studentFeePayment.Transaction_Date_Time__c = system.now();
                    insert studentFeePayment;
                    System.debug('Student Fee Payment Record Inserted: ' + studentFeePayment);
                }*/    
            
                Boolean Rejioncan = false;
                
                // Check if the contact is a rejoiner
                List<Reva_Hostel_Request__c> RHR = [SELECT Id, Rejoiner__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId ORDER BY CreatedDate ASC];
                if (!RHR.isEmpty() && RHR[0].Rejoiner__c) {
                    Rejioncan = true;
                    System.debug('Rejoiner: ' + Rejioncan);
                }
                
                if (!Rejioncan && planType == 'One Semester') {
                    // Create the Caution Fee record
                    Student_Fee__c cautionFee = new Student_Fee__c();
                    //cautionFee.Name = contactDetails.Name + ' ' + contactDetails.RH_Current_Pursuing_Year_of_Student__c + ' ' + 'Caution Deposit';
                    //cautionFee.Name =  'Caution Deposit - '+ Date.today().year();
                    cautionFee.Name = 'Caution Deposit '+yearPart;
                    cautionFee.Contact__c = contactDetails.Id;
                    cautionFee.Student_Personal_Email__c = contactDetails.Personal_Email__c;
                    cautionFee.Student_Mobile_Number__c = contactDetails.MobilePhone;
                    cautionFee.Father_Email_ID__c = contactDetails.Mother_Email_ID__c;
                    cautionFee.Father_Mobile_Number__c = contactDetails.Father_Mobile_Number__c;
                    cautionFee.Mother_Email_ID__c = contactDetails.Mother_Email_ID__c;
                    cautionFee.Mother_Mobile_Number__c = contactDetails.Mother_Mobile_Number__c;
                    cautionFee.Fee_Type__c = 'Hostel Fee';
                    cautionFee.Description__c = 'For Room Allocation Caution Deposit Should Be Paid';
                    cautionFee.Actual_Program_Fee__c = cautionFeeAmount;
                    cautionFee.Session__c = contactDetails.RH_Current_Pursuing_Year_of_Student__c;
                    
                    // Set the Fee_Payment_Criteria__c for caution fee to always Full Payment
                    // Assuming 'Caution Fee - Full Payment' is the name of the Fee Payment Criteria record
                    List<Fee_Payment_Criteria__c> cautionFullPaymentCriteriaList = [SELECT Id FROM Fee_Payment_Criteria__c WHERE Name = 'Hostel Fee - Full Payment' LIMIT 1];
                    if (!cautionFullPaymentCriteriaList.isEmpty()) {
                        cautionFee.Fee_Payment_Criteria__c = cautionFullPaymentCriteriaList[0].Id;
                        cautionFee.Number_of_Installments__c = 1;
                        cautionFee.Payment_Type__c = 'Full Payment';
                        System.debug('Using Full Payment Criteria for Caution Fee: ' + cautionFullPaymentCriteriaList[0]);
                    } else {
                        System.debug('Full Payment Criteria not found for Caution Fee');
                        // Handle the case when the Fee Payment Criteria record is not found
                        return false;
                    }
                    
                    cautionFee.Amount_Pending__c = cautionFeeAmount;
                    cautionFee.Amount__c = cautionFeeAmount;
                    cautionFee.Premium_Room__c = isPremium;
                    
                    // Insert the Caution Fee record
                    insert cautionFee;
                    System.debug('Caution Fee Record Inserted: ' + cautionFee);
                    
                   /* if (UserInfo.getProfileId() == applicantProfileId) {
                        // Create the Caution Payment record
                        Student_Payment__c cautionPayment = new Student_Payment__c();
                        // cautionPayment.Name = contactDetails.Name + ' ' + 'Caution Payment';
                        cautionPayment.Contact__c = contactDetails.Id;
                        cautionPayment.Amount__c = cautionFeeAmount;
                        //cautionPayment.Payment_Status__c = 'Pending';
                        cautionPayment.Payment_Status__c = 'Pending';
                        cautionPayment.Mode_of_Payment__c = 'Online';
                        cautionPayment.Payment_Gateway__c = '';
                        cautionPayment.Fee_Type__c = 'Hostel Fee';
                        insert cautionPayment;
                        System.debug('Caution Payment Record Inserted: ' + cautionPayment);
                        
                        // Create the Caution Fee Payment record
                        Student_Fee_Payment__c cautionFeePayment = new Student_Fee_Payment__c();
                        cautionFeePayment.Student_Fee__c = cautionFee.Id;
                        cautionFeePayment.Student_Payment__c = cautionPayment.Id;
                        cautionFeePayment.Amount__c = cautionFeeAmount;
                        cautionFeePayment.Line_Item_Payment_Status__c ='';
                        //cautionFeePayment.Line_Item_Payment_Status__c = cautionPayment.Payment_Status__c;
                        cautionFeePayment.Mode_of_Payment__c = cautionPayment.Mode_of_Payment__c;
                        cautionFeePayment.Line_Item_Payment_Gateway__c =  cautionPayment.Payment_Gateway__c;
                        cautionFeePayment.Amount__c = cautionPayment.Amount__c;               
                        cautionFeePayment.Transaction_Date_Time__c = system.now();
                        insert cautionFeePayment;
                        System.debug('Caution Fee Payment Record Inserted: ' + cautionFeePayment);
                    }*/
                }
                
                return true; // Return true after successful insertion
                
            } else {
                // Handle the case when no records are found
                System.debug('No Contact record found for ID: ' + contactId);
                return false; // Return false if no records are found
            }
        } catch (Exception e) {
            // Log the exception or handle the error as needed
            System.debug('Exception creating fee record: ' + e.getMessage());
            return false; // Return false in case of an exception
        }
    }
    
      public static Boolean isPUCtestigdStudent(String mobileNumber) {
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
        public static Boolean isPUCtestidStudent(String mobileNumber) {
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
    public static List<Map<String,String>> getSharingOptions() {

        List<Map<String,String>> options = new List<Map<String,String>>();

        for(Room_Sharing_Config__mdt room :
            [SELECT MasterLabel,
                    Room_Value__c,
                    Premium_Only__c,
                    Active__c
             FROM Room_Sharing_Config__mdt
             WHERE Active__c = TRUE
             ORDER BY MasterLabel]) {

            Map<String,String> opt = new Map<String,String>();
            opt.put('label', room.MasterLabel);
            opt.put('value', room.Room_Value__c);
            opt.put('premiumOnly', String.valueOf(room.Premium_Only__c));

            options.add(opt);
        }

        return options;
    }

}