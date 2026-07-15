@isTest
public class BatchClass_Utility_Test 
{
    public static testMethod void BatchClassUtility()
    {
        Batch_Failure_Emails__c btEmail = new Batch_Failure_Emails__c();
        btEmail.name='Assessment Module';
        btEmail.Email_Ids__c = 'chetan@epeoplebc.com';
        insert btEmail;
        
        Test.startTest();         
        ASM_UpdateCourseConnectionBatch btch = new ASM_UpdateCourseConnectionBatch();
        Id jobid= Database.executeBatch(btch,5);
        BatchClass_Utility.sendBatchClassFailureMail('Assessment Module',jobid,'Create Course Connection Batch','Student_Semester_Mapping__c');
        Test.stopTest();
        system.assertEquals('Assessment Module', btEmail.name);
    }
    
}