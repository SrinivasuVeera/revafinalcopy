@isTest
public class ATT_MarkAttToProfSMS_Batch_Sch_Test 
{
    public static testmethod void MarkAttToProfSMS()
    {
        Test.StartTest();
        ATT_MarkAttToProfSMS_Batch_Sch MarkAttentoProf =  new ATT_MarkAttToProfSMS_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('MarkAttendence To Prof', Sch, MarkAttentoProf);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }
}