@istest
global class DeleteEducationHistoryBatch_Sch_Test 
{
    global Static TestMethod Void Fee_DueDate()
    {
        Test.StartTest();
        DeleteEducationHistoryBatch_Sch btch =  new DeleteEducationHistoryBatch_Sch();
        String Sch = '0 0 * * * ?';
        String jobId = system.schedule('Delete EducationHistory Records', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}