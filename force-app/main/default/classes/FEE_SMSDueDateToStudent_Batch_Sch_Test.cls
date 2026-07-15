@isTest
public class FEE_SMSDueDateToStudent_Batch_Sch_Test 
{
    public static testmethod void SMSDueDateToStudent ()
    { 
        Test.StartTest();
        FEE_SMSDueDateToStudent_Batch_Sch SMSDueDatetostudent =  new FEE_SMSDueDateToStudent_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('SMS Due Date To Student', Sch, SMSDueDatetostudent);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }
    
}