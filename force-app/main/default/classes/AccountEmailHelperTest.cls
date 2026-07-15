@isTest
public class AccountEmailHelperTest {
    
    static testMethod void testInsert() {
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};
            
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName = 'standarduser00@testorg.com'
        );
        insert testUser;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        
        ID AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account newAccount = new Account(
            Name = 'New Test Account',
            RecordTypeId = AcaRecId, 
            Display_Name_Program__c = 'Test Program',
            OwnerId = testUser.Id
        );
        
        ID EduRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Account newEduAccount = new Account(
            Name = 'New Educational Institution Account',
            RecordTypeId = EduRecId
            
        );
        insert newEduAccount;
        
        ID UniDepRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account newUniDepAccount = new Account(
            Name = 'New University Department Account',
            RecordTypeId = UniDepRecId
            
        );
        insert newUniDepAccount;
        Test.startTest();
        AccountEmailHelper.handleInsert(new List<Account>{newUniDepAccount});
        AccountEmailHelper.handleInsert(new List<Account>{newAccount});
        AccountEmailHelper.handleInsert(new List<Account>{newEduAccount});
        List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[0]);
        
        Test.stopTest();
        System.assertEquals(0, emailResults.size());
        
        delete testAccount;
        
        delete newEduAccount;
        delete newUniDepAccount;
    }
    
    static testMethod void testUpdate() {
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};
            
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName = 'Bhasa' + DateTime.now().getTime() + '@gmail.com'
        );
        insert testUser;
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        ID AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account newAccount = new Account(
            Name = 'New Test Account',
            Display_Name_Program__c='CV',
            Program_Alias__c='TA',
            Program_Code__c='test',
            Program_Type__c='UG',
            No_of_Years__c=3,
            RecordTypeId = AcaRecId,
            Number_of_Semesters__c=6,
            Intake__c=60,
            Intake_Per_Section__c=60,
            Number_of_Batches__c=2,
            Description='testwe',
            Sequence__c='1');
        insert newAccount;
        
        Map<Id, Account> oldAccountMap = new Map<Id, Account>{testAccount.Id => testAccount};
            
            Test.startTest();
        newAccount.Name = 'Updated Test Account';
        newAccount.Display_Name_Program__c='CV';
        newAccount.Program_Alias__c='TA';
        newAccount.Program_Code__c='test';
        newAccount.Program_Type__c='UG';
        newAccount.No_of_Years__c=3;
        newAccount.Number_of_Semesters__c=6;
        newAccount.Intake__c=60;
        newAccount.Intake_Per_Section__c=60;
        newAccount.Number_of_Batches__c=2;
        newAccount.Description='testwe';
        newAccount.Sequence__c='1';
        update newAccount;
        
        AccountEmailHelper.handleUpdate(new List<Account>{newAccount}, oldAccountMap);
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Test.stopTest();
        
        System.assertEquals(0, emails.size());
        
        delete testAccount;
        delete newAccount;
        
    }
    
    static testMethod void testDelete() {
        
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea.DisplayName = 'REVA Alerts';
        owea.Address = 'alerts@reva.edu.in';
        List<OrgWideEmailAddress> mockOWEAList = new List<OrgWideEmailAddress>{owea};
            
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            ProfileId = profile.Id, 
            UserName ='unique_username_' + DateTime.now().getTime() + '@testorg.com'
        );
        insert testUser;
        
        ID AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account testAccount = new Account(Name = 'Test Account',RecordTypeId = AcaRecId);
        
        insert testAccount;
        ID AcaRecIds = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account newAccount = new Account(Name = 'New Test Account',RecordTypeId = AcaRecIds);
        insert newAccount;
        
        Test.startTest();
        delete testAccount;
        AccountEmailHelper.handleDelete(new List<Account>{newAccount});
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Test.stopTest();
        
        
        System.assertEquals(0, emails.size());
        
        delete newAccount;
        
    }
}