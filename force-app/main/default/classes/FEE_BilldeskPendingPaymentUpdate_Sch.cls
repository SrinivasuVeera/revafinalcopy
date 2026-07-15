global class FEE_BilldeskPendingPaymentUpdate_Sch implements schedulable{

    global void execute(SchedulableContext sc)
    {
        FEE_BilldeskPendingPaymentUpdateBatch billDesk = new FEE_BilldeskPendingPaymentUpdateBatch();
        Database.executeBatch(billDesk, 1);
    }
}