@isTest
public class IAMarksAcknowledgementSchedulerTest {
    
    @isTest
    static void testSchedulerExecution() {
        // Enqueue the job with a test cron expression
        String cronExp = '0 0 12 * * ?'; 
        String jobName = 'Test_IA_Marks_Acknowledgement_Scheduler';

        // Schedule the job
        Test.startTest();
        String jobId = System.schedule(jobName, cronExp, new IAMarksAcknowledgementScheduler());
        Test.stopTest();

        // Assert that the job was scheduled
        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');

        // Optionally, verify scheduled job exists (not mandatory)
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression should match');
    }
}