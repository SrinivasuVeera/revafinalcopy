public class Rpl_SchedulestudentshareBatch implements Schedulable {
    public void execute(SchedulableContext sc) {
        Rpl_StudentShareBatch batchInstance = new Rpl_StudentShareBatch();
        Database.executeBatch(batchInstance, 200); // Adjust the batch size as needed
    }
}