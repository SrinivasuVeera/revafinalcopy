@istest
global class FEE_LateFeeBatch_Sch_Test 
{
    global Static TestMethod Void LateFeeMethod()
    {
        Test.StartTest();
        FEE_LateFeeBatch_Sch btch =  new FEE_LateFeeBatch_Sch();
        String Sch = '0 0 * * * ?';
        String jobId = system.schedule('late fee Batch', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}