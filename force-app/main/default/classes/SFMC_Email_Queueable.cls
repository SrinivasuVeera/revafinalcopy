public class SFMC_Email_Queueable implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        SFMC_Email_Service.fetchEmailAnalytics();
    }
}