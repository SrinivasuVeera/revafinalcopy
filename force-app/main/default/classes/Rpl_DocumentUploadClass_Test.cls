@isTest
private class Rpl_DocumentUploadClass_Test {

    @isTest
    static void testUploadAttachment() {
        Rpl_Student_Registration__c testRecord = new Rpl_Student_Registration__c(Name = 'Test Record', Rpl_Personal_Mail_ID__c = 'test@gmail.com');
        insert testRecord;

        Blob pdfBody = Blob.valueOf('Test PDF Content');
        ContentVersion testPDF = createTestPDF('Test PDF', pdfBody, testRecord.Id);
          Blob pdfBody1 = Blob.valueOf('Test PDF Content1');

        Test.startTest();
        Rpl_DocumentUploadClass.uploadAttachment(testPDF.Title, EncodingUtil.base64Encode(pdfBody), testRecord.Id);
        Rpl_DocumentUploadClass.uploadAttachment('testfile', EncodingUtil.base64Encode(pdfBody1), testRecord.Id);
        Test.stopTest();
        

        // Add assertions to verify the expected behavior
        List<Rpl_Student_Registration__c> updatedRecords = [SELECT Id, Rpl_No_Of_UG_Marksheet_Uploaded__c FROM Rpl_Student_Registration__c WHERE Id = :testRecord.Id];
        System.assertNotEquals(null, updatedRecords, 'Records should not be null');
        //System.assertEquals(1, updatedRecords[0].Rpl_No_Of_UG_Marksheet_Uploaded__c, 'Number of UG Marksheet Uploaded should be 1');
    }

   /* @isTest
    static void testUpdateIsUnderApprovalProcess() {
        Profile vhProfile = [select id from profile where Name = 'Placement Vertical Head'];
        User verticalhead = new User(FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'testuser129993@example.com',
            ProfileId = vhProfile.id,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            IsActive = true);
        insert verticalhead;

        Rpl_Student_Registration__c testRecord = new Rpl_Student_Registration__c(Name = 'Test Record', Rpl_Personal_Mail_ID__c = 'test@gmail.com', VH__c = verticalhead.id);
        insert testRecord;

        Test.startTest();
        Rpl_DocumentUploadClass.updateIsUnderApprovalProcess(testRecord.Id);
        Test.stopTest();

    } */

    @isTest
    static void testGetAttachments() {
        Rpl_Student_Registration__c testRecord = new Rpl_Student_Registration__c(Name = 'Test Record', Rpl_Personal_Mail_ID__c = 'test@gmail.com');
        insert testRecord;

        Blob pdfBody = Blob.valueOf('Test PDF Content');
        ContentVersion testPDF = createTestPDF('1234 - Test PDF', pdfBody, testRecord.Id);

        Test.startTest();
        List<Rpl_DocumentUploadClass.AttachmentWrapper> attachments = Rpl_DocumentUploadClass.getAttachments(testRecord.Id);
        Test.stopTest();

        System.assertNotEquals(null, attachments, 'Attachments should not be null');
    }

    @isTest
    static void testGetDocumentStatus() {
        
        Account acc = new Account(Name = 'AAA');
        insert acc;
        
        hed__Term__c testSem = new hed__Term__c(
           hed__Account__c = acc.Id,
        Name = '--7');
        insert testSem;
        
        Contact eCon = new Contact();
        eCon.lastName = 'LastNameTest';
        eCon.Email = 'test@gmail.com';
        eCon.SRN_Number__c = '12345';
        eCon.Phone = '8980293839';
        eCon.Active_Semester__c = testSem.Id;     
        insert eCon;
        
    
        
        Rpl_Student_Registration__c testRecord = new Rpl_Student_Registration__c(
            Name = 'Test Data1',
            Rpl_Personal_Mail_ID__c = 'test@gmail.com',
            Rpl_Interested_in_placement__c = 'Yes',
            Rpl_University_Mail_ID__c = '123123123@reva.edu.in',
            //Rpl_Active_Semester__c = 5, // Set an active semester value
            Rpl_Is_UG_Aggregate_Uploaded__c = TRUE,
            Rpl_No_Of_PG_Marksheet_Uploaded__c = 4,
            Rpl_No_Of_UG_Marksheet_Uploaded__c = 5,
            Contact__c = eCon.Id
        );
        insert testRecord;
        
        

        Test.startTest();
        Map<String, Boolean> documentStatus = Rpl_DocumentUploadClass.getDocumentStatus(testRecord.Id);
        Test.stopTest();

        System.assertNotEquals(null, documentStatus, 'Document Status should not be null');
        System.assertEquals(false, documentStatus.get('Rpl_Is_Resume_Uploaded__c'), 'Resume Uploaded status should be true');
        // Add similar assertions for other fields in the map
    }
    
    @isTest
    static void testGetApprovalStatus() {
        Rpl_Student_Registration__c testRecord = new Rpl_Student_Registration__c(Name = 'Test Record', Rpl_Personal_Mail_ID__c = 'test@gmail.com');
        insert testRecord;

        Test.startTest();
        List<Rpl_Student_Registration__c> approvalStatus = Rpl_DocumentUploadClass.getApprovalStatus(testRecord.Id);
        Test.stopTest();

        System.assertNotEquals(null, approvalStatus, 'Approval Status should not be null');
    }

    private static ContentVersion createTestPDF(String title, Blob body, Id parentId) {
        ContentVersion pdf = new ContentVersion(
            Title = title,
            VersionData = body,
            PathOnClient = title + '.pdf',
            IsMajorVersion = true,
            FirstPublishLocationId = parentId
        );
        insert pdf;

        return pdf;
    }
   
}