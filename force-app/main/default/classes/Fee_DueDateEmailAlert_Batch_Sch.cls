//This batch class should be run with batch size 1
global class Fee_DueDateEmailAlert_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        Fee_DueDateEmailAlert_Batch sch = new Fee_DueDateEmailAlert_Batch();
        Database.executeBatch(sch,1);
    }
}