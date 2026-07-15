public class Rve_FetchSemesterAttendanceBatchsch implements Schedulable {
    public String session;

    // Constructor for schedule apex
    public Rve_FetchSemesterAttendanceBatchsch(String session) {
        this.session = session;
    }
    
    public void execute(SchedulableContext sc) {
        // Call the batch class
        Rve_FetchSemesterAttendanceBatch batchJob = new Rve_FetchSemesterAttendanceBatch(session);
        Database.executeBatch(batchJob);
    }
}