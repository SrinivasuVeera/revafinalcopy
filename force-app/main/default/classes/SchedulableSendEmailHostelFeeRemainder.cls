global class SchedulableSendEmailHostelFeeRemainder implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendEmailHostelFeeRemainder batch = new SendEmailHostelFeeRemainder();
        Database.executeBatch(batch);
    }
}