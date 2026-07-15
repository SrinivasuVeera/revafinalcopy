public class Student_Leave_WhatsAppNotifications {
    
    public class InputParameters{
        @InvocableVariable(required=true)
        public List<String> recordIds;
        
        @InvocableVariable(required=true)
        public List<String> status;
    }  
    
    
    @InvocableMethod(label='Student Leave Notification')
    public static void sendLeaveApprovalWhatsAppNotification(List<InputParameters> Inputs) {
        List<string> status = Inputs[0].status;
        if (Inputs[0].recordIds != null && Inputs[0].status != null) {
            system.debug('Hello :'+ status[0]);
            if(status[0] == 'Approved'){
                makeLeaveApprovalCallout(Inputs[0].recordIds);
            }else if( status[0] == 'Check Out'){
                makeLeaveCheckOutCallout(Inputs[0].recordIds);
                makeLeaveCheckOutParent(Inputs[0].recordIds);
                makeLeaveCheckOutMentor(Inputs[0].recordIds);
               
            }else if( status[0] == 'Check In'){
                 makeLeaveCheckInStudent(Inputs[0].recordIds);
                makeLeaveCheckInParent(Inputs[0].recordIds);
                makeLeaveCheckInMentor(Inputs[0].recordIds);
            }
        } else {
            System.debug('Record IDs list is empty or null');
        }
    }
    
    @Future(callout=true)
    public static void makeLeaveApprovalCallout(List<String> recordIds) {
        // Fetch the related record data
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id, Start_Date_and_Time__c, End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        // Check if related record is found
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Contact__r.MobilePhone)) {
            REVA_Hostel_Leave_Request__c requiredField = requiredFields[0];
            
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'leaveapproval_student';
            
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            System.debug('templateMetadata: ' + templateMetadata);
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    if (key.trim() == 'studentname') {
                        notification1.params.put(key.trim(), requiredField.Contact__r.Name);
                    } else if (key.trim() == 'leavestartdatetime') {
                        notification1.params.put(key.trim(), String.valueOf(requiredField.Start_Date_and_Time__c));
                    } else if (key.trim() == 'leaveenddate') {
                        notification1.params.put(key.trim() + ' ', String.valueOf(requiredField.End_Date_and_Time__c));
                    } else if (key.trim() == 'reason') {
                        notification1.params.put(key.trim() + ' ', requiredField.Reason_For_Leave__c);
                    }
                }
            }
            
            
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            
            if(requiredField.Contact__r.MobilePhone !=null){
                String plusRemoved = requiredField.Contact__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                
            }  
            
            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp notification response: ' + response);
        } else {
            System.debug('No related record found for the provided ID');
        }
    }
    
    //  @Future(callout=true)
    public static void makeLeaveCheckOutCallout(List<String> recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c, LastModifiedDate,End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_leave_checkout_confirmation_student';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        String formattedCreatedDate = requiredFields[0].LastModifiedDate.format('yyyy-MM-dd', 'IST');
        String formattedCreatedTime = system.now().format('HH:mm:ss', 'IST');
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_leave_checkout_confirmation_student') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Contact__r.Name);
                        }else if (key == 'Check_out_date') {
                            notification1.params.put(key.trim(),string.valueof(stu.Start_Date__c));     
                        }else if (key == 'Check_out_time') {
                            notification1.params.put(key.trim(), formattedCreatedTime);
                        } else if (key == 'Checkin_date') { 
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        }else if (key == 'Leave_Start_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.Start_Date__c));
                        }else if (key == 'Leave_End_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    public static void makeLeaveCheckOutParent(List<String> recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c,LastModifiedDate, End_Date_and_Time__c,Contact__r.Father__r.Name, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_checkout_confirm_parent';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        String formattedCreatedDate = requiredFields[0].LastModifiedDate.format('yyyy-MM-dd', 'IST');
        String formattedCreatedTime = system.now().format('HH:mm:ss', 'IST');
        String CheckInCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_checkout_confirm_parent') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Contact__r.Father__r.Name);
                        }else if (key == 'Check_out_date') {
                            notification1.params.put(key.trim(),formattedCreatedDate);     
                        }else if (key == 'Check_out_time') {
                            notification1.params.put(key.trim(), formattedCreatedTime);
                        } else if (key == 'Check_in_date') { 
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'time') { 
                            notification1.params.put(key.trim(),CheckInCreatedTime );
                        }else if (key == 'Leave_Start_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.Start_Date__c));
                        }else if (key == 'Leave_End_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    public static void makeLeaveCheckOutMentor(List<String> recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c, End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone,Contact__r.Mentor__r.Name
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_checkout_confirm_mentor';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        String formattedCreatedDate = system.now().format('yyyy-MM-dd', 'IST');
        String formattedCreatedTime = system.now().format('HH:mm:ss', 'IST');
        String CheckInCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_checkout_confirm_mentor') {
                    for (String key : keys) {
                        if (key == 'mentor_name') {
                            notification1.params.put(key, stu.Contact__r.Mentor__r.Name);
                        }else if (key == 'Student_Name') {
                            notification1.params.put(key.trim(),stu.Contact__r.Name);     
                        }else if (key == 'Check_out_date') {
                            notification1.params.put(key.trim(),formattedCreatedDate);     
                        }else if (key == 'Check_out_time') {
                            notification1.params.put(key.trim(), formattedCreatedTime);
                        } else if (key == 'Check_in_date') { 
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Start_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.Start_Date__c));
                        }else if (key == 'Leave_End_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    public static void makeLeaveCheckInStudent(List<String> recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c, End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone,Contact__r.Mentor__r.Name
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_leave_checkin_student';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        String formattedCreatedDate = system.now().format('yyyy-MM-dd', 'IST');
        String formattedCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        String CheckInCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_leave_checkin_student') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Contact__r.Name);
                        } else if (key == 'Check_in_date') { 
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Check_in_time') {
                            notification1.params.put(key.trim(), formattedCreatedTime);
                        }else if (key == 'Leave_Start_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.Start_Date__c));
                        }else if (key == 'Leave_End_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    public static void makeLeaveCheckInParent(List<String> recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c, End_Date_and_Time__c, Reason_For_Leave__c,Contact__r.Father__r.Name,Contact__r.Name, Contact__r.MobilePhone,Contact__r.Mentor__r.Name
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_leave_checkin_parent';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        String formattedCreatedDate = system.now().format('yyyy-MM-dd', 'IST');
        String formattedCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        String CheckInCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_leave_checkin_parent') {
                    for (String key : keys) {
                        if (key == 'name') {
                            notification1.params.put(key, stu.Contact__r.Father__r.Name);
                        } else if (key == 'Check_in_date') { 
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Check_in_time') {
                            notification1.params.put(key.trim(), formattedCreatedTime);
                        }else if (key == 'Leave_Start_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.Start_Date__c));
                        }else if (key == 'Leave_End_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    
    public static void makeLeaveCheckInMentor(List<String> recordIds) {
        
        List<REVA_Hostel_Leave_Request__c> requiredFields = [
            SELECT Id,End_Date__c,Start_Date__c, Start_Date_and_Time__c, End_Date_and_Time__c, Reason_For_Leave__c, Contact__r.Name, Contact__r.MobilePhone,Contact__r.Mentor__r.Name
            FROM REVA_Hostel_Leave_Request__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'hostel_checkin_mentor';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        String formattedCreatedDate = system.now().format('yyyy-MM-dd', 'IST');
        String formattedCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        String CheckInCreatedTime = requiredFields[0].End_Date_and_Time__c.format('HH:mm:ss', 'IST');
        
        for( REVA_Hostel_Leave_Request__c stu : requiredFields ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'hostel_checkin_mentor') {
                    for (String key : keys) {
                        if (key == 'mentor_name') {
                            notification1.params.put(key, stu.Contact__r.Mentor__r.Name);
                        } else if (key == 'Student_Name') {
                            notification1.params.put(key, stu.Contact__r.Name);
                        } else if (key == 'Check_in_date') { 
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Check_in_time') {
                            notification1.params.put(key.trim(), formattedCreatedTime);
                        }else if (key == 'Leave_Start_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.Start_Date__c));
                        }else if (key == 'Leave_End_Date') {
                            notification1.params.put(key.trim(), string.valueof(stu.End_Date__c));
                        } else if (key == 'Leave_Reason') {
                            notification1.params.put(key.trim(), stu.Reason_For_Leave__c);
                        }        
                        
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                        if(stu.Contact__r.MobilePhone !=null){
                            String plusRemoved = stu.Contact__r.MobilePhone.replace('+', '');
                            String correctedWhatsappNumber = plusRemoved.replace('-', '');
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                            system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                        }       
                }
            }
        }
        System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
}