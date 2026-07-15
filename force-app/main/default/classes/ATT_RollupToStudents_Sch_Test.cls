@Istest
public class ATT_RollupToStudents_Sch_Test 
{
    public Static TestMethod  Void Method()
    {
        Test.StartTest();
        ATT_RollupToStudents_Sch ASM =  new ATT_RollupToStudents_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('RollUpToStudent', Sch, ASM);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}