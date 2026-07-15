public class RTREarlyPickupBatchContinuation implements Queueable, Database.AllowsCallouts{
private RTREarlyPickUpMultipleBatchNotification batchInstance;
 
    public RTREarlyPickupBatchContinuation(RTREarlyPickUpMultipleBatchNotification batchInstance) {
        this.batchInstance = batchInstance;
    }
 
    public void execute(QueueableContext context) {
        Database.executeBatch(batchInstance);
    }
}