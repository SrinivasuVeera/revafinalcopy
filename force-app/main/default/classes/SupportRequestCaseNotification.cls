public class SupportRequestCaseNotification {
    public class InputParameters {
        @InvocableVariable(required=true)
        public List<String> recordIds;
        
        @InvocableVariable(required=true)
        public List<String> UserCheck;
        
    } 
    @InvocableMethod(label='Support Request notifications to Sub-members')
    public static void processContacts(List<InputParameters> inputs) {
        
        List<string> checkuser =inputs[0].UserCheck;
        if(checkuser[0] == 'WhatsApp'){
            SupportRequstWhatsApp(inputs[0].recordIds,'hostel_support');
        }
    }
    
    @Future(callout=true)
    public static void SupportRequstWhatsApp(List<string> recordIds, String whatsappTemplateName) {
        Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
        notification1.templateId = whatsappTemplateName;
        
        Case caseRecord = [
            SELECT id, Case_Contact_Name__c, SRN_Number__c,createdDate, CaseNumber,Room_Number__c, Hostel_Block__c, Description, Hostel_Category__c, Hostel_Sub_Category__c, OwnerId, 
            phone__c,email__c
            FROM Case 
            WHERE id = :recordIds 
            LIMIT 1
        ];
         String formattedCreatedDate = caseRecord.createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            System.debug('templateMetadata: ' + templateMetadata);
            // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    
                    if (key.trim() == 'name_of_the_student') {
                        notification1.params.put(key.trim(), caseRecord.Case_Contact_Name__c);
                        system.debug('notification1'+notification1);
                    } else if (key.trim() == 'case_number') {
                        
                        notification1.params.put(key.trim(), caseRecord.CaseNumber);
                         system.debug('notification1'+notification1);
                    } else if (key.trim() == 'case_submitted_date') {
                        
                        notification1.params.put(key.trim(), formattedCreatedDate);
                         system.debug('notification1'+notification1);
                    } else if (key.trim() == 'case_category') {
                        
                        notification1.params.put(key.trim(), caseRecord.Hostel_Category__c);
                         system.debug('notification1'+notification1);
                    } else if (key.trim() == 'case_sub_category') {
                        
                        notification1.params.put(key.trim(), caseRecord.Hostel_Sub_Category__c);
                         system.debug('notification1'+notification1);
                    }else if (key.trim() == 'student_registration_number') {
                        
                        notification1.params.put(key.trim(), caseRecord.SRN_Number__c);
                         system.debug('notification1'+notification1);
                    }else if (key.trim() == 'room_number') {
                        
                        notification1.params.put(key.trim(), caseRecord.Room_Number__c);
                         system.debug('notification1'+notification1);
                    }else if (key.trim() == 'hostel_block') {
                        
                        notification1.params.put(key.trim(), caseRecord.Hostel_Block__c);
                         system.debug('notification1'+notification1);
                    }else if (key.trim() == 'description') {
                        
                        notification1.params.put(key.trim(),caseRecord.Description);
                         system.debug('notification1'+notification1);
                    }
                }
        
        }   
        // Create list of notifications
        List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
            
            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        phoneNumbersToNotifications.put(caseRecord.Phone__c, notifications);
        
        // Send notifications
        HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
        System.debug('WhatsApp notification response: ' + response);
    }
}