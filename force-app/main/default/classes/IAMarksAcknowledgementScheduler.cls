public class IAMarksAcknowledgementScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        IAMarksAcknowledgementBySystemBatch batchJob = new IAMarksAcknowledgementBySystemBatch();
        Database.executeBatch(batchJob, 200);
    }
}