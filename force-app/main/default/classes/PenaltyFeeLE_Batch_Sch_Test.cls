@Istest
global class PenaltyFeeLE_Batch_Sch_Test 
{
    global Static TestMethod Void DueMethod()
    {
        Test.StartTest();
        PenaltyFeeLE_Batch_Sch btch =  new PenaltyFeeLE_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Penalty Fee For Lateral Entry Students', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}