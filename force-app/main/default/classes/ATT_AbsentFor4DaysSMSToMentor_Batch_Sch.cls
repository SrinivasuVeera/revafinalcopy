global class ATT_AbsentFor4DaysSMSToMentor_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {        
        ATT_AbsentFor4DaysSMSToMentor_Batch Schcls = new  ATT_AbsentFor4DaysSMSToMentor_Batch();
        DataBase.executeBatch(Schcls,50);
    }
}