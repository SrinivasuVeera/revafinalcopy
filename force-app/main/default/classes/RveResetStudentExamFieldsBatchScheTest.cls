@isTest
public class RveResetStudentExamFieldsBatchScheTest {
    
    @testSetup
static void setupTestData() {
    // Step 1: Create an Academic Program Account
    RecordType academicProgramRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Academic_Program' AND SObjectType = 'Account' LIMIT 1];
    
    Account academicProgram = new Account(
        Name = 'Test Academic Program',
        RecordTypeId = academicProgramRT.Id
    );
    insert academicProgram;

    // Step 2: Create Active Semester record (hed__Term__c) linked to Account
    RecordType semesterRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Semester' AND SObjectType = 'hed__Term__c' LIMIT 1];
    
    hed__Term__c semester = new hed__Term__c(
        Name = 'Test Semester',
        RecordTypeId = semesterRT.Id,
        hed__Account__c = academicProgram.Id,  // <<< REQUIRED FIELD
        Exam_End_Date__c = Date.today().addDays(-1) // yesterday
    );
    insert semester;

    // Step 3: Create Contact with Student Record Type
    Id studentRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();

    Contact student = new Contact(
        FirstName = 'Test',
        LastName = 'Student',
        RecordTypeId = studentRTId,
        Active_Semester__c = semester.Id,
        Checking_Eligibility_for_Exam__c = 'Ineligible',
        Exam_Approval__c = false
    );
    insert student;
}


    @isTest
    static void testScheduler() {
        // Schedule the batch job
        String cronExp = '0 0 0 15 5 ? 2025'; // Arbitrary cron expression
        Test.startTest();
        String jobId = System.schedule('Test Exam Reset Scheduler', cronExp, new RveResetStudentExamFieldsBatchScheduler());
        Test.stopTest();

        // Verify job was scheduled (assert no exception)
        System.assertNotEquals(null, jobId);
    }
}