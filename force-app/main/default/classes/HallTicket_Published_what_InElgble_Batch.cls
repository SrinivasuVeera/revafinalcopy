global class HallTicket_Published_what_InElgble_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public List<String> RecordIds { get; set; }
    public Rve_Exam_Notification__c ExamNotification {get;set;}
    
    // Constructor to initialize RecordIds
    global HallTicket_Published_what_InElgble_Batch(List<String> recIds) {
        this.RecordIds = recIds;
        this.ExamNotification = [ select id,name ,hed_Program_Batch__r.Name, Rve_Semester__r.Name,hed_Program_Batch__c,
            Rve_Semester__c,Rve_Semester__r.Program_Batch__c,  rve_Exam_Start_Date__c,RecordType.Name, hed_IA_Type__c,
            Rve_End_Date__c from Rve_Exam_Notification__c where Id = :RecordIds];
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
       List<Contact> elgcontactListapex = rveSeatingArrangementUpdated.getInEligibleStudents(ExamNotification.Rve_Semester__r.Program_Batch__c);
       set<ID> Inelgibleset = new set<ID>();
            for(contact conlist : elgcontactListapex){
                Inelgibleset.add(conlist.Id);
            }
        return Database.getQueryLocator([
               SELECT Id, Name, MobilePhone, Father_Mobile_Number__c, Father_Name__c, 
           Mother_Mobile_Number__c, Mother_Name__c, Guardian__r.MobilePhone, 
           Guardian__r.Name, Active_Semester__r.Name, Email, Mother_Email_ID__c, 
           Father_Email_ID__c, Guardian__r.Email
           FROM Contact 
           WHERE (
              (Father_Mobile_Number__c != null AND Father_Name__c != null) 
           OR (Mother_Mobile_Number__c != null AND Mother_Name__c != null) 
           OR (Guardian__r.MobilePhone != null AND Guardian__r.Name != null)
           OR (Father_Name__c != null AND Father_Email_ID__c != null)
           OR (Mother_Name__c != null AND Mother_Email_ID__c != null)
           OR (Guardian__r.Name != null AND Guardian__r.Email != null)
          ) 
          AND Active__c = true 
          AND (MobilePhone != null OR Email != null)
          AND Id IN :Inelgibleset
        ]);
    }
    
    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<Contact> InelgContactList) {
        try {
            // Lists to store data for notifications
            List<String> examname = new List<String>();
            List<String> semester = new List<String>();
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];

            
            // Iterate through the records and gather data
                semester.add(ExamNotification.Rve_Semester__r.Name);
                examname.add(
                    ExamNotification.RecordType.Name == 'Semester Notification' ? 'Semester End Exam' :
                    (ExamNotification.RecordType.Name == 'IA Notification' && ExamNotification.hed_IA_Type__c == 'IA 1') ? 'Internal Assessment- 1' :
                    (ExamNotification.RecordType.Name == 'IA Notification' && ExamNotification.hed_IA_Type__c == 'IA 2') ? 'Internal Assessment- 2' :
                    ''
                );

        Integer batchSize1 = 24;
        Integer batchcount1 = 0;
        Integer totalInEligibleRecords = inelgContactList.size();
        
        // Loop through the ContactList in chunks of batchSize
        for (Integer i = 0; i < totalInEligibleRecords; i += batchSize1) {
            // Reset chunk list for the current iteration
            List<Contact> chunk = new List<Contact>();
            batchcount1++;
            // Collect records for the current chunk
            for (Integer j = i; j < Math.min(i + batchSize1, totalInEligibleRecords); j++) {
                chunk.add(inelgContactList[j]);
            }
            System.debug('chunksize=> '+chunk.size());
            // Process the current chunk
            processInEligibleChunk(chunk,examname,semester,owea);
        }

    }
    catch(Exception e)
    {
        System.debug('Line=> '+e.getLineNumber()+' Exception=> '+e.getMessage());
    }
    }
   

    public static void processInEligibleChunk(List<contact>inelgcontactList,list<string>examname,list<string>semester,OrgWideEmailAddress owea){
             String StdinelgtemplateId = 'hallticket_ineliglible';
            String parentinelgtemplateId = 'ineligible_hall_ticket_notification_parents';
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

            
            //////////////////////////// Iterate through contacts to create notifications for inelgible students/////////////////////////
            for (Contact con : inelgcontactList) {
                system.debug(con.name);
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = StdinelgtemplateId;
                notification.params = new Map<String, String>();
                
                // Set dynamic values for each key based on related record
                notification.params.put('StudentName', con.Name);
                notification.params.put('ExamName', String.join(examname, ','));
                
                
                // Map to store notifications for each contact's phone number
                
                
                // Add notification to map
                phoneNumbersToNotifications.put(con.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
              //  System.debug('Response=> '+response);
            }
            
            ////////////////////// Iterate through contacts to create notifications for inelgible parents/////////////////
            for (Contact con : inelgcontactList) {
                system.debug(con.name);
                
                // Determine which parent's contact to use
                String parentContactNumber = '';
                String parentName = '';
                
                if (con.Father_Mobile_Number__c != null) {
                    parentContactNumber = con.Father_Mobile_Number__c;
                    parentName =con.Father_Name__c;
                } else if (con.Mother_Mobile_Number__c != null) {
                    parentContactNumber = con.Mother_Mobile_Number__c;
                    parentName = con.Mother_Name__c;
                } else if (con.Guardian__r.MobilePhone != null) {
                    parentContactNumber = con.Guardian__r.MobilePhone;
                    parentName = con.Guardian__r.Name;
                }
                // Create notifications for parent(s)
                if (parentContactNumber != '') {
                    Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                    notification.templateId = parentinelgtemplateId;
                    notification.params = new Map<String, String>();
                    
                    // Set dynamic values for each key based on related record
                    notification.params.put('parentname', parentName);
                    notification.params.put('studentname', con.Name);
                    notification.params.put('examname', String.join(examname, ','));
                    
                    
                    // Map to store notifications for each contact's phone number
                  //  Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                    
                    
                    // Add notification to map
                    phoneNumbersToNotifications.put(parentContactNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                    
                    //Send Whatsapp notifications
                 //   HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                  //  System.debug('Response=> '+response);
                    
                }
            }
            
            ///////////////////// SMS Notification ////////////////////////////////////
            
          
            List<SMS_API_Utility.shortMessageWrp> InEligiblemessageList = new List<SMS_API_Utility.shortMessageWrp>();
            List<SMS_API_Utility.shortMessageWrp> InEligiblemessageParentList1 = new List<SMS_API_Utility.shortMessageWrp>();
            
            System.debug('inelgcontactList=> '+inelgcontactList.size());
            
            if(!inelgcontactList.isEmpty())
            {
                for(Contact con : inelgcontactList) {
                    System.debug('conName=> '+con.Name+' phone=> '+con.MobilePhone);
                    String phoneNumber = con.MobilePhone;            
                    
                    String message = 'Dear '+con.Name+', This is to inform you that due to ineligibility you are restricted from downloading your Hall Ticket for '+examname[0]+' Please contact your School Director. REVA University';
                    
                    if(phoneNumber != null && message != null){
                        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage.dltContentId = '1007015619802705306';
                        shrtMessage.message = message;
                        shrtMessage.recipient = phoneNumber;
                        InEligiblemessageList.add(shrtMessage);
                    }
                    
                    // Ternary operators for parent phone number and name
                    String parentPhoneNumber = con.Father_Mobile_Number__c != null ? con.Father_Mobile_Number__c
                        : con.Mother_Mobile_Number__c != null ? con.Mother_Mobile_Number__c
                            : con.Guardian__r != null ? con.Guardian__r.MobilePhone : null;
                    
                    String parentName = con.Father_Mobile_Number__c != null ? con.Father_Name__c
                        : con.Mother_Mobile_Number__c != null ? con.Mother_Name__c
                            : con.Guardian__r != null ? con.Guardian__r.Name : null;
                    
                    if(parentPhoneNumber != null && parentName != null) {
                        System.debug('Parent phoneNumber => ' + parentPhoneNumber);          
                        
                        String message1 = 'Dear Mr./Ms. '+parentName+', We regret to inform you that due to ineligibility your ward '+con.Name+' is restricted from downloading the Hall Ticket for '+examname[0]+' REVA University';
                        
                        SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage1.dltContentId = '1007390250352325218';
                        shrtMessage1.message = message1;
                        shrtMessage1.recipient = parentPhoneNumber;
                        InEligiblemessageParentList1.add(shrtMessage1); 
                    }
                }
                
            } 
            
            if(InEligiblemessageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Hall Ticket Notification-Ineligible Stud', InEligiblemessageList);
            }
            if(InEligiblemessageParentList1.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Hall Ticket Notification to Parents-Inel', InEligiblemessageParentList1);
            }

            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);

            
            ///////////////////// Email Notification///////////////////////////////////
            
            // List for eligible student emails
            List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();            
            
            // Iterate through ineligible students to create email notifications
            for (Contact inEligibleStudent : inelgcontactList) {
                String subject = 'Ineligible to download the Hall ticket for ' + String.join(examname, ',');
                String body = EmailTemplatesForReva.sendInEligibleHallTicketEmailtoStudent9(inEligibleStudent.Name, String.join(examname, ','));
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                email.setToAddresses(new String[]{inEligibleStudent.Email});
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendemaillist.add(email); 
            }
            
            // Iterate through ineligible students' parents to create email notifications
            for (Contact inEligibleParent : inelgcontactList) {
                // Determine which parent's contact to use
                String parentEmail = '';
                String parentName = '';
                
                if (inEligibleParent.Father_Email_ID__c != null) {
                    parentEmail = inEligibleParent.Father_Email_ID__c;
                    parentName = inEligibleParent.Father_Name__c;
                } else if (inEligibleParent.Mother_Email_ID__c != null) {
                    parentEmail = inEligibleParent.Mother_Email_ID__c;
                    parentName = inEligibleParent.Mother_Name__c;
                } else if (inEligibleParent.Guardian__r.Email != null) {
                    parentEmail = inEligibleParent.Guardian__r.Email;
                    parentName = inEligibleParent.Guardian__r.Name;
                }
                
                // Create notifications for parent(s)
                if (parentEmail != '') {
                    // Create a new email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setOrgWideEmailAddressId(owea.Id);
                    // Set the recipient email address
                    email.setToAddresses(new String[]{parentEmail});
                    
                    // Set the subject using the provided method
                    String subject = 'Ineligible to download the Hall ticket for ' + String.join(examname, ',');
                    email.setSubject(subject);
                    
                    // Set the HTML body using the provided method
                    String body = EmailTemplatesForReva.sendInEligibleHallTicketEmailtoParent10(parentName, inEligibleParent.Name, String.join(examname, ','));
                    email.setHtmlBody(body);
                    
                    // Add the created email message to ineligibleParentEmails list
                    sendemaillist.add(email); 
                }
            }
            
            
            Messaging.sendEmail(sendemaillist);
    }

    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}