public class AccountEmailHelper {
    private static List<String> recipientEmails = new List<String>{
        'jyotiranjan.panda@reva.edu.in',
        'harshitha.bg@reva.edu.in',
        'rashmi.n@reva.edu.in',
        'shinil.tp@reva.edu.in',
        'velpulagunavardan.reddy@reva.edu.in',
        'nagineni.chaithanya@reva.edu.in'
            };
                private static Map<String, Id> recordTypeMap;
    
    static {
        recordTypeMap = new Map<String, Id>();
        recordTypeMap.put('Academic Program', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId());
        recordTypeMap.put('Educational Institution', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId());
        recordTypeMap.put('University Department', Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId());
    }
    public static void handleInsert(List<Account> newAccounts) {
        System.debug('Handling Insert');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
        
        Set<Id> parentIds = new Set<Id>();
        for (Account newAccount : newAccounts) {
            parentIds.add(newAccount.ParentId);
        }
        
        Map<Id, String> parentNames = new Map<Id, String>();
        for (Account parent : [SELECT Id, Name FROM Account WHERE Id IN :parentIds]) {
            parentNames.put(parent.Id, parent.Name);
        }
        for (String recipientEmail : recipientEmails) {
            for (Account newAccount : newAccounts) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{recipientEmail}); 
                email.setSubject('New Account Created');
                
                
                Boolean sendEmail = false;
                if (isRecordTypeSupported(newAccount.RecordTypeId)) {
                    sendEmail = true;
                }
                if (sendEmail) {
                    String parentNameNew = getParentName(newAccount.ParentId);
                    String createdBy;
                    if (newAccount.CreatedById != null) {
                        User creator = [SELECT Name FROM User WHERE Id = :newAccount.CreatedById LIMIT 1];
                        createdBy = creator.Name;
                    } else {
                        createdBy = 'Unknown'; 
                    }
                    String currentDateTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', 'Asia/Kolkata'); // Change the timezone as needed
                    String body = 'Dear Team, Account created by: ' + createdBy +' (Date and Time: '+currentDateTime+ ')<br/>'+'<br/>';
                    Id recordTypeId = newAccount.RecordTypeId;
                    if (recordTypeMap.containsKey('Academic Program') && recordTypeMap.get('Academic Program') == recordTypeId) {
                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                        body += 'Account Name: ' + newAccount.Name + '<br/>';
                        body += 'Display Name (Program): ' + newAccount.Display_Name_Program__c + '<br/>';
                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                        body += 'Record Type: ' + recordTypeName + '<br/>';
                        body += 'Program Alias: ' + newAccount.Program_Alias__c + '<br/>'; 
                        body += 'Program code: ' + newAccount.Program_Code__c + '<br/>';
                        body += 'Program Type: ' + newAccount.Program_Type__c + '<br/>';
                        body += 'No of Years: ' + newAccount.No_of_Years__c + '<br/>';
                        body += 'Number of Semesters: ' + newAccount.Number_of_Semesters__c + '<br/>';
                        body += 'ParentId: ' + parentNameNew + '<br/>';
                        body += 'Intake: ' + newAccount.Intake__c + '<br/>';
                        body += 'Intake Per Section: ' + newAccount.Intake_Per_Section__c + '<br/>';
                        body += 'Number of Batches: ' + newAccount.Number_of_Batches__c + '<br/>';
                        body += 'Description: ' + newAccount.Description + '<br/>';
                    } else if (recordTypeMap.containsKey('Educational Institution') && recordTypeMap.get('Educational Institution') == recordTypeId) {
                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                        body += 'Account Name: ' + newAccount.Name + '<br/>';
                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                        body += 'Record Type: ' + recordTypeName + '<br/>';
                        body += 'ParentId: ' + parentNameNew + '<br/>';
                        body += 'Sequence: ' + newAccount.Sequence__c + '<br/>';
                    }else if (recordTypeMap.containsKey('University Department') && recordTypeMap.get('University Department') == recordTypeId) {
                        body += 'Account ID: ' + newAccount.Id + '<br/>';
                        body += 'Account Name: ' + newAccount.Name + '<br/>';
                        String recordTypeName = [SELECT Name FROM RecordType WHERE Id = :newAccount.RecordTypeId].Name;
                        body += 'Record Type: ' + recordTypeName + '<br/>';
                        body += 'ParentId: ' + parentNameNew + '<br/>';
                        body += 'Sequence: ' + newAccount.Sequence__c + '<br/>';
                        body += 'School Head: ' + newAccount.School_Head__c + '<br/>';
                        body += 'Vertical Head: ' + newAccount.Vertical_Head__c + '<br/>';
                        body += 'SLCM - HCM ID: ' + newAccount.SLCM_HCM_ID__c + '<br/>';
                    }
                    email.setHtmlBody(body);
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                    emails.add(email);
                }
            }
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void handleUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        if (!newAccounts.isEmpty()) {
            List<Account> updatedAccounts = new List<Account>();
            
            for (Account newAccount : newAccounts) {
                Account oldAccount = oldAccountMap.get(newAccount.Id);
                
                // Check if the account is truly updated
                if (oldAccount != null && isRecordTypeSupported(newAccount.RecordTypeId) && isAccountUpdated(newAccount, oldAccount)) {
                    updatedAccounts.add(newAccount);
                }
            }
            
            // Send email only if there are truly updated accounts
            if (!updatedAccounts.isEmpty()) {
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
                
                for (String recipientEmail : recipientEmails) {
                    for (Account updatedAccount : updatedAccounts) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] {recipientEmail});
                        email.setSubject('Account Updated');
                        
                        String lastModifiedByName = '';
                        if (updatedAccount != null && updatedAccount.LastModifiedById != null) {
                            User lastModifiedUser = [SELECT Name FROM User WHERE Id = :updatedAccount.LastModifiedById LIMIT 1];
                            if (lastModifiedUser != null) {
                                lastModifiedByName = lastModifiedUser.Name;
                            }
                        }
                        
                        String currentDateTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', 'Asia/Kolkata'); 
                        String body = 'Dear Team, Account updated by: ' + lastModifiedByName +' (Date and Time: '+currentDateTime+ ')<br/>'+'<br/>';
                        body += 'Account ID: ' + updatedAccount.Id + '<br/>';
                        body += 'Account Name: ' + updatedAccount.Name + '<br/>'+'<br/>';
                        body += getUpdatedFieldsDetails(updatedAccount);
                        email.setHtmlBody(body);
                        
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea[0].Id);
                        }
                        emails.add(email);
                    }
                }
                
                // Send the emails
                if (!emails.isEmpty()) {
                    Messaging.sendEmail(emails);
                }
            }
        }
    }
    
    private static Boolean isAccountUpdated(Account newAccount, Account oldAccount) {
        return newAccount.Name != oldAccount.Name || 
            newAccount.Display_Name_Program__c != oldAccount.Display_Name_Program__c ||
            newAccount.Program_Alias__c != oldAccount.Program_Alias__c ||
            newAccount.Program_Code__c != oldAccount.Program_Code__c ||
            newAccount.Program_Type__c != oldAccount.Program_Type__c ||
            newAccount.No_of_Years__c != oldAccount.No_of_Years__c ||
            newAccount.Number_of_Semesters__c != oldAccount.Number_of_Semesters__c ||
            newAccount.RecordTypeId != oldAccount.RecordTypeId ||
            newAccount.ParentId != oldAccount.ParentId ||
            newAccount.Intake__c != oldAccount.Intake__c ||
            newAccount.Intake_Per_Section__c != oldAccount.Intake_Per_Section__c ||
            newAccount.Number_of_Batches__c != oldAccount.Number_of_Batches__c ||
            newAccount.Description != oldAccount.Description ||
            newAccount.Sequence__c != oldAccount.Sequence__c ||
            newAccount.School_Head__c != oldAccount.School_Head__c ||
            newAccount.Vertical_Head__c != oldAccount.Vertical_Head__c ||
            newAccount.SLCM_HCM_ID__c != oldAccount.SLCM_HCM_ID__c;
    }
    private static String getUpdatedFieldsDetails(Account updatedAccount) {
        String details = '<b>Updated Fields:</b><br/>';
        
        if (Trigger.oldMap != null && Trigger.oldMap.containsKey(updatedAccount.Id)) {
            Map<Id, SObject> oldMap = Trigger.oldMap;
            Account oldAccount = (Account) oldMap.get(updatedAccount.Id);
            
            
            if (oldAccount != null) {   
                if (updatedAccount.Name != oldAccount.Name) {
                    details += 'Name: ' + oldAccount.Name + ' (old) => ' + updatedAccount.Name + ' (new)<br/>';
                }
                
                if (updatedAccount.Display_Name_Program__c != oldAccount.Display_Name_Program__c) {
                    details += 'Display Name (Program): ' + oldAccount.Display_Name_Program__c + ' (old) => ' + updatedAccount.Display_Name_Program__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Program_Alias__c != oldAccount.Program_Alias__c) {
                    details += 'Program Alias: ' + oldAccount.Program_Alias__c + ' (old) => ' + updatedAccount.Program_Alias__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Program_Code__c != oldAccount.Program_Code__c) {
                    details += 'Program Code: ' + oldAccount.Program_Code__c + ' (old) => ' + updatedAccount.Program_Code__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Program_Type__c != oldAccount.Program_Type__c) {
                    details += 'Program Type: ' + oldAccount.Program_Type__c + ' (old) => ' + updatedAccount.Program_Type__c + ' (new)<br/>';
                }
                
                if (updatedAccount.No_of_Years__c != oldAccount.No_of_Years__c) {
                    details += 'No of Years: ' + oldAccount.No_of_Years__c + ' (old) => ' + updatedAccount.No_of_Years__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Number_of_Semesters__c != oldAccount.Number_of_Semesters__c) {
                    details += 'Number of Semesters: ' + oldAccount.Number_of_Semesters__c + ' (old) => ' + updatedAccount.Number_of_Semesters__c + ' (new)<br/>';
                }
                
                if (updatedAccount.ParentId != oldAccount.ParentId) {
                    String parentNameOld = getParentName(oldAccount.ParentId);
                    String parentNameNew = getParentName(updatedAccount.ParentId);
                    details += 'ParentId: ' + parentNameOld + ' (old) => ' + parentNameNew + ' (new)<br/>';
                }
                if (updatedAccount.RecordTypeId != oldAccount.RecordTypeId) {
                    String RecordtypeOld = getParentName(oldAccount.RecordTypeId);
                    String RecordtypeNew = getParentName(updatedAccount.RecordTypeId);
                    details += 'ParentId: ' + RecordtypeOld + ' (old) => ' + RecordtypeNew + ' (new)<br/>';
                }
                
                
                if (updatedAccount.Intake__c != oldAccount.Intake__c) {
                    details += 'Intake: ' + oldAccount.Intake__c + ' (old) => ' + updatedAccount.Intake__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Intake_Per_Section__c != oldAccount.Intake_Per_Section__c) {
                    details += 'Intake Per Section: ' + oldAccount.Intake_Per_Section__c + ' (old) => ' + updatedAccount.Intake_Per_Section__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Number_of_Batches__c != oldAccount.Number_of_Batches__c) {
                    details += 'Number of Batches: ' + oldAccount.Number_of_Batches__c + ' (old) => ' + updatedAccount.Number_of_Batches__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Description != oldAccount.Description) {
                    details += 'Description: ' + oldAccount.Description + ' (old) => ' + updatedAccount.Description + ' (new)<br/>';
                }
                
                if (updatedAccount.Sequence__c != oldAccount.Sequence__c) {
                    details += 'Sequence: ' + oldAccount.Sequence__c + ' (old) => ' + updatedAccount.Sequence__c + ' (new)<br/>';
                }
                
                if (updatedAccount.School_Head__c != oldAccount.School_Head__c) {
                    details += 'School Head: ' + oldAccount.School_Head__c + ' (old) => ' + updatedAccount.School_Head__c + ' (new)<br/>';
                }
                
                if (updatedAccount.Vertical_Head__c != oldAccount.Vertical_Head__c) {
                    details += 'Vertical Head: ' + oldAccount.Vertical_Head__c + ' (old) => ' + updatedAccount.Vertical_Head__c + ' (new)<br/>';
                }
                
                if (updatedAccount.SLCM_HCM_ID__c != oldAccount.SLCM_HCM_ID__c) {
                    details += 'SLCM - HCM ID: ' + oldAccount.SLCM_HCM_ID__c + ' (old) => ' + updatedAccount.SLCM_HCM_ID__c + ' (new)<br/>';
                }
            }
        }
        return details;
    }
    
    
    public static void handleDelete(List<Account> deletedAccounts) {
        System.debug('Handling Delete');
        
        if (!deletedAccounts.isEmpty()) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
            
            for (String recipientEmail : recipientEmails) {
                for (Account deletedAccount : deletedAccounts) {
                    if (isRecordTypeSupported(deletedAccount.RecordTypeId)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setToAddresses(new String[] {recipientEmail}); 
                        email.setSubject('Account Deleted');
                        String deletedBy = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
                        String currentDateTime = DateTime.now().format('MM/dd/yyyy HH:mm:ss', 'Asia/Kolkata');
                        String body = 'Dear Team, Account deleted by: ' + deletedBy +' (Date and Time: '+currentDateTime+ ')<br/>'+'<br/>';
                        body += 'Account ID: ' + deletedAccount.Id + '<br/>';
                        body += 'Account Name: ' + deletedAccount.Name + '<br/>';
                        email.setHtmlBody(body);
                        if (owea.size() > 0) {
                            email.setOrgWideEmailAddressId(owea[0].Id);
                        }
                        emails.add(email);
                    }
                }
            }
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
    private static Boolean isRecordTypeSupported(Id recordTypeId) {
        // Add the Ids of the supported Record Types here
        Set<Id> supportedRecordTypes = new Set<Id>{
            '0125j000000uuRhAAI',
                '0125j000000uuRkAAI',
                '0125j000000uuRnAAI'
                };
                    return supportedRecordTypes.contains(recordTypeId);
    }
    public static String getParentName(Id parentId) {
        String parentName = '';
        if (parentId != null) {
            List<Account> parentAccounts = [SELECT Name FROM Account WHERE Id = :parentId LIMIT 1];
            if (!parentAccounts.isEmpty()) {
                parentName = parentAccounts[0].Name;
            }
        }
        return parentName;
    }
}