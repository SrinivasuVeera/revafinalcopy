public class RTRLateDropOffParentBatchContinue implements Queueable, Database.AllowsCallouts{
	private RTRLateDropOffParentBatchNotify batchInstance;
 
    public RTRLateDropOffParentBatchContinue(RTRLateDropOffParentBatchNotify batchInstance) {
        this.batchInstance = batchInstance;
    }
 
    public void execute(QueueableContext context) {
        Database.executeBatch(batchInstance);
    }
}