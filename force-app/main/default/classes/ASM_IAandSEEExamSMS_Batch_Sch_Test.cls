@IsTest
public class ASM_IAandSEEExamSMS_Batch_Sch_Test 
{
    public static testmethod void IAandSEEExamSMS()
    {
        Test.StartTest();
        ASM_IAandSEEExamSMS_Batch_Sch IAandSEEExam =  new ASM_IAandSEEExamSMS_Batch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('IAand SEE Exams', Sch, IAandSEEExam);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
        
    }
    
}