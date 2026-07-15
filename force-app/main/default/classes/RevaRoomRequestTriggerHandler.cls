public class RevaRoomRequestTriggerHandler {
    public static void TeachingStaffRoomAllocation (List<Reva_Hostel_Request__c> Reva_Hostel_Requests) {
        for (Reva_Hostel_Request__c revaHostelRequest:  Reva_Hostel_Requests) {
            Contact revaRoomRequestFor = [Select id, Record_Type_Name__c  from Contact where id =:revaHostelRequest.Hostel_Room_Request_For__c LIMIT 1];
            if(revaRoomRequestFor.Record_Type_Name__c == 'Professor' && revaHostelRequest.Status__c == 'Room Allotted' && revaHostelRequest.Reva_Hostel_Room__c == null) {
               /* Map<String,String> roomRequestStatus = new Map<String,String>();
                date dummyDate = (System.today()).addDays(1);
                roomRequestStatus = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(revaHostelRequest.Hostel_Room_Request_For__c, 
                                                                                          revaHostelRequest.Type__c, 
                                                                                          revaHostelRequest.Reva_Hostel_Premium_Room__c,
                                                                                          dummyDate);
                if (roomRequestStatus.get('roomId') != null) {
                    revaHostelRequest.Reva_Hostel_Room__c  = roomRequestStatus.get('roomId');
                } */ 
               
                List<Contact> contactDetails = RevaHostelRequestAndAllotment.getContactDetails(revaHostelRequest.Hostel_Room_Request_For__c);
                
                List<Reva_Hostel_Room__c> availableRooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability(
                    revaHostelRequest.Type__c,
                    'Staff',
                    contactDetails[Constants.baseIndex],
                    revaHostelRequest.Reva_Hostel_Premium_Room__c);
                
                if (availableRooms.size()>0) {
                    revaHostelRequest.Reva_Hostel_Room__c  = availableRooms[Constants.baseIndex].Id;
                } else {
                    revaHostelRequest.addError('Rooms are not available for selected category');
                } 
            }
        }
    }
    
    //Room allocation to 1st Year Student When reach hostel and office enters the joining date for them reference:98
    public static void FirstYearStudentRoomAllocation (Map<id, Reva_Hostel_Request__c> Reva_Hostel_Requests, Map<id, Reva_Hostel_Request__c> Old_Reva_Hostel_Requests) {
        System.debug('FirstYearStudentRoomAllocation ' + Reva_Hostel_Requests);
        Set<Id> revaHostelRequestIds = Reva_Hostel_Requests.keySet();
         set<Id> conRecordIds = new set<Id>();
             
        List<Reva_Hostel_Request__c> Rhr= [SELECT id, Name,Room_Request_Type__c,Hostel_Room_Request_For__c From Reva_Hostel_Request__c where id =:revaHostelRequestIds ];
        for(Reva_Hostel_Request__c hr : Rhr){
            if(hr.Room_Request_Type__c == 'Student' || hr.Room_Request_Type__c == 'Applicant'){
                conRecordIds.add(hr.Hostel_Room_Request_For__c);
            }  
        }
        
        if(conRecordIds.isEmpty()){
            return ;
        }
       
        List<Contact> revaRoomRequestsFor = [Select id, Record_Type_Name__c, RH_Current_Pursuing_Year_of_Student__c, (Select id from Reva_Hostel_Requests__r where id IN: revaHostelRequestIds)  from Contact where ( RH_Current_Pursuing_Year_of_Student__c = '1st Year' Or RH_Current_Pursuing_Year_of_Student__c ='Unknown') AND (Record_Type_Name__c = 'Student' Or Record_Type_Name__c = 'Applicant') and Id IN : conRecordIds];
        for (Contact roomRequestFor : revaRoomRequestsFor ) { 
           // System.debug('roomRequestFor ' + roomRequestFor);
            if (roomRequestFor.Reva_Hostel_Requests__r.size() > 0) {
                for (Reva_Hostel_Request__c revaHostelRequest:  Reva_Hostel_Requests.values()) {
                    System.debug('revaHostelRequest ' + revaHostelRequest);
                    if (revaHostelRequest.Hostel_Room_Request_For__c == roomRequestFor.ID && revaHostelRequest.Status__c == 'Booked' && revaHostelRequest.Reva_Hostel_JoiningDate__c != Old_Reva_Hostel_Requests.get(revaHostelRequest.ID).Reva_Hostel_JoiningDate__c) {
                        System.debug('In If');
                      /*  Map<String,String> roomRequestStatus = new Map<String,String>();
                        roomRequestStatus = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(revaHostelRequest.Hostel_Room_Request_For__c, 
                                                                                                  revaHostelRequest.Type__c, 
                                                                                                  revaHostelRequest.Reva_Hostel_Premium_Room__c,
                                                                                                  revaHostelRequest.Reva_Hostel_JoiningDate__c);
                        System.debug(roomRequestStatus);
                        if (roomRequestStatus.get('roomId') != null) {
                            revaHostelRequest.Reva_Hostel_Room__c  = roomRequestStatus.get('roomId');
                            revaHostelRequest.Status__c = 'Room Allotted';
                        } else {
                            return; // Throw exception if room is not available
                        }*/

                        List<Contact> contactDetails = RevaHostelRequestAndAllotment.getContactDetails(revaHostelRequest.Hostel_Room_Request_For__c);
                
                        List<Reva_Hostel_Room__c> availableRooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability(
                            revaHostelRequest.Type__c,
                            'Student',
                            contactDetails[Constants.baseIndex],
                            revaHostelRequest.Reva_Hostel_Premium_Room__c);
                        
                        if (availableRooms.size()>0) {
                            revaHostelRequest.Reva_Hostel_Room__c  = availableRooms[Constants.baseIndex].Id;
                            revaHostelRequest.Status__c = 'Room Allotted';
                        } else {
                            revaHostelRequest.addError('Rooms are not available for selected category');
                        } 
                    }
                }
            } 
        }
    }

    //for sending sms notification for all the users when Hostel registration completed and the room alloted  by srinivasu veera
    public static void SendRoomAllotmentNotification(List<Reva_Hostel_Request__c> Reva_Hostel_Requests) {
        
        Map<String, String> studentMessages = new Map<String, String>();
        Map<String, String> parentMessages = new Map<String, String>();
        
        for (Reva_Hostel_Request__c revaHostelRequest : Reva_Hostel_Requests) {
            // Check if the Status__c field is being updated and no other fields are modified
            
            // Fetching contact information for the request
            Contact contact = [SELECT Name,Record_Type_Name__c, Phone, MobilePhone,RecordTypeId, RH_Parent_Phone_Number__c,Father__r.Name,Father__r.MobilePhone FROM Contact WHERE Id = :revaHostelRequest.Hostel_Room_Request_For__c LIMIT 1];
            // contact fathernumber = [select id, Name,MobilePhone from Contact where ReportsToId = : contact.Id  Limit 1];
            Decimal amountPaid=0;
            if (contact != null && (contact.Record_Type_Name__c =='Student' || contact.Record_Type_Name__c =='Applicant')) {
                String studentName = contact.Name;
                String studentPhoneNumber ;
                if(contact.MobilePhone != null){
                    String plusRemoved = contact.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    studentPhoneNumber = correctedWhatsappNumber;
                }
                String parentPhoneNumber ;
                if(contact.Father__r.MobilePhone != null){
                    String plusRemoved = contact.Father__r.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    parentPhoneNumber = correctedWhatsappNumber;
                }
                amountPaid = revaHostelRequest.Hostel_Room_Request_For__r.Student_Fee__r.Amount_Paid__c;
                string recordType = revaHostelRequest.Room_Request_Type__c ;
                // Generating messages for student and parent
                String studentMessage = generateStudentMessage(studentName,recordType,amountPaid);
                String parentMessage = generateParentMessage(studentName, amountPaid);
                
                // Adding messages to the respective maps with phone numbers as keys
                if(recordType=='Student'){
                studentMessages.put(studentPhoneNumber, studentMessage);
                parentMessages.put(parentPhoneNumber, parentMessage);
                }
            }
        }
        
        
        // Call the sendSMS method from Rpl_UtilityClass to send SMS notifications for students
        if(!studentMessages.isEmpty()){
        Rpl_UtilityClass.sendSMSAsync('Hostel Reg Cnfrm (Student)', studentMessages);
        }
        // Call the sendSMS method from Rpl_UtilityClass to send SMS notifications for parents
        if(!parentMessages.isEmpty()){
        Rpl_UtilityClass.sendSMSAsync('Hostel Reg Cnfrm (Parent)', parentMessages);
        }
    }
    
    // Generate message for student
    Public static String generateStudentMessage(String studentName,String recordType, Decimal amountPaid) {
        System.debug('Hello');
        string messageResponce;
        if(recordType=='Student'){ 
            messageResponce= 'Dear ' + studentName + ',\n\nWe are pleased to confirm that you have successfully registered for hostel accommodation at the REVA University Hostel.\n\nAmount paid: ' + String.valueOf(amountPaid) + '\n\nRegards,\nHostel Office \nREVA University';
            }
        return messageResponce;
    }
    
    // Generate message for parent
    Public static String generateParentMessage(String studentName, Decimal amountPaid) {
        return 'Dear Parent,We are pleased to confirm that your child ' + studentName + ' has successfully registered for hostel accommodation at the REVA University Hostel.Amount paid: ' + String.valueOf(amountPaid) + 'Regards,Hostel Office REVA University';
    }
    
    // sending sms when the room alloted for student by srinivasu veera
    public static void SendRoomAllotmentNotificationOnChange(List<Reva_Hostel_Request__c> Reva_Hostel_Requests, Map<Id, Reva_Hostel_Request__c> oldMap) {
        Map<String, String> studentMessages = new Map<String, String>();
        
        for (Reva_Hostel_Request__c revaHostelRequest : Reva_Hostel_Requests) {
            // Check if the Status__c field is being updated and no other fields are modified
            if(revaHostelRequest.Room_Request_Type__c =='Student'){
            if (revaHostelRequest.Status__c != oldMap.get(revaHostelRequest.Id).Status__c && revaHostelRequest.Status__c == 'Room Allotted') {
                // Fetching contact information for the request
                Contact contact = [SELECT Name, MobilePhone FROM Contact WHERE Id = :revaHostelRequest.Hostel_Room_Request_For__c LIMIT 1];
                
                if (contact != null) {
                    String studentName = contact.Name;
                    String studentPhoneNumber ;
                    if(contact.MobilePhone != null){
                    String plusRemoved = contact.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    studentPhoneNumber = correctedWhatsappNumber;
                }
                    Decimal amountPaid = revaHostelRequest.Hostel_Room_Request_For__r.Student_Fee__r.Amount_Paid__c;
                    id roomId = revaHostelRequest.Reva_Hostel_Room__c;
                    Reva_Hostel_Room__c room = [SELECT id, Name, Block__c FROM Reva_Hostel_Room__c WHERE id =: roomId LIMIT 1];
                    String roomNumber = room.Name; 
    				String block = room.Block__c;
                    // Generating message for student
                    String studentMessage = generateStudentRoomAllotedMessage(studentName, amountPaid,roomNumber,block);
                    
                    // Adding message to the map with the student's phone number as key
                    studentMessages.put(studentPhoneNumber, studentMessage);
                }
            }
        }
        }
        
        // Call the sendSMS method from Rpl_UtilityClass to send SMS notifications to students
        If(!studentMessages.isEmpty()){
        Rpl_UtilityClass.sendSMSAsync('Room Allocation (Student)', studentMessages);
        }
    }
    
    // Generate message for student
    Public static String generateStudentRoomAllotedMessage(String studentName, Decimal amountPaid, String roomNumber, String block) {
        return 'Dear ' + studentName + ',\n\n' +
           'We are delighted to inform you that your room booking has been confirmed for your upcoming stay. You have been assigned room number ' + roomNumber + ' in ' + block + '.\n\n' +
           'Regards,\nHostel Office\nREVA University';
}

public static void HostelRoomRequestUpdate(List<Reva_Hostel_Request__c> revaHostelRoomRequestList){
    Boolean updateRecordFlag = false;
    List<Reva_Hostel_Request__c> recordsToUpdate = new List<Reva_Hostel_Request__c>();
    
    
    for (Reva_Hostel_Request__c revaHostelRequest : revaHostelRoomRequestList) {
        System.debug('roomRequestStatus :::: '+revaHostelRequest.Status__c);
        System.debug('roomRequestStatus :::: '+revaHostelRequest.Room_Request_Type__c);
        System.debug('roomRequestStatus :::: '+revaHostelRequest.Reva_Hostel_JoiningDate__c );
        System.debug('roomRequestStatus :::: '+revaHostelRequest.Reva_Hostel_Room__c);
        System.debug('roomRequestStatus :::: '+revaHostelRequest.Hostel_Room_Request_For__r.RH_Current_Pursuing_Year_of_Student__c);
        if (revaHostelRequest.Status__c == 'Booked' && 
            revaHostelRequest.Room_Request_Type__c == Utility.CC_Stud_RecType && 
            revaHostelRequest.Reva_Hostel_JoiningDate__c != null && 
            revaHostelRequest.Reva_Hostel_Room__c == null && 
            revaHostelRequest.Hostel_Room_Request_For__r.RH_Current_Pursuing_Year_of_Student__c != 'Unknown') {
                List<Contact> contactDetails = RevaHostelRequestAndAllotment.getContactDetails(revaHostelRequest.Hostel_Room_Request_For__c);
                
                List<Reva_Hostel_Room__c> availableRooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability(
                    revaHostelRequest.Type__c,
                    'Student',
                    contactDetails[Constants.baseIndex],
                    revaHostelRequest.Reva_Hostel_Premium_Room__c);
                
                if (availableRooms.size()>0) {
                    Reva_Hostel_Request__c updatedRequest = revaHostelRequest.clone(false, true, false);
                    updatedRequest.Id = revaHostelRequest.Id; // Ensure the cloned record has the same Id
                    updatedRequest.Reva_Hostel_Room__c = availableRooms[Constants.baseIndex].Id;
                    updatedRequest.Status__c = 'Room Allotted';
                    
                    recordsToUpdate.add(updatedRequest);
                    updateRecordFlag = true;
                } else {
                    revaHostelRequest.addError('Rooms are not available for selected category');
                } 
            } 
        
        
                    /*  Map<String, String> roomRequestStatus = new Map<String, String>();
            roomRequestStatus = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(
            revaHostelRequest.Hostel_Room_Request_For__c,
            revaHostelRequest.Type__c,
            revaHostelRequest.Reva_Hostel_Premium_Room__c,
            revaHostelRequest.Reva_Hostel_JoiningDate__c
            );
            System.debug('roomRequestStatus :::: ' + roomRequestStatus);

            if (roomRequestStatus.get('roomId') != null) {
            // Clone the record to modify it
            Reva_Hostel_Request__c updatedRequest = revaHostelRequest.clone(false, true, false);
            updatedRequest.Id = revaHostelRequest.Id; // Ensure the cloned record has the same Id
            updatedRequest.Reva_Hostel_Room__c = roomRequestStatus.get('roomId');
            updatedRequest.Status__c = 'Room Allotted';

            recordsToUpdate.add(updatedRequest);
            updateRecordFlag = true;
            } else {
            return; // Throw exception if room is not available
            } */
        
    }
    
    if (updateRecordFlag) {
        update recordsToUpdate;
    }
} 

public static void sendNOCToWardenUser(List<Reva_Hostel_Request__c> updatedRequests, Map<Id, Reva_Hostel_Request__c> oldMap){
    System.debug('entered to sendNOCToWardenUser method');
    Set<Id> requestIdsToUpdate = new Set<Id>();
    
    for (Reva_Hostel_Request__c request : updatedRequests) {
        Reva_Hostel_Request__c oldRequest = oldMap.get(request.Id);
        system.debug('Hii:'+oldRequest.Status__c);
        system.debug('Hii:'+request.Status__c);
        if (oldRequest.Status__c != 'Vacated' && request.Status__c == 'Vacated') {
            requestIdsToUpdate.add(request.Id);
        }
        if (!requestIdsToUpdate.isEmpty()) {
            //sendStaffVacationRequestEmail(requestIdsToUpdate);
        }
    }
}
    /*********************************************************************/
    public static void sendStaffVacationRequestEmail(Set<Id> requestIds) {
        User wardenUser = [SELECT Id, Email FROM User WHERE Profile.Name = 'Warden' LIMIT 1];
        
        // Check if the user is found
        if (wardenUser != null) {
            // Generate Visualforce page and send email to warden
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{wardenUser.Email});
            email.setSubject('Staff Vacation Request');
            email.setHtmlBody('Please see the attached NOC document for staff vacation request.');
            
            // Generate PDF from Visualforce page
            for (Id requestId : requestIds) {
                PageReference pdfPage = Page.StaffVacationNOC;
                pdfPage.getParameters().put('id', requestId);
                Blob pdfBlob;
                try {
                    pdfBlob = pdfPage.getContentAsPDF();
                } catch(Exception e) {
                    System.debug('Error generating PDF: ' + e.getMessage());
                    return;
                }
                
                // Attach PDF to email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('StaffVacationRequest.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
                
                // Send email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }
        } else {
            // Handle the case where the user is not found
            System.debug('Warden User not found. Email not sent.');
        }
    } 
    /**********************************************************************/
    //populating the student hostel joining date of student into the student fee record from reva hostel request
    public static void updateJoiningDateInStudentFee(List<Reva_Hostel_Request__c> newHostelRequests, Map<id, Reva_Hostel_Request__c> oldHostelRequestsMap){
        List<Student_Fee__c> feeRecordsToUpdate = new List<Student_Fee__c>();
        
        for (Reva_Hostel_Request__c request : newHostelRequests) {
            // Check if joining date has been updated
            if (request.Reva_Hostel_JoiningDate__c != oldHostelRequestsMap.get(request.Id).Reva_Hostel_JoiningDate__c && request.Hostel_Room_Request_For__c != null) {
                // Retrieve Contact ID from Reva_Hostel_Request__c
                Id contactId = request.Hostel_Room_Request_For__c;
                
                // Query related student fee records
                List<Student_Fee__c> studentFees = [SELECT Id, Date_of_Joining_Hostel__c 
                                                    FROM Student_Fee__c 
                                                    WHERE Contact__c = :contactId 
                                                    AND Fee_Type__c = 'Hostel Fee' and Payment_Type__c = 'Partial Payment' ];
                
                // Update joining date in student fee records
                for (Student_Fee__c fee : studentFees) {
                    fee.Date_of_Joining_Hostel__c = request.Reva_Hostel_JoiningDate__c;
                    fee.Due_Date__c=request.Reva_Hostel_JoiningDate__c + 60;
                    feeRecordsToUpdate.add(fee);
                }
            }
        }
        
        // Update student fee records
        if (!feeRecordsToUpdate.isEmpty()) {
            update feeRecordsToUpdate;
        }
    }
   public static void sendEmailWhenRequestIsCreated(List<Reva_Hostel_Request__c> newRequests) {
        
          //  Id templateId = '00XIk000000YMgwMAG'; 
          //  Id templateId1= '00XIk000000YMgmMAG'; 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Reva_Hostel_Request__c request : newRequests) {
            // Check if Hostel_Room_Request_For__c is not null
            if (request.Hostel_Room_Request_For__c != null) {
                id contactid = request.Hostel_Room_Request_For__c;
               Contact con = [SELECT id, Name, Email, Mother_Email_ID__c, Father_Email_ID__c, Mother_Name__c, Father_Name__c  FROM Contact WHERE id =: contactid LIMIT 1];
               Student_Fee__c sf = new Student_Fee__c();
                Try{
                 sf= [SELECT id,Amount__c,Name From Student_Fee__c where contact__c = :con.Id and Fee_Type__c = 'Hostel Fee' and Name like '%Hostel%' limit 1];
                }catch(exception e){
                    
                }
                String recipientEmail = con.Email;
                String motherEmail = con.Mother_Email_ID__c;
                String fatherEmail = con.Father_Email_ID__c;
                String studentName = con.Name;
                String MotherName = con.Mother_Name__c;
                String FatherName = con.Father_Name__c;    
                Decimal TotalAmount = sf.Amount__c;
                System.debug('student email: '+ recipientEmail);
                System.debug('student email: '+ fatherEmail);
                 System.debug('student email: '+ motherEmail);
                List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
                OrgWideEmailAddress orgWideEmail = new OrgWideEmailAddress();
                // Check if the Org-Wide Email Address exists
                if (!orgWideEmailAddresses.isEmpty()) {
                     orgWideEmail = orgWideEmailAddresses[0];
                }
                // Create the email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // Set the Org-Wide Email Address as the "from" address
                    email.setOrgWideEmailAddressId(orgWideEmail.Id);
               email.setToAddresses(new List<String>{recipientEmail});
               
                email.setSubject('Hostel Registration Confirmation');
                String emailBody = 'Dear ' + studentName + ',\n\n';
               	emailBody += 'We are pleased to inform that you have successfully registered for hostel accommodation at REVA University.\nExperience a secure and comfortable stay akin to home. Please pay the following amount for your room allocation.\n';
                emailBody += 'Amount to be paid:' +TotalAmount+ '\n\n';
                emailBody += '\n\nBest Regards,\nHostel Office\nREVA University';
                email.setPlainTextBody(emailBody);
                emails.add(email);
                    
                            // Create the email message for the mother
        if (motherEmail != null) {
            Messaging.SingleEmailMessage motherEmailMsg = new Messaging.SingleEmailMessage();
              motherEmailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);
            motherEmailMsg.setToAddresses(new List<String>{motherEmail});
            motherEmailMsg.setSubject('Hostel Room Registration' + MotherName);
            String motherEmailBody = 'Dear Parent,\n\n';
            motherEmailBody += 'Greetings from REVA University!\n\n';
            motherEmailBody += 'We are delighted to inform you that your child ' + studentName + ' has been successfully registered for hostel accommodation at REVA University. Rest assured, your child will enjoy a secure and comfortable environment that feels like home.\n\n';
            motherEmailBody += 'To finalise the room allocation, please proceed with the payment.\n\n';
            motherEmailBody += 'Amount to be paid: ' + sf.Amount__c + '\n\n';
            motherEmailBody += '\n\nBest Regards,\nHostel Office\nREVA University';
            motherEmailMsg.setPlainTextBody(motherEmailBody);
            emails.add(motherEmailMsg);
        }

        // Create the email message for the father
        if (fatherEmail != null) {
            Messaging.SingleEmailMessage fatherEmailMsg = new Messaging.SingleEmailMessage();
              fatherEmailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);
            fatherEmailMsg.setToAddresses(new List<String>{fatherEmail});
            fatherEmailMsg.setSubject('Hostel Room Registration ' + FatherName);
            String fatherEmailBody = 'Dear Parent,\n\n';
            fatherEmailBody += 'Greetings from REVA University!\n\n';
            fatherEmailBody += 'We are delighted to inform you that your child ' + studentName + ' has been successfully registered for hostel accommodation at REVA University. Rest assured, your child will enjoy a secure and comfortable environment that feels like home.\n\n';
            fatherEmailBody += 'To finalise the room allocation, please proceed with the payment.\n\n';
            fatherEmailBody += 'Amount to be paid: ' + sf.Amount__c + '\n\n';
            fatherEmailBody += '\n\nBest Regards,\nHostel Office\nREVA University';
            fatherEmailMsg.setPlainTextBody(fatherEmailBody);
            emails.add(fatherEmailMsg);
        }
            
        
        // Send the email messages
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        
        // Check the results and handle any errors
        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    System.debug('Error sending email: ' + error.getMessage());
                }
            }
        }
 }
    }
    }
    public static void sendEmailWhenRoomAllocated(List<Reva_Hostel_Request__c> updatedRequests, Map<id, Reva_Hostel_Request__c> oldMap){
        Set<Id> changedRequestIds = new Set<Id>();
        for (Reva_Hostel_Request__c updatedRequest : updatedRequests) {
            Reva_Hostel_Request__c oldRequest = oldMap.get(updatedRequest.Id);
            if (oldRequest.Reva_Hostel_Room__c != updatedRequest.Reva_Hostel_Room__c && updatedRequest.Hostel_Room_Request_For__c != null) {
                changedRequestIds.add(updatedRequest.Id);
            }
        }

        if (!changedRequestIds.isEmpty()) {
            sendEmailWhenHostelRoomChanged(changedRequestIds);
        }
    }
    
    public static void sendEmailWhenHostelRoomChanged(Set<Id> changedRequestIds) {
           //   Id templateId = '00XIk000000YMh1MAG';  
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Id requestId : changedRequestIds) {
            Reva_Hostel_Request__c request = [SELECT Id, Reva_Hostel_Room__c, Hostel_Room_Request_For__c,
                                              Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.Mother_Email_ID__c,
                                              Hostel_Room_Request_For__r.Father_Email_ID__c
                                              FROM Reva_Hostel_Request__c
                                              WHERE Id = :requestId LIMIT 1];
            Id contactId = request.Hostel_Room_Request_For__c;
            Id roomId = request.Reva_Hostel_Room__c;
            
            Contact con = [SELECT id, Name, Email, Mother_Email_ID__c, Father_Email_ID__c, Mother_Name__c, Father_Name__c 
                           FROM Contact WHERE id =: contactid LIMIT 1];
             Student_Fee__c sf=new  Student_Fee__c();
              Reva_Hostel_Room__c room = new Reva_Hostel_Room__c();
             Try{
             sf= [SELECT id,Amount__c,Name,Amount_Paid__c,Amount_Pending__c,Due_Date__c From Student_Fee__c where contact__c = :con.Id and Fee_Type__c = 'Hostel Fee' and Name like '%Hostel%' limit 1];
              room = [SELECT Name, Block__c FROM Reva_Hostel_Room__c WHERE id =: roomId LIMIT 1];
             }catch(exception e){
                    
                }
            
            String recipientEmail = con.Email;
            String motherEmail = con.Mother_Email_ID__c;
            String fatherEmail = con.Father_Email_ID__c;
            String studentName = con.Name;
            String roomNo = room.Name;
            String blockName = room.Block__c;
        	String MotherName = con.Mother_Name__c;
            String FatherName = con.Father_Name__c;
            OrgWideEmailAddress orgWideEmail = new OrgWideEmailAddress();
              List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
             if (!orgWideEmailAddresses.isEmpty()) {
                     orgWideEmail = orgWideEmailAddresses[0];
             }
            // Create the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
               email.setOrgWideEmailAddressId(orgWideEmail.Id);
            email.setToAddresses(new List<String>{recipientEmail});
            
            //email to student           
            email.setSubject('Hostel Room Allocation - REVA University');
            String emailBody = 'Dear ' + studentName + ',\n\n';
			emailBody += 'Warm greetings from REVA University!\n\n';
    		emailBody +='We are thrilled to announce that your hostel room allocation has been successfully processed. You have been allocated room number ' + roomNo + ' in the ' +blockName+ ' block. \nPlease complete the payment of the remaining amount before the due date.\n\n';
            emailBody += 'Payment Summary:\n\n';
            emailBody += 'Total Amount Due:'+ sf.Amount__c;
            emailBody += '\nAmount Already Paid:' + sf.Amount_Paid__c;
            emailBody += '\nBalance Amount:'+ sf.Amount_Pending__c;
            emailBody += '\nPayment Due Date:'+ sf.Due_Date__c;
            emailBody += '\n\nBest Regards,\nHostel Office\nREVA University';
            email.setPlainTextBody(emailBody);
            emails.add(email);
            
            
            // Create the email message for the mother
        if (motherEmail != null) {
            Messaging.SingleEmailMessage motherEmailMsg = new Messaging.SingleEmailMessage();
             motherEmailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);
            motherEmailMsg.setToAddresses(new List<String>{motherEmail});
            motherEmailMsg.setSubject('Hostel Room Allocation - REVA University' + MotherName);
            String motherEmailBody = 'Dear Parent,\n\n';
            motherEmailBody += 'Warm greetings from REVA University!\n\n';
            motherEmailBody += 'We are thrilled to announce that your hostel room allocation has been successfully processed. You have been allocated room number ' + roomNo + ' in the ' +blockName+ ' block. \nPlease complete the payment of the remaining amount before the due date.\n\n';
            motherEmailBody += 'Payment Summary:\n\n';
            motherEmailBody += 'Total Amount Due:'+ sf.Amount__c;
            motherEmailBody += '\nAmount Already Paid:' + sf.Amount_Paid__c;
            motherEmailBody += '\nBalance Amount:'+ sf.Amount_Pending__c;
            motherEmailBody += '\nPayment Due Date:'+ sf.Due_Date__c;
            motherEmailBody += '\n\nBest Regards,\nHostel Office\nREVA University';
            motherEmailMsg.setPlainTextBody(motherEmailBody);
            emails.add(motherEmailMsg);
        }

        // Create the email message for the father
        if (fatherEmail != null) {
            Messaging.SingleEmailMessage fatherEmailMsg = new Messaging.SingleEmailMessage();
             fatherEmailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);
            fatherEmailMsg.setToAddresses(new List<String>{fatherEmail});
            fatherEmailMsg.setSubject('Hostel Room Allocation ' + FatherName);
            String fatherEmailBody = 'Dear Parent,\n\n';
            fatherEmailBody += 'Warm greetings from REVA University!\n\n';
            fatherEmailBody += 'We are thrilled to announce that your hostel room allocation has been successfully processed. You have been allocated room number ' + roomNo + ' in the ' +blockName+ ' block. \nPlease complete the payment of the remaining amount before the due date.\n\n';
             fatherEmailBody += 'Payment Summary:\n\n';
            fatherEmailBody += 'Total Amount Due:'+ sf.Amount__c;
            fatherEmailBody += '\nAmount Already Paid:' + sf.Amount_Paid__c;
            fatherEmailBody += '\nBalance Amount:'+ sf.Amount_Pending__c;
            fatherEmailBody += '\nPayment Due Date:'+ sf.Due_Date__c;
            fatherEmailBody += '\n\nBest Regards,\nHostel Office\nREVA University';
            fatherEmailMsg.setPlainTextBody(fatherEmailBody);
            emails.add(fatherEmailMsg);
        }
    }    
        // Send the email messages
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        
        // Check the results and handle any errors
        for (Messaging.SendEmailResult result : results) {
            if (!result.isSuccess()) {
                for (Messaging.SendEmailError error : result.getErrors()) {
                    System.debug('Error sending email: ' + error.getMessage());
                }
            }
        }
    }
        
    public static void createStudentHostelAttachment(List<Reva_Hostel_Request__c> requests) {
    Id requestId = null;

    for (Reva_Hostel_Request__c request : requests) {
        System.debug('requestId: ' + request.Id);
        System.debug('Status: ' + request.Vacating_Request__c);
        if (request.Vacating_Request__c == 'Request to warden' || request.Vacating_Request__c == 'Request to Chief Warden' || request.Vacating_Request__c == 'Request to Admin' || (request.Vacating_Request__c == 'Approved' && request.Status__c == 'Vacating Initiated') && request.Room_Request_Type__c =='Student' ){
            requestId = request.Id;
            System.debug('Vacating Initiated requestId: ' + requestId);
            break;
        }
    }

    if (requestId != null) {
        System.enqueueJob(new StudentVacationNOCPdfGenerator(requestId));
    } else {
        System.debug('No request with status "Vacating Initiated" found.');
    }
}

}