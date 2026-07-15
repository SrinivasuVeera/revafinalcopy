global class UpdateStudentFeePaymentBatch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        UpdateStudentFeePaymentBatch sch = new UpdateStudentFeePaymentBatch();
        Database.executeBatch(sch,1);
    }
}