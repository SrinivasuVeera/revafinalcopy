public class FEE_StudentExamPaymentQueue implements Queueable {
    
    set<Id> StudPayFeeIds;
    public FEE_StudentExamPaymentQueue(set<Id> fetchedIds) {
        StudPayFeeIds = fetchedIds;
        system.debug('StudPayFeeIdsFromQueue==>'+StudPayFeeIds.size());
    }
    
    public void execute(QueueableContext context) {
        // Call the future method
         system.debug('StudPayFeeIdsFromQueueExecute==>'+StudPayFeeIds.size());
        FEE_StudentExamPayment_API.sendStudExamFee(StudPayFeeIds);
    }
}