@isTest
public class Reva_ExamApplication_Ctrl_Test {
    
    // Helper method to create a test user and contact
    public static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Student Portal Profile'];
        User u = new User(Alias = 'testuser', Email='testuser@test.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='testuser' + System.currentTimeMillis() + '@test.com');
        insert u;
        return u;
    }
    
    @testSetup
    static void setup() {
        // Create test data here
        // Create parent Account
        Account accparent = new Account(Name = 'TestAccParent');
        insert accparent;
        
        // Create child Account with parentId
        Account acc = new Account(Name = 'TestAcc', ParentId = accparent.Id);
        insert acc;
        system.debug('test account>>'+acc);
        
        
        // Create Program Batch (hed__Program_Plan__c)
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'TestProgramBatch';
        programBatch.hed__Account__c = acc.Id;
        insert programBatch;
        system.debug('test program>>'+programBatch);
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        system.debug('test semester>>'+semester);
        
       
        
        // Create Contact
        Contact con = new Contact();
        con.FirstName = 'Suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = programBatch.Id;
        con.Active_Semester__c = semester.Id;
        con.SRN_Number__c = 'SA001';
        con.Active__c = true;
        insert con;
        system.debug('test con>>'+con);
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Student Portal Profile'];
        
         User u = new User(Alias = 'testuser', Email='testuserExamApplication@test.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                           contactid=con.id,
                          UserName='testuser' + System.currentTimeMillis() + '@test.com');
        insert u;
        
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Name = 'Exam1',
            Rve_Semester__c = semester.id,
            Rve_Publish__c = true,
            RecordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_Semester_Notification').getRecordTypeId(),
            Rve_End_Date__c =  Date.today().addDays(5),
            Rve_Fee__c = 2500,
            Rve_Late_Fee__c = 500,
            Rve_Start_Date__c= Date.today().addDays(1)
           
        );
        insert examNotification;
        system.debug('test examNotification>>'+examNotification);
        
        
        
        Fee_Payment_Criteria__c feePaymentCriteria = new Fee_Payment_Criteria__c(
            Fee_Type__c = 'Examination & Valuation Fee',
            Payment_Type__c = 'Full Payment'
        );
        insert feePaymentCriteria;
        system.debug('test feePaymentCriteria>>'+feePaymentCriteria);
        
    }
    
    @isTest
    static void testGetStudentDetails() {
        Test.startTest();
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];
        System.debug('UserContact=> '+u1.ContactId);
        System.runas(u1){
        List<Contact> result = Reva_ExamApplication_Ctrl.getStudentDetails();
        }
        //System.assertNotEquals(0, result.size(), 'Expected student details');
        Test.stopTest();
    }
    
    @isTest
    static void testGetExamNotificationDetails() {
        Test.startTest();
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];
        System.runas(u1){
        List<Rve_Exam_Notification__c> result = Reva_ExamApplication_Ctrl.getExamNotificationDetails();
        }
        // System.assertNotEquals(0, result.size(), 'Expected exam notification details');
        Test.stopTest();
    }
    
    @isTest
    static void testExamApplicationEligibility() {
        Test.startTest();
         Rve_Exam_Notification__c ExamNotification = [Select Id from Rve_Exam_Notification__c where Name='Exam1' limit 1];
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1]; 
        System.runas(u1){
        Boolean result = Reva_ExamApplication_Ctrl.examApplicationEligibility();
        }
      //  System.assertEquals(true, result, 'Expected exam application eligibility');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCourseDetails() {
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];        
        System.runas(u1){
        List<Contact> condetails = Reva_ExamApplication_Ctrl.getStudentDetails();
        Test.startTest();
        List<hed__Course_Enrollment__c> result = Reva_ExamApplication_Ctrl.getCourseDetails(condetails);
        }
       // System.assertEquals(0, result.size(), 'Expected course details');
        Test.stopTest();
    }
    
    @isTest
    static void testGetBacklogDetails() {
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];
        System.runas(u1){
        List<Contact> condetails = Reva_ExamApplication_Ctrl.getStudentDetails();
        Test.startTest();
        List<hed__Term_Grade__c> result = Reva_ExamApplication_Ctrl.getBacklogDetails(condetails);
        }
      //  System.assertEquals(0, result.size(), 'Expected backlog details');
        Test.stopTest();
    }
    
    @isTest
    static void testGetFeeDetails() {
        Test.startTest();
        List<rve_Fee_Detail__mdt> result = Reva_ExamApplication_Ctrl.getFeeDetails();
      //  System.assertNotEquals(0, result.size(), 'Expected fee details');
        Test.stopTest();
    }
    
    @isTest
    static void testCheckIsFinalYearStudent() {
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];
        System.runas(u1){
        List<Contact> condetails = Reva_ExamApplication_Ctrl.getStudentDetails();
        Test.startTest();
        Boolean result = Reva_ExamApplication_Ctrl.checkIsFinalYearStudent(condetails[0].Program_Batch__c, condetails[0].Active_Semester__c);
        }
       // System.assertEquals(false, result, 'Expected final year student check');
        Test.stopTest();
    }
    
    @isTest
    static void testGetExamDetails() {
        Test.startTest();
        Contact con = [Select Id from contact where lastname='Madala' limit 1];
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];
        System.runas(u1){
        Reva_ExamApplication_Ctrl.ExamDetailsWrapper result = Reva_ExamApplication_Ctrl.getExamDetails();
        }
       // System.assertNotEquals(null, result, 'Expected exam details wrapper');
        Test.stopTest();
    }
    
    @isTest
    static void testInsertRecords() {
        
        Contact con = [Select Id,name from contact where lastname = 'Madala' limit 1];
        Rve_Exam_Notification__c ExamNotification = [Select Id from Rve_Exam_Notification__c where Name = 'Exam1'];
        Rve_Exam_Application__c examApplication = new Rve_Exam_Application__c(
            Name = 'Exam Application',
            Rve_Amount__c = 100,
            Rve_Student__c = con.Id,
            Rve_Exam_Notification__c = Examnotification.Id
        );
      //  insert ExamApplication;
        
        Rve_Exam_Application_Line_Item__c ExamApplicationLineItem = new Rve_Exam_Application_Line_Item__c(
         Rve_Exam_Application__c = ExamApplication.Id
        );
        
       // insert ExamApplicationLineItem;
        System.debug('conId=> '+con.Id);
        User u1 = [Select Id,name,contactId from user where Email='testuserExamApplication@test.com' limit 1];       
        System.runas(u1){
        Reva_ExamApplication_Ctrl.insertRecords(ExamApplication,new List<Rve_Exam_Application_Line_Item__c>{ExamApplicationLineItem});  
        }
        
    }
}