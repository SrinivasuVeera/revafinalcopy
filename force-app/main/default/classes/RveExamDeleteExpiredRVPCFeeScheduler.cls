public class RveExamDeleteExpiredRVPCFeeScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        RveExamDeleteExpiredRVFeeAndPCFeeBatch batch = new RveExamDeleteExpiredRVFeeAndPCFeeBatch();
        Database.executeBatch(batch, 200);
    }
}