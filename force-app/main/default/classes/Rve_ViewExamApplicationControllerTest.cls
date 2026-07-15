@isTest
private class Rve_ViewExamApplicationControllerTest {
    
    @TestSetup
    static void testGetContactDetails() {
        // Create users Records
        Rve_Exam_Notification__c revnotification = testDataFactoryExamination.createExamNotification();
        Contact testContact = testDataFactoryExamination.createContact();    
        system.debug('Test Class Contact Id==>'+testContact);
        
        User testUser = new User(
            ContactId = testContact.Id,
            Username = 'testuser01apx@example.com',
            Email = 'testuser01apx@example.com',
            FirstName = 'testuser01apx',
            LastName = '0123User',
            Alias = 'tuser01@',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
       
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;

        Contact con = new Contact();
        con.FirstName = 'suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = ProgramBatch.Id;
        con.SRN_Number__c='SA001';
        con.Active__c=true;
        insert con;
       
        Rve_Exam_Application__c examApplication = new Rve_Exam_Application__c(
            Rve_Application_Number__c = 'App001',
            Rve_Amount__c = 100.0,
            Rve_Applied_Date__c = Date.today().addDays(-7),
            Rve_Exam_Notification__c = revnotification.Id,
            Rve_Payment_Date__c = Date.today().addDays(-5),
            Rve_Payment_Status__c = 'Success',
            Rve_Payment_Type__c = 'Online',
            Rve_Registration_Number__c = 'Reg001',
            Rve_Status__c = 'Active',
            Rve_Student__c = testContact.Id
        );
        insert examApplication;
        
        Student_Fee__c StudentFee = new Student_Fee__c(
            Name = 'Test Student Fee',
            contact__c = testContact.Id,
            Amount_Pending__c=0,
            Reva_Exam_Application__c = examApplication.id
        );
        insert StudentFee;
        
        Student_Fee_Payment__c feePayment = new Student_Fee_Payment__c(
            Mode_of_Payment__c = 'Online',
            Payment_Date__c = Date.today().addDays(-5),
            Line_Item_Payment_Status__c = 'Success',
            Amount__c = 100,
            SF_Transaction_ID__c = 'Trans001',
            Student_Fee__c = StudentFee.id
        );
        insert feePayment;
        
        system.runAs(testUser) {
            Rve_ViewExamApplicationController.ExamApplicationWrapper result = Rve_ViewExamApplicationController.getContactDetails(examApplication.Id);
            System.assertNotEquals(null, result);
        }
    }

    @isTest
    static void testGetExamApplicationList() {
        User user = [SELECT Id FROM User where username='testuser01apx@example.com' Limit 1];

        system.runAs(user) {
            List<Rve_Exam_Application__c> result = Rve_ViewExamApplicationController.getExamApplicationList();
            System.assertNotEquals(null, result);
        }
    }
    
    @isTest
    static void testGetExamApplicationListException() {
        User testUser = [SELECT Id, ContactId FROM User LIMIT 1];
        System.assertNotEquals(null, testUser, 'Test user should not be null');

        Test.startTest();
        
        try {
            System.runAs(testUser) {
                List<Rve_Exam_Application__c> result = Rve_ViewExamApplicationController.getExamApplicationList();
            }
        } catch (AuraHandledException e) {
            System.assertEquals('Expected error message', e.getMessage(), 'Exception message mismatch');
        }

        Test.stopTest();
    }
    
    @isTest
    static void testGetExampleTimeTable() {
        User user = [SELECT Id FROM User where username='testuser01apx@example.com' Limit 1];
        
        Test.startTest();
        List<Rve_Exam_Application_Line_Item__c> timeTable = Rve_ViewExamApplicationController.getExampleTimeTable(user.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, timeTable);
    }
}