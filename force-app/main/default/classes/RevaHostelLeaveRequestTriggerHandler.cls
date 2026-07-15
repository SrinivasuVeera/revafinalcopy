public class RevaHostelLeaveRequestTriggerHandler {
    Public static String wardenPhone; 
    Public static String wardenName; 
    Public static String parentPhone;
    Public static String parentName;
    Public static String mentorPhone;
    Public static String mentorName;
    Public static String studentName;
    Public static String studentPhone;
    Public static String formattedStartDate;
    Public static String formattedEndDate;
    Public static String reason;    
    Public static String block;
    Public static String roomNo;
    Public static String CheckOutDate;
    Public static String CheckInDate;
    Public static String CheckOutTime;
    Public static String CheckInTime;
    
    public static void leaveApprovalNotification(List<REVA_Hostel_Leave_Request__c> LeaveRequests) {
        Id recordIds = LeaveRequests[0].id;
        if(recordIds != null){
            // makeLeaveCheckOutCallout(recordIds);
            parentLeaveRegWhatsappNoti(recordIds);
            wardenLeaveRegWhatsappNoti(recordIds);
            mentorLeaveRegWhatsappNoti(recordIds);
            
        }
    }
    public static void leaveRequestNotification(List<REVA_Hostel_Leave_Request__c> LeaveRequests) {
        List<Id> RevaLeaveRequests = new List<Id>();
        List<string> checkuser = new List<string>();
        for(REVA_Hostel_Leave_Request__c rvleave: LeaveRequests){
            RevaLeaveRequests.add(rvleave.Id);
        }
        if(RevaLeaveRequests != null){
            makeCalloutAsync(RevaLeaveRequests);
            
        }
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync( list<Id> RevaLeaveRequests ) {
        
        Set<Id> contactIds = new Set<Id>();
        
        REVA_Hostel_Leave_Request__c RevaLeavereq = [SELECT  id,Name,Status__c,Start_Date_and_Time__c,End_Date_and_Time__c,Reason_For_Leave__c,
                                                     Contact__c,Contact__r.MobilePhone,Contact__r.Name,Contact__r.Mentor__c,Contact__r.Mentor__r.Name 
                                                     From REVA_Hostel_Leave_Request__c WHERE id =: RevaLeaveRequests ];
        contactIds.add(RevaLeavereq.Contact__c);
        
        Reva_Hostel_Request__c request = [SELECT id,warden__r.Phone, Block__c,Status__c, warden__r.Name,Hostel_Room_Request_For__c,Hostel_Room_Request_For__r.Father__r.Name,
                                          Hostel_Room_Request_For__r.Father__r.MobilePhone,Hostel_Room_Request_For__r.Mentor__r.Name,Hostel_Room_Request_For__r.Mentor__r.MobilePhone,
                                          Reva_Hostel_Room__r.Name, Room_Number__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c =: contactIds LIMIT 1];   
        
        if(request.warden__r.Phone != null){
            String plusRemoved = request.warden__r.Phone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            WardenPhone = correctedWhatsappNumber;
        }
        if(RevaLeavereq.Contact__r.MobilePhone != null){
            String plusRemoved = RevaLeavereq.Contact__r.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            studentPhone = correctedWhatsappNumber;
        }
        if(request.Hostel_Room_Request_For__r.Mentor__r.MobilePhone != null){
            String plusRemoved = request.Hostel_Room_Request_For__r.Mentor__r.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            mentorPhone = correctedWhatsappNumber;
        }
        if(request.Hostel_Room_Request_For__r.Father__r.MobilePhone != null){
            String plusRemoved = request.Hostel_Room_Request_For__r.Father__r.MobilePhone.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            parentPhone = correctedWhatsappNumber;
        }   
        
        formattedStartDate = RevaLeavereq.Start_Date_and_Time__c.format('dd-MM-yyyy HH:mm:ss', 'IST');   
        formattedEndDate = RevaLeavereq.End_Date_and_Time__c.format('dd-MM-yyyy HH:mm:ss', 'IST');
        CheckOutDate = RevaLeavereq.Start_Date_and_Time__c.format('dd-MM-yyyy', 'IST');   
        CheckInDate = RevaLeavereq.End_Date_and_Time__c.format('dd-MM-yyyy', 'IST');
        CheckOutTime = RevaLeavereq.Start_Date_and_Time__c.format('HH:mm:ss', 'IST');   
        CheckInTime = RevaLeavereq.End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        studentName = RevaLeavereq.Contact__r.Name;
        mentorName = request.Hostel_Room_Request_For__r.Mentor__r.Name;
        parentName = request.Hostel_Room_Request_For__r.Father__r.Name;
        wardenName = request.warden__r.Name;
        Reason = RevaLeavereq.Reason_For_Leave__c;
        block = request.Block__c;
        roomNo = request.Reva_Hostel_Room__r.Name;
        
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        
        if(RevaLeavereq.Status__c == 'Leave Requested'){
            Parentreg(RevaLeavereq , messageList);
            MentorReg(RevaLeavereq , messageList);
            Wardenreg(RevaLeavereq , messageList);
            
        }
        If(RevaLeavereq.Status__c == 'Approved'){
            StudentApproved(RevaLeavereq , messageList);
            ParentApproved(RevaLeavereq , messageList);
            WardenApproved(RevaLeavereq , messageList);
            MentorApproved(RevaLeavereq , messageList);
        }
        If(RevaLeavereq.Status__c == 'Check Out'){
            CheckOutStudent(RevaLeavereq , messageList);
            ParentCheckOut(RevaLeavereq , messageList);
            MentorCheckOut(RevaLeavereq , messageList);
        }
        If(RevaLeavereq.Status__c == 'Check In'){
            CheckInStudent(RevaLeavereq , messageList);
            ParentCheckIn(RevaLeavereq , messageList);
            MentorCheckIn(RevaLeavereq , messageList);
        }
        if (messageList != null) {
            SMS_API_Utility.SendSMSOneToMany('Leave Request (Parent)', messageList); 
            SMS_API_Utility.SendSMSOneToMany('Hostel_Leave_Request_Warden', messageList);
            SMS_API_Utility.SendSMSOneToMany('Hostel_Leave_Request_Mentor', messageList);
            SMS_API_Utility.SendSMSOneToMany('Leave Approval (Student)', messageList);
            SMS_API_Utility.SendSMSOneToMany('Leave Approval (Parent)', messageList);
            SMS_API_Utility.SendSMSOneToMany('Leave Approval (Warden/Mentor)', messageList);
            
            // SMS_API_Utility.SendSMSOneToMany('Check_Out_Notification_Student', messageList);
            //SMS_API_Utility.SendSMSOneToMany('Check_Out_Information_Parent', messageList);
            //SMS_API_Utility.SendSMSOneToMany('Check_out_Information_Mentor', messageList); 
            //SMS_API_Utility.SendSMSOneToMany('Check_in_Information_Students', messageList);
            //SMS_API_Utility.SendSMSOneToMany('Check_in_Information_Parents', messageList);
            //SMS_API_Utility.SendSMSOneToMany('Check_in_Confirmation', messageList);
        }       
    }
    
    // Regiester Notification
    public static void Parentreg (REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        String message = 'Dear ' + parentName + '\n\nWe would like to inform you that your child, ' + studentName + ', has requested leave from the hostel. The details of their leave request are as follows:\n\nLeave start date and time: ' + formattedStartDate + '\nLeave end date:\n' + formattedEndDate + '\nReason for leave: ' + Reason + '\n\nRegards,\nHostel Office,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007782822189483403';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
    public static void Wardenreg(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        String message =  'Dear ' + wardenName + '\n\nWe would like to inform you that one of our students, ' + studentName + ', has requested leave from the hostel. The details of their leave request are as follows:\n\nLeave start date and time: ' + formattedStartDate + '\nLeave end date:\n' + formattedEndDate + '\nReason for leave: ' + Reason + '\nBlock name: ' + block + '\nRoom number: ' + roomNo + '\nMobile number: ' + studentPhone + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007438398890548944';
        shrtMessage.message = message;
        shrtMessage.recipient = WardenPhone;
        messageList.add(shrtMessage);
    }
    public static void MentorReg(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {       
        
        String message = 'Dear ' + mentorName + ', Your mentee ' + studentName + ' has applied for hostel leave from ' + formattedStartDate + ' to ' + formattedEndDate + '. For any objections, please contact block warden asap. REVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007994638059250000';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }
    
    // Approved Notitfications 
    public static void StudentApproved (REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + studentName + '\n\nYour leave request from the hostel has been approved. The details are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: ' + formattedEndDate + '\nReason for the leave: ' + Reason + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007550489527389803';
        shrtMessage.message = message;
        shrtMessage.recipient = studentPhone;
        messageList.add(shrtMessage);
    }
    public static void ParentApproved (REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + parentName + '\n\nPlease be informed that the leave request for ' + studentName + ' has been approved. The details of this request are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: ' + formattedEndDate + '\nReason for leave: ' + Reason + ' \n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007426602285615563';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
    public static void WardenApproved(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {    
        
        String message = 'Dear ' + wardenName + '\n\nPlease be informed that the leave request for '+ studentName +' has been approved. The details are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: '+ formattedEndDate +'\nReason for leave: ' + Reason + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007160852002518651';
        shrtMessage.message = message;
        shrtMessage.recipient = WardenPhone;
        messageList.add(shrtMessage);
    }
    public static void MentorApproved(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + mentorName + '\n\nPlease be informed that the leave request for '+ studentName +' has been approved. The details are as follows:\n\nLeave start date & time: ' + formattedStartDate + '\nLeave end date & time: '+ formattedEndDate +'\nReason for leave: ' + Reason + '\n\nRegards\nHostel office\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007160852002518651';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }
    
    
    //Check Out Notifications
    public static void CheckOutStudent(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + studentName + ',\nYouve successfully completed the security checkout on '+ CheckOutDate +' at '+CheckOutTime +' for hostel leave. Your checkin is scheduled for ' + CheckInDate + '.\n REVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007305717623200000';
        shrtMessage.message = message;
        shrtMessage.recipient = studentPhone;
        messageList.add(shrtMessage);
    }
    public static void ParentCheckOut(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + parentName + '\nYour Child has completed security check-out on ' + CheckOutDate + ' at '+CheckOutTime+' for hostel leave. Their check-in is scheduled for ' + CheckInDate + '.\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007219312319097098';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
    
    public static void MentorCheckOut(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + mentorName +',\nYour mentee '+studentName+ ' has completed check-out on '+ CheckOutDate + ' at '+CheckOutTime+' for hostel leave. Check-in is scheduled for ' + CheckInDate + '.\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007655391598157095';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }
    
    
    // Check In Notifications
    public static void CheckInStudent(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + studentName + ',\nYou have successfully completed the security check-in on '+ CheckInDate +' at '+CheckInTime +' after your hostel leave.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007958936830396769';
        shrtMessage.message = message;
        shrtMessage.recipient = studentPhone;
        messageList.add(shrtMessage);
    }
    
    public static void ParentCheckIn(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + parentName + ',\nYour child has successfully completed the security check-in on ' + CheckInDate + ' at '+CheckInTime+' after their hostel leave.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007973278865491387';
        shrtMessage.message = message;
        shrtMessage.recipient = parentPhone;
        messageList.add(shrtMessage);
    }
    public static void MentorCheckIn(REVA_Hostel_Leave_Request__c stuSet, List<SMS_API_Utility.shortMessageWrp> messageList) {     
        
        String message = 'Dear ' + mentorName +',\nYour mentee ' +studentName+' has successfully completed the security check-in on '+ CheckInDate + ' at '+CheckInTime+' after their hostel leave.\nRegards,\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007090109464134424';
        shrtMessage.message = message;
        shrtMessage.recipient = mentorPhone;
        messageList.add(shrtMessage);
    }
    
    
    
    public static void parentLeaveRegWhatsappNoti(Id recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c,Warden__r.LastName,Warden__r.FirstName, LastModifiedDate,End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone,
            Contact__r.Father__r.Name,Contact__r.Father__r.MobilePhone ,Contact__r.SRN_Number__c FROM REVA_Hostel_Leave_Request__c
            WHERE Id =: recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_leave_notif_parent';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_leave_notif_parent') {
                    for (String key : keys) {
                        if (key == 'parent_name') {
                            notification1.params.put(key, stu.Contact__r.Father__r.Name);
                        }else if (key == 'ward_name') {
                            notification1.params.put(key.trim(),stu.Contact__r.Name);     
                        }else if (key == 'start_date') {
                            notification1.params.put(key.trim(), String.valueof(stu.Start_Date__c));
                        } else if (key == 'end_date') { 
                            notification1.params.put(key.trim(),  String.valueof(stu.End_Date__c));
                        }else if (key == 'SRN_Number') {
                            notification1.params.put(key.trim(), stu.Contact__r.SRN_Number__c);
                        }      
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.Father__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.Father__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    public static void wardenLeaveRegWhatsappNoti(Id recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c,Warden__r.LastName,Warden__r.FirstName,Warden__r.Phone, LastModifiedDate,End_Date_and_Time__c, Reason_For_Leave__c, Contact__c,Contact__r.Name, Contact__r.MobilePhone,
            Contact__r.Father__r.Name,Contact__r.Father__r.MobilePhone ,Contact__r.Mentor__r.MobilePhone,Contact__r.Mentor__r.Name,Contact__r.SRN_Number__c FROM REVA_Hostel_Leave_Request__c
            WHERE Id =: recordIds
            LIMIT 1
        ];
        
        Reva_Hostel_Request__c request = [SELECT id,warden__r.Phone, Block__c,Status__c, warden__r.Name,Hostel_Room_Request_For__c,Hostel_Room_Request_For__r.Father__r.Name,
                                          Hostel_Room_Request_For__r.Father__r.MobilePhone,Hostel_Room_Request_For__r.Mentor__r.Name,Hostel_Room_Request_For__r.Mentor__r.MobilePhone,
                                          Reva_Hostel_Room__r.Name, Room_Number__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c =: requiredFields[0].Contact__c LIMIT 1];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'leaverequest_warden_mentor';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'leaverequest_warden_mentor') {
                    for (String key : keys) {
                        if (key == 'studentname') {
                            notification1.params.put(key, stu.Contact__r.Name);
                        }else if (key == 'warden_faculty_mentor') {
                            notification1.params.put(key.trim(),stu.Warden__r.LastName +' '+ stu.Warden__r.FirstName );     
                        }else if (key == 'leavestartdatetime') {
                            notification1.params.put(key.trim(), String.valueof(stu.Start_Date__c));
                        } else if (key == 'leaveenddate') { 
                            notification1.params.put(key.trim(),  String.valueof(stu.End_Date__c));
                        }else if (key == 'applicationnumber') {
                            notification1.params.put(key.trim(), stu.Contact__r.SRN_Number__c);
                        } else if (key == 'reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        } else if (key == 'blockname') {
                            notification1.params.put(key.trim(), request.Block__c);
                        } else if (key == 'mobilenumber') {
                            notification1.params.put(key.trim(), stu.Contact__r.MobilePhone);
                        } else if (key == 'roomnumber') {
                            notification1.params.put(key.trim(), request.Room_Number__c);
                        } 
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Warden__r.Phone !=null){
                            String plusRemoved = stu.Warden__r.Phone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    public static void mentorLeaveRegWhatsappNoti(Id recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c,Warden__r.LastName,Warden__r.FirstName,Warden__r.Phone, LastModifiedDate,End_Date_and_Time__c, Reason_For_Leave__c, Contact__c,Contact__r.Name, Contact__r.MobilePhone,
            Contact__r.Father__r.Name,Contact__r.Father__r.MobilePhone ,Contact__r.Mentor__r.MobilePhone,Contact__r.Mentor__r.Name,Contact__r.SRN_Number__c FROM REVA_Hostel_Leave_Request__c
            WHERE Id =: recordIds
            LIMIT 1
        ];
        
        Reva_Hostel_Request__c request = [SELECT id,warden__r.Phone, Block__c,Status__c, warden__r.Name,Hostel_Room_Request_For__c,Hostel_Room_Request_For__r.Father__r.Name,
                                          Hostel_Room_Request_For__r.Father__r.MobilePhone,Hostel_Room_Request_For__r.Mentor__r.Name,Hostel_Room_Request_For__r.Mentor__r.MobilePhone,
                                          Reva_Hostel_Room__r.Name, Room_Number__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c =: requiredFields[0].Contact__c LIMIT 1];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'leaverequest_warden_mentor';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'leaverequest_warden_mentor') {
                    for (String key : keys) {
                        if (key == 'studentname') {
                            notification1.params.put(key, stu.Contact__r.Name);
                        }else if (key == 'warden_faculty_mentor') {
                            notification1.params.put(key.trim(),stu.Contact__r.Mentor__r.Name );     
                        }else if (key == 'leavestartdatetime') {
                            notification1.params.put(key.trim(), String.valueof(stu.Start_Date__c));
                        } else if (key == 'leaveenddate') { 
                            notification1.params.put(key.trim(),  String.valueof(stu.End_Date__c));
                        }else if (key == 'applicationnumber') {
                            notification1.params.put(key.trim(), stu.Contact__r.SRN_Number__c);
                        } else if (key == 'reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        } else if (key == 'blockname') {
                            notification1.params.put(key.trim(), request.Block__c);
                        } else if (key == 'mobilenumber') {
                            notification1.params.put(key.trim(), stu.Contact__r.MobilePhone);
                        } else if (key == 'roomnumber') {
                            notification1.params.put(key.trim(), request.Room_Number__c);
                        } 
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.Mentor__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.Mentor__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    
   public static void mealCancelIfLeaveOnSameDay(List<REVA_Hostel_Leave_Request__c> leaveRequests) {
    System.debug('LeaveRequests: ' + leaveRequests);

    // Map to group leave requests by Contact
    Map<Id, List<REVA_Hostel_Leave_Request__c>> leaveRequestMap = new Map<Id, List<REVA_Hostel_Leave_Request__c>>();

    for (REVA_Hostel_Leave_Request__c leaveReq : LeaveRequests) {
        if (leaveReq.Status__c == 'Approved' && leaveReq.Start_Date_and_Time__c.date() == System.today() && leaveReq.CreatedDate.date() == System.today()) {
            System.debug('Inside Approved');
            if(!leaveRequestMap.containskey(leaveReq.Contact__c)){
                    leaveRequestMap.put(leaveReq.Contact__c, new List<REVA_Hostel_Leave_Request__c>{leaveReq});
                }
                leaveRequestMap.get(leaveReq.Contact__c).add(leaveReq);
          
        }
    }

    System.debug('leaveRequestMap: ' + leaveRequestMap);

    // Exit early if there are no valid leave requests
    if (leaveRequestMap.isEmpty()) {
        System.debug('No leave requests to process.');
        return;
    }

    // Fetch relevant meal bookings
    List<Reva_Meal_Booking__c> mealRecords = [
        SELECT Id, Reva_Meal_Booking_Status__c, 
               Booking_For__c, Meal_Start_Time__c, Meal_End_Time__c, Meal_Date__c
        FROM Reva_Meal_Booking__c
        WHERE Booking_For__c IN :leaveRequestMap.keySet()
          AND Reva_Meal_Booking_Status__c = 'Booked'
          AND Meal_Date__c >= :System.today()
    ];

    System.debug('mealRecords: ' + mealRecords);

    // Cancel meals that overlap with leave durations
    List<Reva_Meal_Booking__c> mealsToCancel = new List<Reva_Meal_Booking__c>();

    for (Reva_Meal_Booking__c mealRecord : mealRecords) {
        List<REVA_Hostel_Leave_Request__c> relatedLeaves = leaveRequestMap.get(mealRecord.Booking_For__c);
        System.debug('relatedLeaves: ' + relatedLeaves);
        if (relatedLeaves == null) continue;

        for (REVA_Hostel_Leave_Request__c leaveReq : relatedLeaves) {
            DateTime leaveStart = leaveReq.Start_Date_and_Time__c;
            DateTime leaveEnd = leaveReq.End_Date_and_Time__c != null
                ? leaveReq.End_Date_and_Time__c
                : leaveReq.Start_Date_and_Time__c.addDays(1); // Default end time if null

            DateTime mealStart = DateTime.newInstance(mealRecord.Meal_Date__c, mealRecord.Meal_Start_Time__c);
            DateTime mealEnd = DateTime.newInstance(mealRecord.Meal_Date__c, mealRecord.Meal_End_Time__c);
            
             System.debug('leaveStart: ' + leaveStart);
             System.debug('leaveEnd: ' + leaveEnd);
             System.debug('mealStart: ' + mealStart);
             System.debug('mealEnd: ' + mealEnd);
            
            // Check if meal overlaps with leave
            if ((mealStart >= leaveStart && mealStart <= leaveEnd) || 
                (mealEnd >= leaveStart && mealEnd <= leaveEnd)) {
                    System.debug('Inside cancel: ');
                mealRecord.Reva_Meal_Booking_Status__c = 'Cancelled';
                mealsToCancel.add(mealRecord);
                break; // No need to check further leaves for this meal
            }
        }
    }

    System.debug('mealsToCancel: ' + mealsToCancel);

    // Update meals if there are cancellations
    if (!mealsToCancel.isEmpty()) {
        try {
            System.debug('Cancelled meals updated successfully.');
            update mealsToCancel;
            
        } catch (DmlException e) {
            System.debug('Error updating meals: ' + e.getMessage());
        }
    }
}


    //below one implemented by devender
    /*public static void mealCancelIfLeaveOnSameDay(List<REVA_Hostel_Leave_Request__c> LeaveRequests) {
        System.debug('LeaveRequests---'+LeaveRequests);
        List<Reva_Meal_Booking__c> todayBookedMelasToCancel = new List<Reva_Meal_Booking__c>();
        //Map<Id,String> todayLeavRequestMap  = new Map<Id,String> ();
        
        Map<Id,REVA_Hostel_Leave_Request__c> leaveReqmap = new Map<Id,REVA_Hostel_Leave_Request__c>();
        
        for(REVA_Hostel_Leave_Request__c leaveReq : LeaveRequests){
            System.debug('leaveReq.Start_Date_and_Time__c---'+leaveReq.Start_Date_and_Time__c);
             System.debug('leaveReq. leaveReq.CreatedDat---'+ leaveReq.CreatedDate);
             System.debug('System.today()---'+System.today());
            if(leaveReq.status__c == 'Approved' && leaveReq.Start_Date_and_Time__c == System.today() && leaveReq.CreatedDate ==  System.today()){
                System.debug('Inside Approved');
               // todayLeavRequestMap.put(leaveReq.Id ,leaveReq.Contact__c);
                
                if(!leaveReqmap.containskey(leaveReq.Contact__c)){
                    leaveReqmap.put(leaveReq.Contact__c, new List<REVA_Hostel_Leave_Request__c>{leaveReq});
                }
                leaveReqmap.get(leaveReq.Contact__c).add(leaveReq);
            }
            
        }
        System.debug('leaveReqmap--'+leaveReqmap);
        List<Reva_Meal_Booking__c> mealRecords = [Select Id, Reva_Meal_Booking_Status__c,
                                                  Booking_For__r.Name, Booking_For__r.SRN_Number__c, Booking_For__r.Phone, Booking_For__r.File_Passport_Size_Photo__c
                                                  FROM Reva_Meal_Booking__c WHERE Booking_For__c IN : leaveReqmap.keySet() AND Reva_Meal_Booking_Status__c ='Booked' AND Meal_Date__c >= today ];
        
         System.debug('mealRecords--'+mealRecords);
        if(mealRecords.size() > 0){
            System.debug('mealRecords.size()--'+mealRecords.size());
            for(Reva_Meal_Booking__c mealRecord :mealRecords ){
                
                for(REVA_Hostel_Leave_Request__c  re : leaveReqmap.get(mealRecord.Booking_For__c)){
                    if(re.Id ==  && mealRecord.Meal_start_time__c > re.Start_Date_and_Time__c.Time()){
                     mealRecord.Reva_Meal_Booking_Status__c = 'Cancelled';
                     todayBookedMelasToCancel.add(mealRecord); 
                    }
                
               
                }
                
            }
        }
        
        System.debug('todayBookedMelasToCancel.size()--'+todayBookedMelasToCancel);
        if(!todayBookedMelasToCancel.isEmpty()){
            update todayBookedMelasToCancel;
        }
    }*/
}