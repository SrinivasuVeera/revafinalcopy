public class StudentHostelFeeReminderBatch  implements Database.Batchable<SObject>,  Database.AllowsCallouts {
    Public Boolean ReminderStudent = false;
    Public Boolean FeeStudent = false;
    Public Boolean BlockedStudent = false;
    Public String subject ;
    Public String body;
    Public String Name;
    Public String total;
    Public String paid;
    Public String pending;
    Public String dueDate;
    Public String pName;
    Public String ptotal;
    Public String ppaid;
    Public String ppending;
    Public String pdueDate;
 
    Public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Start Method');
        String FeeType = 'Hostel Fee';
        String query = 'SELECT Id, Name,Fee_for_Notifications__c, Contact__c,Contact__r.Name, Contact__r.MobilePhone, Contact__r.Email,Due_Date__c,Amount__c,Amount_Paid__c,Amount_Pending__c,No_of_Days_Due__c,Number_of_days_due__c, Hostel_Due_Date__c FROM Student_fee__c WHERE Amount_Pending__c > 0 AND Number_of_days_due__c >= -15 AND Fee_type__c =: FeeType AND Hostel_Due_Date__c != Null AND Number_of_days_due__c < 150';  
        return Database.getQueryLocator(query);
    }
    Public void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug('Execute Method');
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
       // Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
       // List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Set<Id> studentFeeIds = new Set<Id>();
        Map<Id, Student_fee__c> feeMap = new Map<Id, Student_fee__c>();
        Map<Id, List<Student_Fee__c>> feeIdToPenaltyMap = new Map<Id, List<Student_Fee__c>>();
        system.debug('Studentscope:'+scope.Size());
        for (Student_fee__c fee : (List<Student_fee__c>)scope) {
            studentFeeIds.add(fee.Id);
            feeMap.put(fee.Id, fee);
        }
        // Query child Penalty_Fee__c records (replace with actual child relationship name)
        system.debug('studentFeeIds:'+studentFeeIds);
        for (Student_Fee__c penalty : [
            SELECT Id, Name, Fee_Name__c, Due_Date__c, Amount__c, Amount_Paid__c, Amount_Pending__c,Student_Hostel_Fee__c
            FROM Student_Fee__c
            WHERE Student_Hostel_Fee__c IN :studentFeeIds
        ]) {
            if (!feeIdToPenaltyMap.containsKey(penalty.Student_Hostel_Fee__c)) {
                feeIdToPenaltyMap.put(penalty.Student_Hostel_Fee__c, new List<Student_Fee__c>());
            }
            feeIdToPenaltyMap.get(penalty.Student_Hostel_Fee__c).add(penalty);
            system.debug('feeIdToPenaltyMap:'+feeIdToPenaltyMap);
        }   
        
        Date today = Date.today();
        
        
        for (Student_fee__c fee : (List<Student_fee__c>)scope) {
              try {
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            Decimal daysPassed = fee.Number_of_days_due__c;
            system.debug('daysPassed:'+daysPassed);
            
            String selectedTemplateApiName;
            if (daysPassed >= -15 && daysPassed <= 0) {
                notification.templateId = 'hostel_fee_reminder_student';  
                ReminderStudent = true;
            } else if (daysPassed >= 1 && daysPassed <= 60) {
                notification.templateId = 'hostel_fee_due_student';
                FeeStudent = true;
                system.debug('FeeStudent:'+FeeStudent);
            } else if (daysPassed > 60) {
                notification.templateId= 'hostel_meal_blocked_student';
                BlockedStudent=True;
            }
            
            
            //notification.templateId = selectedTemplateApiName;
            notification.params = new Map<String, String>();
            
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :notification.templateId
            ];
            system.debug('templateMetadata:'+templateMetadata.size());
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                
                for (String key : keys) {
                    if (metadata.Template_ID__c == 'hostel_fee_reminder_student') {
                        if (key.trim() == 'student_name') {
                            notification.params.put(key.trim(), fee.Contact__r.Name);
                        } else if (key.trim() == 'due_date') {
                            notification.params.put(key.trim(), String.valueOf(fee.Due_Date__c));
                        } else if (key.trim() == 'remaining_amount') {
                            notification.params.put(key.trim(), String.valueOf(fee.Amount_Pending__c));
                        }
                    }else if (metadata.Template_ID__c == 'hostel_fee_due_student') {
                        if (key.trim() == 'student_name') {
                            notification.params.put(key.trim(), fee.Contact__r.Name);
                        } else if (key.trim() == 'due_date') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Due_Date__c));
                        }else if (key.trim() == 'remaining_amount') {
                            notification.params.put(key.trim(), String.valueOf(fee.Amount_Pending__c));
                        }else if (key.trim() == 'penalty_amount') {
                            notification.params.put(key.trim(), String.valueOf(fee.Fee_for_Notifications__c));
                        }
                    }
                    else if (metadata.Template_ID__c == 'hostel_meal_blocked_student') {
                        if (key.trim() == 'student_name') {
                            notification.params.put(key.trim(), String.valueOf(fee.Contact__r.Name));
                        } else if (key.trim() == 'remaining_amount') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Amount_Pending__c));
                        }else if (key.trim() == 'penalty_amount') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Fee_for_Notifications__c));
                        }
                    }
                }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
            if (fee.contact__r.MobilePhone!= null) {
                String plusRemoved = fee.contact__r.MobilePhone.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                
                if (!phoneNumbersToNotifications.containsKey(correctedWhatsappNumber)) {
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                }
            }
            
            //Mail Notification 
            
            // Format amount values
             Name = fee.Name;
             total = '₹' + String.valueOf(fee.Amount__c.setScale(0));
             paid = '₹' + String.valueOf(fee.Amount_Paid__c.setScale(0));
             pending = '₹' + String.valueOf(fee.Amount_Pending__c.setScale(0));
             dueDate = (fee.Hostel_Due_Date__c != null) ? String.valueOf(fee.Hostel_Due_Date__c.format()) : 'N/A';
            
              system.debug('feeIdToPenaltyMap:'+ feeIdToPenaltyMap);
            if (feeIdToPenaltyMap.containsKey(fee.Id)) {
                 for (Student_Fee__c penalty : feeIdToPenaltyMap.get(fee.Id)) {
                 pName = penalty.Name;
                 pdueDate = penalty.Due_Date__c != null ? String.valueOf(penalty.Due_Date__c.format()) : 'N/A';
                 pTotal = '₹' + String.valueOf(penalty.Amount__c.setScale(0));
                 pPaid = '₹' + String.valueOf(penalty.Amount_Paid__c.setScale(0));
                 pPending = '₹' + String.valueOf(penalty.Amount_Pending__c.setScale(0));
                 }
            }
            
            if (ReminderStudent) {  
                
                subject = 'REVA University - Outstanding Fee Payment Reminder';
                
                body = '<p>Dear ' + fee.Contact__r.Name + ',</p>'
                    + '<p>Greetings from REVA University!</p>'
                    + '<p>This is a gentle reminder that your fees for the Hostel academic year (2025-2026) are due. '
                    + 'We kindly request that you settle the outstanding amount at the earliest to avoid any penalties.</p>'
                    
                    + '<p><strong>Please find the details of your dues below:</strong></p>'
                    
                    + '<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse;">'
                    + '<tr><th>Fee Name</th><th>Due Date</th><th>Total Amount</th><th>Amount Paid</th><th>Amount Pending</th></tr>'
                    + '<tr>'
                    + '<td>Hostel Fee</td>'
                    + '<td>' + dueDate + '</td>'
                    + '<td>' + total + '</td>'
                    + '<td>' + paid + '</td>'
                    + '<td>' + pending + '</td>'
                    + '</tr>'
                    + '</table>'
                    
                    + '<p>Please note that a late payment penalty will be applicable as per the University\'s fee policy. '
                    + 'You can pay your fees easily via the Student Life Cycle Management (SLCM) portal.</p>'
                    
                    + '<p><a href="https://reva-university.my.site.com/StudentPortal/s/" target="_blank">Click here to make the payment</a></p>'
                    
                    + '<p><strong>Important:</strong> Please ensure all payments are made exclusively through the SLCM portal.</p>'
                    
                    + '<p>If you have already made the payment, please ignore this message.</p>'
                    
                    + '<p>Thank you for your immediate attention.</p>'
                    
                    + '<p>Warm regards,<br/>'
                    + 'Hostel Office<br/>'
                    + 'REVA University</p>';
                
                
            }
            if(FeeStudent){
                subject = 'REVA University - Outstanding Fee Payment Reminder';
                
                
                body = '<p>Dear ' + fee.Contact__r.Name + ',</p>'
                    + '<p>Greetings from REVA University!</p>'
                    + '<p>Just a gentle reminder — the deadline to pay your hostel fees for the 2025–2026 academic year has already passed. '
                    + 'Please clear it at the earliest.</p>'
                    
                    + '<p><strong>Please find the details of your dues below:</strong></p>'
                    
                    + '<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse;">'
                    + '<tr><th>Fee Name</th><th>Due Date</th><th>Total Amount</th><th>Amount Paid</th><th>Amount Pending</th></tr>'
                    + '<tr>'
                   + '<td>' + Name + '</td>'
                    + '<td>' + dueDate + '</td>'
                    + '<td>' + total + '</td>'
                    + '<td>' + paid + '</td>'
                    + '<td>' + pending + '</td>'
                    + '</tr>'
                    
                    + '<tr>'
                    + '<td>' + pName + '</td>'
                    + '<td>' + pdueDate + '</td>'
                    + '<td>' + ptotal + '</td>'
                    + '<td>' + ppaid + '</td>'
                    + '<td>' + ppending + '</td>'
                    + '</tr>'
                    
                    + '</table>'
                    
                    + '<p>Please note that a late payment penalty will be applicable as per the University\'s fee policy. '
                    + 'You can pay your fees easily via the Student Life Cycle Management (SLCM) portal.</p>'
                    
                    + '<p><a href="https://reva-university.my.site.com/StudentPortal/s/" target="_blank">Click here to make the payment</a></p>'
                    
                    + '<p><strong>Important:</strong> Please ensure all payments are made exclusively through the SLCM portal. '
                    + 'If you have already made the payment, please ignore this message.</p>'
                    
                    + '<p>Thank you for your immediate attention.</p>'
                    + '<p>Warm regards,<br/>Hostel Office<br/>REVA University</p>';
                
            }
            if(BlockedStudent){
                subject = 'Meal Booking Disabled';
                body = '<p>Dear ' + fee.Contact__r.Name + ',</p>'
                    + '<p>Our records indicate that your hostel fee remains unpaid for over 120 days. '
                    + 'As per the hostel fee policy, your meal booking access has been disabled.</p>'
                    
                    + '<p>To resume meal services and avoid any further inconvenience, please settle the outstanding dues immediately.</p>'
                    
                    + '<p><strong>Pending Amount:</strong> ' + pending + '<br/>'
                    + '<strong>Fine:</strong> ' + ppending + '</p>'
                    
                    + '<p>If you require assistance, feel free to contact the Hostel Office.</p>'
                    
                    + '<p>Regards,<br/>REVA University</p>';
                
            }
            List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
            OrgWideEmailAddress orgWideEmail = new OrgWideEmailAddress();
            // Check if the Org-Wide Email Address exists
            if (!orgWideEmailAddresses.isEmpty()) {
                orgWideEmail = orgWideEmailAddresses[0];
            }
            
            if (String.isNotBlank(fee.Contact__r.Email)) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { fee.Contact__r.Email });
            email.setSubject(subject);
            email.setHtmlBody(body);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(orgWideEmail.Id);
            emailList.add(email);
            system.debug('FeeStudent:'+emailList);
            }
              }
             catch (Exception e) {
                System.debug('⚠️ Error processing record: ' + fee.Id + ' - ' + e.getMessage());
             }
        }
        if (!phoneNumbersToNotifications.isEmpty()) {
           
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            system.debug('response'+response);
        }
        
        if (!emailList.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            System.debug('FeeStudent: ' + results);
            
        }
        if(!studentFeeIds.isEmpty()){ 
       //  StudentHostelFeeRemainderSMS.MainMethod(studentFeeIds);
           System.enqueueJob(new StudentHostelFeeRemainderSMSQueueable(studentFeeIds));
            system.debug('studentFeeIds:'+studentFeeIds);
        }
    }
    Public void finish(Database.BatchableContext BC) {
        System.debug('Finish Method');
    }
    
    /* public void execute(SchedulableContext SC) {
Database.executeBatch(new HostelFeeReminderBatch(), 200);
}*/
    
}