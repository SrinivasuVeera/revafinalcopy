@isTest
public class HallTicketExtensionTest {

    @testSetup
    static void setupTestData() {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();  
        
        
        Account testAccount = new Account(Name='TestAcc',RecordTypeId = AccountRecTypeId);
        
        insert testAccount;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = testAccount.Id;
        insert ProgramBatch;
        
        // Create a Contact
         hed__Term__c testSemester = new hed__Term__c(
            hed__Account__c = testAccount.Id,
            Name = 'BOP-2023-2027-Sem-1',
            Term_Number__c = 2
        );
        insert testSemester;
        
        Contact student = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'revatransport@y0pmail.com',
            Active_Semester__c = testSemester.Id,
            Program_Batch__c = ProgramBatch.Id,
            SRN_Number__c = 'RCSE2248'
            // Add other required fields as needed for your test data
        );
        insert student;
        
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1].Id,
            UserName = 'uniqueuser123testuser1@example.com',
            Email = 'testuser@example.com',
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = student.Id
        );
        insert testUser;


        // Create an Exam Notification
        Id recordTypeId = Schema.SObjectType.Rve_Exam_Notification__c.getRecordTypeInfosByDeveloperName().get('hed_IA_Notification').getRecordTypeId();
        Rve_Exam_Notification__c examNotification = new Rve_Exam_Notification__c(
            Name = 'Exam Notification 1',
            Rve_Publish__c = true,
            Rve_Semester__c = testSemester.Id,
            hed_IA_Type__c = 'IA 1',
            rve_Exam_Start_Date__c = Date.today(),
            Rve_End_Date__c = Date.today().addDays(5),
            RecordTypeId = recordTypeId,
            hed_Program_Batch__c = student.Program_Batch__c
        );
        insert examNotification;
        
        
        hed__Course__c Course = new hed__Course__c(
            hed__Course_ID__c = '123456',
            Name = 'Artifical Intelligence',
            hed__Account__c = testAccount.Id,
            HardCore_Sub_Type__c='Theory',
            Maximum_Internal_Marks_Logisys__c = 0,
            Credits__c = 4.0,
            L_T_P__c = '3:0:0',
            No_of_IA_s__c = '1',
            Offered_By_School__c = testAccount.Id,
            Credit_Hours__c = 5.000,
            Maximum_External_Marks__c = 777,
            Total_Maximum_Marks_IA_External__c = 566        
            );
        insert course;

        // Create a Time Table Line Item
        hed_Time_Table_Line_Item__c timeTableLineItem = new hed_Time_Table_Line_Item__c(
            Name = 'Time Table Line Item 1',
            Course__c = course.Id,
            hed_Date__c = Date.today().addDays(1),
            hed_Start_Time__c = Time.newInstance(10, 0, 0, 0),
            hed_End_Time__c = Time.newInstance(12, 0, 0, 0),
            Reva_Exam_Notification__c = examNotification.Id
        );
        insert timeTableLineItem;
        
        Document document;
    document = new Document();
    document.Body = Blob.valueOf('Some Text');
    document.ContentType = 'png';
    document.DeveloperName = 'my_document';
    document.IsPublic = true;
    document.Name = Student.SRN_Number__c;
    document.FolderId = [select id from folder where name = 'Student Images'].id;
    insert document;
    }

    @isTest
    static void testHallTicketExtension() {
        // Set the test user context
        User testUser = [SELECT Id FROM User WHERE Username = 'uniqueuser123testuser1@example.com'];
        
         
        System.runAs(testUser) {
            // Instantiate the controller with a standard controller for Contact
            Contact student = [SELECT Id,SRN_Number__c FROM Contact where SRN_Number__c='RCSE2248'];
            String key = '%' + student.SRN_Number__c + '%';
            system.debug('key'+key);
         //   document doc = [select id,name from document where Name
         //                   LIKE :key limit 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(student);
            HallTicketExtension hallTicketExtension = new HallTicketExtension(sc);

            // Perform assertions
            
        }
    }

    @isTest
    static void testConvertTime() {
        Time testTime = Time.newInstance(8, 30, 0, 0);
        String formattedTime = HallTicketExtension.convertTime(testTime);
        System.assertEquals('08:30 AM', formattedTime, 'The formatted time should be 08:30 AM');
    }

    @isTest
    static void testConvertDate() {
        Date testDate = Date.newInstance(2024, 5, 20);
        String formattedDate = HallTicketExtension.convertDate(testDate);
        System.assertEquals('20-05-24', formattedDate, 'The formatted date should be 20-05-24');
    }
}