@istest
global class Fee_AlertFirstYear_Batch_sch_Test 
{
    global Static TestMethod Void Fee_DueDate()
    {
        Test.StartTest();
        Fee_AlertFirstYear_Batch_sch btch =  new Fee_AlertFirstYear_Batch_sch();
        String Sch = '0 0 * * * ?';
        String jobId = system.schedule('Fee DueDate Batch', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}