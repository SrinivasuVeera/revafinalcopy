@Istest
public class MSTR_UpdateCrseCtnFaculty_Batch_Sch_Test 
{
    public Static TestMethod  Void Method()
    {
        Test.StartTest();
        MSTR_UpdateCrseCtnFaculty_Batch_Sch ASM =  new MSTR_UpdateCrseCtnFaculty_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('UpdateCourseConnection', Sch, ASM);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}