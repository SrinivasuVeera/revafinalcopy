global class FEE_UpdateDueDateBatch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        FEE_UpdateDueDateBatch sch = new FEE_UpdateDueDateBatch();
        Database.executeBatch(sch);
    }
}