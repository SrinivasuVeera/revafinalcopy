@isTest
public class SLCM_HCM_QuarterReqAllotCNFBatch_SchTest {
    
       @IsTest
    static void scheduleTestQuarterCNF(){

         Test.StartTest();
        SLCM_HCM_QuarterReqRoomAllotCNFBatch_Sch quarterCnf =  new SLCM_HCM_QuarterReqRoomAllotCNFBatch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Schedule Quarter Cnf', Sch, quarterCnf);
        Test.stopTest();    
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
       
    }

}