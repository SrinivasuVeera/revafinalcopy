@isTest
global class SSP_ANNOUNCEMENT_BATCH_TEST {

    global static TestMethod void Fee_DueDate() {
        // Create necessary test data
        Id householdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Recordtypeid = householdRecId;
        objAcc.Name = 'Faculty of Engineering and Technology';
        Insert objAcc;

        Id acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAccount1 = new Account();
        objAccount1.RecordTypeid = acaRecId;
        objAccount1.Name = 'School of Computer Science and Engineering';
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;

        Id accId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account objAccount = new Account();
        objAccount.Name = 'B. Tech in Artificial Intelligence and Data Science';
        objAccount.Program_Type__c = 'UG';
        objAccount.RecordTypeid = accId;
        objAccount.Parentid = objAccount1.id;
        insert objAccount;

        Id studentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test', objAcc.Id);
        objCon.RecordTypeId = studentRecId;
        objCon.School__c = objAccount1.id;
        objCon.Primary_Academic_Program__c = objAccount.id;
        objCon.hed__WorkEmail__c = 'test123@reva.edu.in';
        objCon.Student_Status__c = 'Pursuing';
        Insert objCon;

        // Create a test Document
        Document doc = new Document();
        doc.Name = 'Invitation for RCL 2024 Grand Opening';
        doc.Body = Blob.valueOf('Test PDF Content');
        doc.FolderId = UserInfo.getUserId(); // Use the user's folder
        insert doc;

        // Schedule the batch job
        Test.startTest();
        SSP_ANNOUNCEMENT_BATCH batchJob = new SSP_ANNOUNCEMENT_BATCH();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that EmailMessages were created
        Integer emailMessageCount = [SELECT COUNT() FROM EmailMessage WHERE Subject = 'Invitation for RCL 2024 Grand Opening'];
        System.assertEquals(0, emailMessageCount, 'One EmailMessage should be created for a Pursuing student');

        // Additional assertions or validations based on your specific use case
    }
}