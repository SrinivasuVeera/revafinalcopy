@istest
global class SSP_ANNOUNCEMENT_BATCH_SCH_TEST 
{
    global Static TestMethod Void Fee_DueDate()
    {
        Test.StartTest();
        SSP_ANNOUNCEMENT_BATCH_SCH btch =  new SSP_ANNOUNCEMENT_BATCH_SCH();
        String Sch = '0 0 * * * ?';
        String jobId = system.schedule('SSP SCHOLARSHIP ANNOUNCEMENT', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}