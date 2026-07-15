@isTest
public class SLCM_HCM_HstlReqCancelCNFBatch_Sch_Test {
    @IsTest
    static void scheduleTestHstleCancel(){

        Test.StartTest();
        SLCM_HCM_HstlReqRoomCancelCNFBatch_Sch hstleCnfCancel =  new SLCM_HCM_HstlReqRoomCancelCNFBatch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Schedule Hostel Cancel CNF', Sch, hstleCnfCancel);
        Test.stopTest();    
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
       
    }

}