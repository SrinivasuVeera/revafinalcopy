public class Rve_FetchSemesterRoomAllotmentBatchSch implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Create an instance of the batch class
        Rve_FetchSemesterRoomAllotmentBatch batchJob = new Rve_FetchSemesterRoomAllotmentBatch();
        // Execute the batch job
        Database.executeBatch(batchJob,1);
    }
}