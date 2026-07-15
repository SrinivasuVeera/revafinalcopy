global class ATT_RollupToStudents_Sch implements Schedulable
{
    global void execute (SchedulableContext sc)
    {
        ATT_RollupToStudents_Batch Sch = New ATT_RollupToStudents_Batch();
         Database.executeBatch(Sch,1);
    }
}