global class ATT_MarkAttToProfSMS_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ATT_MarkAttToProfSMS_Batch SchCls = new ATT_MarkAttToProfSMS_Batch();
        DataBase.executeBatch(SchCls,50);
    }
}