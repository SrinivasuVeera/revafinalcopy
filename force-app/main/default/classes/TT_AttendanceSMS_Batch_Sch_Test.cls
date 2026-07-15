@IsTest
public class TT_AttendanceSMS_Batch_Sch_Test 
{
    
    public static testmethod void AttendanceSMS()
    {
        Test.StartTest();
        TT_AttendanceSMS_Batch_Sch Attendence =  new TT_AttendanceSMS_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Attendence SMS Batch', Sch, Attendence);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
        
    }
}