@isTest
public class RveExamDeleteExpiredRVAndPCFeeBatchTest {

    @testSetup
    static void setupTestData() {
        Id studentRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id academicRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Id universityDeptRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();

        // Accounts
        Account departmentAccount = new Account(Name = 'School of ECE', RecordTypeId = academicRtId);
        insert departmentAccount;

        Account universityAccount = new Account(Name = 'School of Science', RecordTypeId = universityDeptRtId);
        insert universityAccount;

        // Contact
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            RecordTypeId = studentRtId
        );
        insert contact;

        // Program Plan
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Test Batch');
        insert programBatch;

        // Term
        hed__Term__c term = new hed__Term__c(
            Name = 'Test Term',
            RecordTypeId = termRtId,
            hed__Account__c = departmentAccount.Id,
            Program_Batch__c = programBatch.Id,
            Rve_SEE_Result_Date__c = Date.today().addDays(-1)
        );
        insert term;

        // Course
        hed__Course__c course = new hed__Course__c(
            Name = 'Test Course',
            hed__Account__c = universityAccount.Id,
            Credits__c = 4,
            Offered_By_School__c = universityAccount.Id,
            Credit_Hours__c = 4,
            Maximum_External_Marks__c = 70,
            Total_Maximum_Marks_IA_External__c = 100
        );
        insert course;

        // Course Offering
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
            Name = 'Offering 1',
            hed__Course__c = course.Id,
            hed__Term__c = term.Id
        );
        insert courseOffering;

        // Course Enrollment
        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = contact.Id,
            hed__Course_Offering__c = courseOffering.Id
        );
        insert enrollment;

        // Create expired PC Fee
        Student_Fee__c pcFee = new Student_Fee__c(
            Name = 'Expired PC Fee',
            Contact__c = contact.Id,
            Fee_Type__c = 'PC Fee',
            Amount_Paid__c = 0,
            Due_Date__c = Date.today().addDays(-5)
        );
        insert pcFee;

        // Create expired RV Fee
        Student_Fee__c rvFee = new Student_Fee__c(
            Name = 'Expired RV Fee',
            Contact__c = contact.Id,
            Fee_Type__c = 'RV Fee',
            Amount_Paid__c = 0,
            Due_Date__c = Date.today().addDays(-5)
        );
        insert rvFee;

        // Create Term Grade referencing both fees
        hed__Term_Grade__c tg = new hed__Term_Grade__c(
            hed__Term__c = term.Id,
            Course__c = course.Id,
            AppliedForPhotoCopy__c = true,
            AppliedForRevaluation__c = true,
            Photocopy_Fee__c = pcFee.Id,
            Revaluation_Fee__c = rvFee.Id,
            hed__Course_Offering__c = courseOffering.Id,
            hed__Contact__c = contact.Id
        );
        insert tg;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        RveExamDeleteExpiredRVFeeAndPCFeeBatch batch = new RveExamDeleteExpiredRVFeeAndPCFeeBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Check that fee records were deleted
        List<Student_Fee__c> remainingFees = [SELECT Id FROM Student_Fee__c];
        System.assertEquals(0, remainingFees.size(), 'All expired PC/RV fee records should be deleted');

        // Check that term grade is updated
        hed__Term_Grade__c updatedTG = [SELECT AppliedForRevaluation__c, AppliedForPhotoCopy__c, Revaluation_Fee__c, Photocopy_Fee__c FROM hed__Term_Grade__c LIMIT 1];
        System.assertEquals(false, updatedTG.AppliedForRevaluation__c, 'AppliedForRevaluation should be false');
        System.assertEquals(false, updatedTG.AppliedForPhotoCopy__c, 'AppliedForPhotoCopy should be false');
        System.assertEquals(null, updatedTG.Revaluation_Fee__c, 'Revaluation Fee reference should be null');
        System.assertEquals(null, updatedTG.Photocopy_Fee__c, 'Photocopy Fee reference should be null');
    }
}