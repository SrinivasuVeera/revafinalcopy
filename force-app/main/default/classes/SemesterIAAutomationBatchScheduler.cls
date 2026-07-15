global class SemesterIAAutomationBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {      
        SemesterIAAutomationBatch batch = new SemesterIAAutomationBatch();
        Database.executeBatch(batch, 5);
    }
}