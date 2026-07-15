@Istest
global class PenaltyFee_Batch_Sch_Test 
{
    global Static TestMethod Void DueMethod()
    {
        Test.StartTest();
        PenaltyFee_Batch_Sch btch =  new PenaltyFee_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('PenaltyFee_Batch_Sch', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}