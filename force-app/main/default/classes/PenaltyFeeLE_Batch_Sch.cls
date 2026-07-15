global class PenaltyFeeLE_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        PenaltyFeeLE_Batch sch = new PenaltyFeeLE_Batch();
        Database.executeBatch(sch,1);
    }
}