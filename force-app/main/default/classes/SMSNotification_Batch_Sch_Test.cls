@IsTest
public class SMSNotification_Batch_Sch_Test 
{
    
    public static testmethod void AttendanceSMS()
    {
        Test.StartTest();
        SMSNotification_Batch_Sch Attendence =  new SMSNotification_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('SMS Notification', Sch, Attendence);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
        
    }
}