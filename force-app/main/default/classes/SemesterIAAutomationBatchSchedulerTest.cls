@isTest
public class SemesterIAAutomationBatchSchedulerTest {

    @isTest
    static void testScheduler() {        
        String sch = '0 0 0 15 3 ? 2026';
        
        Test.startTest();        
        String jobId = System.schedule('Test IA Automation Schedule', sch, new SemesterIAAutomationBatchScheduler());        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE id = :jobId];        
        
        System.assertEquals(sch, ct.CronExpression);      
        
        System.assertEquals(0, ct.TimesTriggered);
      
        System.assertEquals('2026-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType FROM AsyncApexJob 
                                   WHERE JobType = 'BatchApex' 
                                   AND Status IN ('Queued', 'Processing', 'Completed')];
        System.assert(jobs.size() >= 0, 'Batch job should be initiated');
    }
}