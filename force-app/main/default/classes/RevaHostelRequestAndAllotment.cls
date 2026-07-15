//******************************** Apex Class - RevaHostelRequestAndAllotment ********************************
//
//  Description -  This apex class is used to check the hostel room availability and return the room number
//  CreatedOn   - 03/11/2023
//  CreatedBy   - Ashish Saini
//
//************************************************************************************************************
public without sharing class RevaHostelRequestAndAllotment {
    
    @AuraEnabled
    public static Id getLoggedInUserId() {
        return UserInfo.getUserId();
    }
    
    @AuraEnabled
    public static Map<String, String> RevaHostelRoomAllotment(String requestForId, String occupancy, Boolean isPremium, Date joiningDate) {
        Map<String, String> roomRequestStatus = new Map<String, String>();
    
        // Validate required parameters
        if (String.isBlank(requestForId) || String.isBlank(occupancy)) {
            throw new AuraHandledException('Missing required parameters: Request ID or Occupancy.');
        }
    
        try {
         
            String roomType = 'Student';
            Id profileId= userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName'+profileName);
            if (profileName == Constants.StudentPortalProfile || profileName == Constants.ApplicantProfile || profileName == Constants.StudentProfile) {
                
                // if (profileName == Constants.StudentPortalProfile || profileName == Constants.ApplicantProfile ) { existing one above line added based on the UAT student profile
                roomType = 'Student';
            } 
            else  {
                roomType = 'Staff';
                User UserInfo = [SELECT Id, Email FROM User WHERE Id = :getLoggedInUserId()];
                System.debug('Current User Info: ' + UserInfo.Id);
                System.debug('Current User Info: ' + UserInfo.Email);
                Contact teachingContact = [SELECT Id, FirstName, LastName, Name,Email, MobilePhone,hed__Gender__c,RecordType.Name
                                           FROM Contact 
                                           WHERE Email = :USerInfo.Email
                                           AND (RecordType.Name = 'Professor' OR RecordType.Name = 'Non Teaching')];
                requestForId = teachingContact.Id;
                System.debug('Request For ID: ' + requestForId);
                System.debug('Request For IDTeaching: ' + teachingContact.Id);
                
                
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
                    
                    roomRequest = [SELECT Id, Name, Block__c, Floor__c,
                                   Vacant_Occupancy__c, Occupied_Occupancy__c, Room_Type__c,
                                   Dormitory_Type__c, Room_Category__c
                                   FROM Reva_Hostel_Room__c WHERE Vacant_Occupancy__c >= 0 AND Maximum_Occupancy__c = :occupancy AND
                                   Dormitory_Type__c = :dormitaryType  AND Room_Type__c = :roomType AND Is_Premium__c = :isPremium 
                                   //AND Room_Category__c = :roomCategory 
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
   /********************************Existing one***********************************************/
    @AuraEnabled
    public static Boolean createStudentFeeRecord(String contactId, String paymentType, Boolean isPremium, Decimal totalFee, Id hostelRequestId) {
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
                        sfp.Line_Item_Payment_Status__c = objStuFeePay1.Payment_Status__c;
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
                String applicantProfileId = [SELECT Id FROM Profile WHERE Name = 'Applicant Profile' LIMIT 1].Id;
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
                    studentFeePayment.Line_Item_Payment_Status__c = studentPayment.Payment_Status__c;
                   //studentFeePayment.Line_Item_Payment_Status__c = '';
                    studentFeePayment.Mode_of_Payment__c = studentPayment.Mode_of_Payment__c;
                    studentFeePayment.Line_Item_Payment_Gateway__c =  studentPayment.Payment_Gateway__c;
                    studentFeePayment.Amount__c = studentPayment.Amount__c;               
                    studentFeePayment.Transaction_Date_Time__c = system.now();
                    insert studentFeePayment;
                    System.debug('Student Fee Payment Record Inserted: ' + studentFeePayment);
                }
                
                Boolean Rejioncan = false;
                
                // Check if the contact is a rejoiner
                List<Reva_Hostel_Request__c> RHR = [SELECT Id, Rejoiner__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId ORDER BY CreatedDate ASC];
                if (!RHR.isEmpty() && RHR[0].Rejoiner__c) {
                    Rejioncan = true;
                    System.debug('Rejoiner: ' + Rejioncan);
                }
                
                if (!Rejioncan) {
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
                    
                    if (UserInfo.getProfileId() == applicantProfileId) {
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
                        //cautionFeePayment.Line_Item_Payment_Status__c ='';
                        cautionFeePayment.Line_Item_Payment_Status__c = cautionPayment.Payment_Status__c;
                        cautionFeePayment.Mode_of_Payment__c = cautionPayment.Mode_of_Payment__c;
                        cautionFeePayment.Line_Item_Payment_Gateway__c =  cautionPayment.Payment_Gateway__c;
                        cautionFeePayment.Amount__c = cautionPayment.Amount__c;               
                        cautionFeePayment.Transaction_Date_Time__c = system.now();
                        insert cautionFeePayment;
                        System.debug('Caution Fee Payment Record Inserted: ' + cautionFeePayment);
                    }
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
     /*******************************************************************************/
     /*******************************************************************************/
   /* @AuraEnabled
    public static Boolean createStudentFeeRecord(String contactId, String paymentType, Boolean isPremium, Decimal totalFee, Id hostelRequestId) {
    try {
        // Fetch cautionFeeAmount from Custom Label
        Decimal cautionFeeAmount = Decimal.valueOf(Label.Reva_Hostel_Caution_Fee_Amount);

        // Retrieve the Contact details
        Contact contactDetails = [SELECT Id, Name, RH_Current_Pursuing_Year_of_Student__c, Personal_Email__c, MobilePhone, Father_Mobile_Number__c, Mother_Email_ID__c, Mother_Mobile_Number__c FROM Contact WHERE Id = :contactId LIMIT 1];

        if (contactDetails != null) {
            System.debug('Contact Details: ' + contactDetails);

            // Create the Student Fee record
            Student_Fee__c studentFee = new Student_Fee__c();
            studentFee.Name = 'Hostel Fee - ' + Date.today().year();
            studentFee.Contact__c = contactDetails.Id; // Set the lookup relationship to the Contact
            studentFee.Student_Personal_Email__c = contactDetails.Personal_Email__c;
            studentFee.Student_Mobile_Number__c = contactDetails.MobilePhone;
            studentFee.Father_Email_ID__c = contactDetails.Mother_Email_ID__c;
            studentFee.Father_Mobile_Number__c = contactDetails.Father_Mobile_Number__c;
            studentFee.Mother_Email_ID__c = contactDetails.Mother_Email_ID__c;
            studentFee.Mother_Mobile_Number__c = contactDetails.Mother_Mobile_Number__c;
            studentFee.Fee_Type__c = 'Hostel Fee';
            if (contactDetails.RH_Current_Pursuing_Year_of_Student__c != 'Unknown') {
                studentFee.Fee_Year__c = contactDetails.RH_Current_Pursuing_Year_of_Student__c;
                studentFee.Session__c = contactDetails.RH_Current_Pursuing_Year_of_Student__c;
            }
            studentFee.Premium_Room__c = isPremium;

            Decimal withoutPremium = Decimal.valueOf(System.Label.WithoutPremium);
            Decimal withPremium = Decimal.valueOf(System.Label.WithPremium);

            if (paymentType.equalsIgnoreCase('Full Payment')) {
                // Full Payment
                List<Fee_Payment_Criteria__c> fullPaymentCriteriaList = [SELECT Id FROM Fee_Payment_Criteria__c WHERE Name = 'Hostel Fee - Full Payment' LIMIT 1];

                if (!fullPaymentCriteriaList.isEmpty()) {
                    studentFee.Fee_Payment_Criteria__c = fullPaymentCriteriaList[0].Id;
                    studentFee.Number_of_Installments__c = 1;
                    studentFee.Payment_Type__c = 'Full Payment';
                    studentFee.Amount_Pending__c = totalFee;
                    studentFee.Amount__c = totalFee;
                    studentFee.Actual_Program_Fee__c = totalFee;
                    System.debug('Using Full Payment Criteria: ' + fullPaymentCriteriaList[0]);
                } else {
                    System.debug('Full Payment Criteria not found');
                    return false;
                }
            } else if (paymentType.equalsIgnoreCase('Partial Payment')) {
                // Partial Payment
                List<Fee_Payment_Criteria__c> partialPaymentCriteriaList = [SELECT Id FROM Fee_Payment_Criteria__c WHERE Name = 'Hostel Fee - Partial Payment' LIMIT 1];

                if (!partialPaymentCriteriaList.isEmpty()) {
                    studentFee.Fee_Payment_Criteria__c = partialPaymentCriteriaList[0].Id;
                    studentFee.Number_of_Installments__c = 3;
                    studentFee.Payment_Type__c = 'Partial Payment';
                    studentFee.Amount_Pending__c = (isPremium == true) ? withPremium : withoutPremium;
                    studentFee.Amount__c = (isPremium == true) ? withPremium : withoutPremium;
                    studentFee.Actual_Program_Fee__c = totalFee;
                    System.debug('Using Partial Payment Criteria: ' + partialPaymentCriteriaList[0]);

                    // Insert the Student Fee record for partial payment
                    insert studentFee;
                    System.debug('Partial Payment Fee Record Inserted: ' + studentFee);

                    // Create another record for the remaining fee
                    Student_Fee__c remainingFee = studentFee.clone(false);
                    remainingFee.Name = 'Hostel Fee Remaining - ' + Date.today().year();
                    remainingFee.Amount_Pending__c = totalFee - studentFee.Amount__c;
                    remainingFee.Amount__c = totalFee - studentFee.Amount__c;
                    remainingFee.Fee_Payment_Criteria__c = partialPaymentCriteriaList[0].Id;
                    remainingFee.Number_of_Installments__c = 3;
                    remainingFee.Payment_Type__c = 'Partial Payment';
                    insert remainingFee;
                    System.debug('Remaining Fee Record Inserted: ' + remainingFee);

                    // Update the Hostel Request with the Student Fee record
                    if (hostelRequestId != null) {
                        Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c WHERE Id = :hostelRequestId LIMIT 1];
                        hostelRequest.Student_Fee__c = studentFee.Id;
                        update hostelRequest;
                        System.debug('Updated Hostel Request with Student Fee');
                    }

                    // Create the Student Payment record for the initial partial payment
                    Student_Payment__c studentPayment = new Student_Payment__c();
                    studentPayment.Contact__c = contactDetails.Id;
                    studentPayment.Amount__c = studentFee.Amount__c;
                    studentPayment.Payment_Status__c = 'Pending';
                    studentPayment.Mode_of_Payment__c = 'Online';
                    studentPayment.Payment_Gateway__c = '';
                    studentPayment.Fee_Type__c = 'Hostel Fee';
                    insert studentPayment;
                    System.debug('Student Payment Record Inserted: ' + studentPayment);

                    // Create the Student Fee Payment record for the initial partial payment
                    Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c();
                    studentFeePayment.Student_Fee__c = studentFee.Id;
                    studentFeePayment.Student_Payment__c = studentPayment.Id;
                    studentFeePayment.Line_Item_Payment_Status__c = studentPayment.Payment_Status__c;
                    studentFeePayment.Mode_of_Payment__c = studentPayment.Mode_of_Payment__c;
                    studentFeePayment.Line_Item_Payment_Gateway__c = studentPayment.Payment_Gateway__c;
                    studentFeePayment.Amount__c = studentPayment.Amount__c;
                    studentFeePayment.Transaction_Date_Time__c = system.now();
                    insert studentFeePayment;
                    System.debug('Student Fee Payment Record Inserted: ' + studentFeePayment);

                    // Create the Student Payment record for the remaining fee
                    Student_Payment__c remainingPayment = new Student_Payment__c();
                    remainingPayment.Contact__c = contactDetails.Id;
                    remainingPayment.Amount__c = remainingFee.Amount__c;
                    remainingPayment.Payment_Status__c = 'Pending';
                    remainingPayment.Mode_of_Payment__c = 'Online';
                    remainingPayment.Payment_Gateway__c = '';
                    remainingPayment.Fee_Type__c = 'Hostel Fee';
                    insert remainingPayment;
                    System.debug('Remaining Payment Record Inserted: ' + remainingPayment);

                    // Create the Student Fee Payment record for the remaining fee
                    Student_Fee_Payment__c remainingFeePayment = new Student_Fee_Payment__c();
                    remainingFeePayment.Student_Fee__c = remainingFee.Id;
                    remainingFeePayment.Student_Payment__c = remainingPayment.Id;
                    remainingFeePayment.Line_Item_Payment_Status__c = remainingPayment.Payment_Status__c;
                    remainingFeePayment.Mode_of_Payment__c = remainingPayment.Mode_of_Payment__c;
                    remainingFeePayment.Line_Item_Payment_Gateway__c = remainingPayment.Payment_Gateway__c;
                    remainingFeePayment.Amount__c = remainingPayment.Amount__c;
                    remainingFeePayment.Transaction_Date_Time__c = system.now();
                    insert remainingFeePayment;
                    System.debug('Remaining Fee Payment Record Inserted: ' + remainingFeePayment);
                } else {
                    System.debug('Partial Payment Criteria not found');
                    return false;
                }
            } else {
                // Insert the Student Fee record for full payment
                insert studentFee;
                System.debug('Full Payment Fee Record Inserted: ' + studentFee);
            }

            Boolean Rejoiner = false;

            // Check if the contact is a rejoiner
            List<Reva_Hostel_Request__c> RHR = [SELECT Id, Rejoiner__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :contactId ORDER BY CreatedDate ASC];
            if (!RHR.isEmpty() && RHR[0].Rejoiner__c) {
                Rejoiner = true;
                System.debug('Rejoiner: ' + Rejoiner);
            }

            if (!Rejoiner) {
                // Create the Caution Fee record
                Student_Fee__c cautionFee = new Student_Fee__c();
                cautionFee.Name = 'Caution Deposit - ' + Date.today().year();
                cautionFee.Contact__c = contactDetails.Id;
                cautionFee.Student_Personal_Email__c = contactDetails.Personal_Email__c;
                cautionFee.Student_Mobile_Number__c = contactDetails.MobilePhone;
                cautionFee.Father_Email_ID__c = contactDetails.Mother_Email_ID__c;
                cautionFee.Father_Mobile_Number__c = contactDetails.Father_Mobile_Number__c;
                cautionFee.Mother_Email_ID__c = contactDetails.Mother_Email_ID__c;
                cautionFee.Mother_Mobile_Number__c = contactDetails.Mother_Mobile_Number__c;
                cautionFee.Fee_Type__c = 'Caution Fee';
                cautionFee.Fee_Payment_Criteria__c = 'a0320000007n9cNAAQ'; // Caution fee payment criteria
                cautionFee.Payment_Type__c = 'One Time Payment';
                cautionFee.Amount_Pending__c = cautionFeeAmount;
                cautionFee.Amount__c = cautionFeeAmount;
                cautionFee.Actual_Program_Fee__c = cautionFeeAmount;

                // Insert the Caution Fee record
                insert cautionFee;
                System.debug('Caution Fee Record Inserted: ' + cautionFee);

                // Update the Hostel Request with the Caution Fee record
                //if (hostelRequestId != null) {
                   // Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c WHERE Id = :hostelRequestId LIMIT 1];
                    //hostelRequest.Caution_Fee__c = cautionFee.Id;
                   // update hostelRequest;
                   // System.debug('Updated Hostel Request with Caution Fee');
                //}
            }
            return true;
        } else {
            System.debug('Contact Details not found');
            return false;
        }
    } catch (Exception e) {
        System.debug('Exception: ' + e.getMessage());
        return false;
    }
}*/


     /*******************************************************************************/
    
    @AuraEnabled
    public static void createPaymentRecord(Decimal amount, Decimal pendingAmount) {
        system.debug('pendingAmount:'+pendingAmount);
        user userId=[SELECT id, Name, ContactId from User Where id= :UserInfo.getUserId() ];
        /*****************newly added*****************/
        List<Student_Fee__c> studentFees = [SELECT Id, Name, Fee_Type__c, Contact__c 
                                            FROM Student_Fee__c 
                                            WHERE Contact__c = :userId.ContactId 
                                            AND Payment_Type__c = 'Partial Payment' 
                                            AND Fee_Type__c = 'Hostel Fee'];
        
        if (studentFees.isEmpty()) {
            System.debug('No Student Fee records found for the criteria.');
            return; // Exit the method if no records are found
        }
        
        Student_Fee__c studentFee = studentFees[0];
        /************************************/
        /**esisring one student_Fee__c studentFee=[select id, Name,Fee_type__c,contact__C from student_Fee__c where contact__C =:userId.ContactId and Payment_Type__c= 'Partial Payment' and Fee_type__c = 'Hostel Fee'];*/
        Student_Payment__c studentPayment = new Student_Payment__c();
        studentPayment.Contact__c = userId.ContactId;
        
        studentPayment.Amount__c = amount;
        studentPayment.Payment_Status__c = 'Pending';
        studentPayment.Mode_of_Payment__c = 'Online';
        studentPayment.Payment_Gateway__c = '';
        studentPayment.Fee_Type__c = 'Hostel Fee';
        insert studentPayment;  
        
        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c();
        studentFeePayment.Student_Fee__c = studentFee.Id;
        studentFeePayment.Student_Payment__c = studentPayment.Id;
        //studentFeePayment.Line_Item_Payment_Status__c ='';
        studentFeePayment.Line_Item_Payment_Status__c = studentPayment.Payment_Status__c;
        studentFeePayment.Mode_of_Payment__c = studentPayment.Mode_of_Payment__c;
        studentFeePayment.Line_Item_Payment_Gateway__c =  studentPayment.Payment_Gateway__c;
        studentFeePayment.Amount__c = studentPayment.Amount__c;               
        studentFeePayment.Transaction_Date_Time__c = system.now();
        insert studentFeePayment;
        
        Student_Payment__c studentPayment2 = new Student_Payment__c();
        studentPayment2.Contact__c = userId.ContactId;    
        studentPayment2.Amount__c = pendingAmount - amount;
        studentPayment2.Payment_Status__c = 'Pending';
        studentPayment2.Mode_of_Payment__c = 'Online';
        studentPayment2.Payment_Gateway__c = '';
        studentPayment2.Fee_Type__c = 'Hostel Fee';
        insert studentPayment2; 
        
        Student_Fee_Payment__c studentFeePayment2 = new Student_Fee_Payment__c();
        studentFeePayment2.Student_Fee__c = studentFee.Id;
        studentFeePayment2.Student_Payment__c = studentPayment2.Id;
        //studentFeePayment2.Line_Item_Payment_Status__c='';
        studentFeePayment2.Line_Item_Payment_Status__c = studentPayment2.Payment_Status__c;
        studentFeePayment2.Mode_of_Payment__c = studentPayment2.Mode_of_Payment__c;
        studentFeePayment2.Line_Item_Payment_Gateway__c =  studentPayment2.Payment_Gateway__c;
        studentFeePayment2.Amount__c = studentPayment2.Amount__c;               
        studentFeePayment2.Transaction_Date_Time__c = system.now();
        insert studentFeePayment2;
    }
    
    @AuraEnabled(cacheable=true)
    public static Student_Fee__c getStudentFee() {
        User userId = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        // Student_Fee__c studentFee = existing one
        List<Student_Fee__c> studentFees = [
            SELECT Id, Name, Fee_Type__c, Payment_Type__c, Amount__c, Amount_Paid__c, Amount_Pending__c
            FROM Student_Fee__c
            WHERE Contact__c = :userId.ContactId
            AND Payment_Type__c = 'Partial Payment'
            AND Fee_Type__c = 'Hostel Fee'
            LIMIT 1
        ];
        /******newly added 24072024****/
        if (!studentFees.isEmpty()) {
            Student_Fee__c studentFee = studentFees[0];
            System.debug('Retrieved Student Fee: ' + studentFee);
            return studentFee;
        } else {
            // Handle the case where no records are found
            System.debug('No Student Fee record found.');
            return null; // Or handle appropriately
        }
        /*********************/
        /*System.debug('Retrieved Student Fee: ' + studentFee);
return studentFee;*/
    }
    @AuraEnabled(cacheable=true)
    public static map<string,object> getStudentFeeAndPaymentDetails (){
        map<string,object> result= new map<string,object>();
        User userId = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<Student_Fee__c> studentFees = [
            SELECT Id, Name, Fee_Type__c, Payment_Type__c, Amount__c, Amount_Paid__c, Amount_Pending__c
            FROM Student_Fee__c
            WHERE Contact__c = :userId.ContactId
            AND Payment_Type__c = 'Partial Payment'
            AND Fee_Type__c = 'Hostel Fee'AND Amount_Pending__c > 0
            LIMIT 1
        ];
        
        result.put('studentFees',studentFees.isEmpty() ? null : studentFees[0]);
        
        List<Student_Payment__c> studentPayments = [
            SELECT Id, Fee_Type__c, Payment_Status__c 
            FROM Student_Payment__c 
            WHERE Contact__c = :userId.ContactId AND Fee_Type__c = 'Hostel Fee'
        ];
        boolean PaymentCheck = true;
        for(Student_Payment__c studentPayment:studentPayments){
            if(studentPayment.Payment_Status__c != 'Success'){
                PaymentCheck = false;
            }          
        }
        system.debug('PaymentCheck:'+PaymentCheck);
        if(PaymentCheck == true){
            result.put('studentPayments',studentPayments.isEmpty() ? null : studentPayments[0]);
        }
        return result;
    }
}