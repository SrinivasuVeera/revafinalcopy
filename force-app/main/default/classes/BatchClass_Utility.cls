public class BatchClass_Utility 
{
	public static void sendBatchClassFailureMail(String moduleName, String jobId, String subject,string objectName)
    {
        Batch_Failure_Emails__c objBatch = Batch_Failure_Emails__c.getValues(moduleName);
        AsyncApexJob objAsyncApexJob = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed,
                                        TotalJobItems, CreatedBy.Email, Apexclass.Name from AsyncApexJob where 
                                        Id =:jobId];
        if(objAsyncApexJob.NumberOfErrors > 0 || test.isRunningTest())
        {
            Debug_Log__c objDebugLog = new Debug_Log__c();
            objDebugLog.Class_Name__c = objAsyncApexJob.Apexclass.Name;
            objDebugLog.Error_Message__c = objAsyncApexJob.ExtendedStatus;
            objDebugLog.No_of_Jobs_Processed__c = objAsyncApexJob.TotalJobItems;
            objDebugLog.No_of_Failure_Jobs__c = objAsyncApexJob.NumberOfErrors;
            objDebugLog.Object_Name__c = objectName;
            Insert objDebugLog;
            
            String dbLogNo = [Select Id, Name from Debug_Log__c where Id =:objDebugLog.Id].Name;
            string Htmlbody='<html><body>'+
                'Dear Sir/Madam,<br/><br/>'+
                '<table cellpadding="6" cellspacing="0" border="1" width="65%">'+
                '<tr><td><b>Debug Log Number</b></td><td>'+dbLogNo+'</td></tr>'+
                '<tr><td><b>Class Name</b></td><td>'+objAsyncApexJob.ApexClass.Name+'</td></tr>'+
                '<tr><td><b>Total Number of Jobs Processed</b></td><td>'+objAsyncApexJob.TotalJobItems+'</td></tr>'+
                '<tr><td><b>Total Number of Failure Jobs</b></td><td>'+objAsyncApexJob.NumberOfErrors+'</td></tr>'+
                '<tr><td><b>Error Message</b></td><td>'+objAsyncApexJob.ExtendedStatus+'</td></tr>'+
                '</table>'+
                '</body></html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(objBatch.Email_Ids__c.split(','));
            mail.setSubject(subject+' - ' + objAsyncApexJob.Status);
            mail.setHtmlBody(Htmlbody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}