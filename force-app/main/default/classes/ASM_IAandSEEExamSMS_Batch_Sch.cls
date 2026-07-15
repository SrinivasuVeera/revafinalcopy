global class ASM_IAandSEEExamSMS_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {        
        ASM_IAandSEEExamSMS_Batch Schcls = new ASM_IAandSEEExamSMS_Batch();
        DataBase.executeBatch(Schcls,50);
    }
    
}