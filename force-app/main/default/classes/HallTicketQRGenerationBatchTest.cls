@IsTest
public class HallTicketQRGenerationBatchTest {

    @IsTest
    static void testBatchExecution() {

        /* ------------------------------
           Record Types
        ------------------------------ */
        Id studentRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('Student')
            .getRecordTypeId();

        Id examRtId = Schema.SObjectType.Rve_Exam_Notification__c
            .getRecordTypeInfosByDeveloperName()
            .get('hed_IA_Notification')
            .getRecordTypeId();

        /* ------------------------------
           Program Batch (REQUIRED)
        ------------------------------ */
         Account school = new Account(Name='Test School');
        insert school;

        Account program = new Account(Name='Test Program', ParentId=school.Id);
        insert program;
         // Create Program Plan (Batch)
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name='Test Batch 2025', hed__Account__c = program.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5));
        insert programBatch;
        
    /*    Program_Batch__c batch = new Program_Batch__c(
            Name = 'Test Batch'
        );
        insert batch; */

        /* ------------------------------
           Semester (REQUIRED)
        ------------------------------ */
         // Create Term (Semester)
        hed__Term__c parentTerm = new hed__Term__c(Name = 'Parent Term 2025', Program_Batch__c = programBatch.Id,hed__Account__c = school.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5));
        insert parentTerm;
        
        hed__Term__c semester = new hed__Term__c(Name='Test Semester 1', Program_Batch__c = programBatch.Id, hed__Account__c = school.Id, hed__Start_Date__c = Date.today().addDays(-1),
            hed__End_Date__c = Date.today().addDays(5), hed__Parent_Term__c = parentTerm.Id);
        insert semester;
        
     /*   Rve_Semester__c sem = new Rve_Semester__c(
            Name = 'Sem 1'
        );
        insert sem; */

        /* ------------------------------
           Contact
        ------------------------------ */
        Contact con = new Contact(
            LastName = 'Student',
            SRN_Number__c = 'SRN001',
            Student_Status__c = 'Pursuing',
            RecordTypeId = studentRtId,
            Program_Batch__c = programBatch.Id,
            Active_Semester__c = semester.Id
        );
        insert con;

        /* ------------------------------
           Exam Notification (MATCHING)
        ------------------------------ */
        Rve_Exam_Notification__c notif = new Rve_Exam_Notification__c(
            RecordTypeId = examRtId,
            Rve_Publish__c = true,
            hed_IA_Type__c = 'IA 1',
            hed_Program_Batch__c = programBatch.Id,
            Rve_Semester__c = semester.Id
        );
        insert notif;

        /* ------------------------------
           Run Batch
        ------------------------------ */
        Test.startTest();
        Database.executeBatch(new HallTicketQRGenerationBatch(), 1);
        Test.stopTest();

        /* ------------------------------
           Validate
        ------------------------------ */
        Contact updated = [
            SELECT HallTicket_QR_Data__c
            FROM Contact
            WHERE Id = :con.Id
        ];

        System.assertNotEquals(
            null,
            updated.HallTicket_QR_Data__c,
            'QR data should be generated'
        );
    }
}