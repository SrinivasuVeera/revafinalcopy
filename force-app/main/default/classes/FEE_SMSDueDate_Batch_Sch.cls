global class FEE_SMSDueDate_Batch_Sch implements Schedulable 
{
    global void execute(SchedulableContext sc)
    {
        FEE_SMSDueDate_Batch SchCls=new FEE_SMSDueDate_Batch();
        DataBase.executeBatch(SchCls,50);
    }
    
}