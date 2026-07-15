public class SchedulableHostelFeeReminderBatch implements Schedulable {
    Public void execute(SchedulableContext sc) {
        StudentHostelFeeReminderBatch batch = new StudentHostelFeeReminderBatch();
        Database.executeBatch(batch,100);
        
        ParentHostelFeeReminderBatch batch2 = new ParentHostelFeeReminderBatch();
        Database.executeBatch(batch2,100);
    }
}