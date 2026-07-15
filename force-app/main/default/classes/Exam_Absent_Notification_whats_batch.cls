global class Exam_Absent_Notification_whats_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameter
    public String RecordIds { get; set; }
    public static hed__Attendance_Event__c AttendanceEvent {get;set;}
    Public static List<SMS_API_Utility.shortMessageWrp> messageList {get;set;}
    public static List<SMS_API_Utility.shortMessageWrp> messageList1 {get;set;}
    
    // Constructor to initialize RecordIds
    global Exam_Absent_Notification_whats_batch(String recordIds) {
        this.RecordIds = recordIds;
        AttendanceEvent = [
            SELECT Id, Name, hed__Course_Name__c, rve_Exam_type__c, hed__Date__c,
    hed__Start_Time__c, hed__End_Time__c, hed__Contact__c, hed__Contact__r.Name, hed__Contact__r.MobilePhone,
    hed__Contact__r.Father_Mobile_Number__c, hed__Contact__r.Father_Name__c, hed__Contact__r.Mother_Name__c, 
    hed__Contact__r.Mother_Mobile_Number__c, hed__Contact__r.Guardian__r.MobilePhone, hed__Contact__r.Guardian__r.Name,
    hed_Malpractice__c from hed__Attendance_Event__c where hed__Course_Name__c !=null AND rve_Exam_type__c !=null AND Id = :RecordIds
        ];
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT 
                                        Id, Name, SRN_Number__c, Father_Mobile_Number__c,MobilePhone,
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
                                        AND Active__c = true AND Mentor__r.MobilePhone != null AND Id = :AttendanceEvent.hed__Contact__c ]);
    }
    
    // Execute method to process the records
    global void execute(Database.BatchableContext bc, List<Contact> ContactList) {
        try {
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];

            Integer batchSize = 24;
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
        public static void processChunk(List<Contact>ContactList,OrgWideEmailAddress owea){
        try{  

            List<Messaging.SingleEmailMessage> sendAbsentNotifications = new List<Messaging.SingleEmailMessage>();
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
                date1.add(String.valueOf(parseDate(AttendanceEvent.hed__Date__c)));
                examname.add(String.valueOf(AttendanceEvent.rve_Exam_type__c));
            
            // Fetching student and parent templates
            String studentTemplateId = 'absent_notification_student';
            String parentTemplateId = 'exam_absent_notification_parents';
            String mentorTemplateId = 'absent_notification_mentee';
            
            
            // Iterate through contacts to create student notifications
                        system.debug('contacttest>>'+contactList);
           

            for (Contact student : contactList) {
                Yellow_AI_Utility.WhatsAppNotification studentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                studentNotification.templateId = studentTemplateId;
                studentNotification.params = new Map<String, String>();
                studentNotification.params.put('StudentName', student.Name);
                studentNotification.params.put('CourseName', String.join(course, ','));
                studentNotification.params.put('examname', String.join(examname, ','));
                studentNotification.params.put('starttime', String.join(starttime, ','));
                studentNotification.params.put('endtime', String.join(lasttime, ','));
                studentNotification.params.put('Date', String.join(date1, ','));
                // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                
                
                // Add student notification to map
                phoneNumbersToNotifications.put(student.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{studentNotification});
                
                // Send WhatsApp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> ' + response);
                string studentEmail='';
                if (student.Email != null) {
                    studentEmail = student.Email;
                } 
                String subject='Marked absent for '+course[0]+'-'+examname[0]+' scheduled on '+date1[0]+', '+starttime[0]+' - '+lasttime[0]+'.';
                String body = EmailTemplatesForReva.IASEEAbsentAttendanceNotificationForStudents(student.Name, examname[0], course[0],date1[0], starttime[0], lasttime[0]);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(subject);
                email.setHtmlBody(body);
                If(studentEmail!=''){
                     email.setToAddresses(new String[]{studentEmail});
                    sendAbsentNotifications.add(email); 
                }
            }
           system.debug('parenttest>>'+ContactList);
            // Iterate through contacts again to create parent notifications
            for (Contact student : ContactList) {
                // Determine which parent's contact to use
                String parentContactNumber = '';
                String parentName = '';
                String parentEmail = '';
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
                if (student.Father_Email_ID__c != null) {
                    parentEmail = student.Father_Email_ID__c;
                } else if (student.Mother_Email_ID__c != null) {
                    parentEmail = student.Mother_Email_ID__c;
                } else if (student.Guardian__r.Email != null) {
                    parentEmail = student.Guardian__r.Email;
                }
                //Send email to parents starts here
                String subject='Your ward is marked absent for'+ course[0]+' '+examname[0]+' scheduled on '+date1[0]+', '+starttime[0]+' - '+lasttime[0]+'.';
                String body = EmailTemplatesForReva.IASEEAbsentAttendanceNotificationForParents(parentname, student.Name, course[0], examname[0], date1[0], starttime[0], lasttime[0]);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(subject);
                email.setOrgWideEmailAddressId(owea.Id);
                email.setHtmlBody(body);
                If(parentEmail!=''){
                     email.setToAddresses(new String[]{parentEmail});
                    sendAbsentNotifications.add(email); 
                }
               
                // Create notifications for parent(s)
                if (parentContactNumber != '') {
                    Yellow_AI_Utility.WhatsAppNotification parentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                    parentNotification.templateId = parentTemplateId;
                    parentNotification.params = new Map<String, String>();
                    parentNotification.params.put('parentname', parentName);
                    parentNotification.params.put('studentname', student.Name);
                    parentNotification.params.put('coursename', String.join(course, ','));
                    parentNotification.params.put('examname', String.join(examname, ','));
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

            for (Contact student : ContactList) {
                Yellow_AI_Utility.WhatsAppNotification studentNotification = new Yellow_AI_Utility.WhatsAppNotification();
                studentNotification.templateId = mentorTemplateId;
                studentNotification.params = new Map<String, String>();
                studentNotification.params.put('mentorname', student.Mentor__r.Name);
                studentNotification.params.put('menteename', student.Name);
                studentNotification.params.put('SRN', student.SRN_Number__c);
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
                string mentorEmail='';
                if (student.Mentor__r.Email != null) {
                    mentorEmail = student.Mentor__r.Email;
                } 
                String subject='Absent for the '+examname[0];
                String body = EmailTemplatesForReva.AbsentAttendnaceToMentor(student.Mentor__r.Name, student.Name, student.SRN_Number__c,examname[0], course[0],date1[0], starttime[0], lasttime[0]);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(subject);
                email.setOrgWideEmailAddressId(owea.Id);
                email.setHtmlBody(body);
                If(mentorEmail!=''){
                     email.setToAddresses(new String[]{mentorEmail});
                    sendAbsentNotifications.add(email); 
                }
            }

            //////////////////////////////////// SMS Notification //////////////////////////

            messageList = new List<SMS_API_Utility.shortMessageWrp>();
            messageList1 = new List<SMS_API_Utility.shortMessageWrp>();
         //   if (!AttendanceList.isEmpty()) {
         //       for (hed__Attendance_Event__c Attendance : AttendanceList) {
                    String phoneNumber = AttendanceEvent.hed__Contact__r.MobilePhone; 
                    System.debug('phoneNumber=> ' + phoneNumber);
            
                    String formattedDate = String.valueOf(AttendanceEvent.hed__Date__c.format());
                    System.debug('Formatted Date: ' + formattedDate);
            
                    String FormattedStartTime = parseTime(AttendanceEvent.hed__Start_Time__c);
                    String FormattedEndTime = parseTime(AttendanceEvent.hed__End_Time__c);
            
                    if (phoneNumber != null) {
                        String message = 'Dear ' + AttendanceEvent.hed__Contact__r.Name + ', You have been marked absent for the ' + AttendanceEvent.hed__Course_Name__c + '-' + AttendanceEvent.rve_Exam_type__c + ' scheduled on ' + formattedDate + ' at ' + FormattedStartTime + '-' + FormattedEndTime + '. REVA University';
                        SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage1.dltContentId = '1007725551527063262';
                        shrtMessage1.message = message;
                        shrtMessage1.recipient = phoneNumber;
                        messageList.add(shrtMessage1);
                    }
            
                    // Ternary operator to determine parent/guardian phone number and name
                    String parentPhoneNumber = AttendanceEvent.hed__Contact__r.Father_Mobile_Number__c != null ? AttendanceEvent.hed__Contact__r.Father_Mobile_Number__c
                                             : AttendanceEvent.hed__Contact__r.Mother_Mobile_Number__c != null ? AttendanceEvent.hed__Contact__r.Mother_Mobile_Number__c
                                             : AttendanceEvent.hed__Contact__r.Guardian__r != null ? AttendanceEvent.hed__Contact__r.Guardian__r.MobilePhone : null;
            
                    String parentName = AttendanceEvent.hed__Contact__r.Father_Mobile_Number__c != null ? AttendanceEvent.hed__Contact__r.Father_Name__c
                                     : AttendanceEvent.hed__Contact__r.Mother_Mobile_Number__c != null ? AttendanceEvent.hed__Contact__r.Mother_Name__c
                                     : AttendanceEvent.hed__Contact__r.Guardian__r != null ? AttendanceEvent.hed__Contact__r.Guardian__r.Name : null;
            
                    if (parentPhoneNumber != null) {
                        String message1 = 'Dear Mr./Ms. ' + parentName + ', This is to inform you that your ward ' + AttendanceEvent.hed__Contact__r.Name + ' has been marked absent for ' + AttendanceEvent.hed__Course_Name__c + '-' + AttendanceEvent.rve_Exam_type__c + ' scheduled on ' + formattedDate + ' from ' + FormattedStartTime + ' to ' + FormattedEndTime + '. REVA University';
                        SMS_API_Utility.shortMessageWrp shrtMessage1 = new SMS_API_Utility.shortMessageWrp();
                        shrtMessage1.dltContentId = '1007695423852716598';
                        shrtMessage1.message = message1;
                        shrtMessage1.recipient = parentPhoneNumber;
                        messageList1.add(shrtMessage1);
                    }
            
            system.debug('size-->'+messageList.size());
            system.debug('size1-->'+messageList1.size());
            if (messageList.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('IA and SEE Absent Attendance', messageList);
            }
            if (messageList1.size() > 0) {
                SMS_API_Utility.SendSMSOneToMany('Absent Notification for Parents', messageList1);
            }
           
           
            Messaging.sendEmail(sendAbsentNotifications);
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

        String formattedDate = String.valueOf(dateneedstobeconvert.format());
        System.debug('Formatted Date: ' + formattedDate);
        return formattedDate;
    }

    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
        
    }
}