@IsTest
public class HallTicketQRGenerationBatchSchedulerTest {

    @IsTest
    static void testSchedulerExecution() { 

        Test.startTest();
        String cronExp = '0 0 1 * * ?';
        System.schedule(
            'TestHallTicketScheduler',
            cronExp,
            new HallTicketQRGenerationBatchScheduler()
        );
        Test.stopTest();

        // Verify the scheduled job was registered
        CronTrigger ct = [
            SELECT Id,
                   CronExpression,
                   State,
                   CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'TestHallTicketScheduler'
            LIMIT 1
        ];

        System.assertEquals(
            '0 0 1 * * ?',
            ct.CronExpression,
            'Cron expression should match 1:00 AM daily schedule'
        );
        System.assertEquals(
            'WAITING',
            ct.State,
            'Scheduled job should be in WAITING state'
        );
    }
}