@isTest
public class ATT_AttdShortageSMS_Batch_Sch_Test 
{   
    public static testmethod void AttdShortageSMS()
    {
        Test.StartTest();
        ATT_AttdShortageSMS_Batch_Sch AttdShortagesms =  new ATT_AttdShortageSMS_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Attdshort age SMS', Sch, AttdShortagesms);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }

}