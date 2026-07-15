global class HstlQuarterBulkNotifiSMS_WtsappQueueable {
    
    global class HostelQuarterWtsappBulkNotification implements System.Queueable, Database.AllowsCallouts {
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> localPhoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        Set<Id> reqIds = new Set<Id>();
        String requestType;
        
        // Constructor to initialize with phone numbers and their notifications
        global HostelQuarterWtsappBulkNotification(Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications,set<Id> reqIds, String requestType) {
            System.debug('reqIds------------------'+reqIds);
            this.localPhoneNumbersToNotifications = phoneNumbersToNotifications;
            this.reqIds = reqIds;
            this.requestType = requestType;
            System.debug('Constructor - inside HostelQuarter Whatsapp ' + this.localPhoneNumbersToNotifications);
            System.debug('reqIds-------eee-----------'+this.reqIds);
        }
        
        // Execute method that performs callouts to send WhatsApp notifications
        global void execute(QueueableContext context) {
            // Store the responses with phone numbers
            Map<String, HttpResponse> phoneNumberToResponseMap = new Map<String, HttpResponse>();
            
            System.debug('Execute Method - inside QueueableHostelBulkWhatsappNotification: ' + this.localPhoneNumbersToNotifications);
            
            // Iterate over the phone numbers
            for (String phoneNumber : this.localPhoneNumbersToNotifications.keySet()) {
                // Create a new map for each phone number and its notifications
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> singlePhoneNotificationMap = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
                singlePhoneNotificationMap.put(phoneNumber, this.localPhoneNumbersToNotifications.get(phoneNumber));
                
                System.debug('Processing phone number: ' + phoneNumber);
                
                try {
                    // Send WhatsApp notification for the current phone number
                    HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(singlePhoneNotificationMap);
                    // Store the response in the map
                    phoneNumberToResponseMap.put(phoneNumber, response);
                    
                    System.debug('Response for ' + phoneNumber + ': ' + response);
                } catch (Exception e) {
                    // Log the error if the request fails
                    System.debug('Error sending WhatsApp notification for ' + phoneNumber + ': ' + e.getMessage());
                }
            }
             System.debug('reqIds---'+this.reqIds);
            if(!this.reqIds.isEmpty()){
                System.debug('reqIds---'+this.reqIds);
                if(this.requestType == 'Hostel'){
                    HostelRequestStaffNotifications.sendHostelBulkSMS(this.reqIds);
                }
                else if (this.requestType == 'Quarter'){
                   QuartersRequestStaffNotifications.sendHostelBulkSMS(this.reqIds);  
                }
               
               
            }
            
            // Final debug log showing all responses
            System.debug('All responses from sendWhatsAppNotifications: ' + phoneNumberToResponseMap);
        }
    }
    
    
    
    
    global class HostelQuarterSMSBulkNotification implements System.Queueable, Database.AllowsCallouts {
        Map<String, List<SMS_API_Utility.shortMessageWrp>> messagesToSMSNotifications = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();        
        // Constructor to initialize with phone numbers and their notifications
        global HostelQuarterSMSBulkNotification(Map<String, List<SMS_API_Utility.shortMessageWrp>> messagesToSMSNotifications ) {
            this.messagesToSMSNotifications = messagesToSMSNotifications;
            System.debug('Constructor - inside messagesToSMSNotifications: ' + this.messagesToSMSNotifications);
        }
        
        // Execute method that performs callouts to send WhatsApp notifications
        global void execute(QueueableContext context) {
            
            System.debug('Execute Method - inside QueueableHostel SMS: ' + this.messagesToSMSNotifications);
            
            // Iterate over the phone numbers
            for (String singleMessage : this.messagesToSMSNotifications.keySet()) {
                // Create a new map for each phone number and its notifications
                System.debug('Processing phone number: ' + singleMessage);
                
                try {
                  
                   SMS_API_Utility.SendSMSOneToMany(singleMessage, this.messagesToSMSNotifications.get(singleMessage));
                    
                    System.debug('Response for sms ' + singleMessage );
                } catch (Exception e) {
                    // Log the error if the request fails
                    System.debug('Error sending SMS notification for ' + singleMessage + ': ' + e.getMessage());
                }
            }
            
        }
    }
    
}