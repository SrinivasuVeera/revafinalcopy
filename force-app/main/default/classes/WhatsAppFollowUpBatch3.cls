Global class WhatsAppFollowUpBatch3 implements Database.Batchable<sobject>, Database.AllowsCallouts {
    
    List<hed__Application__c> successfulIds = new List<hed__Application__c>();
    List<hed__Application__c> unsuccessfulIds = new List<hed__Application__c>();
    
    // Start method to return query locator
       global Database.QueryLocator start(Database.BatchableContext bc)  {
            System.debug('Start Method');
           
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
          	System.debug('Batch3 RecordCount:'+[select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                                           where hed__Applicant__r.Program_Batch__c IN : activeProgBatchList AND hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant' and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Incomplete'
                                          AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size());
           
           	return Database.getQueryLocator([select id, Application_Number__c,hed__Applicant__r.Mobilephone,hed__Applicant__r.name,hed__Application_Status__c,hed__Applicant__r.Application_Fee_Paid__c,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Program_Batch__c from hed__Application__c 
                                           where hed__Applicant__r.Program_Batch__c IN : activeProgBatchList AND hed__Applicant__r.Application_Fee_Paid__c = true and hed__Applicant__r.Admission_Mode__c != null and hed__Applicant__r.Program_Batch__c !=null and hed__Applicant__r.Record_Type_Name__c='Applicant' and hed__Applicant__r.Program_Batch__r.Name LIKE : '%'+batchYearPrefix+ '%' and hed__Application_Status__c='Incomplete'
                                          AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_MONTH(CreatedDate) = 12 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_YEAR(CreatedDate) = :System.today().year())) ]);
           
      
       }
     
    
 global void execute(Database.BatchableContext bc, List<hed__Application__c> contactList) {
     System.debug('Excute Method');
      try {
                                     
            // Fetching template details
           String templateId = 'completeyourapplicationform_11';
          
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
                //notification.params.put('Programname',clist.Primary_Academic_Program__r.Name);
                
                // Add notification to map
               // phoneNumbersToNotifications.put(clist.MobilePhone, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});
                if(clist.hed__Applicant__r.Mobilephone !=null){
                    String plusRemoved = clist.hed__Applicant__r.Mobilephone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});                    
                 }    //Send Whatsapp notifications
             
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
                if(response.getStatusCode() == 202){
                    this.successfulIds.add(clist);                    
                }else{
                    this.unsuccessfulIds.add(clist);
                }  
            }
          
          		System.debug('Batch3 SuccessFul Ids Size :'+this.successfulIds.size());
         		System.debug('Batch3 SuccessFul Ids List :'+this.successfulIds);
				System.debug('Batch3 Un-SuccessFul Ids Size :'+this.unsuccessfulIds.size());
         		System.debug('Batch3 Un-SuccessFul Ids List :'+this.unsuccessfulIds);
                    
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }

    // Finish method 
    global void finish(Database.BatchableContext bc) {
         System.debug('Finish Method');      
    }    
}