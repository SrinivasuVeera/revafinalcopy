public class RTREarlyDropOffMultipleBatchContinuation implements Queueable, Database.AllowsCallouts{
	private RTREarlyDropOffMultipleBatchNotification batchInstance;
 
    public RTREarlyDropOffMultipleBatchContinuation(RTREarlyDropOffMultipleBatchNotification batchInstance) {
        this.batchInstance = batchInstance;
    }
 
    public void execute(QueueableContext context) {
        Database.executeBatch(batchInstance);
    }
}