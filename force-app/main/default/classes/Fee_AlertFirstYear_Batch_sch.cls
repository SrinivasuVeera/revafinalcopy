global class Fee_AlertFirstYear_Batch_sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        Fee_AlertFirstYear_Batch sch = new Fee_AlertFirstYear_Batch();
        Database.executeBatch(sch,1);
    }
}