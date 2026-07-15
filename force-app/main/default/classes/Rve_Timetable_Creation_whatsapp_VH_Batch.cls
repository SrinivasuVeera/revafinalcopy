global class Rve_Timetable_Creation_whatsapp_VH_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // RecordIds property to store the input parameters
    public List<String> RecordIds { get; set; }
    
    // Constructor to initialize RecordIds
    global Rve_Timetable_Creation_whatsapp_VH_Batch(List<String> recordIds) {
        this.RecordIds = recordIds;
    }
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Program_Batch__r.Name, 
            Program_Batch__r.hed__Account__r.Vertical_Head__r.Name, IA_1_Start_date__c, Exam_Start_Date__c, 
            IA_1_End_date__c, IA_2_End_date__c, IA_2_Start_date__c, 
            Program_Batch__r.hed__Account__r.Vertical_Head__r.MobilePhone, Program_Batch__r.hed__Account__r.Vertical_Head__r.Email
            FROM hed__Term__c 
            WHERE Active__c = true 
            AND Program_Batch__r.hed__Account__r.Vertical_Head__r.MobilePhone != null 
            AND Program_Batch__r.hed__Account__r.Vertical_Head__r.Email != null 
            AND Id IN :RecordIds  
        ]);
    }

     global void execute(Database.BatchableContext bc, List<hed__Term__c> semList) {
        System.debug('semList=> '+semList.size());
        Integer batchSize = 98;
        Integer batchcount = 0;
        Integer totalRecords = semList.size();
        
        // Loop through the semList in chunks of batchSize
        for (Integer i = 0; i < totalRecords; i += batchSize) {
            // Reset chunk list for the current iteration
            List<hed__Term__c> chunk = new List<hed__Term__c>();
            batchcount++;
            // Collect records for the current chunk
            for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                chunk.add(semList[j]);
            }
            
            // Process the current chunk
            processChunk(chunk);
        }
        System.debug('BatchCount=> '+batchcount);

    }
    
    // Execute method to process the records
public void processChunk(List<hed__Term__c> semList) {
        try {
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();

            // Collect all Program_Batch__c Ids to query notifications in bulk
            Set<Id> programBatchIds = new Set<Id>();
            for (hed__Term__c term : semList) {
                programBatchIds.add(term.Program_Batch__c);
            }

            // Bulk query for notifications
            Map<Id, List<Rve_Exam_Notification__c>> notificationsMap = new Map<Id, List<Rve_Exam_Notification__c>>();
            List<Rve_Exam_Notification__c> notificationList = [
                SELECT Id, Name, hed_Program_Batch__c, Rve_Semester__c, hed_IA_Type__c, CreatedDate
                FROM Rve_Exam_Notification__c 
                WHERE hed_Program_Batch__c IN :programBatchIds
                AND hed_IA_Type__c != null AND RecordType.DeveloperName = 'hed_IA_Notification'
                AND Rve_Publish__c = true 
                ORDER BY CreatedDate DESC
            ];

            for (Rve_Exam_Notification__c notification : notificationList) {
                if (!notificationsMap.containsKey(notification.hed_Program_Batch__c)) {
                    notificationsMap.put(notification.hed_Program_Batch__c, new List<Rve_Exam_Notification__c>());
                }
                notificationsMap.get(notification.hed_Program_Batch__c).add(notification);
            }

            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'alerts@reva.edu.in' LIMIT 1];

            for (hed__Term__c term : semList) {
                String examName = '';
                List<Rve_Exam_Notification__c> termNotifications = notificationsMap.get(term.Program_Batch__c);

                if (termNotifications != null && !termNotifications.isEmpty()) {
                    for (Rve_Exam_Notification__c notifyList : termNotifications) {
                        if (notifyList.Rve_Semester__c == term.Id && notifyList.hed_IA_Type__c != null) {
                            if (notifyList.hed_IA_Type__c == 'IA 1') {
                                examName = 'Internal Assessment- 2';
                            } else {
                                examName = 'Internal Assessment- 1';
                            }
                            break;
                        }
                    }
                }

                if (examName == '') {
                    if (term.IA_1_Start_date__c == Date.today().addDays(10)) {
                        examName = 'Internal Assessment- 1';
                    } else if (term.IA_2_Start_date__c == Date.today().addDays(10)) {
                        examName = 'Internal Assessment- 2';
                    }
                }

                // Subtract 10 days from Exam_Start_Date__c
                DateTime adjustedDate = term.Exam_Start_Date__c.addDays(-10);
                Date termEndDate1 = adjustedDate.date();
                
                // Extract day and month and pad with zeros if needed
                String day = termEndDate1.day() < 10 ? '0' + termEndDate1.day() : String.valueOf(termEndDate1.day());
                String month = termEndDate1.month() < 10 ? '0' + termEndDate1.month() : String.valueOf(termEndDate1.month());
                String year = String.valueOf(termEndDate1.year());
                
                // Format the date as DD-MM-YYYY
                String formattedDate1 = day + '-' + month + '-' + year;
                
                // Create WhatsApp notification
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = 'ia_timetable_create';
                notification.params = new Map<String, String>();
                notification.params.put('FacultyName', term.Program_Batch__r.hed__Account__r.Vertical_Head__r.Name);
                notification.params.put('examname', examName);
                notification.params.put('programBatch', term.Name);
                notification.params.put('LastDate', formattedDate1);
                
                if (!phoneNumbersToNotifications.containsKey(term.Program_Batch__r.hed__Account__r.Vertical_Head__r.MobilePhone)) {
                    phoneNumbersToNotifications.put(term.Program_Batch__r.hed__Account__r.Vertical_Head__r.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>());
                }
                
                phoneNumbersToNotifications.get(term.Program_Batch__r.hed__Account__r.Vertical_Head__r.MobilePhone).add(notification);
                
                // Create email
                String subject = 'Reminder: Create ' + examName + ' timetable for ' + term.Name;
                String body = EmailTemplatesForReva.sendIATimeTableCreationEmail4(
                    term.Program_Batch__r.hed__Account__r.Vertical_Head__r.Name, 
                    examName, 
                    term.Name, 
                    formattedDate1
                );
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { term.Program_Batch__r.hed__Account__r.Vertical_Head__r.Email });
                email.setOrgWideEmailAddressId(owea.Id);
                email.setSubject(subject);
                email.setHtmlBody(body);
                sendEmailList.add(email);
            }
            
            // Send WhatsApp notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('Response=> ' + response);
            
            // Send emails
            Messaging.sendEmail(sendEmailList);
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
    
    // Finish method to execute post-processing operations
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}