global class SMSNotification_Batch_Sch implements Schedulable 
{
    global void execute(SchedulableContext sc)
    {
        SMSNotification_Batch SchCls = new SMSNotification_Batch();
        DataBase.executeBatch(SchCls,1);
    }
}