@isTest
public class ExamApplicationPDFTest {
    @testSetup
    static void setupData() {
        // Create a Contact for the Student
        // 
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        
       Contact con = new Contact();
        con.FirstName = 'suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = programbatch.Id;
        con.SRN_Number__c='SA001';
        con.Active__c=true;
        insert con;
        
        
        hed__Term__c semester = new hed__Term__c(
        Name = '3rd Semester',
        Program_Batch__c =ProgramBatch.id,
        hed__Account__c = acc.Id,
        hed__Start_Date__c = Date.today().addDays(-30),
        hed__End_Date__c = Date.today().addDays(30));     
        insert semester;
        
        
        // Create Rve_Exam_Notification__c record
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Name = 'Test Exam Notification',
            Rve_Publish__c = true,
            Rve_Semester__c = semester.id,
            Rve_Start_Date__c = Date.newInstance(2024, 5, 1),
            Rve_End_Date__c = Date.newInstance(2024, 5, 15)
        );
        insert examNotification;
        
        // Create Rve_Exam_Application__c record
        Rve_Exam_Application__c examApplication = new Rve_Exam_Application__c(
            Rve_Application_Number__c = 'APP123',
            Name = 'Test Exam Application',
            Rve_Amount__c = 100,
            Rve_Applied_Date__c = Date.today(),
            Rve_Exam_Notification__c = examNotification.Id,
            Rve_Logisys_Field_Check__c = true,
            Rve_Payment_Date__c = Date.today(),
            Rve_Payment_Status__c = 'Success',
            Rve_Payment_Type__c = 'Online',
            Rve_Registration_Number__c = 'REG123',
            Rve_Status__c = 'Active',
            Rve_Student__c = con.Id
        );
        insert examApplication;
        
        Student_Fee__c StudentFee = new Student_Fee__c(
            Name = 'Test Student Fee',
            contact__c = con.Id,
            Amount_Pending__c=0
        );
        
        insert StudentFee;
        
        // Create Student_Fee_Payment__c record
        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
            Mode_of_Payment__c = 'Online',
            Payment_Date__c = Date.today(),
            Line_Item_Payment_Status__c = 'Success',
            Amount__c = 100.0,
            SF_Transaction_ID__c = 'TRANS123',
            Student_Fee__c = StudentFee.id
        );
        insert studentFeePayment;
    }

    @isTest
    static void testExamApplicationPDF() {
        // Retrieve the created student contact and exam application
        Contact student = [SELECT Id FROM Contact WHERE LastName = 'Madala' LIMIT 1];
        Rve_Exam_Application__c examApplication = [SELECT Id FROM Rve_Exam_Application__c WHERE Name = 'Test Exam Application' LIMIT 1];
        
        // Set page parameters
        PageReference pageRef = Page.ExamApplicationPDF; // Ensure this page exists in your org
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', student.Id);
        ApexPages.currentPage().getParameters().put('application', examApplication.Id);
        
        // Create standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(examApplication);
        
        // Instantiate the controller class
        Test.startTest();
        ExamApplicationPDF controller = new ExamApplicationPDF(sc);
        Test.stopTest();
        
        // Assertions to verify the behavior
        System.assertNotEquals(null, controller.student, 'Student should not be null');
      //  System.assertNotEquals(null, controller.examApplication, 'Exam Application should not be null');
        System.assertNotEquals(null, controller.examApplicationNotification, 'Exam Application Notification should not be null');
        System.assertNotEquals(null, controller.StudentFeePayment, 'Student Fee Payment should not be null');
        System.assertEquals('MAY 2024 EXAMINATION', controller.examApplicationHeader, 'Exam Application Header should be correctly formatted');
    }
}