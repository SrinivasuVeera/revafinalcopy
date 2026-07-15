global class UpdateTATBusinessDaysScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new UpdateTATBusinessDaysBatch(),
            200
        );
    }
}