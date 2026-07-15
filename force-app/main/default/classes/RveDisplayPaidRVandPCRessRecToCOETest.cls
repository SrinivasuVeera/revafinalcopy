@isTest
public class RveDisplayPaidRVandPCRessRecToCOETest {

    @testSetup
    static void setupData() {
        Id studentRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id academicRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Id universityDeptRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();

        // Academic and Department Accounts
        Account departmentAccount = new Account(Name = 'School of Life Sciences', RecordTypeId = academicRtId);
        insert departmentAccount;

        Account universityAccount = new Account(Name = 'REVA University', RecordTypeId = universityDeptRtId);
        insert universityAccount;

        // ✅ Match your production Program Batch Name format exactly
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Biotechnology, Biochemistry, and Genetics-(2022-2025)'
        );
        insert programBatch;

        // Active Term
        hed__Term__c activeTerm = new hed__Term__c(
            Name = 'Semester 6',
            RecordTypeId = termRtId,
            hed__Account__c = departmentAccount.Id,
            Program_Batch__c = programBatch.Id,
            Rve_SEE_Result_Date__c = Date.today().addDays(-1)
        );
        insert activeTerm;

        // Student Contact
        Contact student = new Contact(
            FirstName = 'Reva',
            LastName = 'Student',
            RecordTypeId = studentRtId,
            AccountId = departmentAccount.Id,
            Active_Semester__c = activeTerm.Id,
            Program_Batch__c = programBatch.Id
        );
        insert student;

        // Course
        hed__Course__c course = new hed__Course__c(
            Name = 'Biochemistry',
            hed__Account__c = universityAccount.Id,
            Credits__c = 4,
            Offered_By_School__c = universityAccount.Id,
            Credit_Hours__c = 4,
            Maximum_External_Marks__c = 70,
            Total_Maximum_Marks_IA_External__c = 100,
            hed__Course_ID__c = 'BIO101'
        );
        insert course;

        // Course Offering
        hed__Course_Offering__c offering = new hed__Course_Offering__c(
            Name = 'BIO101-Offered',
            hed__Course__c = course.Id,
            hed__Term__c = activeTerm.Id
        );
        insert offering;

        // Course Enrollment
        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = student.Id,
            hed__Course_Offering__c = offering.Id
        );
        insert enrollment;

        // Fee Records
        Student_Fee__c pcFee = new Student_Fee__c(
            Name = 'Photocopy Fee',
            Fee_Type__c = 'PC Fee',
            Amount_Pending__c = 0,
            Due_Date__c = Date.today()
        );
        insert pcFee;

        Student_Fee__c rvFee = new Student_Fee__c(
            Name = 'Revaluation Fee',
            Fee_Type__c = 'RV Fee',
            Amount_Pending__c = 0,
            Due_Date__c = Date.today()
        );
        insert rvFee;

        // ✅ 1. Photocopy applied, paid, not uploaded
        hed__Term_Grade__c tg1 = new hed__Term_Grade__c(
            hed__Term__c = activeTerm.Id,
            Course__c = course.Id,
            hed__Course_Offering__c = offering.Id,
            hed__Contact__c = student.Id,
            AppliedForPhotoCopy__c = true,
            Photocopy_Uploaded__c = false,
            SRN_Number__c = 'REVA001',
            hed__Result__c = 'PASS',
            Secured_Internal_Marks__c = 28,
            Secured_External_Marks__c = 34,
            Photocopy_Fee__c = pcFee.Id
        );
        insert tg1;

        // ✅ 2. Revaluation applied, paid, not uploaded
        hed__Term_Grade__c tg2 = new hed__Term_Grade__c(
            hed__Term__c = activeTerm.Id,
            Course__c = course.Id,
            hed__Course_Offering__c = offering.Id,
            hed__Contact__c = student.Id,
            AppliedForRevaluation__c = true,
            Photocopy_Uploaded__c = false,
            SRN_Number__c = 'REVA002',
            hed__Result__c = 'FAIL',
            Secured_Internal_Marks__c = 18,
            Secured_External_Marks__c = 25,
            Revaluation_Fee__c = rvFee.Id
        );
        insert tg2;

        // ✅ 3. Photocopy applied, paid, uploaded
        hed__Term_Grade__c tg3 = new hed__Term_Grade__c(
            hed__Term__c = activeTerm.Id,
            Course__c = course.Id,
            hed__Course_Offering__c = offering.Id,
            hed__Contact__c = student.Id,
            AppliedForPhotoCopy__c = true,
            Photocopy_Uploaded__c = true,
            SRN_Number__c = 'REVA003',
            hed__Result__c = 'PASS',
            Secured_Internal_Marks__c = 30,
            Secured_External_Marks__c = 40,
            Photocopy_Fee__c = pcFee.Id
        );
        insert tg3;
    }

    @isTest
    static void testFetchResultRecordsForCOE() {
        Test.startTest();
        List<RveDisplayPaidRVandPCResultsRecordsToCOE.ResultWrapper> results =
            RveDisplayPaidRVandPCResultsRecordsToCOE.fetchResultRecordsForCOE();
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Expected 3 result records');

        Boolean hasUpload = false, hasRemove = false, revalOnly = false;
        for (RveDisplayPaidRVandPCResultsRecordsToCOE.ResultWrapper r : results) {
            if (r.appliedForPhotocopy && r.feePaidForPhotocopy && r.showUpload) hasUpload = true;
            if (r.appliedForPhotocopy && r.feePaidForPhotocopy && r.showRemove) hasRemove = true;
            if (r.appliedForRevaluation && !r.showUpload && !r.showRemove) revalOnly = true;
        }
        System.assert(hasUpload, 'Expected at least one record with upload enabled');
        System.assert(hasRemove, 'Expected at least one record with remove enabled');
        System.assert(revalOnly, 'Expected at least one revaluation-only record');
    }
}