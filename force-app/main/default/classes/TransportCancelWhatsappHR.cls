public class TransportCancelWhatsappHR{
@InvocableMethod(label='Send Transport Cancel WhatsApp Notifications to HR' description='Send Transport cancel notifications via WhatsApp to HR')
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
        List<RTR_Reva_Transport_Request__c> requiredFields = [Select id,RTR_Student__r.Name, RecordType.Name, RTR_Student__r.MobilePhone,
                                                              RTR_Student__r.Employee_Number__c,RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name,
                                                              RTR_Route_Pick_Up_Point__r.Name, RTR_Student__r.Account_Name__c


                                                     From RTR_Reva_Transport_Request__c Where Id IN:recordIds];
        system.debug('+++++++recordIrequiredFieldsds'+requiredFields);
        
        
        // Check if related record is found
        if (!requiredFields.isEmpty()) {
            RTR_Reva_Transport_Request__c requiredField = requiredFields[0];
            System.debug('Required field: ' + requiredField);
            // Determine which method to call based on TemplateName__c value
            if (requiredField.RTR_Student__r.Name  != null) {
                System.debug('Contact is present');
                TransportRegisTransAdmin(requiredField);
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
     public static void  TransportRegisTransAdmin(RTR_Reva_Transport_Request__c requiredField) {
         {
        System.debug('Inside TransportRegisEmp method');
       RTR_Reva_Transport_Request__c FReq=[Select id,RTR_Student__r.Name, RecordType.Name, RTR_Student__r.MobilePhone,
                                                              RTR_Student__r.Employee_Number__c,RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name,
                                                              RTR_Route_Pick_Up_Point__r.Name, RTR_Student__r.Account_Name__c		
                                                From RTR_Reva_Transport_Request__c  
                                                WHERE Id=: requiredField.Id];
            User us =[select Id, Name, MobilePhone, Profile_Name__c  from User where Name ='K Latha Raju'];
        //  if(!test.isRunningTest())
        {
            
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'transport_cancel_notif_hr';
            String phoneNumber = us.MobilePhone;
            system.debug('phoneNumber'+phoneNumber);
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
                    if(key.trim() == 'name_of_the_hr'){
                        notification1.params.put(key.trim(),us.Name);
                        system.debug('name_of_the_hr'+us.Name);
                    }
                    else if (key.trim() == 'name_of_the_employee') {
                        notification1.params.put(key.trim(), FReq.RTR_Student__r.Name);
                       system.debug('name_of_the_employee'+FReq.RTR_Student__r.Name);                        
                    }else if (key.trim() == 'employee_code') {
                        notification1.params.put(key.trim(), FReq.RTR_Student__r.Employee_Number__c);
                        system.debug('employee_code'+FReq.RTR_Student__r.Employee_Number__c); 

                    } 
                    else if (key.trim() == 'route_number') {
                        notification1.params.put(key.trim(), FReq.RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name);
                        system.debug('route_number'+FReq.RTR_Route_Pick_Up_Point__r.RTR_Route_Master__r.Name);
                    } else if (key.trim() == 'pick_up_point') {
                        notification1.params.put(key.trim(), FReq.RTR_Route_Pick_Up_Point__r.Name);
                        system.debug('pick_up_point'+FReq.RTR_Route_Pick_Up_Point__r.Name);
                    } else if (key.trim() == 'department_name') {
                       notification1.params.put(key.trim(), String.ValueOf(FReq.RTR_Student__r.Account_Name__c));
                        system.debug('department_name'+FReq.RTR_Student__r.Account_Name__c);
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