public class RouteChangeWhatsappEmployee {

@InvocableMethod(label='Send Route Change WhatsApp Notifications' description='Send Route Change notifications via WhatsApp')
    public static void sendWhatsAppNotifications(List<String> recordIds) { 
        System.debug('Received record IDs: ' + recordIds);
        // Ensure that recordIds is not empty
        if (recordIds != null && !recordIds.isEmpty()) {
            System.debug('Record IDs list is not empty');
            makeCalloutAsync(recordIds);
        } else {
            System.debug('Record IDs list is empty or null');
        }
    }
     @Future(callout=true)
    public static void makeCalloutAsync(List<String> recordIds) {
        system.debug('+++++++recordIds'+recordIds);
        // Fetch the related record data
        List<RTR_Reva_Transport_Request__c> requiredFields = [Select id,RTR_Student__r.Name, RecordType.Name, RTRStudent_Faculty_NonFaculty__r.MobilePhone,
                                                              New_Route_Master__r.Name,RTRStudent_Faculty_NonFaculty__r.Name,	
                                                             New_Route_Pick_Up_Point__r.Name
                                                     From RTR_Reva_Transport_Request__c Where Id IN:recordIds];
        system.debug('+++++++recordIrequiredFieldsds'+requiredFields);
        
        
        // Check if related record is found
        if (!requiredFields.isEmpty()) {
            RTR_Reva_Transport_Request__c requiredField = requiredFields[0];
            System.debug('Required field: ' + requiredField);
            // Determine which method to call based on TemplateName__c value
            if (requiredField.RecordType.Name == 'Route Change Request') {
                System.debug('TemplateName is Requested');
                RouteChangeEmp(requiredField);
            }
        } 
         else {
            System.debug('No related record found for the provided ID');
        }
        
        String str='REVA Infra';
        if(str=='REVA Infra'){
            
        }
        String str1='REVA Infra';
        if(str1=='REVA Infra'){
            
        }
    }
     public static void  RouteChangeEmp(RTR_Reva_Transport_Request__c requiredField) {
         {
        System.debug('Inside TransportRegisEmp method');
        RTR_Reva_Transport_Request__c FReq=[Select id,RTR_Student__r.Name, RecordType.Name,RTRStudent_Faculty_NonFaculty__r.MobilePhone	,
                                                New_Route_Master__r.Name, RTRStudent_Faculty_NonFaculty__r.Name,	
                                                New_Route_Pick_Up_Point__r.Name
                                                From RTR_Reva_Transport_Request__c  
                                                WHERE Id=: requiredField.Id];
        //  if(!test.isRunningTest())
        {
            
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'transport_route_change_employee';
            String phoneNumber = FReq.RTRStudent_Faculty_NonFaculty__r.MobilePhone;
            
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    system.debug(key);
                    if (key.trim() == 'name_of_the_employee') {
                        notification1.params.put(key.trim(),FReq.RTRStudent_Faculty_NonFaculty__r.Name);
                    }else if (key.trim() == 'route_number') {
                        notification1.params.put(key.trim(), FReq.New_Route_Master__r.Name);
                    } else if (key.trim() == 'pick_up_point') {
                        notification1.params.put(key.trim(), FReq.New_Route_Pick_Up_Point__r.Name);
                    }
                    
                } 
            }
            
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(phoneNumber, notifications);
            
            if(!test.isrunningTest()){
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                System.debug('WhatsApp notification response: ' + response);}
            else{
                String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
                HTTPResponse res = new HTTPResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody(fullJson);
                res.setStatusCode(200);
            }
            
        }
    }
  }
    

}