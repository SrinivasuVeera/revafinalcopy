global class FEE_UpdateDueDateLEBatch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        FEE_UpdateDueDateLEBatch sch = new FEE_UpdateDueDateLEBatch();
        Database.executeBatch(sch);
    }
}