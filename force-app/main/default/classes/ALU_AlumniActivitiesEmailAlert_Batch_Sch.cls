global  class ALU_AlumniActivitiesEmailAlert_Batch_Sch implements Schedulable
{
   global void execute(SchedulableContext Sc)
    {
        ALU_AlumniActivitiesEmailAlert_Batch schls = new ALU_AlumniActivitiesEmailAlert_Batch();
        Database.executeBatch(schls,200);
    }
}