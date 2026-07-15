@isTest
public class ATT_AbsentFor4DaySMSToMen_Batch_Sch_Test 
{
    public static testmethod void AbsentFor4DaySMSToMen()
    {
        Test.StartTest();
        ATT_AbsentFor4DaysSMSToMentor_Batch_Sch Absent4days =  new ATT_AbsentFor4DaysSMSToMentor_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('AbsentFor 4days SMs To Mentor', Sch, Absent4days);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }
    
}