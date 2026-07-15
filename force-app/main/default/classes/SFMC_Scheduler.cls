global class SFMC_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {       
        System.enqueueJob(new SFMC_Email_Queueable());
    }
}