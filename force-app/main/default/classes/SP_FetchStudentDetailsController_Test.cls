@isTest
public class SP_FetchStudentDetailsController_Test {
    @testsetup
    public static void testdata() {
        /*Account acc = new Account();
        acc.Name = 'testaccount';
        acc.Industry = 'Advertising';
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id
            
        );
        insert testContact;*/
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        Account acc = new Account();
         acc.name='testaccount';
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id,
            Email = 'testuser@gmail1.com'
        );
        insert testContact;
        
        

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = testContact.Id
        );
        insert testUser;
    }

    @isTest
    static void testGetMenteeLatestCase() {
        // Test data setup
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SobjectType = 'Case' 
                         AND DeveloperName = 'Mentee' 
                         LIMIT 1];
        Contact conObj = [SELECT Id FROM Contact WHERE LastName = 'TestLastName'];
        //Contact conObj1 = [SELECT Id FROM Contact WHERE LastName = 'TestLastName1'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'testaccount'];
        

        User testUser = [select id,ContactId from user where LastName = 'User' and Email = 'testuser@example.com' LIMIT 1];
        
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c( hed__Contact__c= conObj.Id);
        insert pe;
        
        Account acc1 = new Account();
         acc1.name='testaccount1';
        acc1.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Household Account' LIMIT 1].Id;
        insert acc1;

        Contact testContact1 = new Contact(
            FirstName = 'TestFirstName1',
            LastName = 'TestLastName1',
           /* RecordtypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Applicant' LIMIT 1].Id,
            AccountId = acc1.Id,
            Active__c = false,
            Application_Number__c = '23120103347',*/
            Email = 'testuser@gmail.com'
           
        );
        insert testContact1;

        Case testCase = new Case(
            //RecordTypeId = rt.Id,
            ContactId = testUser.ContactId,
            Mentor__c = testContact1.Id,
            status='Active Enrolled'
        );
        insert testCase;
        /*
        CollaborationGroup cb = new CollaborationGroup(Name = 'StudentPortal',CollaborationType='Public');
        insert cb;

        CollaborationGroupMember portalMember = new CollaborationGroupMember(
            CollaborationGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'StudentPortal'].Id,
            MemberId = testUser.Id,
            CollaborationRole = 'Admin'
        );
        insert portalMember;*/

        // Test the getMenteeLatestCase method
        Test.startTest();

        System.runAs(testUser) {
            Case result = SP_FetchStudentDetailsController.getMenteeLatestCase();
            Case result2 = SP_FetchStudentDetailsController.getSupportRequestLatestCase();
           hed__Term__c result3= SP_FetchStudentDetailsController.getNextExamDates();
            Map<String, Boolean> result4 = SP_FetchStudentDetailsController.getStudentPortalTileMenuVisibility();
            //List<Task> result5= SP_FetchStudentDetailsController.getCurrentUserTasks();
            
            
        }

        
        delete testCase;
            Case result6 = SP_FetchStudentDetailsController.getSupportRequestLatestCase();

        Test.stopTest();
    }
    
    
    
    @isTest
    static void getSupportRequestLatestCase() {
        // Test data setup
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SobjectType = 'Case' 
                         AND DeveloperName = 'Mentee' 
                         LIMIT 1];
        Contact conObj = [SELECT Id FROM Contact WHERE LastName = 'TestLastName'];
        //Contact conObj1 = [SELECT Id FROM Contact WHERE LastName = 'TestLastName1'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'testaccount'];
        

        User testUser = [select id,ContactId from user where LastName = 'User' and Email = 'testuser@example.com' LIMIT 1];
        
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c( hed__Contact__c= conObj.Id);
        insert pe;
        
        Account acc1 = new Account();
         acc1.name='testaccount1';
        acc1.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Household Account' LIMIT 1].Id;
        insert acc1;

        Contact testContact1 = new Contact(
            FirstName = 'TestFirstName1',
            LastName = 'TestLastName1',
           /* RecordtypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Applicant' LIMIT 1].Id,
            AccountId = acc1.Id,
            Active__c = false,
            Application_Number__c = '23120103347',*/
            Email = 'testuser@gmail.com'
           
        );
        insert testContact1;

        Case testCase = new Case(
            //RecordTypeId = rt.Id,
            ContactId = testUser.ContactId,
            Mentor__c = testContact1.Id,
            status='Active Enrolled'
        );
        insert testCase;
        /*
        CollaborationGroup cb = new CollaborationGroup(Name = 'StudentPortal',CollaborationType='Public');
        insert cb;

        CollaborationGroupMember portalMember = new CollaborationGroupMember(
            CollaborationGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'StudentPortal'].Id,
            MemberId = testUser.Id,
            CollaborationRole = 'Admin'
        );
        insert portalMember;*/

        // Test the getMenteeLatestCase method
        Test.startTest();

        System.runAs(testUser) {
            Case result2 = SP_FetchStudentDetailsController.getSupportRequestLatestCase();            
            
        }
        

        
        delete testCase;
            Case result6 = SP_FetchStudentDetailsController.getSupportRequestLatestCase();

        Test.stopTest();
    }
    
    
    
     @isTest
    static void getNextExamDates() {
        // Test data setup
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SobjectType = 'Case' 
                         AND DeveloperName = 'Mentee' 
                         LIMIT 1];
        Contact conObj = [SELECT Id FROM Contact WHERE LastName = 'TestLastName'];
        //Contact conObj1 = [SELECT Id FROM Contact WHERE LastName = 'TestLastName1'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'testaccount'];
        

        User testUser = [select id,ContactId from user where LastName = 'User' and Email = 'testuser@example.com' LIMIT 1];
        
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c( hed__Contact__c= conObj.Id);
        insert pe;
        
        Account acc1 = new Account();
         acc1.name='testaccount1';
        acc1.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Household Account' LIMIT 1].Id;
        insert acc1;

        Contact testContact1 = new Contact(
            FirstName = 'TestFirstName1',
            LastName = 'TestLastName1',
           /* RecordtypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Applicant' LIMIT 1].Id,
            AccountId = acc1.Id,
            Active__c = false,
            Application_Number__c = '23120103347',*/
            Email = 'testuser@gmail.com'
           
        );
        insert testContact1;

        Case testCase = new Case(
            //RecordTypeId = rt.Id,
            ContactId = testUser.ContactId,
            Mentor__c = testContact1.Id,
            status='Active Enrolled'
        );
        insert testCase;
        /*
        CollaborationGroup cb = new CollaborationGroup(Name = 'StudentPortal',CollaborationType='Public');
        insert cb;

        CollaborationGroupMember portalMember = new CollaborationGroupMember(
            CollaborationGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'StudentPortal'].Id,
            MemberId = testUser.Id,
            CollaborationRole = 'Admin'
        );
        insert portalMember;*/

        // Test the getMenteeLatestCase method
        Test.startTest();

        System.runAs(testUser) {
            hed__Term__c result3= SP_FetchStudentDetailsController.getNextExamDates(); 
            
        }
        
        delete testCase;
            Case result6 = SP_FetchStudentDetailsController.getSupportRequestLatestCase();

        Test.stopTest();
    }
    
    
     @isTest
    static void getStudentPortalTileMenuVisibility() {
        // Test data setup
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SobjectType = 'Case' 
                         AND DeveloperName = 'Mentee' 
                         LIMIT 1];
        Contact conObj = [SELECT Id FROM Contact WHERE LastName = 'TestLastName'];
        //Contact conObj1 = [SELECT Id FROM Contact WHERE LastName = 'TestLastName1'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'testaccount'];
        

        User testUser = [select id,ContactId from user where LastName = 'User' and Email = 'testuser@example.com' LIMIT 1];
        
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c( hed__Contact__c= conObj.Id);
        insert pe;
        
        Account acc1 = new Account();
         acc1.name='testaccount1';
        acc1.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Household Account' LIMIT 1].Id;
        insert acc1;

        Contact testContact1 = new Contact(
            FirstName = 'TestFirstName1',
            LastName = 'TestLastName1',
           /* RecordtypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Applicant' LIMIT 1].Id,
            AccountId = acc1.Id,
            Active__c = false,
            Application_Number__c = '23120103347',*/
            Email = 'testuser@gmail.com'
           
        );
        insert testContact1;

        Case testCase = new Case(
            //RecordTypeId = rt.Id,
            ContactId = testUser.ContactId,
            Mentor__c = testContact1.Id,
            status='Active Enrolled'
        );
        insert testCase;
        /*
        CollaborationGroup cb = new CollaborationGroup(Name = 'StudentPortal',CollaborationType='Public');
        insert cb;

        CollaborationGroupMember portalMember = new CollaborationGroupMember(
            CollaborationGroupId = [SELECT Id FROM CollaborationGroup WHERE Name = 'StudentPortal'].Id,
            MemberId = testUser.Id,
            CollaborationRole = 'Admin'
        );
        insert portalMember;*/

        // Test the getMenteeLatestCase method
        Test.startTest();

        System.runAs(testUser) {
            Map<String, Boolean> result4 = SP_FetchStudentDetailsController.getStudentPortalTileMenuVisibility();
            //List<Task> result5= SP_FetchStudentDetailsController.getCurrentUserTasks();
            
        }
    }
     @IsTest
    static void testIsGuestUser() {
        Test.startTest();
        Boolean result = SP_FetchStudentDetailsController.isGuestUser();
        Test.stopTest();

        // Assuming the test runs in an authenticated context, the result should be false
        System.assertEquals(false, result);
    }    
    
}