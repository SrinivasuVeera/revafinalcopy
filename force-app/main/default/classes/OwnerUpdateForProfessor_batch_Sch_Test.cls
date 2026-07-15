@isTest
public class OwnerUpdateForProfessor_batch_Sch_Test 
{
    public static testmethod void method()
    {
        {
            Test.StartTest();
            OwnerUpdateForProfessor_batch_Sch Professor =  new OwnerUpdateForProfessor_batch_Sch();
            String Sch = '0 0 * * * ?';
            string jobId = system.schedule('Owner Update For Professor', Sch, Professor);
            Test.stopTest();    
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(sch, ct.CronExpression);
        } 
        
    }
    
}