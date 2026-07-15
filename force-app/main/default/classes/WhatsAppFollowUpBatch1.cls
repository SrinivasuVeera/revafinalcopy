global class WhatsAppFollowUpBatch1 implements Database.Batchable<sobject>,Database.Stateful,Database.AllowsCallouts {
   
 //   List<Contact> successfulIds = new List<Contact>();
 //   List<Contact> unsuccessfulIds = new List<Contact>();
   		public Integer recordsProcessed = 0;
    // Start method to return query locator
        global Database.QueryLocator start(Database.BatchableContext bc) {
           
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
        
        System.debug('Batch1 Record Count:'+[SELECT Id, Name,Mobilephone, CreatedDate,Primary_Academic_Program__r.Name,Program_Batch_Name__c FROM Contact
                                              WHERE Program_Batch__c IN : activeProgBatchList AND Program_Batch_Name__c  LIKE : '%'+batchYearPrefix+ '%' AND Application_Fee_Paid__c = False AND Primary_Academic_Program__c != null AND Record_Type_Name__c = 'Applicant'
                                              AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_MONTH(CreatedDate) = 12
                                              AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))].size());
          
               
        return Database.getQueryLocator([SELECT Id, Name,Mobilephone, CreatedDate,Primary_Academic_Program__r.Name,Program_Batch_Name__c FROM Contact
                                              WHERE Program_Batch__c IN : activeProgBatchList AND Program_Batch_Name__c  LIKE : '%'+batchYearPrefix+ '%' AND Application_Fee_Paid__c = False AND Primary_Academic_Program__c != null AND Record_Type_Name__c = 'Applicant'
                                             AND ((CALENDAR_MONTH(CreatedDate) = 11 AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1)OR(CALENDAR_MONTH(CreatedDate) = 12
                                              AND CALENDAR_YEAR(CreatedDate) = :System.today().year() - 1) OR(CALENDAR_YEAR(CreatedDate) = :System.today().year()))]);
                    
   		}

    
 global void execute(Database.BatchableContext bc, List<Contact> contactList) {
     System.debug('Excute Method');
    try {                                     
            // Fetching template details
            String templateId = 'registrationfeepending_1';
            
            WhatsApp_Notification_Template__mdt metadata = [
                SELECT Template_Field__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :templateId 
                LIMIT 1
            ];
            
            // Map to store notifications for each contact's phone number
            Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

            // Iterate through contacts to create notifications
            for (Contact clist : contactList) {
                Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
                notification.templateId = templateId;
                notification.params = new Map<String, String>();
 				
                notification.params.put('applicantname', clist.name); 
                notification.params.put('programname', clist.Primary_Academic_Program__r.Name);
           //     notification.params.put('applicantname', 'Reva Test name'); 
          //      notification.params.put('programname', 'B.Tech in CS 2024');
                
                // Add notification to map               
                if(clist.Mobilephone !=null){
                    String plusRemoved = clist.Mobilephone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, new List<Yellow_AI_Utility.WhatsAppNotification>{notification});                 
                 }    //Send Whatsapp notifications
             
                System.debug('Phone Number -->'+clist.Mobilephone);
                
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
                if(response.getStatusCode() == 202){
                //    this.successfulIds.add(clist); 
                    recordsProcessed = recordsProcessed + 1;
                }else{
                //    this.unsuccessfulIds.add(clist);
                    recordsProcessed = recordsProcessed - 1;
                }  
            }      
         	/*	System.debug('Batch1 SuccessFul Ids Size :'+this.successfulIds.size());
         		System.debug('Batch1 SuccessFul Ids List :'+this.successfulIds);
				System.debug('Batch1 Un SuccessFul Ids Size :'+this.unsuccessfulIds.size());
         		System.debug('Batch1 Un SuccessFul Ids List :'+this.unsuccessfulIds); */
         
        } catch (Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        } 
    }

    // Finish method 
    global void finish(Database.BatchableContext bc) {
        System.debug('Finish Method');
        System.debug('Total whatsApp number sent :'+recordsProcessed);
    } 
}