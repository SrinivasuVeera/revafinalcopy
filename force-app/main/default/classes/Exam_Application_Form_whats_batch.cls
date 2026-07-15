global class Exam_Application_Form_whats_batch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public List<String> RecordIds { get; set; }
    
    // Constructor to initialize RecordIds
    global Exam_Application_Form_whats_batch(List<String> recordIds) {
        this.RecordIds = recordIds;
    }    
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Rve_Exam_Notification__r.hed_Program_Batch__r.Name,
            Rve_Exam_Notification__r.Rve_Semester__r.Name, Rve_Exam_Notification__r.hed_Program_Batch__c,
            Rve_Exam_Notification__r.Rve_Semester__c, Rve_Exam_Notification__r.Rve_End_Date__c, 
            Rve_Exam_Notification__r.RecordType.Name, 
            Rve_Exam_Notification__r.Rve_Semester__r.IA_2_End_date__c, Rve_Student__r.MobilePhone, Rve_Student__r.Name,
            Rve_Student__r.Email, Rve_Student__c, Student_Name__c
            FROM Rve_Exam_Application__c 
            WHERE Id = :RecordIds AND Rve_Exam_Notification__r.RecordType.Name = 'Semester Notification'
        ]);
    }   
    
    // Execute method to process each batch
    global void execute(Database.BatchableContext bc, List<Rve_Exam_Application__c> notificationList) {
        process(notificationList);
    }
    
    // Method to handle processing logic
    private void process(List<Rve_Exam_Application__c> notificationList) {
        try {
            List<Messaging.SingleEmailMessage> sendAbsentNotifications = new List<Messaging.SingleEmailMessage>();
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            String studentTemplateId = 'exam_form_live_student';
            String siteURL = 'https://reva-university--codev1.sandbox.my.site.com/StudentPortal';
            
            // Iterate through the records and gather data
            for (Rve_Exam_Application__c request : notificationList) {
                Date newEndDate = request.Rve_Exam_Notification__r.Rve_End_Date__c;
                String semester = request.Rve_Exam_Notification__r.Rve_Semester__r.Name;
                String lastdate = parseDate(newEndDate);
                
                // WhatsApp notification preparation
                Yellow_AI_Utility.WhatsAppNotification studentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                studentNotification.templateId = studentTemplateId;
                studentNotification.params = new Map<String, String>{
                    'StudentName' => request.Student_Name__c,
                    'Semester' => semester,
                    'LastDate' => lastdate
                };
                
                if (!phoneNumbersToNotifications.containsKey(request.Rve_Student__r.MobilePhone)) {
                    phoneNumbersToNotifications.put(request.Rve_Student__r.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                }
                phoneNumbersToNotifications.get(request.Rve_Student__r.MobilePhone).add(studentNotification);
                
                // Email notification preparation
                if (request.Rve_Student__r.Email != null) {
                    String subject = 'Semester End Exam Application Form is LIVE for the ' + semester;
                    String body = EmailTemplatesForReva.ExamApplicationFormEmailNotificationToStudnets(request.Student_Name__c, semester, lastdate);
                    //body += '<p>Student Portal Link: <a href="' + siteURL + '">' + siteURL + '</a></p>';
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject(subject);
                    email.setHtmlBody(body);
                    email.setToAddresses(new String[]{request.Rve_Student__r.Email});
                    sendAbsentNotifications.add(email);
                    System.debug('Email Body: ' + body);
                }
                
                // SMS notification preparation
                String phoneNumber = request.Rve_Student__r.MobilePhone;
                String message = 'Dear ' + request.Rve_Student__r.Name + ', The Semester End Exam Application form is LIVE for ' + semester + '. Please login to your student portal to fill the form and pay the examination fee before ' + lastdate + '. REVA University';
                if (phoneNumber != null && message != null) {
                    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                    shrtMessage.dltContentId = '1007257749176895635';
                    shrtMessage.message = message;
                    shrtMessage.recipient = phoneNumber;
                    messageList.add(shrtMessage);
                }
            }
            // Serialize the message list to JSON
            String messageListJson = JSON.serialize(messageList);
            // Send WhatsApp notifications in bulk
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp Response: ' + response);
            system.debug('whatsup respose body '+response.getbody());
            
            // Send email notifications in bulk
            if (!sendAbsentNotifications.isEmpty()) {
                Messaging.sendEmail(sendAbsentNotifications);
            }
            
            // Send SMS notifications in bulk
            System.debug('SMS Message List: ' + messageList);
            if (!messageList.isEmpty()) {
                SMSQueueable smsJob = new SMSQueueable('Exam Application Form', messageListJson);
                System.enqueueJob(smsJob);
                // SMS_API_Utility.SendSMSOneToMany('Exam Application Form', messageList);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }
        
    }
    
    public static String parseDate(Date dateneedstobeconvert) {
        String formattedDate = String.valueOf(dateneedstobeconvert.format());
        System.debug('Formatted Date: ' + formattedDate);
        return formattedDate;
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // Execute any post-processing operations
    }
}
    


/*global class Exam_Application_Form_whats_batch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public List<String> RecordIds { get; set; }
    
    // Constructor to initialize RecordIds
    global Exam_Application_Form_whats_batch(List<String> recordIds) {
        this.RecordIds = recordIds;
    }    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Rve_Exam_Notification__r.hed_Program_Batch__r.Name,
            Rve_Exam_Notification__r.Rve_Semester__r.Name, Rve_Exam_Notification__r.hed_Program_Batch__c,
            Rve_Exam_Notification__r.Rve_Semester__c, Rve_Exam_Notification__r.Rve_End_Date__c, 
            Rve_Exam_Notification__r.RecordType.Name, 
            Rve_Exam_Notification__r.Rve_Semester__r.IA_2_End_date__c, Rve_Student__r.MobilePhone, Rve_Student__r.Name,
            Rve_Student__r.Email, Rve_Student__c, Student_Name__c
            FROM Rve_Exam_Application__c 
            WHERE Id = :RecordIds AND Rve_Exam_Notification__r.RecordType.Name = 'Semester Notification'
        ]);
    }   
    
    global void execute(Database.BatchableContext bc, List<Rve_Exam_Application__c> notificationList) {
        try {
            List<Messaging.SingleEmailMessage> sendAbsentNotifications = new List<Messaging.SingleEmailMessage>();
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            String studentTemplateId = 'exam_form_live_student';
            String siteURL = 'https://reva-university--codev1.sandbox.my.site.com/StudentPortal';
            
            // Iterate through the records and gather data
            for (Rve_Exam_Application__c request : notificationList) {
                Date newEndDate = request.Rve_Exam_Notification__r.Rve_End_Date__c;
                String semester = request.Rve_Exam_Notification__r.Rve_Semester__r.Name;
                String lastdate = parseDate(newEndDate);
                
                // WhatsApp notification preparation
                Yellow_AI_Utility.WhatsAppNotification studentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                studentNotification.templateId = studentTemplateId;
                studentNotification.params = new Map<String, String>{
                    'StudentName' => request.Student_Name__c,
                        'Semester' => semester,
                        'LastDate' => lastdate
                        };
                            
                            if (!phoneNumbersToNotifications.containsKey(request.Rve_Student__r.MobilePhone)) {
                                phoneNumbersToNotifications.put(request.Rve_Student__r.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                            }
                phoneNumbersToNotifications.get(request.Rve_Student__r.MobilePhone).add(studentNotification);
                
                // Email notification preparation
                if (request.Rve_Student__r.Email != null) {
                    String subject = 'Semester End Exam Application Form is LIVE for the ' + semester;
                    String body = EmailTemplatesForReva.ExamApplicationFormEmailNotificationToStudnets(request.Student_Name__c, semester, lastdate);
                    //body += '<p>Student Portal Link: <a href="' + siteURL + '">' + siteURL + '</a></p>';
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject(subject);
                    email.setHtmlBody(body);
                    email.setToAddresses(new String[]{request.Rve_Student__r.Email});
                    sendAbsentNotifications.add(email);
                    System.debug('Email Body: ' + body);
                }
                
                // SMS notification preparation
                String phoneNumber = request.Rve_Student__r.MobilePhone;
                String message = 'Dear ' + request.Rve_Student__r.Name + ', The Semester End Exam Application form is LIVE for ' + semester + '. Please login to your student portal to fill the form and pay the examination fee before ' + lastdate + '. REVA University';
                if (phoneNumber != null && message != null) {
                    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                    shrtMessage.dltContentId = '1007257749176895635';
                    shrtMessage.message = message;
                    shrtMessage.recipient = phoneNumber;
                    messageList.add(shrtMessage);
                }
            }
            // Serialize the message list to JSON
            String messageListJson = JSON.serialize(messageList);
            // Send WhatsApp notifications in bulk
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp Response: ' + response);
            
            // Send email notifications in bulk
            if (!sendAbsentNotifications.isEmpty()) {
                Messaging.sendEmail(sendAbsentNotifications);
            }
            
            // Send SMS notifications in bulk
            System.debug('SMS Message List: ' + messageList);
            if (!messageList.isEmpty()) {
                SMSQueueable smsJob = new SMSQueueable('Exam Application Form', messageListJson);
                System.enqueueJob(smsJob);
                // SMS_API_Utility.SendSMSOneToMany('Exam Application Form', messageList);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
        }
        
    }
    
    public static String parseDate(Date dateneedstobeconvert) {
        String formattedDate = String.valueOf(dateneedstobeconvert.format());
        System.debug('Formatted Date: ' + formattedDate);
        return formattedDate;
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // Execute any post-processing operations
    }
    
}*/