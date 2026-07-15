global class ATT_AttdShortageSMS_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {        
        ATT_AttdShortageSMS_Batch Schcls = new ATT_AttdShortageSMS_Batch();
        DataBase.executeBatch(Schcls,50);
    }
}