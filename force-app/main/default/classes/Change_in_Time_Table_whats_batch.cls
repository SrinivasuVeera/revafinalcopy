global class Change_in_Time_Table_whats_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public String RecordIds { get; set; }
    public static Rve_Exam_Notification__c ExamNotification {get;set;} 
    public static List<hed_Time_Table_Line_Item__c>lineItems {get;set;}
    
    // Constructor to initialize RecordIds
    global Change_in_Time_Table_whats_batch(String recordIds) {
        lineitems = new List<hed_Time_Table_Line_Item__c>();
        this.RecordIds = recordIds;
        ExamNotification = [select id, name, hed_Program_Batch__r.Name, Rve_Semester__r.Name, 
                                 hed_Program_Batch__c, Rve_Semester__c, rve_Exam_Start_Date__c, 
                                 RecordType.Name, hed_IA_Type__c, Rve_End_Date__c from Rve_Exam_Notification__c 
                                 where Id = :RecordIds];

         lineItems = [SELECT Id, Name, hed_Date__c, hed_Start_Time__c, Reva_Exam_Notification__c, 
                                                             hed_End_Time__c, Course__r.HardCore_Sub_Type__c 
                                                             FROM hed_Time_Table_Line_Item__c 
                                                             WHERE Reva_Exam_Notification__c = :ExamNotification.Id];
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, MobilePhone,Father__c, Father_Name__c, Father_Mobile_Number__c,Father_Email_ID__c, Mother_Email_ID__c, Guardian__r.Email, 
                                         Active_Semester__r.Name,Mother_Name__c,Mother_Mobile_Number__c,
                                         Guardian__r.Name,Guardian__r.MobilePhone,Email,Mother__c,Guardian__c
                                         FROM Contact 
                                         WHERE Active_Semester__c = :ExamNotification.Rve_Semester__c 
                                         AND
                                          MobilePhone != null AND Email != null AND Active__c = true 
        ]);
    }
    
    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<Contact> contactList) {
        try {

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
                chunk.add(contactList[j]);
                System.debug('ChunkSize=> '+chunk.size());
            }
            processChunk(chunk,owea);

            // Process the current chunk
      //  System.enqueueJob(new HallTicket_Published_whats_batchQueue(chunk,ExamName,Semester));
        }
        System.debug('BatchCount=> '+batchcount);

        }
        catch(Exception e)
        {
            System.debug('line=> '+e.getLinenumber()+' Exception=> '+e.getMessage());
        }
    }

    public static void processChunk(List<Contact>ContactList,OrgWideEmailAddress owea){
        try{    
             // Lists to store data for notifications
            List<String> semester = new List<String>();
            List<String> examname = new List<String>();  
                semester.add(ExamNotification.Rve_Semester__r.Name);
                
                 examname.add(
                    ExamNotification.RecordType.Name == 'Semester Notification' ? 'Semester End Exam' :
                    (ExamNotification.RecordType.Name == 'IA Notification' && ExamNotification.hed_IA_Type__c == 'IA 1') ? 'Internal Assessment- 1' :
                    (ExamNotification.RecordType.Name == 'IA Notification' && ExamNotification.hed_IA_Type__c == 'IA 2') ? 'Internal Assessment- 2' :
                    ''
                );            
            
            // Fetching template details
            String templateId = 'change_timetable_exam';
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];

         //   String SMSTemplateId =
            
          
            // Iterate through contacts to create notifications
            system.debug('conlist-test>>'+contactList);
            for (Contact clist : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                
                // Set dynamic values for each key based on related record
                // notification.params.put('name', con.Name);
                notification.params.put('StudentName',clist.Name );
                notification.params.put('Semester', String.join(semester, ','));
                notification.params.put('ExamName', String.join(examname, ','));
                
                  // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            
                
                // Add notification to map
                phoneNumbersToNotifications.put(clist.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }
            /////////////////////////// SMS Notification /////////////////////////////

            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            //List<SMS_API_Utility.shortMessageWrp> messageList1 = new List<SMS_API_Utility.shortMessageWrp>();

        if(ContactList.size()>0)
        {
        for(Contact con : contactList) {
            String phoneNumber = con.MobilePhone;            
            System.debug('phoneNumber=> '+phoneNumber) ;          

            String message = 'Dear '+con.Name+', The '+examname[0]+'-Theory and Practical timetable for '+con.Active_Semester__r.Name+' has been published. Please login to your Student Portal for more details. REVA University';
            if(phoneNumber != null && message != null){
                SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                shrtMessage.dltContentId = '1007659400080202417';
                shrtMessage.message = message;
                shrtMessage.recipient = phoneNumber;
                messageList.add(shrtMessage);
            }

    }
}
        
        if(messageList.size() > 0) {
            SMS_API_Utility.SendSMSOneToMany('Change in Timetable', messageList);
        }
        

            ///////////////////////////Email Notification ////////////////////////////

            // List to store email messages
            List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();
 
            String subject = 'Change in the Timetable for ' + examname[0] + ' on ' + ExamNotification.rve_Exam_Start_Date__c.format().substringBefore(' ');
            for (Contact conList : contactList) {
                
                // Construct email body
                String body = '<!DOCTYPE html>' +
                    '<html>' +
                    '<head>' +
                    '<meta charset="utf-8">' +
                    '<title>Timetable Change Notification</title>' +
                    '</head>' +
                    '<body>' +
                    '<p>Dear Mr./Ms. ' + conList.Name + ',</p>' +
                    '<p>Greetings of the day!</p>' +
                    '<p>Please be informed that the timetable for ' + semester[0] + ' ' + examname[0] + ' has been updated.</p>' +
                    '<p>Start Date: ' + ExamNotification.rve_Exam_Start_Date__c.format().substringBefore(' ') + '<br>' +
                    'End Date: ' + ExamNotification.Rve_End_Date__c.format().substringBefore(' ') + '</p>' +
                    '<table border="1">' +
                    '<tr>' +
                    '<th>Date</th>' +
                    '<th>Type</th>' +
                    '<th>Subject</th>' +
                    '<th>Time</th>' +
                    '</tr>';
                
                // Add table rows for each line item
                for (hed_Time_Table_Line_Item__c lineItem : lineItems) {
                    body += '<tr>' +
                        '<td>' + lineItem.hed_Date__c.format().substringBefore(' ') + '</td>' +
                        '<td>' + lineItem.Course__r.HardCore_Sub_Type__c + '</td>' +
                        '<td>' + lineItem.name + '</td>' +  // Assuming exam name remains constant for all line items
                        '<td>' + getTimeString(lineItem.hed_Start_Time__c) + ' - ' + getTimeString(lineItem.hed_End_Time__c) + '</td>' +
                        '</tr>';
                }
                
                // Complete the email body
                body += '</table>' +
                    '<p>All the best!</p>' +
                    '<p>Thank You &amp; Warm regards,</p>' +
                    '<p>REVA University</p>' +
                    '</body>' +
                    '</html>';
                
                // Create email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new string[] {conList.Email}); // Assuming email is stored in Contact's Email field
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendemaillist.add(email);
            }

            ////////////////// Email Notification for Parents ///////////////////////////

            for (Contact student : contactList) {

                String ParentEmail = student.Father__c != null && student.Father_Email_ID__c != null ? student.Father_Email_ID__c
                : student.Mother__c != null && student.Mother_Email_ID__c != null ? student.Mother_Email_ID__c
                : student.Guardian__c != null ? student.Guardian__r.Email : null;
                // Construct email body
                
                String ParentName = student.Father__c != null && student.Father_Email_ID__c != null ? student.Father_Email_ID__c
                : student.Mother__c != null && student.Mother_Email_ID__c != null ? student.Mother_Email_ID__c
                : student.Guardian__c != null ? student.Guardian__r.Name : null;

                String body = '<!DOCTYPE html>' +
                    '<html>' +
                    '<head>' +
                    '<meta charset="utf-8">' +
                    '<title>Timetable Change Notification</title>' +
                    '</head>' +
                    '<body>' +
                    '<p>Dear Mr./Ms. ' + ParentName + ',</p>' +
                    '<p>Greetings of the day!</p>' +
                    '<p>Please be informed that the timetable for ' + semester[0] + ' ' + examname[0] + ' has been updated for your ward '+student.Name+'.</p>' +
                    '<p>Start Date: ' + ExamNotification.rve_Exam_Start_Date__c.format().substringBefore(' ') + '<br>' +
                    'End Date: ' + ExamNotification.Rve_End_Date__c.format().substringBefore(' ') + '</p>' +
                    '<table border="1">' +
                    '<tr>' +
                    '<th>Date</th>' +
                    '<th>Type</th>' +
                    '<th>Subject</th>' +
                    '<th>Time</th>' +
                    '</tr>';
                
                // Add table rows for each line item
                for (hed_Time_Table_Line_Item__c lineItem : lineItems) {
                    body += '<tr>' +
                        '<td>' + lineItem.hed_Date__c.format().substringBefore(' ') + '</td>' +
                        '<td>' + lineItem.Course__r.HardCore_Sub_Type__c + '</td>' +
                        '<td>' + lineItem.name + '</td>' +  // Assuming exam name remains constant for all line items
                        '<td>' + getTimeString(lineItem.hed_Start_Time__c) + ' - ' + getTimeString(lineItem.hed_End_Time__c) + '</td>' +
                        '</tr>';
                }
                
                // Complete the email body
                body += '</table>' +
                    '<p>All the best!</p>' +
                    '<p>Thank You &amp; Warm regards,</p>' +
                    '<p>REVA University</p>' +
                    '</body>' +
                    '</html>';
                
                // Create email message
                Messaging.SingleEmailMessage parentemailnotification = new Messaging.SingleEmailMessage();
                parentemailnotification.setToAddresses(new String[] {ParentEmail}); // Assuming email is stored in Contact's Email field
                parentemailnotification.setOrgWideEmailAddressId(owea.Id);
                parentemailnotification.setSubject(subject);
                parentemailnotification.setHtmlBody(body);
                sendemaillist.add(parentemailnotification);
        }
           
            // Send email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sendemaillist);
            if (results[0].isSuccess()) {
                System.debug('Email sent successfully.');
            } else {
                System.debug('Failed to send email: ' + results[0].getErrors()[0].getMessage());
            }
            
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }

    // Utility method to format Time to String
    private static String getTimeString(Time timeValue) {
        DateTime dt = DateTime.newInstance(Date.today(), timeValue);
        return dt.format('hh:mm a');
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}