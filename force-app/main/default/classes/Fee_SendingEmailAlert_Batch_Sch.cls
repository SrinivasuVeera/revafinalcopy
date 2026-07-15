//This batch class should be run with batch size 1
global class Fee_SendingEmailAlert_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        Fee_SendingEmailAlert_Batch sch = new Fee_SendingEmailAlert_Batch();
        Database.executeBatch(sch,1);
    }
}