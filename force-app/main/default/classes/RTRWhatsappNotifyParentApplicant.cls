public class RTRWhatsappNotifyParentApplicant {
 @InvocableMethod(label='RTR Send WhatsApp Notifications To Parent' description='RTR Send notifications via WhatsApp To Parent')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds!=null && !recordIds.isEmpty()){
            
            makeCalloutAsync(recordIds);           
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
    
    @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        
        List<Transport_Registeration__c> TrRegList = [Select id, Contact__r.id,Route_Master__r.Name, Route_Pick_Up_Point__r.Name  
                                                     From Transport_Registeration__c Where Id IN:recordIds];
        System.debug('TrRegList-->> '+TrRegList);
        // populate contactId in List
        List<Id> contactIds = new List<Id>();
        
        for(Transport_Registeration__c trsRegList :TrRegList){
            System.debug('TrsRegList ContactId-->> '+trsRegList.Contact__r.id);
            contactIds.add(trsRegList.Contact__r.id);
        }
        
        // Fetch the related record data
        List<Student_Fee__c> requiredFields = [SELECT Id, Amount_Paid__c, Amount_Pending__c, contact__r.Application_Number__c, Amount__c,contact__r.Father__r.name,Contact__r.RH_Parent_Phone_Number__c,
                                               Academic_Program__c, SRN_Number__c, Contact__r.Name, Due_Date__c,Contact__r.Id,Contact__r.MobilePhone,
                                               RTR_Transport_Registration__r.Route_Master__r.name, RTR_Transport_Registration__r.Route_Pick_Up_Point__r.Name
                                               from Student_Fee__c WHERE Contact__r.Id IN :contactIds AND Fee_Type__c = 'Transportation Fee' Order by CreatedDate DESC LIMIT 1];
        
        System.debug('requiredFields-->> '+requiredFields);
        
        if(!requiredFields.isEmpty()){
            
            Student_Fee__c requiredField = requiredFields[0];
            
            // Create WhatsAppNotification instance
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'transportregistrationconfirmation_parent_applicant';
            
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
                    if (key.trim() == 'parentname') {
                       notification1.params.put(key.trim(), requiredField.contact__r.Father__r.name);
                    } else if (key.trim() == 'applicationnumber') {
                        // Assuming applicationnumber is a text field
                       notification1.params.put(key.trim(), requiredField.Contact__r.Application_Number__c);
                    }else if (key.trim() == 'applicantname') {
                        // Assuming name is a text field
                       notification1.params.put(key.trim(), requiredField.Contact__r.Name);
                    }
                    else if (key.trim() == 'program') {
                        // Assuming program is a text field
                       notification1.params.put(key.trim(), requiredField.Academic_Program__c);
                    }
                    else if (key.trim() == 'routenumber') {
                        // Assuming routenumber is a number field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.RTR_Transport_Registration__r.Route_Master__r.name));
                    }
                    else if (key.trim() == 'pickuppoint') {
                        // Assuming pickuppoint is a number field
                       notification1.params.put(key.trim(), requiredField.RTR_Transport_Registration__r.Route_Pick_Up_Point__r.Name);
                    }
                     else if (key.trim() == 'totalmount') {
                        // Assuming totalamount is a number field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.Amount__c));
                    }
                     else if (key.trim() == 'amountpaid') {
                        // Assuming amountpaid is a number field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.Amount_Paid__c));
                    }
                     else if (key.trim() == 'amountpending') {
                        // Assuming amountpending is a number field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.Amount_Pending__c));
                    }
                     else if (key.trim() == 'duedate') {
                        // Assuming duedate is a number field
                       notification1.params.put(key.trim(), String.ValueOf(requiredField.Due_Date__c));
                    }
                }
            }
        
        
        	// Create list of notifications
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};

            // Create map of phone numbers to notifications
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(requiredField.Contact__r.RH_Parent_Phone_Number__c, notifications);

            // Send notifications
            HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
    }
         else {
            System.debug('No related record found for the provided ID');
        }
}
}