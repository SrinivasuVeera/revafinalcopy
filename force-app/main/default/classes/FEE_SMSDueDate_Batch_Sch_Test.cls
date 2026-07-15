@IsTest
public class FEE_SMSDueDate_Batch_Sch_Test 
{
    public static testmethod void SMSDueDate_Batch()
    {
        Test.StartTest();
        FEE_SMSDueDate_Batch_Sch Feesduedate =  new FEE_SMSDueDate_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('FEE SMS DUE DATE', Sch, Feesduedate);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
    
}