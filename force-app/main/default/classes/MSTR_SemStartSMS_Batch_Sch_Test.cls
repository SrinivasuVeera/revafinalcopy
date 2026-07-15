@isTest
public class MSTR_SemStartSMS_Batch_Sch_Test 
{
    public static testmethod void SemStartSMS_Batch()
    {
        Test.StartTest();
        MSTR_SemStartSMS_Batch_Sch Semstartsms =  new MSTR_SemStartSMS_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Sem Start Sms', Sch, Semstartsms);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }
    
}