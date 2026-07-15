@isTest
public class RveExamDeleteExpiredRVPCFeeSchedulerTest {
    
    @isTest
    static void testSchedulerRunsWithoutError() {
        // Future date and time to avoid AsyncException during validation
        String cronExp = '0 0 5 20 12 ? 2025'; // Dec 20, 2025 @ 5:00 AM
        String jobName = 'Test_DeleteExpiredRVPCFeeScheduler';

        Test.startTest();
        String jobId = System.schedule(jobName, cronExp, new RveExamDeleteExpiredRVPCFeeScheduler());
        Test.stopTest();
        
        // Assert job is scheduled
        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');

        // Optionally verify scheduled job details
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression should match');
    }
}