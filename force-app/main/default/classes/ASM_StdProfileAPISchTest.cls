/*@isTest
public class ASM_StdProfileAPISchTest {
    public static testmethod Void exe(){
        Test.startTest();
        String Sch = '0 0 * * * ?';
        system.schedule('ASM_StdProfileAPISch',Sch, new ASM_StdProfileAPISch());
        Test.stopTest(); 
    }  
    
   
}*/
@isTest
public class ASM_StdProfileAPISchTest {

    @isTest
    static void testScheduledJobExecution() {
        
        Test.startTest();

        // Simulate scheduling the job
        ASM_StdProfileAPISch scheduler = new ASM_StdProfileAPISch();
        String jobId = System.schedule('Test ASM Scheduler', '0 0 1 * * ?', scheduler);

        // Optional: directly invoke execute method
        scheduler.execute(null);

        Test.stopTest();


        System.debug('Scheduler job ID: ' + jobId);
    }
}