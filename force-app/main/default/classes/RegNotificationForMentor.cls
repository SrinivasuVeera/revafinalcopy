global class RegNotificationForMentor implements Database.Batchable<sobject>, Database.AllowsCallouts {
 
     private String mentorName; 
     private String semName;
     private String studName;
     private String srnNumber;
     private String mobilePhone;
     private String menteePhone;
    
    public RegNotificationForMentor(String mentorNameParam, string semNameParam,String studNameParam,String srnNumberParam,String mobilePhoneParam, String menteePhoneParam){
        mentorName = mentorNameParam;
        semName = semNameParam;
        studName = studNameParam;
        srnNumber = srnNumberParam;
        mobilePhone = mobilePhoneParam;
        menteePhone = menteePhoneParam;
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
             String templateId = 'semester_regis_mentor'; 
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();         
          	      
                    
            // Iterate through contacts to create notifications
            if (mentorName != null && semName != null && studName != null && srnNumber != null) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                notification.params.put('Mentor_name', mentorName);
                notification.params.put('Semester_Name', semName);
                notification.params.put('Student_Name', studName);
                notification.params.put('SRN', srnNumber);  
                notification.params.put('Student_Contact',menteePhone);                
                
                //Mentor_name,Semester_Name,Student_Name,SRN,Student_Contact	
                // Add notification to map               
                if(mobilePhone != null){
                    String plusRemoved = mobilePhone.replace('+', '');
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