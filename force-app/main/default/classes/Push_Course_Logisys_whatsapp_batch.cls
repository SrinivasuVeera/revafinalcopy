global class Push_Course_Logisys_whatsapp_batch implements Database.Batchable<sobject>, Database.AllowsCallouts {

        // RecordIds property to store the input parameter
    public list<String> RecordIds { get; set; }
    
    // Constructor to initialize RecordIds
    global Push_Course_Logisys_whatsapp_batch(list<String> recordIds) {
        this.RecordIds = recordIds;
    }
    // Start method to return query locator
       global Database.QueryLocator start(Database.BatchableContext bc) {
           return Database.getQueryLocator([
               SELECT Id, Name,hed__Term__r.name,Offered_By_School__r.Vertical_Head__r.name,
               Offered_By_School__r.Vertical_Head__r.MobilePhone, Offered_By_School__c, 
               hed__Course__r.hed__Course_ID__c,hed__Term__r.IA_1_Start_date__c
               from hed__Course_Offering__c where
               hed__Term__r.Active__c =true and Trigger_Approval__c  = false  and 
               Offered_By_School__r.Vertical_Head__r.MobilePhone !=null AND Offered_By_School__r.Vertical_Head__r.email !=null AND
                hed__Term__r.IA_1_Start_date__c	!=null AND Id In:RecordIds  
               
           ]);
       }

       global void execute(Database.BatchableContext bc, List<hed__Course_Offering__c> CourseList) {
        System.debug('CourseList=> '+CourseList.size());
        Integer batchSize = 98;
        Integer batchcount = 0;
        Integer totalRecords = CourseList.size();
        
        // Loop through the CourseList in chunks of batchSize
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Reset chunk list for the current iteration
            List<hed__Course_Offering__c> chunk = new List<hed__Course_Offering__c>();
            batchcount++;
            // Collect records for the current chunk
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                chunk.add(CourseList[j]);
            }
            
            // Process the current chunk
            processChunk(chunk);
        }
        System.debug('BatchCount=> '+batchcount);

    }

    // Execute method to process the records
public void processChunk(List<hed__Course_Offering__c> CourseList) {
        system.debug('Courcse list'+courseList);
        try {
            
            // Fetching template details
            String templateId = 'push_course_offerings_to_logisys';
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
                
                //formated date of IA_1_Start_date__c
                
                DateTime termEndDateTime1 = clist.hed__Term__r.IA_1_Start_date__c;
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
                notification.params.put('FacultyName',clist.Offered_By_School__r.Vertical_Head__r.name);
               // notification.params.put('examname',clist.hed__Term__r.name);
                notification.params.put('semester',clist.hed__Term__r.name);
              //  notification.params.put('coursecode',clist.hed__Course__r.hed__Course_ID__c);
                notification.params.put('lastdate', formattedDate1);
               
                 // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

                // Add notification to map
                phoneNumbersToNotifications.put(clist.Offered_By_School__r.Vertical_Head__r.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                
                //Send Whatsapp notifications
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);
            }
            
            /////////////////send email////////////////////////
           
             List<Messaging.SingleEmailMessage> sendemaillist = new List<Messaging.SingleEmailMessage>();
            
             OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];

            for (hed__Course_Offering__c newcourseList : courselist) {
                
                //formated date
                 DateTime termEndDateTime1 = newcourseList.hed__Term__r.IA_1_Start_date__c;
                Date termEndDate1 = termEndDateTime1.date();
                
                // Extract day and month and pad with zeros if needed
                String day = termEndDate1.day() < 10 ? '0' + termEndDate1.day() : String.valueOf(termEndDate1.day());
                String month = termEndDate1.month() < 10 ? '0' + termEndDate1.month() : String.valueOf(termEndDate1.month());
                String year = String.valueOf(termEndDate1.year());
                
                // Format the date as DD-MM-YYYY
                String formattedDate1 = day + '-' + month + '-' + year;
                
                System.debug('formattedDate>>' + formattedDate1);

                
                //email body
                String subject = 'Reminder: Course Offerings push to Logisys for ' + newcourseList.hed__Term__r.name;
                String body = EmailTemplatesForReva.sendPushCourseOffering3(newcourseList,formattedDate1);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setOrgWideEmailAddressId(owea.Id);
                email.setToAddresses(new String[]{newcourseList.Offered_By_School__r.Vertical_Head__r.email});
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