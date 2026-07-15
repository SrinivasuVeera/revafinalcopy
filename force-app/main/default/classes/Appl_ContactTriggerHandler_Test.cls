@isTest
public with sharing class Appl_ContactTriggerHandler_Test {
    
    @TestSetup
    public static void createData(){
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        
        // create a test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '123-456-7890',
            BillingStreet = '123 Main St',
            BillingCity = 'Anytown',
            BillingState = 'CA',
            BillingPostalCode = '12345',
            BillingCountry = 'USA',
            OwnerId = UserInfo.getUserId()
        );
        insert testAccount;
        
        Contact conWithAliasG8 = new Contact(
            FirstName ='Sai',
            MiddleName = 'K',
            LastName = 'Kumari',
            Email = 'saig8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = false,
            AccountId = testAccount.Id,
            Application_Number__c = '222333555'
        );
        
        Contact conWithAlias8 = new Contact(
            FirstName = 'Sai',
            MiddleName = '',
            LastName = 'Kiran',
            Email = 'sai8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = false,
            AccountId = testAccount.Id,
            Application_Number__c = '222333555'
        );
        
        Contact conWithAliasL8 = new Contact(
            FirstName = 'Sai',
            MiddleName = 'K',
            LastName = 'K',
            Email = 'sail8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = false,
            AccountId = testAccount.Id,
            Application_Number__c = '222333555'
        );
        Contact primaryContact = new Contact();
        primaryContact.LastName='Fresh Contact';
        //primaryContact.Company='Test Company';
        primaryContact.utm_source__c='Primary';
        primaryContact.MobilePhone = '9876543210';
        primaryContact.Primary_Source__c= 'Primary';
        insert primaryContact;
        
        Contact secondaryContact = new Contact();
        secondaryContact.LastName='Fresh Contact1';
        //secondaryContact.Company='Test Company';
        secondaryContact.utm_source__c='Secondary';
        secondaryContact.MobilePhone = '9876543210';
        secondaryContact.Country_Code__c = 'India (+91)';
        secondaryContact.Primary_Source__c= 'Secondary';
        secondaryContact.Secondary_Source__c= 'Secondary';
        insert secondaryContact;
        
        insert conWithAliasG8;
        insert conWithAlias8;
        insert conWithAliasL8;
        
        Contact con1 = new Contact(
            FirstName = 'Jai',
            MiddleName = 'K',
            LastName = 'K',
            Email = 'sail8@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = ApplicantRT.Id,
            Application_Fee_Paid__c = false,
            AccountId = testAccount.Id,
            Application_Number__c = '222333555',
            pi__last_activity__c=DateTime.now()-1
        );
        insert con1;
    }
    
    
    @isTest static void TestAllUserCreation(){
        
        List<Contact> contacts = [Select Id, Name, Application_Fee_Paid__c, Record_Type_Name__c from Contact];
        Map<Id, Contact> oldMap = new Map<Id, Contact>();
        Set<ID> contactIds = new Set<ID>();
        
        for(Contact c: contacts){
            oldMap.put(c.Id, c);
            contactIds.add(c.Id);
            c.Application_Fee_Paid__c = true;
        }
        update contacts;
        
        test.startTest();
        Appl_ContactTriggerHandler.applicantUserCreation(contacts,oldMap);
        test.stopTest();
        
        List<Contact> l8Contact = [select Id, Name,Record_Type_Name__c from Contact where Email = 'sail8@gmail.com'];
        List<User> o8User = [select Id, Name from User where Email = 'sai8@gmail.com'];
        List<User> g8User = [select Id, Name from User where Email = 'saig8@gmail.com'];
        
        system.assertEquals(g8User.size(), 0);
        system.assertEquals(o8User.size(), 0);
        //system.assertEquals(l8Contact.size(), 1);
    }   
    
    @isTest static void TestPartialUserCreation(){
        
        List<Contact> contacts = [Select Id, Name, Application_Fee_Paid__c, Record_Type_Name__c from Contact];
        Map<Id, Contact> oldMap = new Map<Id, Contact>();
        Set<ID> contactIds = new Set<ID>();
        
        for(Contact c: contacts){
            oldMap.put(c.Id, c);
            contactIds.add(c.Id);
            c.Application_Fee_Paid__c = true;
        }
        update contacts;
        
        Contact conWithAlias8 = [select Id, FirstName, LastName,Record_Type_Name__c, MiddleName, Email, Application_Number__c from Contact where Email = 'sai8@gmail.com' Limit 1];
        Id profileId = [SELECT Id FROM Profile WHERE Name = : 'Applicant Profile'].Id;
        Organization orgDetails = [Select Name, IsSandbox from Organization Limit 1];
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser){
            // Assign a role to the account 
            Account testAccount = [Select Id, OwnerId From Account Where Name = 'Test Account' Limit 1];
            User accountOwner = [SELECT Id, UserRoleId FROM User WHERE Id = :testAccount.OwnerId limit 1];
            accountOwner.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'COE' limit 1].Id;
            update accountOwner;
        }
        user u = new User(
            FirstName = conWithAlias8.FirstName,
            MiddleName = conWithAlias8.MiddleName,
            LastName = conWithAlias8.LastName,
            Email = conWithAlias8.Email,
            ProfileId = profileId,
            ContactId = conWithAlias8.Id,
            
            TimeZoneSidKey = 'Asia/Kolkata', // CAN BE SET ALSO BASED ON THE COUNTRY OF THE CONTACT
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_IN',
            IsActive = false,
            Alias = conWithAlias8.FirstName + conWithAlias8.LastName,
            UserName = conWithAlias8.Application_Number__c + '@' + 'reva.edu.in.' + orgDetails.Name.deleteWhiteSpace()
        );
        insert u;
        
        test.startTest();
        Appl_ContactTriggerHandler.applicantUserCreation(contacts,oldMap);
        test.stopTest();
        
        List<Contact> l8Contact = [select Id, Name,Record_Type_Name__c from Contact where Email = 'sail8@gmail.com'];
        List<User> o8User = [select Id, Name from User where Email = 'sai8@gmail.com'];
        List<User> g8User = [select Id, Name from User where Email = 'saig8@gmail.com'];
        
        system.assertEquals(g8User.size(), 0); 
        system.assertEquals(o8User.size(), 1); // one user Record
        //system.assertEquals(l8Contact.size(), 1); 
    }   
    
    @isTest
    public static void updateContactSourceTest(){
        
        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        List<Contact> newContact = new List<Contact>();
        
        Contact oldContact = [Select Id, LastName,MobilePhone,Record_Type_Name__c, Country_Code__C,pi__last_activity__c
                 from Contact where FirstName='Jai' Limit 1];
        oldContactMap.put(oldContact.Id,oldContact);
        
        oldContact.pi__last_activity__c=DateTime.now();
        update oldContact;
        
        newContact.add(oldContact);
        
        Test.startTest();
        Appl_ContactTriggerHandler.updateContactSource(oldContactMap,newContact);
        Test.stopTest();
    }
    
}