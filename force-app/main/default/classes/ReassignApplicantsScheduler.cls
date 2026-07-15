global class ReassignApplicantsScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new ReassignApplicantsBatch(),
            200
        );
    }
}