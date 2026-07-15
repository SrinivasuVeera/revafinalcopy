public class RTRLateDropOffBatchContinuation implements Queueable, Database.AllowsCallouts {
    private RTRLateDropOffBatchNotification batchInstance;
 
    public RTRLateDropOffBatchContinuation(RTRLateDropOffBatchNotification batchInstance) {
        this.batchInstance = batchInstance;
    }
 
    public void execute(QueueableContext context) {
        Database.executeBatch(batchInstance);
    }
}