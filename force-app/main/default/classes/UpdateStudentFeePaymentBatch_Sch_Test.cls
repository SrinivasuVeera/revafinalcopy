@istest
global class UpdateStudentFeePaymentBatch_Sch_Test 
{
    global Static TestMethod Void Fee_DueDate()
    {
        Test.StartTest();
        UpdateStudentFeePaymentBatch_Sch btch =  new UpdateStudentFeePaymentBatch_Sch();
        String Sch = '0 0 * * * ?';
        String jobId = system.schedule('Update Student Fee Payment', Sch, btch);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    } 
}