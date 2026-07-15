@isTest
public class RveExamPhotocopyFileUploadControllerTest {
    
    @testSetup
    static void setupData() {
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

        // Create test course with required fields
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

        // Create fee record to satisfy formula condition
        Student_Fee__c fee = new Student_Fee__c(
            Name = 'Test Fee',
            Fee_Type__c = 'PC Fee',
            Amount_Pending__c = 0,
            Due_Date__c = Date.today()
        );
        insert fee;

        // Create term grade record with necessary fields
        hed__Term_Grade__c tg = new hed__Term_Grade__c(
            hed__Term__c = term.Id,
            Course__c = course.Id,
            AppliedForPhotoCopy__c = true,
            Photocopy_Uploaded__c = false,
            Photocopy_Fee__c = fee.Id,
            hed__Course_Offering__c = courseOffering.Id,
            hed__Contact__c = contact.Id
        );
        insert tg;
    }

    @isTest
    static void testGetPhotocopyRecordsWithFiles() {
        hed__Term_Grade__c tg = [SELECT Id FROM hed__Term_Grade__c LIMIT 1];
        List<Id> ids = new List<Id>{ tg.Id };
        
        Test.startTest();
        List<RveExamPhotocopyFileUploadController.ResultPhotocopyWrapper> result =
            RveExamPhotocopyFileUploadController.getPhotocopyRecordsWithFiles(ids);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(tg.Id, result[0].resultId);
        System.assertEquals(true, result[0].appliedForPhotocopy);
        System.assertEquals(true, result[0].feePaid);
        System.assertEquals(false, result[0].fileUploaded);
        System.assertEquals(true, result[0].showUpload);
    }

    @isTest
    static void testUploadFile() {
        hed__Term_Grade__c tg = [SELECT Id FROM hed__Term_Grade__c LIMIT 1];

        Blob content = Blob.valueOf('Test file content');
        String base64 = EncodingUtil.base64Encode(content);
        String filename = 'SampleUpload.txt';

        Test.startTest();
        RveExamPhotocopyFileUploadController.uploadFile(base64, filename, tg.Id);
        Test.stopTest();

        hed__Term_Grade__c updatedTg = [SELECT Photocopy_Uploaded__c FROM hed__Term_Grade__c WHERE Id = :tg.Id];
        System.assertEquals(true, updatedTg.Photocopy_Uploaded__c);
    }

    @isTest
    static void testDeleteFile() {
        hed__Term_Grade__c tg = [SELECT Id FROM hed__Term_Grade__c LIMIT 1];

        // Ensure file is uploaded first
        Blob content = Blob.valueOf('Dummy content');
        String base64 = EncodingUtil.base64Encode(content);
        String filename = 'ToDeleteFile.txt';

        RveExamPhotocopyFileUploadController.uploadFile(base64, filename, tg.Id);
        hed__Term_Grade__c uploadedTg = [SELECT Photocopy_Uploaded__c FROM hed__Term_Grade__c WHERE Id = :tg.Id];
        System.assertEquals(true, uploadedTg.Photocopy_Uploaded__c);

        Test.startTest();
        RveExamPhotocopyFileUploadController.deleteFile(tg.Id);
        Test.stopTest();

        hed__Term_Grade__c tgAfterDelete = [SELECT Photocopy_Uploaded__c FROM hed__Term_Grade__c WHERE Id = :tg.Id];
        System.assertEquals(false, tgAfterDelete.Photocopy_Uploaded__c);
    }
}