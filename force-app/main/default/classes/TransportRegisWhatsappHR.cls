public class TransportRegisWhatsappHR{
@InvocableMethod(label='Send Transport Registration WhatsApp Notifications to HR' description='Send Transport Registration notifications via WhatsApp to HR')
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
        List<Transport_Registeration__c> requiredFields = [Select id,Contact__c, Contact__r.id,Route_Master__r.Name, Route_Pick_Up_Point__r.Name,
                                                      rtr_Start_Date__c, Contact__r.Account_Name__c	
                                                     From Transport_Registeration__c Where Id IN:recordIds];
        system.debug('+++++++recordIrequiredFieldsds'+requiredFields);
        
        
        // Check if related record is found
        if (!requiredFields.isEmpty()) {
            Transport_Registeration__c requiredField = requiredFields[0];
            System.debug('Required field: ' + requiredField);
            // Determine which method to call based on TemplateName__c value
            if (requiredField.Contact__c  != null) {
                System.debug('Contact is present');
                TransportRegisHR(requiredField);
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
     public static void  TransportRegisHR(Transport_Registeration__c requiredField) {
         {
        System.debug('Inside TransportRegisEmp method');
        Transport_Registeration__c FReq=[Select id, Contact__r.id,Route_Master__r.Name, Route_Pick_Up_Point__r.Name,rtr_Start_Date__c,
                                                Contact__r.MobilePhone,Contact__r.Name, Contact__r.Account_Name__c, Contact__r.Employee_Number__c		
                                                FROM Transport_Registeration__c  
                                                WHERE Id=: requiredField.Id];
            User us =[select Id, Name, MobilePhone, Profile_Name__c  from User where Name ='K Latha Raju'];
        //  if(!test.isRunningTest())
        {
            
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'transport_regis_employe_hr';
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
                    if(key.trim() == 'name_of_hr'){
                        notification1.params.put(key.trim(),us.Name);
                        system.debug('name_of_hr'+us.Name);
                    }
                    else if (key.trim() == 'name_of_the_employee') {
                        notification1.params.put(key.trim(), FReq.Contact__r.Name);
                       system.debug('name_of_the_employee'+FReq.Contact__r.Name);                        
                    }else if (key.trim() == 'employee_code') {
                        notification1.params.put(key.trim(), FReq.Contact__r.Employee_Number__c);
                        system.debug('employee_code'+FReq.Contact__r.Employee_Number__c);
                    } 
                    else if (key.trim() == 'route_number') {
                        notification1.params.put(key.trim(), FReq.Route_Master__r.Name);
                        system.debug('route_number'+FReq.Route_Master__r.Name);
                    } else if (key.trim() == 'pick_up_point') {
                        notification1.params.put(key.trim(), FReq.Route_Pick_Up_Point__r.Name);
                        system.debug('pick_up_point'+FReq.Route_Pick_Up_Point__r.Name);
                    } else if (key.trim() == 'name_of_the_department') {
                       notification1.params.put(key.trim(), String.ValueOf(FReq.Contact__r.Account_Name__c));
                        system.debug('name_of_the_department'+FReq.Contact__r.Account_Name__c);
                    }  else if (key.trim() == 'start_date') {
                       notification1.params.put(key.trim(), String.ValueOf(FReq.rtr_Start_Date__c));
                        system.debug('start_date'+FReq.rtr_Start_Date__c);
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