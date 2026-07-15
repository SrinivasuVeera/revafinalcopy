public class ReassignmentSendSMSANdWhatsapp {

    
    public static String ApplicantName;
    Public static string ApplicantOwnerName;
    Public static string ApplicantOwnerMobile;
    public static String PhoneNumber;
    public static String PhoneNumberownercon;
    public static String ContactApplicationNumber;
    public static String LeadName;
    Public static string LeadOwnerName;
    Public static string LeadOwnerMobile;
    public static String LeadPhoneNumber;
    public static String LeadApplicationNumber;
    public static String PhoneNumberownerlead;
    

     public static void handleOwnerChangeContact(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        List<Contact> contactsToUpdate = new List<Contact>();
         List<Id> contactIds = new List<Id>();
         Boolean Check = False;
        for (Contact con : newContacts) {
             if(con.Assigned__c == oldMap.get(con.Id).Assigned__c){
               
               if (con.OwnerId != oldMap.get(con.Id).OwnerId) {
              
                   contactsToUpdate.add(con);
             
                 }
            }       
        }
    
        if (!contactsToUpdate.isEmpty()) {
           
               for (Contact con : contactsToUpdate) {
                     contactIds.add(con.Id);
                if(con.Check_OwnerChnage__c == False){
                        Check = true;
                    }
            }
          
           System.enqueueJob(new QueueableBulkSMSNotification(contactIds));
            if(Check == true){
                SendWhatsApptoOwner(contactsToUpdate,'counselor_reassignment'); 
            }
           
        }
         
             }
    
        
 @Future(callout=true)
public static void makeCalloutAsyncContact( list<Id> Contacts) {
        list<contact> conlist=[select id,name,mobilephone,Assigned__c,Check_OwnerChnage__c, Application_Number__c,Owner.Name, Owner.Mobilephone from contact where id =:Contacts ];
    System.debug('conlist::'+conlist);
   List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); // Define messageList here
    List<Contact> contactsToUpdate = new List<Contact>();
    for(Contact sp:conlist){
         contactsToUpdate.add(sp);
      ApplicantName = sp.Name;
      ApplicantOwnerName = sp.owner.Name;
      ApplicantOwnerMobile=sp.Owner.MobilePhone;
        ContactApplicationNumber=sp.Application_Number__c;
        if(sp.mobilephone != null){
         String plusRemoved = sp.mobilephone.replace('+', '');
          String correctedWhatsappNumber = plusRemoved.replace('-', '');
            PhoneNumber = correctedWhatsappNumber;
        }if(sp.Owner.mobilephone != null){
         String plusRemoved = sp.Owner.mobilephone.replace('+', '');
          String correctedWhatsappNumber = plusRemoved.replace('-', '');
            PhoneNumberownercon = correctedWhatsappNumber;
        }
    if (!conlist.isEmpty()) {
            
            if (sp.Assigned__c == True) {
                ReAssignSmsContact(sp, messageList);
                if(sp.Check_OwnerChnage__c == false){
                ReAssignSmsContactOwner(sp, messageList);
               }
            }
     
    } else {
        System.debug('No related records found for the provided IDs');
    }
}
      if (!messageList.isEmpty()) {
          SMS_API_Utility.SendSMSOneToMany('Lead_Reassignment_Applicant', messageList);
          SMS_API_Utility.SendSMSOneToMany('Lead_Reassignment_Counsellor', messageList);
        }
    SendWhatsApptoApplicant(contactsToUpdate,'lead_reassignment'); 
   
}
  
  public static void ReAssignSmsContact(Contact Conset, List<SMS_API_Utility.shortMessageWrp> messageList) {
     
    String ApplicantName = ApplicantName;
    String ApplicantOwnerMobile=ApplicantOwnerMobile;
    String ApplicantOwnerName=ApplicantOwnerName;
    string phnNumber=PhoneNumber;
    String message = 'Dear ' + ApplicantName +  ',\n\nPlease be informed that your lead is being re-assigned to counsellor ' + ApplicantOwnerName + ' for further assistance.\n\nFor further process, kindly connect with \n'+ ApplicantOwnerName + '\n '+  ApplicantOwnerMobile + '.\n\nRegards.\nREVA University';
 
    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007307690992626076';
    shrtMessage.message = message;
    shrtMessage.recipient = phnNumber;
    messageList.add(shrtMessage);
}
 public static void ReAssignSmsContactOwner(Contact Conset, List<SMS_API_Utility.shortMessageWrp> messageList) {
     
    String ApplicantName = ApplicantName;
    String ApplicantOwnerMobile=ApplicantOwnerMobile;
    String ApplicantOwnerName=ApplicantOwnerName;
    string phnNumber=ApplicantOwnerMobile;
    String message = 'Dear ' + ApplicantOwnerName +  ',\n\nThis is to inform you that App No ' + ContactApplicationNumber + ' has been re-assigned to you.\n\n Kindly proceed with the needful.\n\nRegards.\nREVA University';
 
    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007028137269399166';
    shrtMessage.message = message;
    shrtMessage.recipient = phnNumber;
    messageList.add(shrtMessage);
}
 
    
    Public static void SendWhatsApptoApplicant(list<Contact> Contacts,String whatsappTemplateName){
          Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
          notification1.templateId = whatsappTemplateName;
          List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
          Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
       
        list<contact> conlist=[select id,name,mobilephone,Assigned__c,Check_OwnerChnage__c,Application_Number__c, Owner.Name, Owner.Mobilephone from contact where id =:Contacts ];
            notification1.params = new Map<String, String>();
        for(Contact con:conlist){
          
        if (con != null && con.OwnerId != null && con.Owner != null) {

             for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
               String[] keys = metadata.Template_Field__c.split(',');
                   
                 if(metadata.Template_ID__c == 'lead_reassignment') {
                     
                      for (String key : keys) {
                          if (key == 'Applicantname') {
                              notification1.params.put(key, con.Name);
                          }else if (key == 'NewCounselorName') {
                              notification1.params.put(key, con.Owner.Name);
                          }else if (key == 'NewcounselorMobileNumber') {
                              notification1.params.put(key, con.Owner.MobilePhone);
                          }
                      }
                 }
             
             }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   if(con.mobilephone !=null){
                        String plusRemoved = con.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                       system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                   }   
        }
        
    System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
     
    }
    
     Public static void SendWhatsApptoOwner(list<Contact> Contacts,String whatsappTemplateName){
          Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
          notification1.templateId = whatsappTemplateName;
          List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
          Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        list<contact> conlist=[select id,name,mobilephone,Assigned__c,Check_OwnerChnage__c,Application_Number__c, Owner.Name, Owner.Mobilephone from contact where id =:Contacts ];
            notification1.params = new Map<String, String>();
        for(Contact con:conlist){  
           
            if(con.Check_OwnerChnage__c == false){
        if (con != null && con.OwnerId != null && con.Owner != null) {

             for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
               String[] keys = metadata.Template_Field__c.split(',');
                   
                 if(metadata.Template_ID__c == 'counselor_reassignment') {
                     
                      for (String key : keys) {
                          if (key == 'newcounselor') {
                              notification1.params.put(key, con.Owner.Name);
                          }else if (key == 'Applicationnumber') {
                              notification1.params.put(key, con.Application_Number__c);
                          }
                      }
                 }
             
             }
            }
        }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   if(con.Owner.Mobilephone !=null){
                        String plusRemoved = con.Owner.Mobilephone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                       system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                   }   
        }
        
    System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
   
    }
    
  
    
//Lead Start    

  public static void handleOwnerChangeLead(List<LEad> newLeads, Map<Id, Lead> oldMap) {
        List<Lead> LeadsToUpdate = new List<Lead>();
         List<Id> LeadIds = new List<Id>();
       boolean check = False;
        for (Lead con : newLeads) {
            if(con.Assigned__c == oldMap.get(con.Id).Assigned__c){
            if (con.OwnerId != oldMap.get(con.Id).OwnerId) {
                LeadsToUpdate.add(con);
            }
            }       
        }
    
        if (!LeadsToUpdate.isEmpty()) {
            for (Lead con : LeadsToUpdate) {
                LeadIds.add(con.Id);
                if(con.Check_OwnerChnage__c == False){
                    check = true;
                }
            }
            
              System.enqueueJob(new QueueableBulkLeadSMSNotification(LeadIds));
            
            if( check == true){
                SendWhatsApptoLeadOwner(LeadsToUpdate,'counselor_reassignment');
            }
            
          
        }
    }
    
    
  @Future(callout=true)
  public static void makeCalloutAsyncLead( list<Id> Leads) {
    list<Lead> Leadlist=[select id,name,mobilephone,Assigned__c,Application_Number__c,Check_OwnerChnage__c, Owner.Name, Owner.Phone from Lead where id =:Leads ];
    List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>(); // Define messageList here
    System.debug('Leadlist::'+Leadlist);
    List<Lead> LeadsToUpdate = new List<Lead>();
    for(Lead sp:Leadlist){
          LeadsToUpdate.add(sp);
      LeadName = sp.Name;
      LeadOwnerName = sp.owner.Name;
      LeadApplicationNumber=sp.Application_Number__c;
      LeadOwnerMobile=sp.Owner.Phone;
        if(sp.mobilephone != null){
         String plusRemoved = sp.mobilephone.replace('+', '');
          String correctedWhatsappNumber = plusRemoved.replace('-', '');
            LeadPhoneNumber = correctedWhatsappNumber;
        system.debug('PhoneNumber:::'+LeadPhoneNumber);
        }if(sp.Owner.Phone != null){
         String plusRemoved = sp.Owner.Phone.replace('+', '');
          String correctedWhatsappNumber = plusRemoved.replace('-', '');
            PhoneNumberownerlead = correctedWhatsappNumber;
        }
    if (!Leadlist.isEmpty()) {
          
            if (sp.Assigned__c == True) {
                ReAssignSmsLead(sp, messageList);
                  if(sp.Check_OwnerChnage__c == false){
                ReAssignSmsLeadOwner(sp, messageList);
                  }
            }
      
    } else {
        System.debug('No related records found for the provided IDs');
    }
}
    if (!messageList.isEmpty()) {
            SMS_API_Utility.SendSMSOneToMany('Lead_Reassignment_Applicant', messageList);
            SMS_API_Utility.SendSMSOneToMany('Lead_Reassignment_Counsellor', messageList);
        }
     SendWhatsApptoLead(LeadsToUpdate,'lead_reassignment');
}
  
  public static void ReAssignSmsLead(Lead Conset, List<SMS_API_Utility.shortMessageWrp> messageList) {
     
    String ApplicantName = LeadName;
    String ApplicantOwnerMobile=LeadOwnerMobile;
    String ApplicantOwnerName=LeadOwnerName;
    string phnNumber=LeadPhoneNumber;
    String message = 'Dear ' + ApplicantName +  ',\n\nPlease be informed that your lead is being re-assigned to counsellor ' + ApplicantOwnerName + ' for further assistance.\n\nFor further process, kindly connect with \n'+ ApplicantOwnerName + '\n '+  ApplicantOwnerMobile + '.\n\nRegards.\nREVA University';
 
    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007307690992626076';
    shrtMessage.message = message;
    shrtMessage.recipient = phnNumber;
    messageList.add(shrtMessage);
}
    public static void ReAssignSmsLeadOwner(Lead Conset, List<SMS_API_Utility.shortMessageWrp> messageList) {
     
    String ApplicantName = LeadName;
    String ApplicantOwnerMobile=LeadOwnerMobile;
    String ApplicantOwnerName=LeadOwnerName;
    string phnNumber=LeadOwnerMobile;
    String message = 'Dear ' + ApplicantOwnerName +  ',\n\nThis is to inform you that App No ' + LeadApplicationNumber + ' has been re-assigned to you.\n\n Kindly proceed with the needful.\n\nRegards.\nREVA University';
 
    // Assuming you have a method to send SMS and you pass the message and phone number
    SMS_API_Utility.shortMessageWrp shrtMessage = new SMS_API_Utility.shortMessageWrp();
    shrtMessage.dltContentId = '1007028137269399166';
    shrtMessage.message = message;
    shrtMessage.recipient = phnNumber;
    messageList.add(shrtMessage);
}    

    Public static void SendWhatsApptoLead(list<Lead> Leads,String whatsappTemplateName){
          Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
          notification1.templateId = whatsappTemplateName;
          List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
          Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        list<Lead> Leadlist=[select id,name,MobilePhone,Assigned__c, Owner.Name, Owner.Phone from Lead where id =:Leads ];
            notification1.params = new Map<String, String>();
        for(Lead con:Leadlist){ 
        if (con != null && con.OwnerId != null && con.Owner != null) {

             for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
               String[] keys = metadata.Template_Field__c.split(',');
                   
                 if(metadata.Template_ID__c == 'lead_reassignment') {
                     
                      for (String key : keys) {
                          if (key == 'Applicantname') {
                              notification1.params.put(key, con.Name);
                          }else if (key == 'NewCounselorName') {
                              notification1.params.put(key, con.Owner.Name);
                          }else if (key == 'NewcounselorMobileNumber') {
                              notification1.params.put(key, con.Owner.Phone);
                          }
                      }
                 
             }
             }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   if(con.mobilephone !=null){
                    String plusRemoved = con.MobilePhone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                 system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                   }   
        }
        
             System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
         
    }
    
  Public static void SendWhatsApptoLeadOwner(list<Lead> Leads,String whatsappTemplateName){
          Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
          notification1.templateId = whatsappTemplateName;
          List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
          Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        list<Lead> Leadlist=[select id,name,MobilePhone,Assigned__c, Owner.Name, Owner.Phone,Application_Number__c from Lead where id =:Leads ];
            notification1.params = new Map<String, String>();
        for(Lead con:Leadlist){ 
        if (con != null && con.OwnerId != null && con.Owner != null) {

             for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
               String[] keys = metadata.Template_Field__c.split(',');
                   
                 if(metadata.Template_ID__c == 'counselor_reassignment') {
                     
                      for (String key : keys) {
                          if (key == 'newcounselor') {
                              notification1.params.put(key, con.Owner.Name);
                          }else if (key == 'Applicationnumber') {
                              notification1.params.put(key, con.Application_Number__c);
                          }
                      }
                 
             }
             }
            }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   if(con.Owner.Phone !=null){
                        String plusRemoved = con.Owner.Phone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                       system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                   }   
        }
        
          System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
       
    }
  
    
     Public static void SendWhatsApptoReassignedOwner(list<Contact> Contacts,String whatsappTemplateName){
          Yellow_AI_Utility.WhatsAppNotification notification1 = new Yellow_AI_Utility.WhatsAppNotification();
          notification1.templateId = whatsappTemplateName;
          List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :notification1.templateId];
          Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();
        
        list<contact> conlist=[select id,name,mobilephone,Assigned__c,Application_Fee_Paid_Date__c,Check_OwnerChnage__c,Application_Number__c,Program_Batch__r.Name , Owner.Name, Owner.Mobilephone from contact where id =:Contacts ];
            notification1.params = new Map<String, String>();
        for(Contact con:conlist){  
           
            if(con.Check_OwnerChnage__c == false){
        if (con != null && con.OwnerId != null && con.Owner != null) {

             for (WhatsApp_Notification_Template__mdt metadata : templateMetadata) {
               String[] keys = metadata.Template_Field__c.split(',');
                   
                 if(metadata.Template_ID__c == 'tat') {
                     
                      for (String key : keys) {
                          if (key == 'counsellor_name') {
                              notification1.params.put(key, con.Owner.Name);
                          }else if (key == 'Applicant_Name') {
                              notification1.params.put(key, con.Name);
                          }else if (key == 'Application_Number') {
                              notification1.params.put(key, con.Application_Number__c);
                          }else if (key == 'Program_Name') {
                              notification1.params.put(key, con.Program_Batch__r.Name );
                          }else if (key == 'Application_Fee_Paid_Date') {
                              notification1.params.put(key.trim(), String.valueOf(con.Application_Fee_Paid_Date__c));
                          }
                      }
                 }
             
             }
            }
        }
            List<Yellow_AI_Utility.WhatsAppNotification> notifications = new List<Yellow_AI_Utility.WhatsAppNotification>{notification1};
                   if(con.Owner.Mobilephone !=null){
                        String plusRemoved = con.Owner.Mobilephone.replace('+', '');
                    String correctedWhatsappNumber = plusRemoved.replace('-', '');
                    phoneNumbersToNotifications.put(correctedWhatsappNumber, notifications);
                       system.debug('PhoneNumber:::'+correctedWhatsappNumber);
                   }   
        }
        
    System.enqueueJob(new QueueableBulkWhatsappNotification(phoneNumbersToNotifications));
   
    }

}