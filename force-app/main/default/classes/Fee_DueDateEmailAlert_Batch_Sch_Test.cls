@istest
global class Fee_DueDateEmailAlert_Batch_Sch_Test 
{
    global Static TestMethod Void Fee_DueDate()
    {
        Test.StartTest();
        Fee_DueDateEmailAlert_Batch_Sch btch =  new Fee_DueDateEmailAlert_Batch_Sch();
        String Sch = '0 0 * * * ?';
        String jobId = system.schedule('Fee DueDate Batch', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}