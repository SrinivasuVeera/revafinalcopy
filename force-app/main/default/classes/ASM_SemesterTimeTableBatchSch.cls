public class ASM_SemesterTimeTableBatchSch implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Create an instance of the batch class
        ASM_SemesterTimeTableBatch batchJob = new ASM_SemesterTimeTableBatch();
        // Execute the batch job
        Database.executeBatch(batchJob);
    }
}