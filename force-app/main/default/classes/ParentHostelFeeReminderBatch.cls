public class ParentHostelFeeReminderBatch implements Database.Batchable<SObject>,  Database.AllowsCallouts {
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
         system.debug('query:'+ [SELECT Id, Name,Fee_for_Notifications__c, Contact__c,Contact__r.Name, Contact__r.MobilePhone, Contact__r.Email,Due_Date__c,Amount__c,Amount_Paid__c,Amount_Pending__c,No_of_Days_Due__c, Hostel_Due_Date__c FROM Student_fee__c WHERE Amount_Pending__c > 0 AND Number_of_days_due__c >= -15 AND Fee_type__c =: FeeType]);
        String query = 'SELECT Id, Name,Fee_for_Notifications__c, Contact__c,Contact__r.Name, Contact__r.MobilePhone, Contact__r.Email,Contact__r.Father_Email_ID__c,Contact__r.Mother_Email_ID__c,Contact__r.Father_Mobile_Number__c,Contact__r.Mother_Mobile_Number__c, Due_Date__c,Amount__c,Amount_Paid__c,Amount_Pending__c,No_of_Days_Due__c,Number_of_days_due__c, Hostel_Due_Date__c FROM Student_fee__c WHERE Amount_Pending__c > 0 AND Number_of_days_due__c >= -15 AND Fee_type__c =: FeeType AND Hostel_Due_Date__c != NULL AND Number_of_days_due__c < 150';
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
        system.debug('Parentscope:'+scope.Size());
        Date today = Date.today();
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
        
        
        for (Student_fee__c fee : (List<Student_fee__c>)scope) {
          Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            Decimal daysPassed = fee.Number_of_days_due__c;
            system.debug('daysPassed:'+daysPassed);
            
            String selectedTemplateApiName;
            if (daysPassed >= -15 && daysPassed <= 0) {
                notification.templateId = 'hostel_fee_reminder_parent';  
                ReminderStudent = true;
            } else if (daysPassed >= 1 && daysPassed <= 60) {
                notification.templateId = 'hostel_fee_due_parent';
                FeeStudent = true;
                system.debug('FeeStudent:'+FeeStudent);
            } else if (daysPassed > 60) {
                notification.templateId= 'hostel_meal_blocked_parent';
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
                    if (metadata.Template_ID__c == 'hostel_fee_reminder_parent') {
                        if (key.trim() == 'due_date') {
                            notification.params.put(key.trim(), String.valueOf(fee.Due_Date__c));
                        }else if (key.trim() == 'remaining_amount') {
                            notification.params.put(key.trim(), String.valueOf(fee.Amount_Pending__c));
                        }
                    }else if (metadata.Template_ID__c == 'hostel_fee_due_parent') {
                        if (key.trim() == 'due_date') {
                            notification.params.put(key.trim(), String.valueOf(fee.Due_Date__c));
                        } else if (key.trim() == 'remaining_amount') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Amount_Pending__c));
                        }else if (key.trim() == 'penalty_fee') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Fee_for_Notifications__c));
                        }
                    }
                    else if (metadata.Template_ID__c == 'hostel_meal_blocked_parent') {
                        if (key.trim() == 'pending_amount') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Amount_Pending__c));
                        }else if (key.trim() == 'fine_amount') {
                            notification.params.put(key.trim(),  String.valueOf(fee.Fee_for_Notifications__c));
                        }
                    }
                }
            }   
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                
                // Now add to father’s WhatsApp
                if (String.isNotBlank(fee.Contact__r.Father_Mobile_Number__c)) {
                    String fatherNumber = fee.Contact__r.Father_Mobile_Number__c.replace('+', '').replace('-', '');
                    if (!phoneNumbersToNotifications.containsKey(fatherNumber)) {
                        phoneNumbersToNotifications.put(fatherNumber, new List<Yellow_AI_Utility.WhatsAppNotification>());
                    }
                    phoneNumbersToNotifications.get(fatherNumber).add(notification);
                }
            
            // Add to mother’s WhatsApp
            if (String.isNotBlank(fee.Contact__r.Mother_Mobile_Number__c)) {
                String motherNumber = fee.Contact__r.Mother_Mobile_Number__c.replace('+', '').replace('-', '');
                if (!phoneNumbersToNotifications.containsKey(motherNumber)) {
                    phoneNumbersToNotifications.put(motherNumber, new List<Yellow_AI_Utility.WhatsAppNotification>());
                }
                phoneNumbersToNotifications.get(motherNumber).add(notification);
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
                
                body = '<p>Dear Parent,</p>'
                    + '<p>Greetings from REVA University!</p>'
                    + '<p>This is a gentle reminder that your fees for the Hostel academic year (2025-2026) are due. '
                    + 'We kindly request that you settle the outstanding amount at the earliest to avoid any penalties.</p>'
                    
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
                    + '</table>'
                    
                    + '<p>Please note that a late payment penalty will be applicable as per the University\'s fee policy. '
                    + 'You can pay your fees easily via SLCM (Student portal).</p>'
                    
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
   
                body = '<p>Dear Parent,</p>'
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
                    + 'You can pay your fees easily via the SLCM portal.</p>'
                    
                    + '<p><a href="https://reva-university.my.site.com/StudentPortal/s/" target="_blank">Click here to make the payment</a></p>'
                    
                    + '<p><strong>Important:</strong> Please ensure all payments are made exclusively through the SLCM portal. '
                    + 'If you have already made the payment, please ignore this message.</p>'
                    
                    + '<p>Thank you for your immediate attention.</p>'
                    + '<p>Warm regards,<br/>Hostel Office<br/>REVA University</p>';
                
            }
            if(BlockedStudent){
                
                subject = 'Hostel Fee Pending – Meal Booking Disabled for Your Ward';
                
                body = '<p>Dear Sir/Madam,</p>'
                    + '<p>Your ward’s hostel fee has not been paid for more than 120 days.'
                    + 'Due to this prolonged delay, meal booking access has been blocked until the fee is cleared.</p>'
                    
                    + '<p>Please arrange payment of the outstanding amount to restore full access to hostel services.</p>'
                    
                    + '<p><strong>Pending Amount:</strong> ' + pending + '<br/>'
                    + '<strong>Fine:</strong> ' + ppending + '</p>'
                    
                    + '<p>For further support, please contact the Hostel Office.</p>'
                    
                    + '<p>Best regards,<br/>REVA University</p>';
                
            }
            List<OrgWideEmailAddress> orgWideEmailAddresses = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
            OrgWideEmailAddress orgWideEmail = new OrgWideEmailAddress();
            // Check if the Org-Wide Email Address exists
            if (!orgWideEmailAddresses.isEmpty()) {
                orgWideEmail = orgWideEmailAddresses[0];
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            
            if (String.isNotBlank(fee.Contact__r.Father_Email_ID__c)) {
                toAddresses.add(fee.Contact__r.Father_Email_ID__c);
            }
            if (String.isNotBlank(fee.Contact__r.Mother_Email_ID__c)) {
                toAddresses.add(fee.Contact__r.Mother_Email_ID__c);
            }
            
            if (!toAddresses.isEmpty()) {
                email.setToAddresses(toAddresses);
                email.setSubject(subject);
                email.setHtmlBody(body);
                email.setSaveAsActivity(false);
                email.setOrgWideEmailAddressId(orgWideEmail.Id);
                emailList.add(email);
}            
        }
        
    
        if (!phoneNumbersToNotifications.isEmpty()) {
             system.debug('phoneNumbersToNotifications:'+phoneNumbersToNotifications);
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            system.debug('response'+response);
        }
        
        if (!emailList.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                System.debug('FeeStudent: ' + results);

        }
         
     
    }
    Public void finish(Database.BatchableContext BC) {
        System.debug('Finish Method');
    }
}