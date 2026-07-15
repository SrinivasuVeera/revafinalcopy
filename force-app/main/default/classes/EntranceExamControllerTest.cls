@IsTest
public class EntranceExamControllerTest {
       @TestSetup
    static void setupTestData() {
        // Create a test User
        User testUser = new User(
            LastName = 'testuser',
            Username = 'testuser333@example.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, // Adjust profile name as per your org
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create a Contact for the User
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com'
        );
        insert testContact;

        // Create a hed__Application__c record for the User
        hed__Application__c app = new hed__Application__c(
            hed__Applicant__c = testUser.contactId
        );
        insert app;

        // Create an Entrance_Exam__c record related to the Application
        Entrance_Exam__c exam = new Entrance_Exam__c(
            Name = 'Test Exam',
            Exam_Type__c = 'National',
            Rank__c = '1',
            Roll_No__c = '12345',
            State__c = 'Andhra Pradesh',
            Application__c = app.Id
        );
        insert exam;
        
          Entrance_Exam__c examRecord = new Entrance_Exam__c();
        examRecord.Name = 'Sample Exam';
        examRecord.National_level__c = 'GATE';
        examRecord.State_level__c = 'KCET';
        examRecord.State__c = 'Andhra Pradesh';
        insert examRecord;
    }

   


    @IsTest
    static void testGetExamNameOptions() {
        // Call the method
        Test.startTest();
        List<String> nationalExamOptions = EntranceExamController.getExamNameOptions();
        Test.stopTest();

        // Assert that the options are not null and contain expected values
        System.assertNotEquals(null, nationalExamOptions, 'National Exam options should not be null');
        System.assert(nationalExamOptions.contains('GATE'), 'Options should include "National Exam 1"');
    }

    @IsTest
    static void testGetStateExamNameOptions() {
        // Call the method
        Test.startTest();
        List<String> stateExamOptions = EntranceExamController.getStateExamNameOptions();
        Test.stopTest();

        }

    @IsTest
    static void testGetStateOptions() {
        // Call the method
        Test.startTest();
        List<String> stateOptions = EntranceExamController.getStateOptions();
        Test.stopTest();

        // Assert that the options are not null and contain expected values
        System.assertNotEquals(null, stateOptions, 'State options should not be null');
    }
    
     @IsTest
    static void testAllotedOptions() {
        // Call the method
        Test.startTest();
        List<String> stateOptions = EntranceExamController.getAllotedCategoryOptions();
        Test.stopTest();

          }
    
     @IsTest
    static void testCreateEntranceExamRecord() {
        // Get the current user (the one created in test setup)
        User testUser = [SELECT Id,ContactId FROM User WHERE Username = 'testuser333@example.com' LIMIT 1];

        // Create a list of ExamWrapper objects using constructor
        List<EntranceExamController.ExamWrapper> examWrappers = new List<EntranceExamController.ExamWrapper>();

        EntranceExamController.ExamWrapper exam1 = new EntranceExamController.ExamWrapper();
        exam1.examName = 'Exam 1';
        exam1.rank = '1';
        exam1.rollNo = '1001';
        exam1.examType = 'State';
        exam1.state = 'Andhra Pradesh';
        
        EntranceExamController.ExamWrapper exam2 = new EntranceExamController.ExamWrapper();
        exam2.examName = 'Exam 2';
        exam2.rank = '2';
        exam2.rollNo = '1002';
        exam2.examType = 'State';
        exam2.state = 'Andhra Pradesh';

        examWrappers.add(exam1);
        examWrappers.add(exam2);

        // Call the method to create the entrance exam records
        Test.startTest();
        EntranceExamController.createEntranceExamRecord(examWrappers);
        Test.stopTest();

        // Verify that the Entrance_Exam__c records were inserted
        List<Entrance_Exam__c> insertedExams = [
            SELECT Name, Rank__c, Roll_No__c, Exam_Type__c, State__c 
            FROM Entrance_Exam__c 
            WHERE Application__c IN (SELECT Id FROM hed__Application__c WHERE hed__Applicant__c = :testUser.ContactId)
        ];

      
    }
     @IsTest
    static void testUpdateEntranceExamField() {
        // Get the current user (the one created in test setup)
        User testUser = [SELECT Id,ContactId FROM User WHERE Username = 'testuser333@example.com' LIMIT 1];

        // Call the method
        Test.startTest();
        EntranceExamController.updateEntranceExamField(true); // Passing true as entranceExamValue
        EntranceExamController.getStateByExamName('CUSAT CAT');
        Test.stopTest();

        // Verify the update
        hed__Application__c updatedApp = [
            SELECT Entrance_Exam__c 
            FROM hed__Application__c 
            WHERE hed__Applicant__c = :testUser.ContactId 
            LIMIT 1
        ];
        System.assert(updatedApp.Entrance_Exam__c == true, 'The Entrance_Exam__c field should be updated to true.');
    }

    @IsTest
    static void testEntranceExamRecords() {
        // Get the current user (the one created in test setup)
        User testUser = [SELECT Id,ContactId FROM User WHERE Username = 'testuser333@example.com' LIMIT 1];

        // Call the method
        Test.startTest();
        Boolean result = EntranceExamController.EntranceExamRecords();
        Test.stopTest();

       }

    @IsTest
    static void testGetSavedEntranceExams() {
        // Get the current user (the one created in test setup)
        User testUser = [SELECT Id,ContactId FROM User WHERE Username = 'testuser333@example.com' LIMIT 1];
        
        // Call the method
        Test.startTest();
        List<Entrance_Exam__c> exams = EntranceExamController.getSavedEntranceExams(testUser.ContactId);
        Test.stopTest();

        // Verify the result
        System.assertNotEquals(exams, null, 'The list of entrance exams should not be null');
        System.assert(exams.size() > 0, 'The list should contain at least one exam.');
        System.assert(exams[0].Name == 'Test Exam', 'The exam name should be "Test Exam"');
        System.assert(exams[0].Rank__c == '1', 'The exam rank should be "1"');
    }

@IsTest
static void testDeleteEntranceExamRecord() {
    // Create a test Entrance_Exam__c record
    Entrance_Exam__c examRecord = new Entrance_Exam__c(
        Name = 'Test Exam to Delete',
        Exam_Type__c = 'National',
        Rank__c = '5',
        Roll_No__c = '67890',
        State__c = 'Karnataka'
    );
    insert examRecord;

    // Verify the record was created
    Entrance_Exam__c insertedExam = [SELECT Id FROM Entrance_Exam__c WHERE Id = :examRecord.Id LIMIT 1];
    System.assertNotEquals(null, insertedExam, 'The Entrance_Exam__c record should exist before deletion.');

    // Call the method to delete the record
    Test.startTest();
    EntranceExamController.deleteEntranceExamRecord(insertedExam.Id);
    Test.stopTest();

    // Verify the record was deleted
    Integer examCount = [SELECT COUNT() FROM Entrance_Exam__c WHERE Id = :examRecord.Id];
    System.assertEquals(0, examCount, 'The Entrance_Exam__c record should be deleted.');
}

    
}