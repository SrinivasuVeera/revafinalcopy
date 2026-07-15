public class RTRWhatsappNotificationFaculty {
    
		@InvocableMethod(label='RTR Send WhatsApp Notifications To Faculty' description='RTR Send notifications via WhatsApp To Faculty')
    public static void trsWhatsappNotification(List<String> recordIds){
        
        if(recordIds!=null && !recordIds.isEmpty()){
            
            makeCalloutAsync(recordIds);           
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        
        List<Transport_Registeration__c> requiredFields = [Select id, Contact__r.id, Contact__r.Employee_Number__c,Amount_Paid__c, 
                                                          Route_Master__r.Name, Contact__r.name, Contact__r.MobilePhone, rtr_Start_Date__c,
                                                          Route_Pick_Up_Point__r.Name  From Transport_Registeration__c Where Id IN:recordIds];
        
      
        System.debug('requiredFields-->> '+requiredFields);
        
        if(!requiredFields.isEmpty()){
            
            Transport_Registeration__c requiredField = requiredFields[0];
            
            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'transport_registration_confirmation_staff';
            
            // Fetch keys from custom metadata based on templateId
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            
             // Populate the params map dynamically
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                // Split values based on comma and add each as a separate key
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    // You can set dynamic values for each key based on the related record
                    if (key.trim() == 'employeename') {
                       notification1.params.put(key.trim(), requiredField.Contact__r.name);
                    } else if (key.trim() == 'employeeid') {
                        // Assuming employeeid is a text field
                       notification1.params.put(key.trim(), requiredField.Contact__r.Employee_Number__c );
                    } 
                    else if (key.trim() == 'routenumber') {
                        // Assuming routenumber is a number field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.Route_Master__r.name));
                    }
                    else if (key.trim() == 'pickuppoint') {
                        // Assuming pickuppoint is a number field
                       notification1.params.put(key.trim(), requiredField.Route_Pick_Up_Point__r.Name);
                    }
                     else if (key.trim() == 'transportdeduction') {
                        // Assuming transportationcharge is a currency field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.Amount_Paid__c));
                    }
                     else if (key.trim() == 'registrationdate') {
                        // Assuming dateofregistration is a date field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.rtr_Start_Date__c));
                    }                     
                }
            }
        
        
        	// Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(requiredField.Contact__r.MobilePhone, notifications);

            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
    }
         else {
            System.debug('No related record found for the provided ID');
        }

}
}