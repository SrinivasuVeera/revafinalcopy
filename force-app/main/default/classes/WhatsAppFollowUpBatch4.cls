global class WhatsAppFollowUpBatch4 implements Database.Batchable<sobject>,Database.Stateful,Database.AllowsCallouts {
    
    List<Lead> successfulIds = new List<Lead>();
    List<Lead> unsuccessfulIds = new List<Lead>();
    
    // Start method to return query locator
       global Database.QueryLocator start(Database.BatchableContext bc)  {
         System.debug('Start Method');
         Integer currentYear = Date.today().year();
         String batchYearPrefix = String.valueOf(currentYear);        
           
         return Database.getQueryLocator([SELECT Id, Name,Mobilephone, CreatedDate, Status FROM Lead
                                              WHERE Status = 'Verified' AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_MONTH(CreatedDate) = 12
                                              AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_YEAR(CreatedDate) = :System.today().year())) LIMIT 20000]);

      
       }
     
    
 global void execute(Database.BatchableContext bc, List<Lead> contactList) {
     System.debug('Excute Method');
      try {                                     
            // Fetching template details
             String templateId = 'registration_verified_lead';
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

            // Iterate through contacts to create notifications
            for (Lead clist : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                notification.params.put('applicantname',clist.Name); 
                                
                // Add notification to map               
                if(clist.Mobilephone !=null){
                    String plusRemoved = clist.Mobilephone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});                    
                }    //Send Whatsapp notifications
             
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                //System.debug('Response=> '+response);
                if(response.getStatusCode() == 202){
                    this.successfulIds.add(clist);                    
                }else{
                    this.unsuccessfulIds.add(clist);
                } 
              
            }            
                System.debug('Batch4 SuccessFul Ids Size :'+this.successfulIds.size());
                System.debug('Batch4 SuccessFul Ids List :'+this.successfulIds);
                System.debug('Batch4 Un SuccessFul Ids Size :'+this.unsuccessfulIds.size());
                System.debug('Batch4 Un SuccessFul Ids List :'+this.unsuccessfulIds);
         
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }

    // Finish method 
    global void finish(Database.BatchableContext bc) {
         System.debug('Finish Method');      
    }    
}