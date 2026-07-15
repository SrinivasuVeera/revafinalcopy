@isTest
public class SLCM_HCM_HstlReqAllotCNFBatch_SchTest {
   

    @IsTest
    static void scheduleTestHstleCNF(){

         Test.StartTest();
        SLCM_HCM_HstlReqRoomAllotCNFBatch_Sch hstleCnf =  new SLCM_HCM_HstlReqRoomAllotCNFBatch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Schedule Hostel Cnf', Sch, hstleCnf);
        Test.stopTest();    
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
       
    }
   
}