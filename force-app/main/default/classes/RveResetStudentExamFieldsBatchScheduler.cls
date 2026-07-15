public class RveResetStudentExamFieldsBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        RveResetStudentExamFieldsBatch batch = new RveResetStudentExamFieldsBatch();
        Database.executeBatch(batch, 200); // 200 is the batch size
    }
}