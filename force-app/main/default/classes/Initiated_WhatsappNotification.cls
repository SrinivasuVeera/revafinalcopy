public class Initiated_WhatsappNotification {

    @InvocableMethod(label='Send WhatsApp Notifications' description='Send notifications via WhatsApp')
    public static void Appointment_InitiatedNotifications(List<String> recordIds) {
        // Ensure that recordIds is not empty
        if (recordIds != null && !recordIds.isEmpty()) {
            // Make the callout asynchronously
            Appointment_Initiated(recordIds);
        } else {
           // System.debug('Record IDs list is empty or null');
        }
    }
    
        @Future(callout=true)
    public static void Appointment_Initiated(List<String> recordIds) {
        // Fetch the related record data
        List<ManodhaaraAppointment__c> requiredFields = [
            SELECT Id, Appointment_Date_Formatted__c, Start_Date_Time__c,Time_Slot_Formatted__c,Severity__c, End_Date_Time__c,Name, Case__r.Contact.Name, Case__r.Contact.MobilePhone
            FROM ManodhaaraAppointment__c
            WHERE Id IN :recordIds
            LIMIT 1
        ];
// System.debug('ManodhaaraAppointment__c'+requiredFields);
        // Check if related record is found
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Case__r.Contact.MobilePhone)) {
            ManodhaaraAppointment__c requiredField = requiredFields[0];

            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'manodhaara_appointment_request';

            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
        //System.debug('templateMetadata: ' + templateMetadata);
            // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'Severity') {
                        notification1.params.put(key.trim(), requiredField.Severity__c);
                        //notification1.params.put(key.trim(), 'requiredField.Case__r.Contact.Name');
                    } else if (key.trim() == 'date') {
                        // Assuming Start_Date__c is a Date field
                       // notification1.params.put(key.trim(), String.valueOf(requiredField.Appointment_Date_Formatted__c));
                        notification1.params.put(key.trim(), String.valueOf(requiredField.Appointment_Date_Formatted__c));
                    } else if (key.trim() == 'time') {
                        // Assuming Start_Date__c is a DateTime field
                        notification1.params.put(key.trim(), String.valueOf(requiredField.Time_Slot_Formatted__c));
                       // notification1.params.put(key.trim(), 'hj');
                    } else if (key.trim() == 'appointmentnumber') {
                        // Assuming End_Date__c is a DateTime field
                        notification1.params.put(key.trim(), requiredField.Name);
                        //notification1.params.put(key.trim(),'ioo');
                    }
                }
            }
			
            // Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(requiredField.Case__r.Contact.MobilePhone, notifications);

            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
           // System.debug('WhatsApp notification response: ' + response);
        } else {
           // System.debug('No related record found for the provided ID');
        }
    }

}