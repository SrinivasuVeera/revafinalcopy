global class Results_notifiy_to_SandP_whats_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public String RecordIds { get; set; }
    public static hed__Term_Grade__c Result {get; set;} 
    
    // Constructor to initialize RecordIds
    global Results_notifiy_to_SandP_whats_batch(String recordIds) {
        this.RecordIds = recordIds;
        Result = [Select Id,name,hed__Contact__c,hed__Contact__r.Name,hed__Contact__r.MobilePhone,hed__Contact__r.Father_Name__c,
                  hed__Contact__r.Father_Email_ID__c, hed__Contact__r.Mother_Email_ID__c, hed__Contact__r.Guardian__r.Email,  
                  hed__Term__r.Name,hed__Contact__r.Father_Mobile_Number__c,hed__Contact__r.Mother_Mobile_Number__c,hed__Contact__r.Mother_Name__c
                  ,hed__Contact__r.Guardian__r.name,hed__Contact__r.Guardian__r.MobilePhone
                  from hed__Term_Grade__c where hed__Course_Offering__c = null AND  Id = :RecordIds ];
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name,MobilePhone,Father_Mobile_Number__c,Email,
            Father_Name__c,Mother_Mobile_Number__c, Mother_Name__c,Guardian__r.Email,Mother_Email_ID__c,Father_Email_ID__c,
            Guardian__r.MobilePhone,Guardian__r.Name FROM Contact WHERE
            Active_Semester__c = :result.hed__Term__c 
            AND MobilePhone != null AND Active__c = true AND Id = :result.hed__Contact__c
            AND  (
                (Father_Mobile_Number__c != null AND Father_Name__c != null) 
                OR (Mother_Mobile_Number__c != null AND Mother_Name__c != null) 
                OR (Guardian__r.MobilePhone != null AND Guardian__r.Name != null)
            )
        ]);
    }
    
    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<Contact> contactList) {
        try {
            // Lists to store data for notifications
            Integer batchSize = 24;
            Integer batchcount = 0;
            Integer totalRecords = contactList.size();
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
            
            System.debug('totalRecords=> '+totalRecords);
            
            // Loop through the ContactList in chunks of batchSize
            for (Integer i = 0; i < totalRecords; i += batchSize) {
                // Reset chunk list for the current iteration
                List<Contact> chunk = new List<Contact>();
                batchcount++;
                // Collect records for the current chunk
                for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                    chunk.add(ContactList[j]);
                    System.debug('ChunkSize=> '+chunk.size());
                }
                processChunk(chunk,owea);
                
            }
        }
        catch(Exception e)
        {
            System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
        }
    }
    
    public static void processChunk(List<Contact>ContactList, OrgWideEmailAddress owea){
        
        try{
            List<String> semester = new List<String>();
            
            // Iterate through the records and gather data
            semester.add(result.hed__Term__r.name);
            
            // Fetching template details
            String studentTemplateId = 'result_notification_student';
            String parentTemplateId = 'results_published_parents';
            
            
            // Iterate through contacts to create notifications for students
            for (Contact clist : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = studentTemplateId;
                notification.params = new Map<String, String>();
                
                // Set dynamic values for each key based on related record
                // notification.params.put('name', con.Name);
                notification.params.put('StudentName',clist.Name );
                notification.params.put('Semester', String.join(semester, ','));
                
                // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                
                
                // Add notification to map
                phoneNumbersToNotifications.put(clist.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }
            
            // Iterate through contacts to create notifications for parents
            for (Contact student : contactList) {
                // Determine which parent's contact to use
                String parentContactNumber = '';
                String parentName = '';
                
                if (student.Father_Mobile_Number__c != null) {
                    parentContactNumber = student.Father_Mobile_Number__c;
                    parentName =student.Father_Name__c;
                } else if (student.Mother_Mobile_Number__c != null) {
                    parentContactNumber = student.Mother_Mobile_Number__c;
                    parentName = student.Mother_Name__c;
                } else if (student.Guardian__r.MobilePhone != null) {
                    parentContactNumber = student.Guardian__r.MobilePhone;
                    parentName = student.Guardian__r.Name;
                }
                
                // Create notifications for parent(s)
                if (parentContactNumber != '') {
                    Yellow_AI_Utility.WhatsAppNotification parentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                    parentNotification.templateId = parentTemplateId;
                    parentNotification.params = new Map<String, String>();
                    parentNotification.params.put('parentname', parentName);
                    parentNotification.params.put('studentname', student.Name);
                    parentNotification.params.put('semestername', String.join(semester, ','));
                    //parentNotification.params.put('examname', String.join(examname, ','));
                    //parentNotification.params.put('StartDate', String.join(startdate, ','));
                    // parentNotification.params.put('EndDate', String.join(lastdate, ','));                
                    // Map to store notifications for each contact's phone number
                    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                    
                    
                    // Add notification to map
                    phoneNumbersToNotifications.put(parentContactNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{parentNotification});
                    
                    //Send Whatsapp notifications
                    HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                    System.debug('Response=> '+response);
                }
            }
            
            /////////////////////////////////// SMS Notification ///////////////////////////////
            
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            List<SMS_API_Utility.shortMessageWrp> messageList1 = new List<SMS_API_Utility.shortMessageWrp>();
            
            //if (!resList.isEmpty()) {
            //  for (hed__Term_Grade__c Result : resList) {
            String phoneNumber = Result.hed__Contact__r.MobilePhone; 
            System.debug('phoneNumber=> ' + phoneNumber);          
            
            String message = 'Dear ' + Result.hed__Contact__r.Name + ', Please be informed that the results of ' + Result.hed__Term__r.Name + ' has been published. Please login to your student portal for more details. REVA University';
            
            if (phoneNumber != null && message != null) {
                SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                shrtMessage1.dltContentId = '1007105396194257106';
                shrtMessage1.message = message;
                shrtMessage1.recipient = phoneNumber;
                messageList.add(shrtMessage1);
            }
            
            String parentPhoneNumber = Result.hed__Contact__r.Father_Mobile_Number__c != null ? 
                Result.hed__Contact__r.Father_Mobile_Number__c : 
            (Result.hed__Contact__r.Mother_Mobile_Number__c != null ? 
             Result.hed__Contact__r.Mother_Mobile_Number__c : 
             Result.hed__Contact__r.Guardian__r.MobilePhone);
                 
                 String parentName = Result.hed__Contact__r.Father_Mobile_Number__c != null ? 
                 Result.hed__Contact__r.Father_Name__c : 
            (Result.hed__Contact__r.Mother_Mobile_Number__c != null ? 
             Result.hed__Contact__r.Mother_Name__c : 
             Result.hed__Contact__r.Guardian__r.Name);
                 
                 if (parentPhoneNumber != null) {
                     System.debug('Parent/Guardian phoneNumber=> ' + parentPhoneNumber);
                     
                     String message1 = 'Dear Mr./Ms. ' + parentName + ', Please be informed that the results of ' + Result.hed__Term__r.Name + ' for your ward ' + Result.hed__Contact__r.Name + ' has been published. Please take some time to review the results. REVA University';
                     
                     SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                     shrtMessage1.dltContentId = '1007514598864465744';
                     shrtMessage1.message = message1;
                     shrtMessage1.recipient = parentPhoneNumber;
                     messageList1.add(shrtMessage1);
                 }
            //}
            //}
            
            if (messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Result', messageList);
            }
            
            if (messageList1.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Result Published Notification to Parents', messageList1);
            }
            
            //create the email list 
            List<Messaging.SingleEmailMessage> emaillist = new List<Messaging.SingleEmailMessage>();
            
            //create email notification
            for (Contact email1 : contactList) {
                //email body  
                String subject = 'Results published for ' + semester[0];
                String body = EmailTemplatesForReva.results21(email1.Name, semester[0] );
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{email1.Email});
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                emaillist.add(email);
            }
        
            Messaging.sendEmail(emaillist);
            
            /////////////////////////////send email to parent///////////////////////
            
            //create the email list 
            List<Messaging.SingleEmailMessage> parentemaillist = new List<Messaging.SingleEmailMessage>();
            
            //create email notification
            for (Contact email1 : contactList) {
                
                // Determine which parent's contact to use
                String parentemail = '';
                String parentEmailName = '';
                
                
                if (email1.Father_Email_ID__c != null) {
                    parentemail = email1.Father_Email_ID__c;
                    parentEmailName =email1.Father_Name__c;
                } else if (email1.Mother_Email_ID__c != null) {
                    parentemail = email1.Mother_Email_ID__c;
                    parentEmailName = email1.Mother_Name__c;
                } else if (email1.Guardian__r.Email != null) {
                    parentemail = email1.Guardian__r.Email;
                    parentEmailName = email1.Guardian__r.Name;
                }
                
                //email body  
                String subject = 'Results published for ' + semester[0]+ ' for your ward.';
                String body = EmailTemplatesForReva.results22(email1.Name, semester[0], parentEmailName);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{parentemail});
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                parentemaillist.add(email);
            }
            
            Messaging.sendEmail(parentemaillist);
            
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {	
        // execute any post-processing operations
    }
}