public class HostelRequestStaffNotifications {
    
    
    public static String staffName;
    public static String Employcode;
    public static String DptName;
    public static String FloorNo;
    public static String Disgnation;
    public static String BlockNo;
    public static String RoomNo;
    public static String staffPhoneNumber;
    public static String joiningDate;
    
    public static String reportMngrPhone;
    public static String adminDirecPhone;
    public static String hrPhone;
    public static String hostelOfficePhone;
    
    
    public static void sendBulkWhatsappNotifications(set<Id> requestIds) {
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsStaff = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsReManager = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsAdmin = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsHR = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsOffice = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        if(requestIds != null) {
            List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name,Approved_by_Hostel_Office__c,Approved_by_HR_Lead__c,Approved_by_AdminDirector__c,
                                                           Approved_by_ReportingManager__c, Status__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, 
                                                           Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Phone,
                                                           Reporting_Manager__r.Phone,Reporting_Manager__r.MobilePhone,
                                                           Admin_Director__r.Phone,Admin_Director__r.MobilePhone,
                                                           HR_Lead__r.MobilePhone,HR_Lead__r.Phone,
                                                           Hostel_Officer__r.Phone,Hostel_Officer__r.MobilePhone,
                                                           Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :requestIds];
            
            for(Reva_Hostel_Request__c hsReq :hostelRequests){
                reportMngrPhone =  hsReq.Reporting_Manager__r.MobilePhone != null ? hsReq.Reporting_Manager__r.MobilePhone.replace('+', '').replace('-', '') :hsReq.Reporting_Manager__r.Phone !=null ? hsReq.Reporting_Manager__r.Phone.replace('+', '').replace('-', '') : '';
                adminDirecPhone =  hsReq.Admin_Director__r.MobilePhone != null ? hsReq.Admin_Director__r.MobilePhone.replace('+', '').replace('-', '') :hsReq.Admin_Director__r.Phone !=null ?hsReq.Admin_Director__r.Phone.replace('+', '').replace('-', '') : '';
                hrPhone =  hsReq.HR_Lead__r.MobilePhone != null ? hsReq.HR_Lead__r.MobilePhone.replace('+', '').replace('-', '') :hsReq.HR_Lead__r.Phone !=null ?hsReq.HR_Lead__r.Phone.replace('+', '').replace('-', '') :'';
                hostelOfficePhone =  hsReq.Hostel_Officer__r.MobilePhone != null ? hsReq.Hostel_Officer__r.MobilePhone :hsReq.Hostel_Officer__r.Phone !=null ? hsReq.Hostel_Officer__r.Phone.replace('+', '').replace('-', ''):'';
                staffPhoneNumber = hsReq.Hostel_Room_Request_For__r.MobilePhone !=null ?hsReq.Hostel_Room_Request_For__r.MobilePhone.replace('+', '').replace('-', '') :hsReq.Hostel_Room_Request_For__r.Phone !=null ? hsReq.Hostel_Room_Request_For__r.Phone.replace('+', '').replace('-', '') :'';
                
                if(hsReq.Status__c == 'Booked'){
                    if(hsReq.Approved_by_ReportingManager__c == false){ // send notification to Staff and reporting Manager
                        phoneNumbersToNotificationsStaff = staffBooking(hsReq.Id); 
                        phoneNumbersToNotificationsReManager = reportMangerApprovalNotifi(hsReq.Id);
                        
                        if(!phoneNumbersToNotificationsStaff.isEmpty()){
                            System.debug('phoneNumbersToNotificationsStaff Ma---'+phoneNumbersToNotificationsStaff);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsStaff);  
                        }
                        
                        if(!phoneNumbersToNotificationsReManager.isEmpty()){
                            System.debug('phoneNumbersToNotificationsReManager Ma---'+phoneNumbersToNotificationsReManager);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsReManager);  
                        }
                    }
                    else if(hsReq.Approved_by_ReportingManager__c == true &&  hsReq.Approved_by_AdminDirector__c == false){ // send notification to Admin director
                        phoneNumbersToNotificationsAdmin = adminDirectorApprovalNotifi(hsReq.Id);
                        if(!phoneNumbersToNotificationsAdmin.isEmpty()){
                            System.debug('phoneNumbersToNotificationsAdmin Ma---'+phoneNumbersToNotificationsAdmin);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsAdmin);  
                        }
                        
                    }
                    else if(hsReq.Approved_by_AdminDirector__c == true && hsReq.Approved_by_HR_Lead__c == false){ // send notification to HR Lead
                        phoneNumbersToNotificationsHR = hrApprovalNotifi(hsReq.Id);
                        if(!phoneNumbersToNotificationsHR.isEmpty()){
                            System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsHR);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsHR);  
                        }
                        
                    }
                    else if(hsReq.Approved_by_HR_Lead__c == true && hsReq.Approved_by_Hostel_Office__c == false){  // send notification to Hostel Office
                        phoneNumbersToNotificationsOffice = hostelOfficeApprovalNotifi(hsReq.Id);
                        
                        if(!phoneNumbersToNotificationsOffice.isEmpty()){
                            System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsOffice);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsOffice);  
                        }
                        
                    }
                }
                else if(hsReq.Status__c == 'Room Allotted' && hsReq.Is_HCM_Salary_Deduction_CNF__c == true) {
                    System.debug('Room Allotted--inside-');
                    phoneNumbersToNotificationsStaff = staffAllotmentNotifi(hsReq.Id);
                    phoneNumbersToNotificationsReManager = reportManagerAllotmentNotifi(hsReq.Id);
                    phoneNumbersToNotificationsAdmin = adminDirectorAllotmentNotifi(hsReq.Id);
                    phoneNumbersToNotificationsOffice = hostelOfficeAllotmentNotifi(hsReq.Id);
                    phoneNumbersToNotificationsHR = hrAllotmentNotifi(hsReq.Id);
                    
                    if(!phoneNumbersToNotificationsReManager.isEmpty()){
                        System.debug('phoneNumbersToNotificationsReManager Ma---'+phoneNumbersToNotificationsReManager);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsReManager);  
                    }
                    if(!phoneNumbersToNotificationsAdmin.isEmpty()){
                        System.debug('phoneNumbersToNotificationsAdmin Ma---'+phoneNumbersToNotificationsAdmin);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsAdmin);  
                    }
                    if(!phoneNumbersToNotificationsStaff.isEmpty()) {
                        System.debug('phoneNumbersToNotificationsStaff Ma---'+phoneNumbersToNotificationsStaff);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsStaff);  
                    }
                    
                    if(!phoneNumbersToNotificationsHR.isEmpty()) {
                        System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsHR);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsHR);  
                    }
                    
                    if(!phoneNumbersToNotificationsOffice.isEmpty()) {
                        System.debug('phoneNumbersToNotifications office Ma---'+phoneNumbersToNotificationsOffice);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsOffice);  
                    }
                    System.debug('phoneNumbersToNotifications  All ---'+phoneNumbersToNotifications);
                    
                }
                
            }
            
            
            system.debug('requestIds===================='+requestIds);
            if(!phoneNumbersToNotifications.isEmpty()){
                if(!Test.isRunningTest()){
                    System.enqueueJob(new HstlQuarterBulkNotifiSMS_WtsappQueueable.HostelQuarterWtsappBulkNotification(phoneNumbersToNotifications,requestIds,'Hostel'));
            }
                }
                
        }
    }
    
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> staffBooking(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Employee_Number__c FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        system.debug('recordId2:'+recordId);
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_rqst_ack_staff';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        system.debug('templateMetadata2:'+templateMetadata);
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_rqst_ack_staff') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }
                    }
                }
                system.debug('notification123:'+notification);
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                if(req.Hostel_Room_Request_For__r.MobilePhone != null) {
                    system.debug('Phone123:'+req.Hostel_Room_Request_For__r.MobilePhone);
                    phoneNumbersToNotifications.put(staffPhoneNumber, notifications);
                }
            system.debug('notifications;;;'+notifications);
        }
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        //System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        // SLCM_HCMAPIQueueableHandler.HostelRequestApprovalHierarchyAPIQueueable(null,phoneNumbersToNotifications);
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> reportMangerApprovalNotifi(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c,Reporting_Manager__r.Name,Admin_Director__r.Name,HR_Lead__r.Name,Hostel_Officer__r.Name FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        system.debug('recordId2:'+recordId);
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_shr_reopm';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        system.debug('templateMetadata2:'+templateMetadata);
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_shr_reopm') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }
                        else if(key == 'reporting_manager'){
                            notification.params.put(key, req.Reporting_Manager__r.Name);
                        }
                        else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }
                        else if (key == 'department_name') {
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        } 
                        else if (key == 'designation') {
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.MobilePhone);
                        }
                    }
                }
                system.debug('notification123:'+notification);
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
            phoneNumbersToNotifications.put(reportMngrPhone, notifications);
                
            system.debug('notifications;;;'+notifications);
        }
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> adminDirectorApprovalNotifi(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c,Reporting_Manager__r.Name,
                                                       Admin_Director__r.Name FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        system.debug('recordId2:'+recordId);
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_shr_admd';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        system.debug('templateMetadata2:'+templateMetadata);
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_shr_admd') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }
                        else if(key == 'Admin_director'){
                            notification.params.put(key, req.Admin_Director__r.Name);
                        }
                        else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }else if (key == 'department_name') {
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        } 
                        else if (key == 'designation') {
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } 
                        else if(key == 'mobile_number'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.MobilePhone);
                        }
                    }
                }
                system.debug('notification123:'+notification);
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                
                    phoneNumbersToNotifications.put(adminDirecPhone, notifications);
                
            system.debug('notifications;;;'+notifications);
        }
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> hrApprovalNotifi(Id recordId) {
        System.debug('recordId--HR Booking---'+recordId);
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c, Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c,HR_Lead__r.Name FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_hostel_approval_rq_hr';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_hostel_approval_rq_hr') {
                    for(String key : keys) {
                        if(key == 'hr_name') {
                            notification.params.put(key, req.HR_Lead__r.Name);
                        }else if(key == 'staff_name'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }else if (key == 'department_name') {
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        } else if (key == 'designation') {
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } 
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                System.debug('notifications---'+notifications);
           
            phoneNumbersToNotifications.put(hrPhone, notifications);
            System.debug('phoneNumbersToNotifications--HR Booking---'+phoneNumbersToNotifications);
            
        }
        System.debug('notifications--HR Booking---'+phoneNumbersToNotifications);
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> hostelOfficeApprovalNotifi(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c, Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name,Hostel_Room_Request_For__r.Department, Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Designation__c,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Officer__r.Name,Reva_Hostel_JoiningDate__c FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_hrqst_approved_hostel_office';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_hrqst_approved_hostel_office') {
                    for(String key : keys) {
                        if(key == 'joining_Date') {
                            notification.params.put(key, String.valueOf(req.Reva_Hostel_JoiningDate__c));
                        }else if(key == 'staff_name'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        } else if (key == 'department_Name') {
                            String Department_Name = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, Department_Name);
                        }else if (key == 'designation') {
                            String Designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, Designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.MobilePhone);
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
            
            phoneNumbersToNotifications.put(hostelOfficePhone, notifications);
           
        }
         return phoneNumbersToNotifications;
    }
    
    
    
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> staffAllotmentNotifi(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Floor__c,Room_Number__c, Reva_Hostel_Room__c,Reva_Hostel_JoiningDate__c,Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.Phone,Block__c FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_hos_roo_allo_stf';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_hos_roo_allo_stf') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'block_no'){
                            notification.params.put(key, req.Block__c);
                        }else if(key == 'floor_No'){
                            notification.params.put(key, req.Floor__c);
                        }else if(key == 'room_No'){
                            notification.params.put(key, req.Room_Number__c);
                        }
                        else if(key == 'Joining_date'){
                            notification.params.put(key, String.valueOf(req.Reva_Hostel_JoiningDate__c));
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                  
            phoneNumbersToNotifications.put(staffPhoneNumber, notifications);
          
        }
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> reportManagerAllotmentNotifi(Id recordId){
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Floor__c,Room_Number__c,Reva_Hostel_JoiningDate__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Block__c,Reporting_Manager__r.Name,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_hrqst_allot_rep_man';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_hrqst_allot_rep_man') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'reporting_manager'){
                            notification.params.put(key, req.Reporting_Manager__r.Name);
                        }else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }else if(key == 'department_name'){
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        }else if(key == 'designation'){
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'block_number'){
                            notification.params.put(key, req.Block__c);
                        }else if(key == 'floor_number'){
                            notification.params.put(key, req.Floor__c);
                        }else if(key == 'room_number'){
                            notification.params.put(key, req.Room_Number__c);
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                  
            phoneNumbersToNotifications.put(reportMngrPhone, notifications);
           
        }
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> adminDirectorAllotmentNotifi (Id recordId){
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Floor__c,Room_Number__c, Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Block__c,Admin_Director__r.Name,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c
                                                       FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'hostel_allot_host_of_notif_copy';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'hostel_allot_host_of_notif_copy') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'admin_director'){
                            notification.params.put(key, req.Admin_Director__r.Name);
                        }else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }else if(key == 'department_name'){
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        }else if(key == 'designation'){
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'block_number'){
                            notification.params.put(key, req.Block__c);
                        }else if(key == 'floor_number'){
                            notification.params.put(key, req.Floor__c);
                        }else if(key == 'room_number'){
                            notification.params.put(key, req.Room_Number__c);
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
               
            phoneNumbersToNotifications.put(adminDirecPhone, notifications);
          
        }
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> hrAllotmentNotifi(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Floor__c,Room_Number__c, Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.MobilePhone,Block__c,Reporting_Manager__r.Name,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c
                                                       FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'hostel_allot_hr_notif_copy';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'hostel_allot_hr_notif_copy') {
                    for(String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'hr_name'){
                            notification.params.put(key, req.Reporting_Manager__r.Name);
                        }else if(key == 'employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }else if(key == 'department_name'){
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        }else if(key == 'designation'){
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'block_number'){
                            notification.params.put(key, req.Block__c);
                        }else if(key == 'floor_number'){
                            notification.params.put(key, req.Floor__c);
                        }else if(key == 'room_number'){
                            notification.params.put(key, req.Room_Number__c);
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
               
            phoneNumbersToNotifications.put(hrPhone, notifications);
            
        }
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> hostelOfficeAllotmentNotifi(Id recordId) {
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name, Status__c,Hostel_Room_Request_For__r.MobilePhone, Room_Number__c,Floor__c,Block__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name, Hostel_Room_Request_For__r.Phone,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Department,Hostel_Room_Request_For__r.Designation__c,Reva_Hostel_JoiningDate__c FROM Reva_Hostel_Request__c WHERE Id = :recordId];
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_hrqst_allotted_hso';
        
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c, Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for(Reva_Hostel_Request__c req : hostelRequests) {
            notification.params = new Map<String, String>();
            for(WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                if(metadata.Template_ID__c == 'h_hrqst_allotted_hso') {
                    for(String key : keys) {
                        if(key == 'Staff_Name') {
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Name);
                        }else if(key == 'Joining_Date'){
                            notification.params.put(key, String.valueOf(req.Reva_Hostel_JoiningDate__c));
                        }else if(key == 'Employee_code'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.Employee_Number__c);
                        }else if(key == 'Department_Name'){
                            String department = req.Hostel_Room_Request_For__r.Department != null 
                                ? req.Hostel_Room_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department);
                        }else if(key == 'Designation'){
                            String designation = req.Hostel_Room_Request_For__r.Designation__c != null 
                                ? req.Hostel_Room_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        }else if(key == 'mobile_number'){
                            notification.params.put(key, req.Hostel_Room_Request_For__r.MobilePhone);
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
               
            phoneNumbersToNotifications.put(hostelOfficePhone, notifications);
           
        }
        
        //System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        return phoneNumbersToNotifications;
    }
    
    
    
    /********************SMS sending for Teaching&NonTeaching*******************************************/
    
    /*****************************************************************/
    
    
    public static void sendHostelBulkSMS(Set<Id> requestIds) {
        System.debug('requestIds----->'+requestIds);
        // Consolidating the template maps for all notifications
        Map<String, List<SMS_API_Utility.shortMessageWrp>> allMessages = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Name,Approved_by_Hostel_Office__c,Approved_by_HR_Lead__c,
                                                       Approved_by_AdminDirector__c,Approved_by_ReportingManager__c, Status__c,Reva_Hostel_Room__c, Hostel_Room_Request_For__r.Name,
                                                       Reporting_Manager__r.Name,Admin_Director__r.Name,HR_Lead__r.Name,Hostel_Officer__r.Name,Hostel_Officer__r.Phone,Hostel_Officer__r.MobilePhone,
                                                       Reva_Hostel_Request__c.Reva_Hostel_JoiningDate__c,Hostel_Room_Request_For__r.Phone,
                                                       Admin_Director__r.Phone,Admin_Director__r.MobilePhone,Reporting_Manager__r.Phone,Reporting_Manager__r.MobilePhone,HR_Lead__r.Phone,HR_Lead__r.MobilePhone,
                                                       Hostel_Room_Request_For__r.MobilePhone,Hostel_Room_Request_For__r.Employee_Number__c,Hostel_Room_Request_For__r.Designation__c,Reva_Hostel_Room__r.Name,
                                                       Is_HCM_Salary_Deduction_CNF__c,Block__c,Floor__c,Room_Number__c,Hostel_Room_Request_For__r.Department FROM Reva_Hostel_Request__c
                                                       WHERE Id IN :requestIds 
                                                       AND (Status__c = 'Booked' OR Status__c = 'Room Allotted' )];
        System.debug('hostelRequests----->'+hostelRequests);
        for (Reva_Hostel_Request__c request : hostelRequests) {
            staffName = request.Hostel_Room_Request_For__r.Name;
            RoomNo = request.Reva_Hostel_Room__r.Name;
            FloorNo = request.Floor__c;
            BlockNo = request.Block__c;
            Employcode = request.Hostel_Room_Request_For__r.Employee_Number__c;
            joiningDate = string.valueOf(request.Reva_Hostel_JoiningDate__c);
            DptName = request.Hostel_Room_Request_For__r.Department != null ? request.Hostel_Room_Request_For__r.Department : 'NOT AVAILABLE';
            Disgnation = request.Hostel_Room_Request_For__r.Designation__c != null ? request.Hostel_Room_Request_For__r.Designation__c : 'NOT AVAILABLE';
            
            //staffPhoneNumber = request.Hostel_Room_Request_For__r.MobilePhone !=null ? request.Hostel_Room_Request_For__r.MobilePhone.replace('+', '').replace('-', '') :request.Hostel_Room_Request_For__r.Phone.replace('+', '').replace('-', '');
            //reportMngrPhone = request.Reporting_Manager__r.MobilePhone != null ? request.Reporting_Manager__r.MobilePhone.replace('+', '').replace('-', '') :request.Reporting_Manager__r.Phone.replace('+', '').replace('-', '');
            //adminDirecPhone = request.Admin_Director__r.MobilePhone != null ? request.Admin_Director__r.MobilePhone.replace('+', '').replace('-', '') :request.Admin_Director__r.Phone.replace('+', '').replace('-', '');
            //hrPhone = request.HR_Lead__r.MobilePhone != null ? request.HR_Lead__r.MobilePhone.replace('+', '').replace('-', '') :request.HR_Lead__r.Phone.replace('+', '').replace('-', '');
            //hostelOfficePhone = request.Hostel_Officer__r.MobilePhone != null ? request.Hostel_Officer__r.MobilePhone.replace('+', '').replace('-', '') :request.Hostel_Officer__r.Phone.replace('+', '').replace('-', '');
            
            reportMngrPhone =  request.Reporting_Manager__r.MobilePhone != null ? request.Reporting_Manager__r.MobilePhone.replace('+', '').replace('-', '') :request.Reporting_Manager__r.Phone !=null ? request.Reporting_Manager__r.Phone.replace('+', '').replace('-', '') : '';
            adminDirecPhone =  request.Admin_Director__r.MobilePhone != null ? request.Admin_Director__r.MobilePhone.replace('+', '').replace('-', '') :request.Admin_Director__r.Phone !=null ?request.Admin_Director__r.Phone.replace('+', '').replace('-', '') : '';
            hrPhone =  request.HR_Lead__r.MobilePhone != null ? request.HR_Lead__r.MobilePhone.replace('+', '').replace('-', '') :request.HR_Lead__r.Phone !=null ?request.HR_Lead__r.Phone.replace('+', '').replace('-', '') :'';
            hostelOfficePhone =  request.Hostel_Officer__r.MobilePhone != null ? request.Hostel_Officer__r.MobilePhone :request.Hostel_Officer__r.Phone !=null ? request.Hostel_Officer__r.Phone.replace('+', '').replace('-', ''):'';
            staffPhoneNumber = request.Hostel_Room_Request_For__r.MobilePhone !=null ?request.Hostel_Room_Request_For__r.MobilePhone.replace('+', '').replace('-', '') :request.Hostel_Room_Request_For__r.Phone !=null ? request.Hostel_Room_Request_For__r.Phone.replace('+', '').replace('-', '') :'';
            
            if (request.Status__c == 'Booked') {
                System.debug('--Status Booked--->');
                if(request.Approved_by_ReportingManager__c == false){
                    allMessages.putAll(staffBookingSMS()); // staff SMS notification
                    allMessages.putAll(reportManaSMS());
                }
                
                else if(request.Approved_by_ReportingManager__c == true &&  request.Approved_by_AdminDirector__c == false){
                    allMessages.putAll(adminDireBookingSMS());
                }
                
                else if(request.Approved_by_AdminDirector__c == true && request.Approved_by_HR_Lead__c == false){
                    allMessages.putAll(hrBookingSMS()); //HR SMS Notification
                }
                
                else if(request.Approved_by_HR_Lead__c == true && request.Approved_by_Hostel_Office__c == false){
                    allMessages.putAll(hostelOfficeBookingSMS()); // Hostel office SMS Notifcation
                }
            } else if (request.Status__c == 'Room Allotted' &&  request.Is_HCM_Salary_Deduction_CNF__c == true) {
                System.debug('--Status Room Alloted--->');
                
                allMessages.putAll(staffAllotmentSMS());
                allMessages.putAll(reportManaAllotmentSMS());
                allMessages.putAll(adminDireAllotmentSMS());
                allMessages.putAll(hrAllotmentSMS());
                allMessages.putAll(hostelOfficeAllotmentSMS());
            }
        }
        System.debug('--allMessages-->'+allMessages);
        if (!allMessages.isEmpty()) {
            if(!test.isRunningTest()){
                System.enqueueJob(new HstlQuarterBulkNotifiSMS_WtsappQueueable.HostelQuarterSMSBulkNotification(allMessages));
            }
            
        }
    }
    
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> staffBookingSMS() {
        System.debug('staffName ----'+staffName +'staffNumber---'+staffPhoneNumber);
        return createMessageMap('Hostel_Request_Staff', 
                                'Dear ' + staffName + ',\nYour Hostel request has been received. We will notify you once it is processed.\nRegards,\nREVA University.', 
                                staffPhoneNumber, '1007240148112049281');
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> reportManaSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+'staffNumber');
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        //New Hostel request received from {#var#}. Please review the request. Employee Code:{#var#} Department: {#var#} Designation: {#var#} Regards REVA University
        String message = 'New Hostel request received from '+staffName+ '. Please go with the further process. Employee Code : '+Employcode+' \nREVA University';
        messageMap.putAll(createMessageMap('Hstl_Req_To_RM', message, reportMngrPhone, '1007198257693261217'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> adminDireBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+adminDirecPhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        //New Hostel request received from {#var#}. Please review the request. Employee Code:{#var#} Department: {#var#} Designation: {#var#} Regards REVA University
        String message = 'New Hostel request has been received from '+staffName+ '. Please approve it for further processing. Employee Code: '+Employcode+' \nREVA University';
        				  //New Hostel request has been received from Rahul. Please approve it for further processing. Employee Code: REVA 1234 REVA University
        messageMap.putAll(createMessageMap('Hstl_Req_AdminDirector', message, adminDirecPhone, '1007938359619607785'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hrBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+hrPhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        //New Hostel request received from {#var#}. Please review the request. Employee Code:{#var#} Department: {#var#} Designation: {#var#} Regards REVA University
        String message = 'New Hostel request received from '+staffName+ '. Please review the request. Employee Code:'+Employcode+' Department: '+DptName+' Designation: '+Disgnation+' \nRegards \nREVA University';
        messageMap.putAll(createMessageMap('Hostel_Request_HR_Notification', message, hrPhone, '1007302088967796336'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hostelOfficeBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+hostelOfficePhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
            //String message = 'New Hostel request received from ' + staffName + '. Please review the request.\nREVA University';
            String message = 'The Hostel request is approved for '+staffName+ '. Please proceed with further process. Employee Code: '+Employcode+' \nREVA University';
                             //The Hostel request is approved for Rahul, please proceed with further process. Employee Code: REVA 1234 REVA University
            messageMap.putAll(createMessageMap('Hstl_Req_To_HostelOffie', message, hostelOfficePhone, '1007923267049834644'));
       
        return messageMap;
    }
    
    // Refactored method to create staff allotment message
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> staffAllotmentSMS() {
        String message = 'Dear '+staffName+', Your hostel room has been allocated per your request. Block No:'+BlockNo+ ' Floor No:'+FloorNo+' Room No:'+RoomNo+' \nREVA University';
        return createMessageMap('Hostel_Room_Allocation_Staff', message, staffPhoneNumber, '1007411262503630615');
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> reportManaAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
            // String message = 'Hostel Room is allocated to ' + staffName + '. Contact No: 9182820978\nREVA University';
            String message = 'Hostel room is allotted to '+staffName+'. Employee Code: '+Employcode+' \nREVA University';
            messageMap.putAll(createMessageMap('Hstl_Allotment_To_RM', message, reportMngrPhone, '1007042577520892888'));
       
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> adminDireAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
            // String message = 'Hostel Room is allocated to ' + staffName + '. Contact No: 9182820978\nREVA University';
            String message = 'Hostel room is allotted for '+staffName+ '. Employee code: '+Employcode+' \nRegards \nREVA University';
                              //Hostel room is allotted for Rahul. Employee code: REVA 1234 Regards REVA University
            messageMap.putAll(createMessageMap('Hstl_Room_Allot_AdminDirector', message, adminDirecPhone, '1007221103688406339'));
       
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hrAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
            // String message = 'Hostel Room is allocated to ' + staffName + '. Contact No: 9182820978\nREVA University';
            String message = 'Hostel Room is allocated to '+staffName+ '. Employee Code: '+Employcode+' Department: '+DptName+' Designation: '+Disgnation+' Contact No: '+staffPhoneNumber+' \nRegards \nREVA University';
            messageMap.putAll(createMessageMap('Hostel_Room_Allotted_Information_to_HR', message, hrPhone, '1007296201075336833'));
       
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hostelOfficeAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
            // String message = 'Hostel Room is allocated to ' + staffName + '. Contact No: 9182820978\nREVA University';
            String message = 'Hostel room is allocated to the following staff. Staff Name: '+staffName+ '. Employee Code: '+Employcode+' \nREVA University';
            messageMap.putAll(createMessageMap('Hstl_Room_Allot_To_HostelOffice', message, hostelOfficePhone, '1007023631235400523'));
       
        return messageMap;
    }
    
    // General method to create and return a message map
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> createMessageMap(String templateKey, String message, String recipient, String dltContentId) {
        System.debug('message -2---'+message +'recipient-2--'+recipient +'dltContentId==='+dltContentId+'templateKey====='+templateKey);
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
        SMS_API_Utility.shortMessageWrp shortMessage = new SMS_API_Utility.shortMessageWrp();
        shortMessage.dltContentId = dltContentId;
        shortMessage.message = message;
        shortMessage.recipient = recipient;
        messageList.add(shortMessage);
        System.debug('messageList -2---'+messageList );
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        messageMap.put(templateKey, messageList);
        System.debug('messageMap -2---'+messageMap );
        return messageMap;
    }
    
    
}