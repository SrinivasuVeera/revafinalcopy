global class Exam_Malpractice_Notify_whats_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public String RecordIds { get; set; }
    public static hed__Attendance_Event__c AttendanceEvent {get;set;}
    public static List<contact> mentorList {get;set;}
    
    // Constructor to initialize RecordIds
    global Exam_Malpractice_Notify_whats_batch(String recordIds) {
        this.RecordIds = recordIds;
        AttendanceEvent = [ SELECT Id, Name, hed__Course_Name__c, rve_Exam_type__c, hed__Date__c,
        hed__Start_Time__c, hed__End_Time__c, hed__Contact__c, hed__Contact__r.Name,
        hed__Contact__r.MobilePhone, hed__Contact__r.Father_Mobile_Number__c,
        hed__Contact__r.Father_Name__c, hed__Contact__r.Mother_Name__c,
        hed__Contact__r.Mother_Mobile_Number__c, hed__Contact__r.Guardian__r.MobilePhone,
        hed__Contact__r.Guardian__r.Name, hed_Malpractice__c
        FROM hed__Attendance_Event__c
        where hed__Course_Name__c !=null AND  Id = :RecordIds limit 1];

    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                                        SELECT 
                                        Id, Name, SRN_Number__c, Father_Mobile_Number__c,
                                        Father_Name__c, Mother_Mobile_Number__c, Mother_Name__c,
                                        Guardian__r.MobilePhone, Guardian__r.Company_Name__c, 
                                        Mentor__r.Name, Mentor__r.MobilePhone,Guardian__r.Email,Mother_Email_ID__c,Father_Email_ID__c,Email,Mentor__r.Email
                                        FROM 
                                        Contact 
                                        WHERE 
                                        (
                                            (Father_Mobile_Number__c != null AND Father_Name__c != null) 
                                            OR (Mother_Mobile_Number__c != null AND Mother_Name__c != null) 
                                            OR (Guardian__r.MobilePhone != null AND Guardian__r.Name != null)
                                        ) 
                                        AND Active__c = true AND Id = :AttendanceEvent.hed__Contact__c
        ]);
    }
    
    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<Contact> ParentList) {
        try {

            // Query to fetch related mentor
            mentorList= [SELECT 
                                       Id, Name, SRN_Number__c,Mentor__r.Email,
                                       Mentor__r.Name, Mentor__r.MobilePhone 
                                       FROM 
                                       Contact 
                                       WHERE Active__c = true 
                                       AND Mentor__r.MobilePhone != null AND Id = :AttendanceEvent.hed__Contact__c
                                      ];
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];

        Integer batchSize = 24;
        Integer batchcount = 0;
        Integer totalRecords = ParentList.size();

 // Loop through the ContactList in chunks of batchSize
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Reset chunk list for the current iteration
            List<Contact> chunk = new List<Contact>();
            batchcount++;
            // Collect records for the current chunk
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                chunk.add(ParentList[j]);
                System.debug('ChunkSize=> '+chunk.size());
            }
            processChunk(chunk,owea);

        }
        }
        catch(Exception e)
        {
            System.debug('line=> '+e.getLinenumber()+' Exception=> '+e.getMessage());

        }
    }

     public static void processChunk(List<Contact>ParentList,OrgWideEmailAddress owea){
        try{    
            // Lists to store data for notifications
            List<String> course = new List<String>();
            List<String> date1 = new List<String>();
            List<String> starttime = new List<String>();
            List<String> lasttime = new List<String>();
            List<String> examname = new List<String>();
            
            // Iterate through the records and gather data
                course.add(AttendanceEvent.hed__Course_Name__c);
                starttime.add(parseTime(AttendanceEvent.hed__Start_Time__c));
                lasttime.add(parseTime(AttendanceEvent.hed__End_Time__c));
                date1.add(parseDate(AttendanceEvent.hed__Date__c));
                examname.add(String.valueOf(AttendanceEvent.rve_Exam_type__c));
            
            
            
            // Fetching student and parent templates
            String parentTemplateId = 'malpractice_notification_to_parents';
            String mentorTemplateId = 'malpractice_notification_to_mentor';
            
           
            // Iterate through contacts again to create parent notifications
            for (Contact student : parentList) {
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
                    parentNotification.params.put('coursename', String.join(course, ','));
                    parentNotification.params.put('exam', String.join(examname, ','));
                    parentNotification.params.put('starttime', String.join(starttime, ','));
                    parentNotification.params.put('endtime', String.join(lasttime, ','));
                    parentNotification.params.put('date', String.join(date1, ','));
                    
                    // Map to store notifications for each contact's phone number
                    Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                    
                    
                    // Add parent notification to map
                    phoneNumbersToNotifications.put(parentContactNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{parentNotification});
                    
                    // Send WhatsApp notifications
                    HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                    System.debug('Response=> ' + response);
                }
            }
            
            
            // Iterate through contacts to create mentor notifications
            for (Contact student : mentorList) {
                Yellow_AI_Utility.WhatsAppNotification studentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                studentNotification.templateId = mentorTemplateId;
                studentNotification.params = new Map<String, String>();
                studentNotification.params.put('mentorname', student.Mentor__r.Name);
                studentNotification.params.put('menteename', student.Name);
                studentNotification.params.put('srn', student.SRN_Number__c);
                studentNotification.params.put('coursename', String.join(course, ','));
                studentNotification.params.put('examname', String.join(examname, ','));
                studentNotification.params.put('starttime', String.join(starttime, ','));
                studentNotification.params.put('endtime', String.join(lasttime, ','));
                studentNotification.params.put('date', String.join(date1, ','));
                // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                
                
                // Add student notification to map
                phoneNumbersToNotifications.put(student.Mentor__r.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{studentNotification});
                
                // Send WhatsApp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> ' + response);
            }


            ////////////////////////////// SMS Notification //////////////////////////////////////////

            List<SMS_API_Utility.shortMessageWrp> messageList2 = new List<SMS_API_Utility.shortMessageWrp>();

         //   if (!attendanceList.isEmpty()) {
         //       for (hed__Attendance_Event__c record : attendanceList) {

                    // Determine parent/guardian contact details using ternary operator
                    String parentPhoneNumber = AttendanceEvent.hed__Contact__r.Father_Mobile_Number__c != null ? AttendanceEvent.hed__Contact__r.Father_Mobile_Number__c :
                                               AttendanceEvent.hed__Contact__r.Mother_Mobile_Number__c != null ? AttendanceEvent.hed__Contact__r.Mother_Mobile_Number__c :
                                               AttendanceEvent.hed__Contact__r.Guardian__r.MobilePhone;

                    String parentName = AttendanceEvent.hed__Contact__r.Father_Name__c != null ? AttendanceEvent.hed__Contact__r.Father_Name__c :
                                        AttendanceEvent.hed__Contact__r.Mother_Name__c != null ? AttendanceEvent.hed__Contact__r.Mother_Name__c :
                                        AttendanceEvent.hed__Contact__r.Guardian__r.Name;
                    
                    SYstem.debug('164=-> '+parentPhoneNumber);

                    // Handling malpractice notifications
                    if (AttendanceEvent.hed_Malpractice__c == true) {

                        if (parentPhoneNumber != null) {
                            String malpracticeMessage = 'Dear Mr./Ms.'+parentName+', We regret to inform you that your ward '+AttendanceEvent.hed__Contact__r.Name+' has been disbarred due to malpractice during the '+AttendanceEvent.rve_Exam_type__c+' for the '+AttendanceEvent.hed__Course_Name__c+' course conducted on '+parseDate(AttendanceEvent.hed__Date__c)+'. REVA University';
                            SMS_API_Utility.shortMessageWrp shrtMessage2 = new SMS_API_Utility.shortMessageWrp();
                            shrtMessage2.dltContentId = ' 1007028494138827087';
                            shrtMessage2.message = malpracticeMessage;
                            shrtMessage2.recipient = parentPhoneNumber;
                            messageList2.add(shrtMessage2);
                        }
                    }
                //}
            //}

            System.debug('186=> '+messageList2);

            if (messageList2.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Malpractice SMS to Parent', messageList2);
            }
            
            //////////////////////////////send emaail to parent //////////////////////////////////////
            
            //create the email list 
             List<Messaging.SingleEmailMessage> parentsendemaillist = new List<Messaging.SingleEmailMessage>();
            
            //create email notification
            for (Contact emailparent : parentList) {
                // Determine which parent's contact to use
                String parentemail = '';
                String parentNameEmail = '';
                
                if (emailparent.Father_Email_ID__c != null) {
                    parentemail = emailparent.Father_Email_ID__c;
                    parentNameEmail =emailparent.Father_Name__c;
                } else if (emailparent.Mother_Email_ID__c != null) {
                    parentemail = emailparent.Mother_Email_ID__c;
                    parentNameEmail = emailparent.Mother_Name__c;
                } else if (emailparent.Guardian__r.Email != null) {
                    parentemail = emailparent.Guardian__r.Email;
                    parentNameEmail = emailparent.Guardian__r.Name;
                }
                
                  if (parentemail != '') {
                      
                         //email body
                String subject =  'Notification on malpractice incident' ;
                String body = EmailTemplatesForReva.sendMallPraticeEmailtoParent20(parentNameEmail, emailparent.Name,examname[0],course[0], date1[0], starttime[0], lasttime[0] );
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{parentemail});
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                parentsendemaillist.add(email);
                  }
                
            }
            Messaging.sendEmail(parentsendemaillist);

          /////////////////////////////////////////send email for mentor///////////////////////////////////////////
          
            //create the email list 
             List<Messaging.SingleEmailMessage> mentorendemaillist = new List<Messaging.SingleEmailMessage>();
            
            //create email notification
            for (Contact emailmentor : mentorList) {
                         //email body  
                String subject =  'Notification on malpractice incident' ;
                String body = EmailTemplatesForReva.sendMallPraticeEmailtoMentor19(emailmentor.Mentor__r.Name, emailmentor.Name,emailmentor.SRN_Number__c ,examname[0],course[0], date1[0], starttime[0], lasttime[0] );
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{emailmentor.Mentor__r.Email});
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                mentorendemaillist.add(email);
                  }
                
            
            Messaging.sendEmail(mentorendemaillist);
            
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
    
    public static String parseTime(Time ConvertTime){
       
        String timeStr = String.valueOf(ConvertTime); // Your time string
       
        // Extract hour and minutes
        Integer hour = Integer.valueOf(timeStr.substring(0, 2));
        Integer minutes = Integer.valueOf(timeStr.substring(3, 5)); // Extract the minutes part
       
        // Determine AM/PM
        String suffix = (hour >= 12) ? 'PM' : 'AM';
       
        // Convert to 12-hour format
        hour = (hour > 12) ? hour - 12 : (hour == 0 ? 12 : hour);
           
            // Ensure minutes are formatted with two digits
            String formattedMinutes = (minutes < 10) ? '0' + minutes.toString() : minutes.toString();
       
        // Format the time string including minutes
        String formattedTime = hour + ':' + formattedMinutes + ' ' + suffix;
       
        // Output the formatted time string
        System.debug(formattedTime);
        return formattedTime;
    }
    
    public static String parseDate(Date dateneedstobeconvert){
        //formated date
        
        // Extract day and month and pad with zeros if needed
        String day = dateneedstobeconvert.day() < 10 ? '0' + dateneedstobeconvert.day() : String.valueOf(dateneedstobeconvert.day());
        String month = dateneedstobeconvert.month() < 10 ? '0' + dateneedstobeconvert.month() : String.valueOf(dateneedstobeconvert.month());
        String year = String.valueOf(dateneedstobeconvert.year());
        
        // Format the date as DD-MM-YYYY
        String formattedDate1 = day + '-' + month + '-' + year;
        
        System.debug('formattedDate>>' + formattedDate1);
        return formattedDate1;
    }
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}