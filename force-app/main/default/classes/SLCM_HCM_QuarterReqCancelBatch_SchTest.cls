@isTest
public class SLCM_HCM_QuarterReqCancelBatch_SchTest {

       @IsTest
    static void scheduleTestQuarterCancel(){

         Test.StartTest();
        SLCM_HCM_QuarterReqCancelCNFBatch_Sch quarterCancel =  new SLCM_HCM_QuarterReqCancelCNFBatch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Schedule Quarter Cancel', Sch, quarterCancel);
        Test.stopTest();    
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
       
    }
}