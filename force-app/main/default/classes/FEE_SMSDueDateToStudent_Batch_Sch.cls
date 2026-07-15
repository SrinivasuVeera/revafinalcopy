global class FEE_SMSDueDateToStudent_Batch_Sch implements Schedulable
{
    global void execute (SchedulableContext sc)
    {
        FEE_SMSDueDateToStudent_Batch Schcls = new FEE_SMSDueDateToStudent_Batch();
        DataBase.executeBatch(Schcls,50);
    }
    
}