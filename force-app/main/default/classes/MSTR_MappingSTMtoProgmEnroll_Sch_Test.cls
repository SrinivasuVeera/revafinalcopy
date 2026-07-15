@istest
public class MSTR_MappingSTMtoProgmEnroll_Sch_Test 
{
    public Static Testmethod Void STMtoProgmEnroll()
    {
        Test.StartTest();
        MSTR_MappingSTMtoProgmEnroll_Schedule CourSch =  new MSTR_MappingSTMtoProgmEnroll_Schedule();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Create Course Connection', Sch, CourSch);
        Test.stopTest();    
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }    
}