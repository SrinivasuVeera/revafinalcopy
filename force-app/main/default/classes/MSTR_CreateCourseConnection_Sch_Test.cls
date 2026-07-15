@Istest
public class MSTR_CreateCourseConnection_Sch_Test 
{
    public Static TestMethod  Void Method()
    {
        Test.StartTest();
        MSTR_CreateCourseConnection_Schedule CourSch =  new MSTR_CreateCourseConnection_Schedule();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Create Course Connection', Sch, CourSch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}