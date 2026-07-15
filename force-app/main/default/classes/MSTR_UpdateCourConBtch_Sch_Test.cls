@IsTest
public class MSTR_UpdateCourConBtch_Sch_Test 
{
	public static testmethod void Test()
    {
        Test.StartTest();
        MSTR_UpdateCourConBtch_Sch Semstartsms =  new MSTR_UpdateCourConBtch_Sch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('Sem Start Sms', Sch, Semstartsms);
        Test.stopTest();    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);  
    }
}