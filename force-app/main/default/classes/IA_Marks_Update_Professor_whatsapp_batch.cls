global class IA_Marks_Update_Professor_whatsapp_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    //RecordIds property to store the input parameter
    public list<String> RecordIds { get; set; }
    
    // Constructor to initialize RecordIds
    global IA_Marks_Update_Professor_whatsapp_batch(list<String> recordIds) {
        this.RecordIds = recordIds;
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name,hed__Faculty__r.name,hed__Faculty__r.MobilePhone,hed__Term__r.name,hed__Term__r.Program_Batch__r.Name,
            hed__Course__r.hed__Course_ID__c,hed__Term__r.IA_2_End_date__c,IA_Marks_Update_Status__c,
            IA_2_Marks_Update_Status__c from hed__Course_Offering__c where
            (IA_Marks_Update_Status__c !='Completed' OR IA_2_Marks_Update_Status__c != 'Completed') 
            AND hed__Term__r.Active__c =true AND hed__Faculty__r.MobilePhone!=null AND hed__Faculty__r.Email !=null
            AND  Id In:RecordIds
            
        ]);
    }

    global void execute(Database.BatchableContext bc, List<hed__Course_Offering__c> courseList) {
        Integer batchSize = 98;
        Integer batchcount = 0;
        Integer totalRecords = courseList.size();
        
        // Loop through the courseList in chunks of batchSize
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Reset chunk list for the current iteration
            List<hed__Course_Offering__c> chunk = new List<hed__Course_Offering__c>();
            batchcount++;
            // Collect records for the current chunk
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                chunk.add(courseList[j]);
            }
            
            // Process the current chunk
            processChunk(chunk);
        }
        System.debug('BatchCount=> '+batchcount);

    }
    
    // Execute method to process the records
public void processChunk(List<hed__Course_Offering__c> courseList) {
        try {
            
            
            // Fetching template details
            String templateId = 'ia_marks_entry_notification';
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            
            // Iterate through contacts to create notifications
            for (hed__Course_Offering__c clist : courseList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                
                
                
                DateTime termEndDateTime1 = clist.hed__Term__r.IA_2_End_date__c;
                Date termEndDate1 = termEndDateTime1.date();
                
                // Extract day and month and pad with zeros if needed
                String day = termEndDate1.day() < 10 ? '0' + termEndDate1.day() : String.valueOf(termEndDate1.day());
                String month = termEndDate1.month() < 10 ? '0' + termEndDate1.month() : String.valueOf(termEndDate1.month());
                String year = String.valueOf(termEndDate1.year());
                
                // Format the date as DD-MM-YYYY
                String formattedDate1 = day + '-' + month + '-' + year;
                
                System.debug('formattedDate>>' + formattedDate1);
                
                // Set dynamic values for each key based on related record
                // notification.params.put('name', con.Name);
                notification.params.put('FacultyName',clist.hed__Faculty__r.name);
                notification.params.put('examname',clist.hed__Term__r.name);
                notification.params.put('Semester',clist.hed__Term__r.name);
                notification.params.put('coursecode',clist.hed__Course__r.hed__Course_ID__c);
                notification.params.put('lastdate', formattedDate1);
                // Determine examname based on conditions
                String examname;
                if (clist.IA_Marks_Update_Status__c == 'Completed' && clist.IA_2_Marks_Update_Status__c != 'Completed') {
                    examname = 'Internal Assessment - 2';
                } else if (clist.IA_Marks_Update_Status__c != 'Completed' && clist.IA_2_Marks_Update_Status__c == 'Completed') {
                    examname = 'Internal Assessment - 1';
                } else if (clist.IA_Marks_Update_Status__c != 'Completed' && clist.IA_2_Marks_Update_Status__c != 'Completed') {
                    // Handle other cases if needed
                    examname = 'Internal Assessment - 1'; // Default value
                } else {
                    // Handle other cases if needed
                    examname = ''; // Default value
                }
                notification.params.put('examname', examname);
                
                // Map to store notifications for each contact's phone number
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                
                
                
                // Add notification to map
                phoneNumbersToNotifications.put(clist.hed__Faculty__r.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }
            
            
            
            /////////////////////////send email///////////////////// 
            
            List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'notifications@reva.edu.in' LIMIT 1];
            
            for (hed__Course_Offering__c newcourseList : courselist) {
                //get the exam name based up on the conditions
                String examname;
                if (newcourseList.IA_Marks_Update_Status__c == 'Completed' && newcourseList.IA_2_Marks_Update_Status__c != 'Completed') {
                    examname = 'Internal Assessment - 2';
                } else if (newcourseList.IA_Marks_Update_Status__c != 'Completed' && newcourseList.IA_2_Marks_Update_Status__c == 'Completed') {
                    examname = 'Internal Assessment - 1';
                } else if (newcourseList.IA_Marks_Update_Status__c != 'Completed' && newcourseList.IA_2_Marks_Update_Status__c != 'Completed') {
                    // Handle other cases if needed
                    examname = 'Internal Assessment - 1'; // Default value
                } else {
                    // Handle other cases if needed
                    examname = ''; // Default value
                }
                //to send formated date
                DateTime termEndDateTime = newcourseList.hed__Term__r.IA_2_End_date__c;
                Date termEndDate = termEndDateTime.date();
                
                // Extract day and month and pad with zeros if needed
                String day = termEndDate.day() < 10 ? '0' + termEndDate.day() : String.valueOf(termEndDate.day());
                String month = termEndDate.month() < 10 ? '0' + termEndDate.month() : String.valueOf(termEndDate.month());
                String year = String.valueOf(termEndDate.year());
                
                // Format the date as DD-MM-YYYY
                String formattedDate = day + '-' + month + '-' + year;
                
                System.debug('formattedDate>>' + formattedDate);
                
                system.debug('email>>'+newcourseList.hed__Faculty__r.Email);
                
                //email body

                String subject = 'Reminder: ' + examname + ' marks entry for course - ' + newcourseList.hed__Course__r.hed__Course_ID__c;
                String body = EmailTemplatesForReva.sendIAMarksEntryEmailtoFaculty2(newcourseList, examname,formattedDate);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                email.setToAddresses(new String[]{newcourseList.hed__Faculty__r.Email});
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendemaillist.add(email);
                
                
            }
            Messaging.sendEmail(sendemaillist);
            
            system.debug('list>>'+sendemaillist);
            system.debug('size>>'+sendemaillist.size());
            
            
            
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}