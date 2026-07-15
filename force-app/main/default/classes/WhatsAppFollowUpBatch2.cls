global class WhatsAppFollowUpBatch2 implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    // Start method to return query locator
    global Database.QueryLocator start(Database.BatchableContext bc)  {
    //     System.debug('Start Method');
        // The list of active program Batches
       List<Fee_Master__c> activeProgBatchObjList = 
            [SELECT Program_Batch__c,Program_Batch__r.Name FROM Fee_Master__c WHERE IsActive__c =true AND Fee_Type__c ='Application Fee' AND Applicant_Category__c = 'Indian (SAARC)'];
        List<String> activeProgBatchList = new List<String>();
		
        // Query accepts string list so it is converted obj list to string list
        for(Fee_Master__c feeMaster : activeProgBatchObjList){
            if (feeMaster.Program_Batch__r != null) {
                activeProgBatchList.add(feeMaster.Program_Batch__c);
            }        	
    	}   
        
                
         Integer currentYear = Date.today().year();
         String batchYearPrefix = String.valueOf(currentYear); 
        
         System.debug('Application -->'+[SELECT hed__Applicant__r.Program_Batch__c,hed__Applicant__c,Application_Number__c,hed__Application_Status__c FROM hed__Application__c]);
        
   /*      system.debug('Batch2 RecordCount :'+[select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                                           where  hed__Applicant__r.Application_Fee_Paid__c = true  and hed__Applicant__r.Admission_Mode__c != null  and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant'
                                             and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Started' 
                                             AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)
                     OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size());
   */        
    /*       return Database.getQueryLocator(
               [select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,
                hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                where hed__Applicant__r.Program_Batch__c IN : activeProgBatchList AND hed__Applicant__r.Application_Fee_Paid__c = true 
                and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant'  
                and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Started'                
                AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)
                     OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))]);
           */
        return Database.getQueryLocator([SELECT id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c FROM hed__Application__c 
                                           WHERE hed__Applicant__r.Program_Batch__c IN : activeProgBatchList AND hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant'  and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Started'
                                         AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))]);
      	
       }
     
    
 global void execute(Database.BatchableContext bc, List<hed__Application__c> contactList) {  
      try {                                     
            // Fetching template details
             String templateId = 'submityourapplicationform_1'; 
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

            // Iterate through contacts to create notifications
            for (hed__Application__c clist : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
                notification.params.put('Applicantname',clist.hed__Applicant__r.name);                         
                
                // Add notification to map               
                if(clist.hed__Applicant__r.Mobilephone !=null){
                    String plusRemoved = clist.hed__Applicant__r.Mobilephone.replace('+', '');
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