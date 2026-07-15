global class UpdateTheTotalAttendanceScheduleApex implements schedulable {    
    global void execute(SchedulableContext sc) {
        // Schedule the batch job
        UpdateTheTotalAttendanceOfStudent batchJob = new UpdateTheTotalAttendanceOfStudent();
        Database.executeBatch(batchJob,100);
    }
}