global class FEE_LateFeeBatch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        FEE_LateFeeBatch sch = new FEE_LateFeeBatch();
        Database.executeBatch(sch,1);
    }
}