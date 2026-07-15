//This batch class should be run with batch size 1
global class PenaltyFee_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        PenaltyFee_Batch sch = new PenaltyFee_Batch();
        Database.executeBatch(sch,1);
    }
}