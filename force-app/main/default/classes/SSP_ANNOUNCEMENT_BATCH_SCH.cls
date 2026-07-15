global class SSP_ANNOUNCEMENT_BATCH_SCH implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        SSP_ANNOUNCEMENT_BATCH sch = new SSP_ANNOUNCEMENT_BATCH();
        Database.executeBatch(sch,1);
    }
}