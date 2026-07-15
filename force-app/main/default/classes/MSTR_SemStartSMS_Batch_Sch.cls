global class MSTR_SemStartSMS_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        MSTR_SemStartSMS_Batch Schcls = new MSTR_SemStartSMS_Batch();
        Database.executeBatch(Schcls,50);
    }
    
}