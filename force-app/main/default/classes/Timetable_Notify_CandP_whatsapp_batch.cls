global class Timetable_Notify_CandP_whatsapp_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public String RecordIds { get; set; }
    public Rve_Exam_Notification__c ExamNotification {get;set;} 
    
    // Constructor to initialize RecordIds
    global Timetable_Notify_CandP_whatsapp_batch(String recordIds) {
        this.RecordIds = recordIds;
       this.ExamNotification = [select id,name ,hed_Program_Batch__r.Name, Rve_Semester__r.Name,hed_Program_Batch__c, Rve_Semester__c,  rve_Exam_Start_Date__c,RecordType.Name, 
            Rve_End_Date__c,hed_IA_Type__c from Rve_Exam_Notification__c where Id = :recordIds];
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, MobilePhone, Father_Mobile_Number__c, Father_Name__c, 
            Mother_Mobile_Number__c, Mother_Name__c, Active_Semester__r.Name, 
            Guardian__r.MobilePhone, Guardian__r.Name, Email, 
            Mother_Email_ID__c, Father_Email_ID__c, Guardian__r.Email 
            FROM Contact  
            WHERE Active_Semester__c = :this.ExamNotification.Rve_Semester__c 
            AND Active__c = true 
            AND (
            (MobilePhone != null AND (
               (Father_Mobile_Number__c != null AND Father_Name__c != null) 
            OR (Mother_Mobile_Number__c != null AND Mother_Name__c != null) 
            OR (Guardian__r.MobilePhone != null AND Guardian__r.Name != null)
            )) 
            OR 
           (Email != null AND (
               (Father_Email_ID__c != null AND Father_Name__c != null) 
            OR (Mother_Email_ID__c != null AND Mother_Name__c != null) 
            OR (Guardian__r.Email != null AND Guardian__r.Name != null)
           ))
        )
        ]);
    }

    global void execute(Database.BatchableContext bc, List<contact> ContactList) {
        System.debug('ContactList=> '+ContactList.size());
        Integer batchSize = 49;
        Integer batchcount = 0;
        Integer totalRecords = ContactList.size();
        
        // Loop through the ContactList in chunks of batchSize
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Reset chunk list for the current iteration
            List<Contact> chunk = new List<Contact>();
            batchcount++;
            // Collect records for the current chunk
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                chunk.add(ContactList[j]);
            }
            
            // Process the current chunk
            processChunk(chunk);
        }
        System.debug('BatchCount=> '+batchcount);

    }
    
    // Execute method to process the records
public void processChunk(List<Contact> contactList) {
    try {
            System.debug('ContactList=> '+contactList.size());
            // Lists to store data for notifications
            
            List<String> semester = new List<String>();
            List<String> startdate = new List<String>();
            List<String> lastdate = new List<String>();
            List<String> examname = new List<String>();
            
            // Iterate through the records and gather data
        //    for (Rve_Exam_Notification__c request : notificationList) {
                semester.add(this.ExamNotification.Rve_Semester__r.Name);
                startdate.add(String.valueOf(this.ExamNotification.rve_Exam_Start_Date__c));
                lastdate.add(String.valueOf(this.ExamNotification.Rve_End_Date__c));
                
                examname.add(
                    this.ExamNotification.RecordType.Name == 'Semester Notification' ? 'Semester End Exam' :
                    (this.ExamNotification.RecordType.Name == 'IA Notification' && this.ExamNotification.hed_IA_Type__c == 'IA 1') ? 'Internal Assessment- 1' :
                    (this.ExamNotification.RecordType.Name == 'IA Notification' && this.ExamNotification.hed_IA_Type__c == 'IA 2') ? 'Internal Assessment- 2' :
                    ''
                );
          //  }            
            
            // Fetching student and parent templates
            String studentTemplateId = 'timetable_notification';
            String parentTemplateId = 'time_table_notification_for_parents';
            
            // Iterate through contacts to create student notifications
            for (Contact student : contactList) {
                Yellow_AI_Utility.WhatsAppNotification studentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                studentNotification.templateId = studentTemplateId;
                studentNotification.params = new Map<String, String>();
                studentNotification.params.put('StudentName', student.Name);
                studentNotification.params.put('Semester', String.join(semester, ','));
                studentNotification.params.put('ExamName', String.join(examname, ','));
                studentNotification.params.put('StartDate', String.join(startdate, ','));
                studentNotification.params.put('EndDate', String.join(lastdate, ','));
                // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                
                // Add student notification to map
                phoneNumbersToNotifications.put(student.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{studentNotification});
                
                // Send WhatsApp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> ' + response);
            }
            
            // Iterate through contacts again to create parent notifications
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
                    // parentNotification.params.put('Semester', String.join(semester, ','));
                    parentNotification.params.put('examname', String.join(examname, ','));
                    //parentNotification.params.put('StartDate', String.join(startdate, ','));
                    // parentNotification.params.put('EndDate', String.join(lastdate, ','));
                    
                    // Map to store notifications for each contact's phone number
                    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                    
                    // Add parent notification to map
                    phoneNumbersToNotifications.put(parentContactNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{parentNotification});
                    
                    // Send WhatsApp notifications
                    HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                    System.debug('Response=> ' + response);
                }
            }


            ///////////////////////// SMS Notification //////////////////////////////////////
    
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            List<SMS_API_Utility.shortMessageWrp> messageList1 = new List<SMS_API_Utility.shortMessageWrp>();
    
            if(ContactList.size()>0)
            {
            for(Contact con : contactList) {
                String phoneNumber = con.MobilePhone;            
                System.debug('phoneNumber=> '+phoneNumber) ;          
    
                String message = 'Dear '+con.Name+', The '+examname[0]+'-Theory and Practical timetable for '+con.Active_Semester__r.Name+' has been published. Please login to your Student Portal for more details. REVA University';
                if(phoneNumber != null && message != null){
                    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                    shrtMessage.dltContentId = '1007973862672805648';
                    shrtMessage.message = message;
                    shrtMessage.recipient = phoneNumber;
                    messageList.add(shrtMessage);
                }
                
                String parentPhoneNumber = con.Father_Mobile_Number__c != null ? con.Father_Mobile_Number__c
                                     : con.Mother_Mobile_Number__c != null ? con.Mother_Mobile_Number__c
                                     : con.Guardian__r != null ? con.Guardian__r.MobilePhone : null;
            
            String parentName = con.Father_Mobile_Number__c != null ? con.Father_Name__c
                             : con.Mother_Mobile_Number__c != null ? con.Mother_Name__c
                             : con.Guardian__r != null ? con.Guardian__r.Name : null;
    
    
            if(parentPhoneNumber != null && parentName != null) {
                System.debug('Parent phoneNumber => ' + parentPhoneNumber);          
                
                String message1 = 'Dear Mr./Ms. ' + parentName + ', We would like to inform you that the timetable for ' + examname[0] + ' for your ward ' + con.Name + ' is published. REVA University';
                
                SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                shrtMessage1.dltContentId = '1007046042969860826';
                shrtMessage1.message = message1;
                shrtMessage1.recipient = parentPhoneNumber;
                messageList1.add(shrtMessage1); 
            }
        }
    }
            
            if(messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Timetable Notification', messageList);
            }
            if(messageList1.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Time Table Notification to the Parents', messageList1);
            }
          
            
  ////////////////////////////////// Email Notification ///////////////////////////////////////////////////////
           
            List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];
system.debug('owea>>'+owea);

            if(this.ExamNotification!=null)
            {
            list<hed_Time_Table_Line_Item__c> TimeTables = [Select Id,Name,course__c,course__r.name,hed_Date__c,hed_Start_Time__c,Reva_Exam_Notification__r.hed_IA_Type__c,
                                                            hed_End_Time__c,course__r.HardCore_Sub_Type__c from hed_Time_Table_Line_Item__c
                                                           where Reva_Exam_Notification__c=:this.ExamNotification.Id];
            
            String subject = examname[0]+' TimeTable Published for ' +this.ExamNotification.Rve_Semester__r.Name;

                
                for(Contact student : contactList){
               //  String EmailBody = EmailTemplatesForReva.sendTimeTableNotificationEmailtoStudent5(Student.Name, notificationList[0].hed_IA_Type__c, notificationList[0].Rve_Semester__r.Name, String.valueOf(notificationList[0].rve_Exam_Start_Date__c), String.valueof(notificationList[0].Rve_End_Date__c), '01/06/2024');
                
               //  System.debug('EmailBody=> '+EmailBody);
                    // Construct email body
                String body = '<!DOCTYPE html>' +
                    '<html>' +
                    '<head>' +
                    '<meta charset="utf-8">' +
                    '<title>'+ examname[0]+' Timetable Published for Notification '+this.ExamNotification.Rve_Semester__r.Name+'</title>' +
                    '</head>' +
                    '<body>' +
                    '<p>Dear '+student.Name+ ',</p>' +
                    '<p>Greetings of the day!</p>' +
                    '<p>The '+ examname[0]+'- Theory and Practical Timetable for '+this.ExamNotification.Rve_Semester__r.Name+' has been published </p>' +
                    '<p>Start Date: ' + this.ExamNotification.rve_Exam_Start_Date__c.format().substringBefore(' ') + '<br>' +
                    'End Date: ' + this.ExamNotification.Rve_End_Date__c.format().substringBefore(' ') + '</p>' +
                    '<table border="1">' +
                    '<tr>' +
                    '<th>Date</th>' +
                    '<th>Type</th>' +
                    '<th>Subject</th>' +
                    '<th>Time</th>' +
                    '</tr>';
                
                // Add table rows for each line item
                for (hed_Time_Table_Line_Item__c lineItem : TimeTables) {
                    body += '<tr>' +
                        '<td>' + lineItem.hed_Date__c.format().substringBefore(' ') + '</td>' +
                        '<td>' + lineItem.Course__r.HardCore_Sub_Type__c + '</td>' +
                        '<td>' + lineItem.name + '</td>' +  // Assuming exam name remains constant for all line items
                        '<td>' + getTimeString(lineItem.hed_Start_Time__c) + ' - ' + getTimeString(lineItem.hed_End_Time__c) + '</td>' +
                        '</tr>';
                }
                
                // Complete the email body
                body += '</table>' +
                    '<p>Result will be published in your student portal on 12/06/2025</p>' +
                    '<p>Thank You &amp; Warm regards,</p>' +
                    '<p>REVA University</p>' +
                    '</body>' +
                    '</html>';
                
                // Create email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new string[] {student.Email}); // Assuming email is stored in Contact's Email field
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendemaillist.add(email);



                //////////// Parent Email Notification ////////////////////

            String ParentEmailSubject = ' TimeTable Published for '+examname[0];

            String ParentEmail = student.Father_Email_ID__c!=null?student.Father_Email_ID__c:(student.Mother_Email_ID__c!=null?student.Mother_Email_ID__c:student.Guardian__r.Email);
            String ParentName = student.Father_Email_ID__c!=null?student.Father_Name__c:(student.Mother_Email_ID__c!=null?student.Mother_Name__c:student.Guardian__r.Name);
                String ParentEmailbody = '<!DOCTYPE html>' +
                    '<html>' +
                    '<head>' +
                    '<meta charset="utf-8">' +
                   // '<title>'+NotificationList[0].hed_IA_Type__c+' Timetable Published for Notification '+NotificationList[0].Rve_Semester__r.Name+'</title>' +
                    '</head>' +
                    '<body>' +
                    '<p>Dear Mr./Ms. '+ParentName+ ',</p>' +
                    '<p>Hope this email finds you well. We would like to inform you that the timetable for '+examname[0]+' for your ward '+student.Name+' is published.</p>' +
                    '<p>We wish your child a very best in their upcoming exam.<br>' +
                    '<p>Thank You &amp; Warm regards,</p>' +
                    '<p>REVA University</p>' +
                    '</body>' +
                    '</html>';

                Messaging.SingleEmailMessage ParentemailParam = new Messaging.SingleEmailMessage();
                ParentemailParam.setToAddresses(new string[] {ParentEmail}); // Assuming email is stored in Contact's Email field
                ParentemailParam.setSubject(ParentEmailSubject);
                ParentemailParam.setOrgWideEmailAddressId(owea.Id);
                ParentemailParam.setHtmlBody(ParentEmailbody);
                sendemaillist.add(ParentemailParam);    

            }
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
    private String getTimeString(Time timeValue) {
        DateTime dt = DateTime.newInstance(Date.today(), timeValue);
        return dt.format('hh:mm a');
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}