public class LusersWhatsAppAndSMS {
    
   
    public class InputParameters {
        @InvocableVariable(required=true)
        public List<String> recordIds;

        @InvocableVariable(required=true)
        public List<String> userIds;
       
        @InvocableVariable(required=true)
        public List<String> UserCheck;
    }
    
    public static String ApplicantName;
    public static String Block;
    public static String Room;
    public static String Category;
    Public static string ApplicantOwnerName;
    Public static string ApplicantOwnerMobile;
    Public static String PhoneNumbersms;
    @InvocableMethod(label='L Users Notifications')
    public static void processContacts(List<InputParameters> inputs) {
        List<Id> LUserId =inputs[0].userIds ;
        List<string> checkuser =inputs[0].UserCheck;
        system.debug('checkuser[0]:'+checkuser[0]);
        if(LUserId != Null &&  checkuser[0] != Null ){
            makeCalloutAsync(inputs[0].recordIds,LUserId,checkuser[0]);
            if(checkuser[0] == 'L1'){
                L1UserMethod(inputs[0].recordIds, 'template_1_initial_complaint_l1_copy',LUserId );
            }   if(checkuser[0] == 'L2'){
                L1UserMethod(inputs[0].recordIds, 'template_2_escalation_to_l2_copy',LUserId );
            }  if(checkuser[0] == 'L3'){
                L1UserMethod(inputs[0].recordIds, 'template_3_escalation_to_l3_copy',LUserId );
            } if(checkuser[0] == 'L4'){
                L1UserMethod(inputs[0].recordIds, 'template_4_escalation_to_l4_copy',LUserId );
            }  
        }
    }
    
    @Future(callout=true)
    public static void L1UserMethod(List<string> recordIds, String whatsappTemplateName , list<Id> userId ) {
        List<Domain> domainList = [
            SELECT Id, DomainType, Domain, HttpsOption 
            FROM Domain 
            WHERE HttpsOption = 'CommunityAlt'
        ];
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        
        Case caseRecord = [
            SELECT id, Case_Contact_Name__c, SRN_Number__c,createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c, Hostel_Sub_Category__c, OwnerId 
            FROM Case 
            WHERE id = :recordIds 
            LIMIT 1
        ];
        String formattedCreatedDate = caseRecord.createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
        Contact contactRecord = [
            SELECT id, Name, SRN_Number__c 
            FROM Contact 
            WHERE SRN_Number__c = :caseRecord.SRN_Number__c 
            LIMIT 1
        ];
        
        Reva_Hostel_Request__c hostelRequest = [
            SELECT id, Reva_Hostel_Room__r.Name 
            FROM Reva_Hostel_Request__c 
            WHERE Hostel_Room_Request_For__c = :contactRecord.Id 
            LIMIT 1
        ];
        List<User> caseOwnerList = [SELECT Id,Name, Phone FROM User WHERE (contactId =:userId or id =:userId ) ];
        system.debug('caseOwnerList==>'+caseOwnerList);
        
        for (User caseOwner : caseOwnerList) {
            Yellow_AI_Utility.WhatsAppNotification notification = new Yellow_AI_Utility.WhatsAppNotification();
            notification.templateId = whatsappTemplateName;
            notification.params = new Map<String, String>();
            
            List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c 
                FROM WhatsApp_Notification_Template__mdt 
                WHERE Template_ID__c = :notification.templateId
            ];
            
            for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
                String[] keys = metadata.Template_Field__c.split(',');
                
                
                for (String key : keys) {
                    if (metadata.Template_ID__c == 'template_1_initial_complaint_l1_copy') {
                        if (key == 'L1_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Student_Name') {
                            notification.params.put(key, contactRecord.Name);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.Hostel_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.Hostel_Sub_Category__c);
                        } else if (key == 'SRN_Number') {
                            notification.params.put(key, caseRecord.SRN_Number__c);
                        } else if (key == 'Room_Number') {
                            notification.params.put(key, hostelRequest.Reva_Hostel_Room__r.Name);
                        } else if (key == 'Block_Name') {
                            notification.params.put(key, caseRecord.Hostel_Block__c);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), 'https://' + domainList[0].Domain+caseRecord.Id);
                        }
                    }else if (metadata.Template_ID__c == 'template_2_escalation_to_l2_copy') {
                        if (key == 'L2_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_Date') {
                            notification.params.put(key, formattedCreatedDate);
                        }else if (key == 'Student_Name') {
                            notification.params.put(key, contactRecord.Name);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.Hostel_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.Hostel_Sub_Category__c);
                        } else if (key == 'SRN_Number') {
                            notification.params.put(key, caseRecord.SRN_Number__c);
                        } else if (key == 'Room_Number') {
                            notification.params.put(key, hostelRequest.Reva_Hostel_Room__r.Name);
                        } else if (key == 'Block_Name') {
                            notification.params.put(key, caseRecord.Hostel_Block__c);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), 'https://' + domainList[0].Domain+caseRecord.Id);
                        }
                    }else if (metadata.Template_ID__c == 'template_3_escalation_to_l3_copy') {
                        if (key == 'L3_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_Date') {
                            notification.params.put(key, formattedCreatedDate);
                        }else if (key == 'Student_Name') {
                            notification.params.put(key, contactRecord.Name);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.Hostel_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.Hostel_Sub_Category__c);
                        } else if (key == 'SRN_Number') {
                            notification.params.put(key, caseRecord.SRN_Number__c);
                        } else if (key == 'Room_Number') {
                            notification.params.put(key, hostelRequest.Reva_Hostel_Room__r.Name);
                        } else if (key == 'Block_Name') {
                            notification.params.put(key, caseRecord.Hostel_Block__c);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), 'https://' + domainList[0].Domain+caseRecord.Id);
                        }
                    }else if (metadata.Template_ID__c == 'template_4_escalation_to_l4_copy') {
                        if (key == 'L4_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_Date') {
                            notification.params.put(key, formattedCreatedDate);
                        }else if (key == 'Student_Name') {
                            notification.params.put(key, contactRecord.Name);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.Hostel_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.Hostel_Sub_Category__c);
                        } else if (key == 'SRN_Number') {
                            notification.params.put(key, caseRecord.SRN_Number__c);
                        } else if (key == 'Room_Number') {
                            notification.params.put(key, hostelRequest.Reva_Hostel_Room__r.Name);
                        } else if (key == 'Block_Name') {
                            notification.params.put(key, caseRecord.Hostel_Block__c);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), 'https://' + domainList[0].Domain+caseRecord.Id);
                        }
                        
                    } 
                    
                    
                }
                
                List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification};
                    
                    if (caseOwner.Phone != null) {
                        String plusRemoved = caseOwner.Phone.replace('+', '');
                        String correctedWhatsappNumber = plusRemoved.replace('-', '');
                        
                        if (!phoneNumbersToNotifications.containsKey(correctedWhatsappNumber)) {
                            phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                        }
                        
                        
                    }
            }
            
            
            if (!phoneNumbersToNotifications.isEmpty()) {
                
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
            }
        }
    }
    
    
    @Future(callout=true)
    public static void makeCalloutAsync( List<string> recordIds, list<Id> userId, String checkUser ) {
        system.debug('caseRecord==rec>'+recordIds);
        system.debug('caseRecord==user>'+userId);
        system.debug('caseRecord==cuser>'+checkUser);
        system.debug('caseRecord==cr>'+[SELECT id, Case_Contact_Name__c, SRN_Number__c,createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c, Hostel_Sub_Category__c, OwnerId FROM Case
                           WHERE id = :recordIds 
                           LIMIT 1
                          ]);
        Case caseRecord = [SELECT id, Case_Contact_Name__c, SRN_Number__c,createdDate, CaseNumber, Hostel_Block__c, Description, Hostel_Category__c, Hostel_Sub_Category__c, OwnerId FROM Case
                           WHERE id = :recordIds 
                           LIMIT 1
                          ];  
       
        String formattedCreatedDate = caseRecord.createdDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
        Contact contactRecord = [
            SELECT id, Name, SRN_Number__c 
            FROM Contact 
            WHERE SRN_Number__c = :caseRecord.SRN_Number__c 
            LIMIT 1
        ];
        
        Reva_Hostel_Request__c hostelRequest = [
            SELECT id, Reva_Hostel_Room__r.Name 
            FROM Reva_Hostel_Request__c 
            WHERE Hostel_Room_Request_For__c = :contactRecord.Id 
            LIMIT 1
        ];
        List<User> caseOwnerList = [SELECT Id,Name, Phone FROM User WHERE (contactId =:userId or id =:userId ) ];
        
        ApplicantName = contactRecord.Name;
        ApplicantOwnerMobile = caseOwnerList[0].Phone;
        ApplicantOwnerName = caseOwnerList[0].Name;
        Block = caseRecord.Hostel_Block__c;
        Room = hostelRequest.Reva_Hostel_Room__r.Name;
        Category = caseRecord.Hostel_Category__c;
        
        if(ApplicantOwnerMobile != null){
            String plusRemoved = ApplicantOwnerMobile.replace('+', '');
            String correctedWhatsappNumber = plusRemoved.replace('-', '');
            PhoneNumbersms = correctedWhatsappNumber;
        }
        if (caseRecord != Null) {
            List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();
            system.debug('Hello'+checkUser);
            
            if(checkUser == 'L1'){
                SmsApplicantl1(caseRecord , messageList);
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('L1_Notification', messageList); 
                }
            }else if(checkUser == 'L2' || checkUser == 'L3' ||checkUser == 'L4'){   
                system.debug('Hello'+checkUser);
                SmsApplicantL2(caseRecord , messageList);
                if (!messageList.isEmpty()) {
                    SMS_API_Utility.SendSMSOneToMany('LuserNotifiation', messageList);   
                }
            }
            
        }
    }
    
    public static void SmsApplicantL1(Case stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        
        String message = 'Dear ' + ApplicantOwnerName +  ',\nNew Support request from ' + ApplicantName + ' in Room: ' + Room + ', at Block: ' + Block + ' , Category: ' + Category + '.\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007346548700801624';
        shrtMessage.message = message;
        shrtMessage.recipient = PhoneNumbersms;
        messageList.add(shrtMessage);
    }
    public static void SmsApplicantL2(Case stuPaySet, List<SMS_API_Utility.shortMessageWrp> messageList) {
        
        String message = 'Dear ' + ApplicantOwnerName +  ',\nSupport request from ' + ApplicantName + ' in Room: ' + Room + ', at Block: ' + Block + ', Category: ' + Category + ' Hence it is escalated to you.\nREVA University';
        SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
        shrtMessage.dltContentId = '1007760957230554775';
        shrtMessage.message = message;
        shrtMessage.recipient = PhoneNumbersms;
        messageList.add(shrtMessage);
    } 
    
}