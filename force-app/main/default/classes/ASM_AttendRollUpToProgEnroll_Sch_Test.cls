@Istest
global class ASM_AttendRollUpToProgEnroll_Sch_Test 
{
    global Static TestMethod  Void Method()
    {
        Test.StartTest();
        ASM_AttendRollUpToProgEnrollment_Sch ASM =  new ASM_AttendRollUpToProgEnrollment_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('AttendenceRollUp', Sch, ASM);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}