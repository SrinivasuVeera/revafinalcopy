public class Update_Student_Support_WAppNotification {
    @InvocableMethod(label='Student Support Case Cahanged Notification' description='Send Support WhatsApp Notifications to student')
    public static void sendChangedCaseWhatsAppNotification(List<String> recordIds) {
        // Ensure that recordIds is not empty
        if (recordIds != null && !recordIds.isEmpty()) {
            // Make the callout asynchronously
            makeLeaveApprovalCallout(recordIds);
        } else {
            System.debug('Record IDs list is empty or null');
        }
    }

    @Future(callout=true)
    public static void makeLeaveApprovalCallout(List<String> recordIds) {
        // Fetch the related record data
        List<Case> requiredFields = [
            SELECT Contact.Name, Contact.MobilePhone,Case_Contact_Name__c,Contact_Mobile_Number__c,Hostel_Sub_Category__c, Hostel_Category__c, Sub_Category__c, CaseNumber, CreatedDate, Description, Status
            FROM Case
            WHERE Id IN :recordIds
            LIMIT 1
        ];
        // Check if related record is found
        if (!requiredFields.isEmpty() && !String.isBlank(requiredFields[0].Contact_Mobile_Number__c)) {
            Case requiredField = requiredFields[0];

            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'complaintupdate_student';

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
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'studentname') {
                        notification1.params.put(key.trim(), requiredField.Case_Contact_Name__c);
                    } else if (key.trim() == 'complainttype') {
                        // Assuming Start_Date__c is a Date field
                        String complaintType = requiredField.Hostel_Category__c + requiredField.Hostel_Sub_Category__c != '' ? '-'+requiredField.Hostel_Category__c: '';
                        notification1.params.put(key.trim() + ' ', complaintType);
                    } else if (key.trim() == 'complaintnumber') {
                        // Assuming End_Date__c is a DateTime field
                        notification1.params.put(key.trim() + ' ', requiredField.CaseNumber);
                    } else if (key.trim() == 'complaintcreationdate') {
                        notification1.params.put(key.trim() + ' ', String.valueOf(requiredField.CreatedDate));
                    } else if (key.trim() == 'complaintdescription') {
                        notification1.params.put(key.trim() + ' ', requiredField.Description);
                    } else if (key.trim() == 'complaintstatus') {
                        notification1.params.put(' ' + key.trim() + ' ', requiredField.Status);
                    }
                }
            }
			
            // Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            System.debug('notification1: ' + notification1);
            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
           // phoneNumbersToNotifications.put(requiredField.Contact_Mobile_Number__c, notifications);

            if(requiredField.Contact_Mobile_Number__c !=null){
                String plusRemoved = requiredField.Contact_Mobile_Number__c.replace('+', '');
                String correctedWhatsappNumber = plusRemoved.replace('-', '');
                phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
            }  
             
            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
            System.debug('WhatsApp notification response: ' + response);
        } else {
            System.debug('No related record found for the provided ID');
        }
    }
}