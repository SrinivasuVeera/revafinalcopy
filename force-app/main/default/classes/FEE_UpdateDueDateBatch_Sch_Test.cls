@Istest
global class FEE_UpdateDueDateBatch_Sch_Test 
{
    global Static TestMethod Void DueMethod()
    {
        Test.StartTest();
        FEE_UpdateDueDateBatch_Sch btch =  new FEE_UpdateDueDateBatch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('FEE_UpdateDueDateBatch_Sch', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}