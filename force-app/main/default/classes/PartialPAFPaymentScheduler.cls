global class PartialPAFPaymentScheduler
implements Schedulable {

    global void execute(SchedulableContext sc) {

        Database.executeBatch(
            new PartialPAFPaymentBatch(),
            20
        );
    }
}