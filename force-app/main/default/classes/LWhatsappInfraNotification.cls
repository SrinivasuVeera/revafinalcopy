public class LWhatsappInfraNotification {

    public class InputParameters {
        @InvocableVariable(required=true)
        public List<String> recordIds;

        @InvocableVariable(required=true)
        public List<String> userIds;
       
        @InvocableVariable(required=true)
        public List<String> UserCheck;
    }
    
    
    @InvocableMethod(label='L Users Notifications')
    public static void processContacts(List<InputParameters> inputs) {
        List<Id> LUserId =inputs[0].userIds ;
        List<string> checkuser =inputs[0].UserCheck;
        system.debug('checkuser[0]:'+checkuser[0]);
        if(LUserId != Null &&  checkuser[0] != Null ){
          //  makeCalloutAsync(inputs[0].recordIds,LUserId,checkuser[0]);
            if(checkuser[0] == 'L1'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l1_',LUserId );
                 system.debug('checkuser##############:'+checkuser);
            }   if(checkuser[0] == 'L2'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l2_updated',LUserId );
                 system.debug('checkuser##################:'+checkuser);
            }  if(checkuser[0] == 'L3'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l3_copy',LUserId );
                system.debug('checkuser###################:'+checkuser);
            } if(checkuser[0] == 'L4'){
                L1UserMethod(inputs[0].recordIds, 'infrastructure_support_l4',LUserId );
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
            SELECT id, OwnerId,CreatedDate, CaseNumber, Description, INFRA_Category__c, INFRA_Sub_Category__c,Facility__c,Facility__r.Name

            FROM Case 
            WHERE id = :recordIds 
            LIMIT 1
        ];
        String formattedCreatedDate = caseRecord.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'IST');
    
        List<User> caseOwnerList = [SELECT Id,Name, Phone FROM User WHERE (contactId =:userId or id =:userId ) LIMIT 1];
        
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
                    if (metadata.Template_ID__c == 'infrastructure_support_l1_') {
                        if (key == 'L1_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Raised_by') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.INFRA_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.INFRA_Sub_Category__c);
                        } else if (key == 'facility') {
                            notification.params.put(key, caseRecord.Facility__r.Name);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), Label.NonTeachingFacultyURL);
                        }
                    }else if (metadata.Template_ID__c == 'infrastructure_support_l2_updated') {
                        if (key == 'L2_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        }  else if (key == 'Raised_by') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                           
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.INFRA_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.INFRA_Sub_Category__c);
                        } else if (key == 'facility') {
                            notification.params.put(key, caseRecord.Facility__r.Name);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), Label.NonTeachingFacultyURL);
                        }
                    }else if (metadata.Template_ID__c == 'infrastructure_support_l3_copy') {
                        if (key == 'L3_Support_Person') {
                            notification.params.put(key, caseOwner.Name);
                        }  else if (key == 'Raised_by') {
                            notification.params.put(key, caseOwner.Name);
                        } else if (key == 'Case_raised_date') {
                            notification.params.put(key, formattedCreatedDate);
                        } else if (key == 'Case_Number') {
                            notification.params.put(key, caseRecord.CaseNumber);
                        } else if (key == 'infra_category') {
                            notification.params.put(key, caseRecord.INFRA_Category__c);
                        } else if (key == 'infra_sub_category') {
                            notification.params.put(key, caseRecord.INFRA_Sub_Category__c);
                        } else if (key == 'facility') {
                            notification.params.put(key, caseRecord.Facility__r.Name);
                        } else if (key == 'Description') {
                            notification.params.put(key, caseRecord.Description);
                        } else if (key == 'Case_link') {
                            notification.params.put(key.trim(), Label.NonTeachingFacultyURL);
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
  
          
        }
          if (!phoneNumbersToNotifications.isEmpty()) {
                
                HttpResponse response = Yellow_AI_Utility.sendWhatsAppNotifications(phoneNumbersToNotifications);
                
            }
    }
    
    }