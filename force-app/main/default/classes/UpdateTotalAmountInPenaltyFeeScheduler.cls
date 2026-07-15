global class UpdateTotalAmountInPenaltyFeeScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Instantiate the batch class
        UpdateTotalAmountInPenaltyFeeBatch batchInstance = new UpdateTotalAmountInPenaltyFeeBatch();
        database.executebatch(batchInstance);
    }
}