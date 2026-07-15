global class HallTicketQRGenerationBatchScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Date examDate = Date.today().addDays(10);

        HallTicketQRGenerationBatchNew batch =
            new HallTicketQRGenerationBatchNew(examDate);

        Database.executeBatch(batch, 200);
    }
}