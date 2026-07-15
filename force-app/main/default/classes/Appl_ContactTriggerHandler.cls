public without sharing class Appl_ContactTriggerHandler {
    
    public static final string APPL_RT_NAME = 'Applicant';
    
    public static void applicantUserCreation(List<Contact> contactsList, Map<Id,Contact> oldMap){
        List<Contact> conRec = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        set<Id> batchContactIds = new Set<Id>();
        for (Contact c : contactsList){
            if (c.Record_Type_Name__c == 'Applicant' &&
                oldMap.get(c.id).Application_Fee_Paid__c != c.Application_Fee_Paid__c &&
                c.Application_Fee_Paid__c == true){
                    if (!System.isBatch()){ //Future methods cannot be called from batch
                        contactIds.add(c.Id);
                    }
                    else
                    {
                        batchContactIds.add(c.Id);
                    }
                }
        }
        
        
        /* Custom Metadata can be used to configure Test_Mode to avoid user creation during testing other features. */
        if(!contactIds.isEmpty() || !batchContactIds.isEmpty()){
            try{
                if(!contactIds.isEmpty()){
                    createApplicantUser(contactIds);
                }
                else if(!batchContactIds.isEmpty()){
                    conRec = [select id, Application_Fee_Paid__C,Record_Type_Name__c,MobilePhone,Country_Code__c,Application_Number__C from contact where Id IN : batchContactIds];
                    System.enqueueJob(new QueueableSendApplicationNumberSMS(conRec));
                    
                }
                
            }
            catch (Exception e){
                System.debug('Exception Error:'+ e);
            }
        }
    }
    
    @future
    public static void createApplicantUser(Set<Id> contactIds){
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = : 'Applicant Profile'].Id;
        Organization orgDetails = [Select Name, IsSandbox from Organization Limit 1];
        
        List<User> usersToBeCreated = new List<User>();
        List<User> usersToBeUpdated = new List<User>();
        
        List<Contact> contacts = [Select Id, FirstName, MiddleName, LastName, Email, Application_Number__c, Nick_Name__c,
                                  Record_Type_Name__c, Application_Fee_Paid__c, MobilePhone from Contact WHERE Id IN :contactIds];
        
        Set<String> emails = new Set<String>();
        
        for(Contact c : contacts){
            
            if(!String.isBlank(c.Email)){            
                emails.add(c.Email.trim().toLowerCase());
            }
        }
        
        Map<String, User> emailUserMap = new Map<String, User>();
        
        if(!emails.isEmpty()){
            
            for(User u : [SELECT Id,ContactId,FederationIdentifier,Username,Email,MobilePhone FROM User
                          WHERE Email IN :emails]){
                              
                              if(!String.isBlank(u.Email)){                
                                  emailUserMap.put(u.Email.trim().toLowerCase(),u);
                              }
                          }
        }
        
        for(Contact c : contacts){
            
            if(String.isBlank(c.Email)){
                continue;
            }
            
            String emailKey = c.Email.trim().toLowerCase();
            
            if(emailUserMap.containsKey(emailKey)){
                
                User existingUser = emailUserMap.get(emailKey);
                
                String archiveSuffix = '_old_' + String.valueOf(Datetime.now().getTime());
                String archivedEmail = c.Email;
                if(c.Email.contains('@')){
                    List<String> emailParts = c.Email.split('@');
                    archivedEmail = emailParts[0] + archiveSuffix + '@' + emailParts[1];
                }
                String archivedUsername = existingUser.Username;
                
                if(existingUser.Username.contains('@')){
                    List<String> userParts = existingUser.Username.split('@',2);
                    archivedUsername = userParts[0] + archiveSuffix + '@' + userParts[1];
                }
                
                existingUser.Username = archivedUsername;                
                existingUser.Email = archivedEmail;                
                existingUser.FederationIdentifier = archivedEmail;                
                existingUser.IsActive = false;                
                usersToBeUpdated.add(existingUser);                
                System.debug('Archived Existing User: ' + existingUser.Id);
            }
            
            User newUser = setUserInfo(c,profileId,orgDetails);        
            usersToBeCreated.add(newUser);
        }
        
        if(!usersToBeUpdated.isEmpty() && !Test.isRunningTest()){        
            update usersToBeUpdated;
        }
        
        if(!usersToBeCreated.isEmpty() && !Test.isRunningTest()){        
            insert usersToBeCreated;
        }   
        
    }
    private static User setUserInfo(Contact c, String profileId, Organization orgDetails){
        
        User applUser = new User();
        String userFullName = c.FirstName + c.LastName;
        
        applUser.FirstName = c.FirstName;
        applUser.MiddleName = c.MiddleName;
        applUser.LastName = c.LastName;
        applUser.ContactId = c.Id;
        applUser.ProfileId = profileId;
        applUser.Email = c.Email;
        applUser.MobilePhone = c.MobilePhone;
        applUser.TimeZoneSidKey = 'Asia/Kolkata'; // CAN BE SET ALSO BASED ON THE COUNTRY OF THE CONTACT
        applUser.LanguageLocaleKey = 'en_US';
        applUser.EmailEncodingKey = 'UTF-8';
        applUser.LocaleSidKey = 'en_IN';
        applUser.IsActive = true;
        applUser.CommunityNickname = c.Nick_Name__c + System.currentTimeMillis();
        applUser.FederationIdentifier = c.Email;
        applUser.UserPreferencesDisableMessageEmail = true;
        
        
        if(userFullName.length() > 8){
            applUser.alias = userFullName.substring(0,8);
        }
        else {
            applUser.alias = userFullName;
        }
        
        if(orgDetails.IsSandbox){
            applUser.Username = c.Application_Number__c+ '@' + 'reva.edu.in.' + orgDetails.Name.deleteWhiteSpace();
        }else{
            applUser.Username = c.Application_Number__c+ '@' + 'reva.edu.in';
        }
        
        return applUser;
    }
    
    public static void updateContactSource(Map<Id,Contact> oldContactMap, List<Contact> newContacts){
        
        for(Contact eachContact : newContacts){
            
            if(eachContact.Record_Type_Name__C == APPL_RT_NAME){
                // Making sure that the update is from the sync -- D0nt pass utmsource in the flow. (not for creatio nor for update)
                if (eachContact.pi__last_activity__c != oldContactMap.get(eachContact.Id).pi__last_activity__c) {
                    
                    
                    if ((eachContact.utm_source__c == '' || eachContact.utm_source__c == null) 
                        && eachContact.pi__first_touch_url__c !='' && (oldContactMap.get(eachContact.Id).pi__first_touch_url__c == '' || oldContactMap.get(eachContact.Id).pi__first_touch_url__c == null)) {
                            eachContact.utm_source__c = 'Organic';
                        }
                    else if ((eachContact.utm_source__c == '' || eachContact.utm_source__c == null) 
                             && eachContact.pi__first_touch_url__c == '' && (oldContactMap.get(eachContact.Id).pi__first_touch_url__c == '' || oldContactMap.get(eachContact.Id).pi__first_touch_url__c == null)) {
                                 eachContact.utm_source__c = 'Direct';
                             }
                    if (oldContactMap.get(eachContact.Id).utm_source__c != eachContact.utm_source__c) {
                        PardotSourceUtility.setSourcesOnContact(eachContact, oldContactMap.get(eachContact.Id)); 
                    }
                    
                }
            }
            
            
            
        }
    }
    
}