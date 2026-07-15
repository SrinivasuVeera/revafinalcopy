//This batch class should be run with batch size 1
global class DeleteEducationHistoryBatch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        DeleteEducationHistoryBatch sch = new DeleteEducationHistoryBatch();
        Database.executeBatch(sch,2000);
    }
}