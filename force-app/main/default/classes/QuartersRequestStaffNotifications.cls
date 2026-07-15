public class QuartersRequestStaffNotifications {
    
    
    public static String staffName;
    public static String employcode;
    public static String staffMobileNumber;
    public static String floorNo;
    public static String houseNo;
    public static String BlockNo;
    public static String RoomNo;
    public static String joiningDate;
    public static String disgnation;
    public static String department;
    
    
    public static String reportMngrPhone;
    public static String adminDirecPhone;
    public static String hrPhone;
    public static String hostelOfficePhone;
    
    public static void sendQuarterBulkWhatsappNotifications(set<Id> requestIds) {
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsStaff = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsReManager = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsAdmin = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsHR = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsOffice = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotificationsOfficeAfterHCMconf = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        if(requestIds != null) {
            List<Staff_Quarters_Request__c> quarterRequests = [SELECT Id, Name,Approved_by_ReportingManager__c,Approved_by_AdminDirector__c,
                                                               Approved_by_HR_Lead__c,Approved_by_Hostel_Office__c,Status__c,
                                                               Staff_Quarters_Room__c,Quarter_Request_For__c,Quarter_Request_For__r.Name,
                                                               Quarter_Request_For__r.Employee_Number__c,Quarter_Request_For__r.MobilePhone,Quarter_Request_For__r.Phone,
                                                               Reporting_Manager__r.Phone,Reporting_Manager__r.MobilePhone,
                                                               Admin_Director__r.Phone,Admin_Director__r.MobilePhone,
                                                               HR_Lead__r.MobilePhone,HR_Lead__r.Phone,
                                                               Hostel_Officer__r.Phone,Hostel_Officer__r.MobilePhone,
                                                               Is_HCM_Salary_Deduction_CNF__c FROM Staff_Quarters_Request__c WHERE Id = :requestIds];
            for(Staff_Quarters_Request__c qaReq :quarterRequests){
                    reportMngrPhone =  qaReq.Reporting_Manager__r.MobilePhone != null ? qaReq.Reporting_Manager__r.MobilePhone.replace('+', '').replace('-', '') :qaReq.Reporting_Manager__r.Phone != null ? qaReq.Reporting_Manager__r.Phone.replace('+', '').replace('-', '') :'';
                    adminDirecPhone =  qaReq.Admin_Director__r.MobilePhone != null ? qaReq.Admin_Director__r.MobilePhone.replace('+', '').replace('-', '') :qaReq.Admin_Director__r.Phone != null ? qaReq.Admin_Director__r.Phone.replace('+', '').replace('-', '') :'';
                    hrPhone =  qaReq.HR_Lead__r.MobilePhone != null ? qaReq.HR_Lead__r.MobilePhone.replace('+', '').replace('-', '') :qaReq.HR_Lead__r.Phone != null ? qaReq.HR_Lead__r.Phone.replace('+', '').replace('-', '') :'';
                    hostelOfficePhone =  qaReq.Hostel_Officer__r.MobilePhone != null ? qaReq.Hostel_Officer__r.MobilePhone :qaReq.Hostel_Officer__r.Phone != null ? qaReq.Hostel_Officer__r.Phone.replace('+', '').replace('-', '') :'';
                    staffMobileNumber = qaReq.Quarter_Request_For__r.MobilePhone !=null ?qaReq.Quarter_Request_For__r.MobilePhone.replace('+', '').replace('-', '') : qaReq.Quarter_Request_For__r.Phone != null ? qaReq.Quarter_Request_For__r.Phone.replace('+', '').replace('-', ''):'';
                if(qaReq.Status__c == 'Booked') {
                    System.debug('Booked--inside-');
                  
                    
                    if(qaReq.Approved_by_ReportingManager__c == false){
                        phoneNumbersToNotificationsStaff = StaffBooking(qaReq.Id);
                        phoneNumbersToNotificationsReManager = reportMangerApprovalNotifi(qaReq.Id);
                        if(!phoneNumbersToNotificationsStaff.isEmpty()){
                            System.debug('phoneNumbersToNotificationsStaff Ma---'+phoneNumbersToNotificationsStaff);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsStaff);  
                        }
                        if(!phoneNumbersToNotificationsReManager.isEmpty()){
                            System.debug('phoneNumbersToNotificationsReManager Ma---'+phoneNumbersToNotificationsReManager);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsReManager);  
                        }
                    } else if(qaReq.Approved_by_ReportingManager__c == true &&  qaReq.Approved_by_AdminDirector__c == false){
                        phoneNumbersToNotificationsAdmin = adminDirectorApprovalNotifi(qaReq.Id);
                        if(!phoneNumbersToNotificationsAdmin.isEmpty()){
                            System.debug('phoneNumbersToNotificationsAdmin Ma---'+phoneNumbersToNotificationsAdmin);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsAdmin);  
                        }
                    }
                    else if(qaReq.Approved_by_AdminDirector__c == true && qaReq.Approved_by_HR_Lead__c == false){ // send notification to HR Lead
                        phoneNumbersToNotificationsHR = HRBooking(qaReq.Id);
                        if(!phoneNumbersToNotificationsHR.isEmpty()){
                            System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsHR);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsHR);  
                        }
                        
                    }
                    else if(qaReq.Approved_by_HR_Lead__c == true && qaReq.Approved_by_Hostel_Office__c == false){ // send notification to HOstel Office Lead
                        phoneNumbersToNotificationsOffice = HostelOfficeBooking(qaReq.Id);
                        if(!phoneNumbersToNotificationsOffice.isEmpty()){
                            System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsOffice);
                            phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsOffice);  
                        }
                        
                    }
                }
                
                else if(qaReq.Status__c == 'Approved' && qaReq.Approved_by_Hostel_Office__c == true && qaReq.Is_HCM_Salary_Deduction_CNF__c == true ){ // send notification to HOstel Office after HCM confirmation
                    phoneNumbersToNotificationsOfficeAfterHCMconf = hostelOfficeafterHCMconfToRoomAllocation(qaReq.Id);
                    if(!phoneNumbersToNotificationsOfficeAfterHCMconf.isEmpty()){
                        System.debug('phoneNumbersToNotificationsOfficeAfterHCMconf Ma---'+phoneNumbersToNotificationsOfficeAfterHCMconf);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsOfficeAfterHCMconf);  
                    }
                }
                
                else if(qaReq.Status__c == 'Room Allotted' && qaReq.Is_HCM_Salary_Deduction_CNF__c == true) {
                    System.debug('Room Allotted--inside-');
                    phoneNumbersToNotificationsStaff = StaffAllotment(qaReq.Id);
                    phoneNumbersToNotificationsReManager = reportManagerAllotmentNotifi(qaReq.Id);
                    phoneNumbersToNotificationsAdmin = adminDirectorAllotmentNotifi(qaReq.Id);
                    phoneNumbersToNotificationsHR = HRAllotment(qaReq.Id);
                    phoneNumbersToNotificationsOffice = HostelOfficeAllotment(qaReq.Id);
                    
                    if(!phoneNumbersToNotificationsStaff.isEmpty()){
                        System.debug('phoneNumbersToNotificationsStaff Ma---'+phoneNumbersToNotificationsStaff);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsStaff);  
                    }
                    if(!phoneNumbersToNotificationsReManager.isEmpty()){
                        System.debug('phoneNumbersToNotificationsReManager Ma---'+phoneNumbersToNotificationsReManager);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsReManager);  
                    }
                    if(!phoneNumbersToNotificationsAdmin.isEmpty()){
                        System.debug('phoneNumbersToNotificationsAdmin Ma---'+phoneNumbersToNotificationsAdmin);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsAdmin);  
                    }
                    if(!phoneNumbersToNotificationsHR.isEmpty()){
                        System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsHR);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsHR);  
                    }
                    
                    if(!phoneNumbersToNotificationsOffice.isEmpty()){
                        System.debug('phoneNumbersToNotificationsHR Ma---'+phoneNumbersToNotificationsOffice);
                        phoneNumbersToNotifications.putAll(phoneNumbersToNotificationsOffice);  
                    }
                    System.debug('phoneNumbersToNotifications Ma---'+phoneNumbersToNotifications);
                    
                }
                
            }
            
            
            system.debug('requestIds===================='+requestIds);
            if(!phoneNumbersToNotifications.isEmpty()){
                if(!Test.isRunningTest()){
                   System.enqueueJob(new HstlQuarterBulkNotifiSMS_WtsappQueueable.HostelQuarterWtsappBulkNotification(phoneNumbersToNotifications,requestIds,'Quarter')); 
                }
                
            }
        }
    }
    
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> StaffBooking(Id recordId) {
        
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,Room_Request_For__r.Phone From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'h_sqr_ack_staff';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_ack_staff') {
                    for (String key : keys) {
                        if (key == 'staff_name') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
              
                    phoneNumbersToNotifications.put(staffMobileNumber, notifications);
                    system.debug('PhoneNumber:::'+staffMobileNumber);
                           
                }
            }
        }
        
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        return phoneNumbersToNotifications;
    }   
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> reportMangerApprovalNotifi(Id recordId) {
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,Reporting_Manager__r.Name,
                                                       Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,Quarter_Request_For__r.Employee_Number__c
                                                       From Staff_Quarters_Request__c WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_sqr_rqst_rm';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c qRe : Revaguestre ){
            notification.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_rqst_rm') {
                    for (String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, qRe.Quarter_Request_For__r.Name);
                        }
                        else if(key == 'reporting_manager'){
                            notification.params.put(key, qRe.Reporting_Manager__r.Name);
                        }
                        else if(key == 'employee_code'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'department_name') {
                            String department_name = qRe.Quarter_Request_For__r.Department != null 
                                ? qRe.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department_name);
                        } else if (key == 'designation') {
                            String designation = qRe.Quarter_Request_For__r.Designation__c != null 
                                ? qRe.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.MobilePhone);
                        } else if(key == 'Quarters_type'){
                            notification.params.put(key, qRe.Type__c);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                    phoneNumbersToNotifications.put(reportMngrPhone, notifications);
                    system.debug('PhoneNumber:::'+reportMngrPhone);
                         
                }
            }
        }
        
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> adminDirectorApprovalNotifi(Id recordId) {
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,Quarter_Request_For__r.Employee_Number__c,Admin_Director__r.Name
                                                       From Staff_Quarters_Request__c WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_sqr_rqst_admd';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c qRe : Revaguestre ){
            notification.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_rqst_admd') {
                    for (String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, qRe.Quarter_Request_For__r.Name);
                        }
                        else if(key == 'admin_director'){
                            notification.params.put(key, qRe.Admin_Director__r.Name);
                        }
                        else if(key == 'employee_code'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.Employee_Number__c);
                        }else if (key == 'department_name') {
                            String department_name = qRe.Quarter_Request_For__r.Department != null 
                                ? qRe.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department_name);
                        } else if (key == 'designation') {
                            String designation = qRe.Quarter_Request_For__r.Designation__c != null 
                                ? qRe.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.MobilePhone);
                        } else if(key == 'Quarters_type'){
                            notification.params.put(key, qRe.Type__c);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                      
                    phoneNumbersToNotifications.put(adminDirecPhone, notifications);
                    system.debug('PhoneNumber:::'+adminDirecPhone);
                       
                }
            }
        }
        
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> HRBooking(Id recordId) {
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,Quarter_Request_For__r.Employee_Number__c,HR_Lead__r.Name
                                                       From Staff_Quarters_Request__c WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_sqr_rqst_hr';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c qRe : Revaguestre ){
            notification.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_rqst_hr') {
                    for (String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, qRe.Quarter_Request_For__r.Name);
                        }
                        else if(key == 'hr_name'){
                            notification.params.put(key, qRe.HR_Lead__r.Name);
                        }
                        else if(key == 'employee_code'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'department_name') {
                            String department_name = qRe.Quarter_Request_For__r.Department != null 
                                ? qRe.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, department_name);
                        } else if (key == 'designation') {
                            String designation = qRe.Quarter_Request_For__r.Designation__c != null 
                                ? qRe.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.MobilePhone);
                        } else if (key == 'Quarters_type') {
                            notification.params.put(key, qRe.Type__c);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                
                    phoneNumbersToNotifications.put(hrPhone, notifications);
                    system.debug('PhoneNumber:::'+hrPhone);
                        
                }
            }
        }
        
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);

        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> HostelOfficeBooking(Id recordId) {
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,Quarter_Request_For__r.Employee_Number__c,
                                                       Hostel_Officer__r.Name,Staff_Quarters_Joining_Date__c From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_sqr_approved_hso';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c qRe : Revaguestre ){
            notification.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_approved_hso') {
                    for (String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, qRe.Quarter_Request_For__r.Name);
                        }
                        
                        else if(key == 'Emp_code'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'Department_Name') {
                            String Department_Name = qRe.Quarter_Request_For__r.Department != null 
                                ? qRe.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, Department_Name);
                        } else if (key == 'Designation') {
                            String Designation = qRe.Quarter_Request_For__r.Designation__c != null 
                                ? qRe.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, Designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.MobilePhone);
                        } else if(key == 'Date'){
                            notification.params.put(key, String.valueOf(qRe.Staff_Quarters_Joining_Date__c));
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                        
                    phoneNumbersToNotifications.put(hostelOfficePhone, notifications);
                    system.debug('PhoneNumber:::'+hostelOfficePhone);
                         
                }
            }
        }
        
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> hostelOfficeafterHCMconfToRoomAllocation(Id recordId) {
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,Quarter_Request_For__r.Employee_Number__c,
                                                       Hostel_Officer__r.Name,Staff_Quarters_Joining_Date__c From Staff_Quarters_Request__c  WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
        notification.templateId = 'h_sqr_alloc_hso';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c qRe : Revaguestre ){
            notification.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_alloc_hso') {
                    for (String key : keys) {
                        if(key == 'staff_name') {
                            notification.params.put(key, qRe.Quarter_Request_For__r.Name);
                        }
                        
                        else if(key == 'Employee_code'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'Department_Name') {
                            String Department_Name = qRe.Quarter_Request_For__r.Department != null 
                                ? qRe.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, Department_Name);
                        } else if (key == 'Designation') {
                            String Designation = qRe.Quarter_Request_For__r.Designation__c != null 
                                ? qRe.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification.params.put(key, Designation);
                        } else if(key == 'mobile_number'){
                            notification.params.put(key, qRe.Quarter_Request_For__r.MobilePhone);
                        } else if(key == 'Joining_Date'){
                            notification.params.put(key, string.valueOf(qRe.Staff_Quarters_Joining_Date__c));
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                       
                    phoneNumbersToNotifications.put(hostelOfficePhone, notifications);
                    system.debug('PhoneNumber:::'+hostelOfficePhone);
                        
                }
            }
        }
        
        system.debug('phoneNumbersToNotifications::'+phoneNumbersToNotifications);
        return phoneNumbersToNotifications;
    }
    
    
    
    
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> StaffAllotment(Id recordId) {
        System.debug('Phone Number -->'+recordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Staff_Quarters_Room__r.Floor__c,
                                                       Staff_Quarters_Room__r.Name,Quarter_Request_For__r.MobilePhone,Quarter_Request_For__r.Name,Staff_Quarters_Joining_Date__c
                                                       From Staff_Quarters_Request__c WHERE id =: recordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'h_sqr_alloc_staff';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_alloc_staff') {
                    for (String key : keys) {
                        if (key == 'staff_name') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Name);
                        }else if (key == 'floor_No') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Floor__c);
                        }else if (key == 'House_No') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Name);
                        }else if (key == 'joining_date') {
                            notification1.params.put(key, String.valueOf(stu.Staff_Quarters_Joining_Date__c));
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   
                    phoneNumbersToNotifications.put(staffMobileNumber, notifications);
                    system.debug('PhoneNumber:::'+staffMobileNumber);
                }       
            }
        }
        
        return phoneNumbersToNotifications;
        //System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> reportManagerAllotmentNotifi(Id recordId){
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone, 
                                                       Staff_Quarters_Room__r.Floor__c,Staff_Quarters_Room__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Name,Staff_Quarters_Joining_Date__c,Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,
                                                       Quarter_Request_For__r.Employee_Number__c,Reporting_Manager__r.Name
                                                       From Staff_Quarters_Request__c
                                                       WHERE id =: recordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'h_sqr_alloc_repom';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_alloc_repom') {
                    for (String key : keys) {
                        if (key == 'staff_name') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Name);
                        }else if (key == 'reporting_manager_name') {
                            notification1.params.put(key, stu.Reporting_Manager__r.Name);
                        }
                        else if (key == 'employee_code') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'department_name') {
                            String department_name = stu.Quarter_Request_For__r.Department != null 
                                ? stu.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, department_name);
                        } else if (key == 'designation') {
                            String designation = stu.Quarter_Request_For__r.Designation__c != null 
                                ? stu.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, designation);
                        } else if (key == 'floor_number') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Floor__c);
                        } else if (key == 'house_number') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   
                    phoneNumbersToNotifications.put(reportMngrPhone, notifications);
                    system.debug('PhoneNumber:::'+reportMngrPhone);
                }       
            }
        }
        
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> adminDirectorAllotmentNotifi (Id recordId){
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,Staff_Quarters_Room__r.Floor__c,Staff_Quarters_Room__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Name,Staff_Quarters_Joining_Date__c,Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,
                                                       Quarter_Request_For__r.Employee_Number__c,Admin_Director__r.Name From Staff_Quarters_Request__c WHERE id =: recordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_alloc_hos_notif_copy';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_alloc_hos_notif_copy') {
                    for (String key : keys) {
                        if (key == 'staff_name') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Name);
                        }else if (key == 'general_admin') {
                            notification1.params.put(key, stu.Admin_Director__r.Name);
                        }else if (key == 'employee_code') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'department_name') {
                            String department_name = stu.Quarter_Request_For__r.Department != null 
                                ? stu.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, department_name);
                        } else if (key == 'designation') {
                            String designation = stu.Quarter_Request_For__r.Designation__c != null 
                                ? stu.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, designation);
                        } else if (key == 'floor_number') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Floor__c);
                        } else if (key == 'house_number') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                      
                    phoneNumbersToNotifications.put(adminDirecPhone, notifications);
                    system.debug('PhoneNumber:::'+adminDirecPhone);
                }       
            }
        }
        
        return phoneNumbersToNotifications;
    } 
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> HRAllotment(Id recordId) {
        System.debug('Phone Number -->'+recordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,
                                                       Staff_Quarters_Room__r.Floor__c,Staff_Quarters_Room__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Name,Staff_Quarters_Joining_Date__c,Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,
                                                       Quarter_Request_For__r.Employee_Number__c,HR_Lead__r.Name
                                                       From Staff_Quarters_Request__c
                                                       WHERE id =: recordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'staff_quar_alloc_hr_notif_copy';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'staff_quar_alloc_hr_notif_copy') {
                    for (String key : keys) {
                        if (key == 'hr_name') {
                            notification1.params.put(key, stu.HR_Lead__r.Name);
                        }else if (key == 'staff_name') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Name);
                        }else if (key == 'employee_code') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'department_name') {
                            String department_name = stu.Quarter_Request_For__r.Department != null 
                                ? stu.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, department_name);
                        } else if (key == 'designation') {
                            String designation = stu.Quarter_Request_For__r.Designation__c != null 
                                ? stu.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, designation);
                        } else if (key == 'floor_number') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Floor__c);
                        } else if (key == 'house_number') {
                            notification1.params.put(key, stu.Staff_Quarters_Room__r.Name);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                    
                    phoneNumbersToNotifications.put(hrPhone, notifications);
                    system.debug('PhoneNumber:::'+hrPhone);
                         
                }
            }
        }
        //System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
        return phoneNumbersToNotifications;
    }
    public static Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> HostelOfficeAllotment(Id recordId) {
        System.debug('Phone Number -->'+RecordId);
        List<Staff_Quarters_Request__c> Revaguestre = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Room_Request_For__r.Name,Room_Request_For__r.Phone,
                                                       Staff_Quarters_Room__r.Floor__c,Staff_Quarters_Room__r.Name,Quarter_Request_For__r.MobilePhone,
                                                       Quarter_Request_For__r.Name,Staff_Quarters_Joining_Date__c,Quarter_Request_For__r.Department,Quarter_Request_For__r.Designation__c,
                                                       Quarter_Request_For__r.Employee_Number__c,Hostel_Officer__r.Name
                                                       From Staff_Quarters_Request__c
                                                       WHERE id =: RecordId];
        
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = 'h_sqr_allotted_hso';
        Map<Id,Decimal> NoofRooms = new Map<Id,Decimal>();
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c,Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        for( Staff_Quarters_Request__c stu : Revaguestre ){
            notification1.params = new Map<String, String>();
            Map<String,String> CounselorName = new Map<String,String>(); 
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                if(metadata.Template_ID__c == 'h_sqr_allotted_hso') {
                    for (String key : keys) {
                        if (key == 'Quarters_type') {
                            notification1.params.put(key, stu.Type__c);
                        }else if (key == 'Staff_Name') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Name);
                        }else if (key == 'Joining_Date') {
                            notification1.params.put(key, String.valueOf(stu.Staff_Quarters_Joining_Date__c));
                        }  else if (key == 'Department_Name') {
                            String Department_Name = stu.Quarter_Request_For__r.Department != null 
                                ? stu.Quarter_Request_For__r.Department 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, Department_Name);
                        } else if (key == 'designation') {
                            String designation = stu.Quarter_Request_For__r.Designation__c != null 
                                ? stu.Quarter_Request_For__r.Designation__c 
                                : 'NOT AVAILABLE';
                            notification1.params.put(key, designation);
                        } else if (key == 'Employee_code') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.Employee_Number__c);
                        } else if (key == 'mobile_number') {
                            notification1.params.put(key, stu.Quarter_Request_For__r.MobilePhone);
                        }
                    }
                    
                    List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                    
                    phoneNumbersToNotifications.put(hostelOfficePhone, notifications);
                    system.debug('PhoneNumber:::'+hostelOfficePhone);
                }       
            }
        }
        
           return phoneNumbersToNotifications;
    }
    
    
    /********************SMS sending for Teaching&NonTeaching*******************************************/
    
    /*****************************************************************/
    
    
    public static void sendHostelBulkSMS(Set<Id> requestIds) {
        System.debug('requestIds----->'+requestIds);
        // Consolidating the template maps for all notifications
        Map<String, List<SMS_API_Utility.shortMessageWrp>> allMessages = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        List<Staff_Quarters_Request__c> quarterRequests = [Select id,Name ,Status__c ,Type__c,Staff_Quarters_Room__c,Staff_Quarters_Joining_Date__c,
                                                           Staff_Quarters_Room__r.Name,Staff_Quarters_Room__r.Floor__c , Quarter_Request_For__r.Designation__c,
                                                           Quarter_Request_For__r.Department ,Quarter_Request_For__r.Employee_Number__c,
                                                           Reporting_Manager__r.Name,Reporting_Manager__r.MobilePhone,Reporting_Manager__r.Phone,
                                                           Admin_Director__r.Name,Admin_Director__r.MobilePhone,Admin_Director__r.Phone,
                                                           Hostel_Officer__r.MobilePhone,Hostel_Officer__r.Name,Hostel_Officer__r.Phone, Quarter_Request_For__r.Phone,
                                                           HR_Lead__r.MobilePhone ,HR_Lead__r.Name,HR_Lead__r.Phone,Quarter_Request_For__r.Name,Quarter_Request_For__r.MobilePhone,
                                                           Approved_by_ReportingManager__c,Is_HCM_Salary_Deduction_CNF__c,Approved_by_Hostel_Office__c,
                                                           Approved_by_HR_Lead__c,Approved_by_AdminDirector__c
                                                           From Staff_Quarters_Request__c
                                                           WHERE id =: requestIds AND (Status__c = 'Booked' OR Status__c = 'Room Allotted' OR Status__c = 'Approved')
        ];
        System.debug('QuarterRequests----->'+quarterRequests);
        for (Staff_Quarters_Request__c qaReq : quarterRequests) {
            staffName = qaReq.Quarter_Request_For__r.Name;
            houseNo = qaReq.Staff_Quarters_Room__r.Name;
            floorNo = qaReq.Staff_Quarters_Room__r.Floor__c;
            employcode = qaReq.Quarter_Request_For__r.Employee_Number__c;
            joiningDate = string.valueOf(qaReq.Staff_Quarters_Joining_Date__c) ;
            department = qaReq.Quarter_Request_For__r.Department != null ? qaReq.Quarter_Request_For__r.Department : 'NOT AVAILABLE';
            disgnation = qaReq.Quarter_Request_For__r.Designation__c != null ? qaReq.Quarter_Request_For__r.Designation__c : 'NOT AVAILABLE';
            
            reportMngrPhone =  qaReq.Reporting_Manager__r.MobilePhone != null ? qaReq.Reporting_Manager__r.MobilePhone.replace('+', '').replace('-', '') :qaReq.Reporting_Manager__r.Phone == null ? qaReq.Reporting_Manager__r.Phone.replace('+', '').replace('-', '') :'';
            adminDirecPhone =  qaReq.Admin_Director__r.MobilePhone != null ? qaReq.Admin_Director__r.MobilePhone.replace('+', '').replace('-', '') :qaReq.Admin_Director__r.Phone == null ? qaReq.Admin_Director__r.Phone.replace('+', '').replace('-', '') :'';
            hrPhone =  qaReq.HR_Lead__r.MobilePhone != null ? qaReq.HR_Lead__r.MobilePhone.replace('+', '').replace('-', '') :qaReq.HR_Lead__r.Phone == null ? qaReq.HR_Lead__r.Phone.replace('+', '').replace('-', '') :'';
            hostelOfficePhone =  qaReq.Hostel_Officer__r.MobilePhone != null ? qaReq.Hostel_Officer__r.MobilePhone :qaReq.Hostel_Officer__r.Phone == null ? qaReq.Hostel_Officer__r.Phone.replace('+', '').replace('-', '') :'';
            staffMobileNumber = qaReq.Quarter_Request_For__r.MobilePhone !=null ?qaReq.Quarter_Request_For__r.MobilePhone.replace('+', '').replace('-', '') : qaReq.Quarter_Request_For__r.Phone == null ? qaReq.Quarter_Request_For__r.Phone.replace('+', '').replace('-', ''):'';
            
            if (qaReq.Status__c == 'Booked') {
                if(qaReq.Approved_by_ReportingManager__c == false){
                    allMessages.putAll(staffBookingSMS());
                    allMessages.putAll(reportingManBookingSMS());
                    
                } else if(qaReq.Approved_by_ReportingManager__c == true &&  qaReq.Approved_by_AdminDirector__c == false){
                    
                    allMessages.putAll(adminDirecBookingSMS());
                } else if(qaReq.Approved_by_AdminDirector__c == true && qaReq.Approved_by_HR_Lead__c == false) {
                    allMessages.putAll(hrBookingSMS());
                } else if(qaReq.Approved_by_HR_Lead__c == true && qaReq.Approved_by_Hostel_Office__c == false) {
                    allMessages.putAll(hostelOfficeBookingSMS());
                }
                
                
            } else if(qaReq.Status__c == 'Approved' && qaReq.Approved_by_Hostel_Office__c == true && qaReq.Is_HCM_Salary_Deduction_CNF__c == true ){
                allMessages.putAll(hostelOfficeRoomAllotSMS());
                
            } else if (qaReq.Status__c == 'Room Allotted' && qaReq.Is_HCM_Salary_Deduction_CNF__c == true) {
                System.debug('--Status Room Alloted--->');
                allMessages.putAll(staffAllotmentSMS());
                allMessages.putAll(reportManagerAllotmentSMS());
                allMessages.putAll(adminDirecAllotmentSMS());
                allMessages.putAll(hrAllotmentSMS());
                allMessages.putAll(hostelOfficeAllotmentSMS());
            }
        }
        System.debug('--allMessages-->'+allMessages);
        if (!allMessages.isEmpty()) {
            System.enqueueJob(new HstlQuarterBulkNotifiSMS_WtsappQueueable.HostelQuarterSMSBulkNotification(allMessages));
        }
    }
    
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> staffBookingSMS() {
        System.debug('staffName ----'+staffName +'staffNumber---'+staffMobileNumber);
        String message = 'Dear '+staffName+', Your request for Staff Quarters has been received. We will notify you once it is processed. \nRegards, \nREVA University';
        				  //Dear {#var#}, Your request for Staff Quarters has been received. We will notify you once it is processed. Regards, REVA University 
       					 //Dear Rahul, Your request for Staff Quarters has been received. We will notify you once it is processed. Regards, REVA University
        return createMessageMap('Staff_Quarters_ReqNotification_to_Staff',message, staffMobileNumber, '1007468806114250000');
    }
    
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> reportingManBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+reportMngrPhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'New Staff Quarters request received from '+staffName+', please go with the further process. Employee Code: '+employcode+' \nRegards \nREVA University'; 
        messageMap.putAll(createMessageMap('Staff_Quarters_Req_To_RM', message, reportMngrPhone, '1007531861654219042'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> adminDirecBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+adminDirecPhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'New staff quarters request received from '+staffName+', kindly login to the portal to approve for further processing. Employee Code:'+employcode+' \nREVA University';            
        messageMap.putAll(createMessageMap('Staff_Quarters_Req_AdminDire', message, adminDirecPhone, '1007177897150549556'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hrBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+hrPhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'New staff Quarters request received from '+staffName+'. Please review the request. Employee Code:'+employcode+' Department:'+department+' Designation:'+disgnation+' \nREVA University';            
        messageMap.putAll(createMessageMap('Staff_Quarters_req_To_HR', message, hrPhone, '1007574276474539782'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hostelOfficeBookingSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+hostelOfficePhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'The staff Quarters request for '+staffName+' has been approved, please proceed with further process. Employee Code: '+employcode+' \nREVA University';            
        messageMap.putAll(createMessageMap('Staff_Quarters_Req_To_HostelOffice', message, hostelOfficePhone, '1007284293661440709'));
        
        return messageMap;
    }
    
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hostelOfficeRoomAllotSMS() {
        System.debug('staffName -2---'+staffName +'staffNumber-2--'+hostelOfficePhone);
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        String message = 'Please allocate the quarters for the following staff. Name: '+staffName+' Employee Code: '+employcode+' \nREVA University';            
        messageMap.putAll(createMessageMap('Staff_QuartersRoomAllocation_ToHostelOff', message, hostelOfficePhone, '1007680386972514419'));
        
        return messageMap;
    }
    
    
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> staffAllotmentSMS() {
        String message = 'Dear '+staffName+', Your Quarters is allocated as per your request. Floor No:'+floorNo+' House No:'+houseNo+' \nRegards, \nREVA University';
        return createMessageMap('Quarters_Allocation_Staff', message, staffMobileNumber, '1007430938745779093');
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> reportManagerAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'The Quarters were allocated to '+staffName+'. Employee Code: '+employcode+' \nRegards \nREVA University';
        messageMap.putAll(createMessageMap('Staff_Quarters_Allotment_To_RM', message, reportMngrPhone, '1007633175825069602'));
        
        return messageMap;
    }
    
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> adminDirecAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'The Quarters allotted to '+staffName+'. Employee Code: '+employcode+' \nRegards \nREVA University.';
        			     //The Quarters allotted to Rahul. Employee Code: REVA 1234 Regards REVA University.
        messageMap.putAll(createMessageMap('Staff_Quarters_Allot_To_AdminDire', message, adminDirecPhone, '1007301539086327423'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hrAllotmentSMS( ) {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'Staff Quarters is allocated to '+staffName+'. Employee Code: '+employcode+' Designation: '+disgnation+' Department: '+department+' Floor No: '+floorNo+' House No: '+houseNo+' \nREVA University';
        messageMap.putAll(createMessageMap('Staff_Quarters_Allot_ToHR', message, hrPhone, '1007321453805394014'));
        
        return messageMap;
    }
    public static Map<String, List<SMS_API_Utility.shortMessageWrp>> hostelOfficeAllotmentSMS() {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messageMap = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        
        String message = 'Quarters is allotted to '+staffName+'. Employee Code: '+employcode+' \nRegards \nREVA University';
        messageMap.putAll(createMessageMap('Staff_Quarters_Allotted_To_HostelOffice', message, hostelOfficePhone, '1007158202403828353'));
        
        return messageMap;
    }
    
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