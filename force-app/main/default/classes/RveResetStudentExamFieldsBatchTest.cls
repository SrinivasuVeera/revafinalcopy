@isTest
public class RveResetStudentExamFieldsBatchTest {
    @isTest
    static void testBatchExecution_SingleMatch() {
        // Fetch RecordTypes
        RecordType studentRt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Contact' AND DeveloperName = 'Student' 
            LIMIT 1
        ];
        
        RecordType semRt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'hed__Term__c' AND DeveloperName = 'Semester' 
            LIMIT 1
        ];

        // Insert required Account and Program Plan
        Account testAccount = new Account(Name = 'Test Institution');
        insert testAccount;

        hed__Program_Plan__c testProgramPlan = new hed__Program_Plan__c(
            Name = 'Test Program Plan'
        );
        insert testProgramPlan;

        // Create a Semester with all 3 end dates set to YESTERDAY
        Date yesterday = Date.today().addDays(-1);
        hed__Term__c semester = new hed__Term__c(
            Name = 'Test Semester',
            RecordTypeId = semRt.Id,
            Exam_End_Date__c = yesterday,
            IA_1_End_date__c = yesterday,
            IA_2_End_date__c = yesterday,
            hed__Account__c = testAccount.Id,
            Program_Batch__c = testProgramPlan.Id
        );
        insert semester;

        // Create a Contact that should match the batch criteria
        Contact ineligibleStudent = new Contact(
            FirstName = 'Ineligible',
            LastName = 'Student',
            RecordTypeId = studentRt.Id,
            Active_Semester__c = semester.Id,
            Checking_Eligibility_for_Exam__c = 'Ineligible', // <- case-sensitive match
            Exam_Approval__c = false,
            Description = 'To be cleared',
            Date_of_Approval__c = Date.today()
        );
        insert ineligibleStudent;

        // Execute the batch
        Test.startTest();
        RveResetStudentExamFieldsBatch batch = new RveResetStudentExamFieldsBatch();
        Database.executeBatch(batch, 1); // Batch size 1
        Test.stopTest();

        // Query updated Contact to verify field resets
        Contact updatedCon = [
            SELECT Checking_Eligibility_for_Exam__c, Exam_Approval__c, Description, Date_of_Approval__c
            FROM Contact 
            WHERE Id = :ineligibleStudent.Id
        ];
        
       System.assertEquals(null, updatedCon.Checking_Eligibility_for_Exam__c, 'Eligibility should be reset');
        System.assertEquals(null, updatedCon.Description, 'Description should be cleared');
        System.assertEquals(null, updatedCon.Date_of_Approval__c, 'Date of approval should be cleared');
        System.assertEquals(false, updatedCon.Exam_Approval__c, 'Exam approval should remain false');

        // Assert Exam_Approval_History__c was created
        List<Exam_Approval_History__c> histories = [
            SELECT Contact__c, Approved__c 
            FROM Exam_Approval_History__c 
            WHERE Contact__c = :ineligibleStudent.Id
        ];
        System.assertEquals(1, histories.size(), 'One exam history record expected');
        System.assertEquals(false, histories[0].Approved__c, 'History should mark as not approved');
    }
}