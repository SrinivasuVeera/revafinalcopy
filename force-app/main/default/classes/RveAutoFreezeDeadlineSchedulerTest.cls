@Istest
public class RveAutoFreezeDeadlineSchedulerTest {
 public Static TestMethod Void DueMethod()
    {
        Test.StartTest();
        RveAutoFreezeDeadlineScheduler btch =  new RveAutoFreezeDeadlineScheduler();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Auto Freeze Deadline', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }
}