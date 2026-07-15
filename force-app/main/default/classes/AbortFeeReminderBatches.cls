public class AbortFeeReminderBatches {
    
    public static void abortJobByName() {
        //System.debug('abortJobByName : jobName ' +  );
        List<CronTrigger> cronTriggers = [select id, TimesTriggered, NextFireTime, CronExpression, PreviousFireTime, StartTime, EndTime 
                                          from CronTrigger WHERE CronJobDetail.Name LIKE '%Fee Reminder%'];
        for(CronTrigger cronTrigger : cronTriggers ) {
            abortJobById(cronTrigger.Id);
        }
    }
    
    public static void abortJobById(String jobId) {
        System.debug('GoogleEmailSch.abortJobById : jobId ' + jobId );
        System.abortJob(jobId);
    }
}