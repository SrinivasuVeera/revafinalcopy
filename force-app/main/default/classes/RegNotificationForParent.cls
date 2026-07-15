global class RegNotificationForParent implements Database.Batchable<sobject>, Database.AllowsCallouts {
       
	private String semName;    
    private Contact contact;
    private List<Contact> parentList;            
    
    public RegNotificationForParent(Contact conObjParam, List<Contact> parentListParam, string semNameParam){
        contact = conObjParam;
        semName = semNameParam;   
        parentList = parentListParam;
    }
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc)  {
         System.debug('Start Method');
        
      //  Contact contactStudObj = [SELECT Id, Name,SRN_Number__c,hed__WorkEmail__c, MobilePhone, Program_Batch_Name__c FROM Contact WHERE Id = :contactId LIMIT 1];
        
        return Database.getQueryLocator([SELECT Id, Name,SRN_Number__c,hed__WorkEmail__c, MobilePhone FROM Contact LIMIT 1]);
        
	 }
     
    
 global void execute(Database.BatchableContext bc, List<Contact> contactList) {  
      try {                                     
            // Fetching template details
             String templateId = 'semester_regis_parent'; 
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();         
          	String studName = contact.Name;
            String srnNumber = contact.SRN_Number__c;      
                    
            // Iterate through contacts to create notifications
            for (Contact clist : parentList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                notification.params.put('Parent_or_Guardian', clist.Name);
                notification.params.put('Semester_Name', semName);
                notification.params.put('Student_Name', studName);
                notification.params.put('SRN', srnNumber);              
                               
                // Add notification to map               
                if(clist.MobilePhone !=null){
                    String plusRemoved = clist.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});                    
                }    //Send Whatsapp notifications
             
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('Response=> '+response);        
              
            }            
          	
         
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }

    // Finish method 
    global void finish(Database.BatchableContext bc) {
         System.debug('Finish Method');      
    }    
}