@IsTest
public class HallTicketQRDailySchedulerTest {

    @TestSetup
    static void setupData() {

        Id studentRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('Student')
            .getRecordTypeId();

        Account school = new Account(Name = 'Test School');
        insert school;

        Account program = new Account(Name = 'Test Program', ParentId = school.Id);
        insert program;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name               = 'Test Batch 2026',
            hed__Account__c    = program.Id,
            hed__Start_Date__c = Date.today().addDays(-10),
            hed__End_Date__c   = Date.today().addDays(10)
        );
        insert programBatch;

        Contact student = new Contact(
            LastName              = 'Test Student',
            SRN_Number__c         = 'SRN001',
            Application_Number__c = 'APP001',
            Student_Status__c     = 'Pursuing',
            RecordTypeId          = studentRtId,
            Active__c             = true,
            Program_Batch__c      = programBatch.Id
        );
        insert student;

        IA_Seating_Room_Allotment__c room = new IA_Seating_Room_Allotment__c(
            Name                = 'Room-101',
            Exam_Name__c        = 'B. Tech in Civil Engineering-(2024-2028)',
            Room__c             = 'Room-101',
            IA_Type__c          = 'IA 1',
            rve_Date_of_Exam__c = Date.today(),
            Exam_Time__c        = Time.newInstance(9,  0, 0, 0),
            End_Time__c         = Time.newInstance(12, 0, 0, 0),
            Students__c         = 'SRN001'
        );
        insert room;
    }

    @IsTest
    static void testSchedulerExecutes() {

        String cronExp = '0 34 2 * * ?';
        String jobName = 'Test HallTicket QR Scheduler';

        Test.startTest();
        String jobId = System.schedule(
            jobName,
            cronExp,
            new HallTicketQRDailyScheduler()
        );
        Test.stopTest();

        // Verify the job was scheduled successfully
        CronTrigger ct = [
            SELECT Id, CronExpression, State, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertNotEquals(null, ct,             'CronTrigger should exist');
        System.assertEquals('0 34 2 * * ?', ct.CronExpression, 'Cron expression should match 2AM daily');
        System.assertEquals('WAITING',     ct.State,          'Job state should be WAITING');
        System.assertNotEquals(null,        ct.NextFireTime,   'Next fire time should be set');
    }
}