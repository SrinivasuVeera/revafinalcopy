@isTest
public class ALU_AlumniActivEmailAltBatch_Sch_Test
{
   
     public Static TestMethod void Schmethod()
    {  
        Test.StartTest();
        ALU_AlumniActivitiesEmailAlert_Batch_Sch reSch = new ALU_AlumniActivitiesEmailAlert_Batch_Sch();
        String sch = '0 0 12 * * ?';
        system.schedule('jobName', sch, reSch);     
        Test.StopTest();        
    
         
    }
}