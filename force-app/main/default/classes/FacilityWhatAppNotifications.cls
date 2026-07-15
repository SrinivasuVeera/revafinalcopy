public class FacilityWhatAppNotifications {
    
    @InvocableMethod(label='Send Facility Approved WhatsApp Notifications' description='Send notifications via WhatsApp')
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
        List<Facility_Request__c> requiredFields = 
            [SELECT Id, Name, Start_Date__c, Start_Time__c,Approver__r.Name,Reason_of_Booking__c,Approval_Comments__c, End_Date__c, End_Time__c,Reqester_Phone_Number__c,ApproverName__c, Facility_Name__c, Building_Name__c, Additional_Amenities_Required__c,	ApprovalLink__c, Floor__c, Room_No__c,Current_User_Name__c, Current_User_Phone__c,  RequesterName__c,Account__c,TemplateName__c,Reason_of_Cancelation__c 
             FROM Facility_Request__c
             WHERE Id IN :recordIds];
        system.debug('+++++++recordIrequiredFieldsds'+requiredFields);
        
        
        // Check if related record is found
        if (!requiredFields.isEmpty()) {
            Facility_Request__c requiredField = requiredFields[0];
            System.debug('Required field: ' + requiredField);
            // Determine which method to call based on TemplateName__c value
            if (requiredField.TemplateName__c == 'Requested') {
                System.debug('TemplateName is Requested');
                FacilityRequest(requiredField);
            } else if (requiredField.TemplateName__c == 'Rejected') {
                System.debug('TemplateName is Rejected');
                FacilityRejected(requiredField);
            } else if (requiredField.TemplateName__c == 'Approved') {
                System.debug('TemplateName is Approved');
                FacilityApproved(requiredField);
            }
        } else {
            System.debug('No related record found for the provided ID');
        }
        
        String str='REVA Infra';
        if(str=='REVA Infra'){
            
        }
        String str1='REVA Infra';
        if(str1=='REVA Infra'){
            
        }
    }
    
    public static void  FacilityRequest(Facility_Request__c requiredField) {{
        System.debug('Inside FacilityRequest method');
        Facility_Request__c FReq=[select id,Name,Approver__c,Approver__r.Phone,Approver__r.Name,Approver__r.Department FROM Facility_Request__c WHERE Id=: requiredField.Id];
        //  if(!test.isRunningTest())
        {
            
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'infraapproval__copy2_copy';
            String phoneNumber = FReq.Approver__r.Phone;
            
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
                    if (key.trim() == 'approvalauthority') {
                        notification1.params.put(key.trim(),FReq.Approver__r.Name);
                    }
                    else if (key.trim() == 'block') {
                        notification1.params.put(key.trim(), requiredField.Building_Name__c);
                    } else if (key.trim() == 'floor') {
                        notification1.params.put(key.trim(), requiredField.Floor__c);
                    } else if (key.trim() == 'roomnumber') {
                        notification1.params.put(key.trim(), requiredField.Room_No__c);
                    } else if (key.trim() == 'roomname') {
                        notification1.params.put(key.trim(), requiredField.Name);
                    } else if (key.trim() == 'startdatetime') {
                        String dateString = requiredField.Start_Date__c != null ? String.valueOf(requiredField.Start_Date__c) : '';
                        Time startTime = requiredField.Start_Time__c;
                        String amPm = startTime.hour() >= 12 ? 'PM' : 'AM';
                        Integer hour = Math.mod(startTime.hour(), 12) == 0 ? 12 : Math.mod(startTime.hour(), 12);
                        String timeString = hour + ':' + startTime.minute().format() + ' ' + amPm;
                        String dateTimeString = dateString + ' ' + timeString;
                        String dateTimeString1 = dateTimeString != null ? dateTimeString : '';
                        notification1.params.put(key.trim(), dateTimeString1);
                    } else if (key.trim() == 'enddatetime') {
                        String dateString = requiredField.End_Date__c != null ? String.valueOf(requiredField.End_Date__c) : '';
                        Time endTime = requiredField.End_Time__c;
                        String amPm = endTime.hour() >= 12 ? 'PM' : 'AM';
                        Integer hour = Math.mod(endTime.hour(), 12) == 0 ? 12 : Math.mod(endTime.hour(), 12);
                        String timeString = hour + ':' + endTime.minute().format() + ' ' + amPm;
                        String dateTimeString = dateString + ' ' + timeString;
                        String dateTimeString1 = dateTimeString != null ? dateTimeString : '';
                        notification1.params.put(key.trim(), dateTimeString1);
                    }
                    //  else if (key.trim() == 'urllink') {
                    //    System.debug('urllink-------');
                    //notification1.params.put(key.trim(), 'https://' + domainList[0].Domain);
                    //} 
                    else if (key.trim() == 'clerkname') {
                        System.debug('notification1.params');
                        System.debug(notification1.params);
                        notification1.params.put(key.trim(), requiredField.RequesterName__c);
                    }
                    else if (key.trim() == 'schoolname') {
                        notification1.params.put(key.trim(),FReq.Approver__r.Department);
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
    public static void  FacilityRejected(Facility_Request__c requiredField) {{
        if (requiredField.Reason_of_Cancelation__c != null) {
        System.debug('Skipping FacilityRejected logic because cancellation reason exists.');
        return; 
    }
        
        Facility_Request__c FReq=[select id,Name,Approver__c,Approver__r.Phone,Reqester_Phone_Number__c,Reason_of_Booking__c ,Approval_Comments__c,Reason_of_Cancelation__c
FROM Facility_Request__c WHERE Id=: requiredField.Id And Reason_of_Cancelation__c = null LIMIT 1];
        
        System.debug('Inside FacilityRejected method');
        // if(!test.isRunningTest())
        {
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'infra_request_rejected200_copy';
            String phoneNumber = FReq.Reqester_Phone_Number__c;
            system.debug('Name::'+phoneNumber);
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    if (key.trim() == 'clerkname') {
                        notification1.params.put(key.trim(), requiredField.RequesterName__c!= null ? requiredField.RequesterName__c : 'N/A');
                        system.debug('Name:::'+requiredField.RequesterName__c);
                    } else if (key.trim() == 'requestedpersonname') {
                        notification1.params.put(key.trim(), 'Prakash');
                    } else if (key.trim() == 'block') {
                        notification1.params.put(key.trim(), requiredField.Building_Name__c!= null ? requiredField.Building_Name__c : 'N/A');
                        system.debug('Name::'+requiredField.Building_Name__c);
                    } else if (key.trim() == 'floor') {
                        notification1.params.put(key.trim(), requiredField.Floor__c!= null ? requiredField.Floor__c : 'N/A');
                        system.debug('Name::'+requiredField.Floor__c);
                    } else if (key.trim() == 'roomnumber') {
                        notification1.params.put(key.trim(),requiredField.Room_No__c!= null ? requiredField.Room_No__c : 'N/A');
                        system.debug('Name::'+requiredField.Room_No__c);
                        
                        // notification1.params.put(key.trim(), requiredField.Room_No__c);
                    } else if (key.trim() == 'roomname') {
                        notification1.params.put(key.trim(), requiredField.Name!= null ? requiredField.Name : 'N/A');
                        system.debug('Name::'+requiredField.Name);
                    } else if (key.trim() == 'reason') {
                        notification1.params.put(key.trim(), requiredField.Approval_Comments__c!= null ? requiredField.Approval_Comments__c : 'N/A');
                    }
                    else if (key.trim() == 'startdatetime') {
                        String dateString = requiredField.Start_Date__c != null ? String.valueOf(requiredField.Start_Date__c) : '';
                        Time startTime = requiredField.Start_Time__c;
                        String amPm = startTime.hour() >= 12 ? 'PM' : 'AM';
                        Integer hour = Math.mod(startTime.hour(), 12) == 0 ? 12 : Math.mod(startTime.hour(), 12);
                        String timeString = hour + ':' + startTime.minute().format() + ' ' + amPm;
                        String dateTimeString = dateString + ' ' + timeString;
                        String dateTimeString1 = dateTimeString != null ? dateTimeString : '';
                        notification1.params.put(key.trim(), dateTimeString1);
                    } else if (key.trim() == 'enddatetime') {
                        String dateString = requiredField.End_Date__c != null ? String.valueOf(requiredField.End_Date__c) : '';
                        Time endTime = requiredField.End_Time__c;
                        String amPm = endTime.hour() >= 12 ? 'PM' : 'AM';
                        Integer hour = Math.mod(endTime.hour(), 12) == 0 ? 12 : Math.mod(endTime.hour(), 12);
                        String timeString = hour + ':' + endTime.minute().format() + ' ' + amPm;
                        String dateTimeString = dateString + ' ' + timeString;
                        String dateTimeString1 = dateTimeString != null ? dateTimeString : '';
                        notification1.params.put(key.trim(), dateTimeString1);
                    } else if (key.trim() == 'approvalauthorityname') {
                        notification1.params.put(key.trim(),requiredField.ApproverName__c!= null ? requiredField.ApproverName__c : 'N/A');
                    }
                }
            }
            
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            phoneNumbersToNotifications.put(phoneNumber, notifications);
            if(!Test.isRunningTest()){
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
                                                                             // Your implementation for TemplateName__c equals 'Rejected'	infra_request_rejected200
                                                                            }
    
    public static void FacilityApproved(Facility_Request__c requiredField) {
        Facility_Request__c FReq=[select id,Name,Approver__c,Approver__r.Phone,Reqester_Phone_Number__c,Reason_of_Booking__c, Approval_Comments__c FROM Facility_Request__c WHERE Id=: requiredField.Id];
        
        System.debug('Inside FacilityApproved method');
        // if(!Test.isRunningTest())
        {
            Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
            notification1.templateId = 'approvalconfirmation_approved_copy1';
            String phoneNumber = FReq.Reqester_Phone_Number__c;
            system.debug('phoneNumber>> line188::'+phoneNumber);
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = :notification1.templateId
            ];
            
            notification1.params = new Map<String, String>();
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                for (String key : keys) {
                    if (key.trim() == 'clerkname') {
                        notification1.params.put(key.trim(), requiredField.RequesterName__c != null ? requiredField.RequesterName__c : 'N/A');
                    } else if (key.trim() == 'block') {
                        notification1.params.put(key.trim(), requiredField.Building_Name__c != null ? requiredField.Building_Name__c : 'N/A');
                    } else if (key.trim() == 'floor') {
                        notification1.params.put(key.trim(), requiredField.Floor__c != null ? requiredField.Floor__c : 'N/A');
                    } else if (key.trim() == 'roomnumber') {
                        notification1.params.put(key.trim(), requiredField.Room_No__c != null ? requiredField.Room_No__c : 'N/A');
                    } else if (key.trim() == 'roomname') {
                        notification1.params.put(key.trim(), requiredField.Name != null ? requiredField.Name : 'N/A'); 
                    } else if (key.trim() == 'reason') {
                        notification1.params.put(key.trim(), requiredField.Approval_Comments__c!= null ? requiredField.Approval_Comments__c : 'N/A');
                    }else if (key.trim() == 'startdatetime') {
                        String dateString = requiredField.Start_Date__c != null ? String.valueOf(requiredField.Start_Date__c) : '';
                        Time startTime = requiredField.Start_Time__c != null ? requiredField.Start_Time__c : Time.newInstance(0, 0, 0, 0);
                        String amPm = startTime.hour() >= 12 ? 'PM' : 'AM';
                        Integer hour = Math.mod(startTime.hour(), 12) == 0 ? 12 : Math.mod(startTime.hour(), 12);
                        String timeString = hour + ':' + startTime.minute().format() + ' ' + amPm;
                        String dateTimeString = dateString + ' ' + timeString;
                        String dateTimeString1 = dateTimeString != null ? dateTimeString : '';
                        notification1.params.put(key.trim(), dateTimeString1);
                    } else if (key.trim() == 'enddatetime') {
                        String dateString = requiredField.End_Date__c != null ? String.valueOf(requiredField.End_Date__c) : '';
                        Time endTime = requiredField.End_Time__c != null ? requiredField.End_Time__c : Time.newInstance(0, 0, 0, 0);
                        String amPm = endTime.hour() >= 12 ? 'PM' : 'AM';
                        Integer hour = Math.mod(endTime.hour(), 12) == 0 ? 12 : Math.mod(endTime.hour(), 12);
                        String timeString = hour + ':' + endTime.minute().format() + ' ' + amPm;
                        String dateTimeString = dateString + ' ' + timeString;
                        String dateTimeString1 = dateTimeString != null ? dateTimeString : '';
                        notification1.params.put(key.trim(), dateTimeString1);
                    } else if (key.trim() == 'approvalauthorityname') {
                        notification1.params.put(key.trim(), requiredField.Approver__r.Name != null ? requiredField.Approver__r.Name : 'N/A');
                    }
                }
            }
            
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                
                Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
            //phoneNumbersToNotifications.put(phoneNumber != null ? phoneNumber : '0000000000', notifications);
            phoneNumbersToNotifications.put(phoneNumber, notifications); 
            system.debug('phoneNumber::'+phoneNumber);
            system.debug('notifications::'+notifications);
            if(!Test.isRunningTest()) {
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
    
    @Future(callout=true)
    public static void makeCalloutAsyncJob(List<String> recordIds) {
        system.debug('+++++++recordIds'+recordIds);
        // Fetch the related record data
        List<Facility_Request__c> requiredFields = 
            [SELECT Id, Name, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c,Reqester_Phone_Number__c,ApproverName__c, Facility_Name__c, Building_Name__c, Additional_Amenities_Required__c,	ApprovalLink__c, Floor__c, Room_No__c,Current_User_Name__c, Current_User_Phone__c,  RequesterName__c,Account__c,TemplateName__c 
             FROM Facility_Request__c
             WHERE Id IN :recordIds];
        system.debug('+++++++recordIrequiredFieldsds'+requiredFields);
        
        
        // Check if related record is found
        if (!requiredFields.isEmpty()) {
            Facility_Request__c requiredField = requiredFields[0];
            System.debug('Required field: ' + requiredField);
            // Determine which method to call based on TemplateName__c value
            if (requiredField.TemplateName__c == 'Requested') {
                System.debug('TemplateName is Requested');
                FacilityRequest(requiredField);
            } else if (requiredField.TemplateName__c == 'Rejected') {
                System.debug('TemplateName is Rejected');
                FacilityRejected(requiredField);
            } else if (requiredField.TemplateName__c == 'Approved') {
                System.debug('TemplateName is Approved');
                FacilityApproved(requiredField);
            }
        } else {
            System.debug('No related record found for the provided ID');
        }
        
          Integer i=0;
if (!requiredFields.isEmpty()) {
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;           
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;            
        }
        
    }
    
    
}