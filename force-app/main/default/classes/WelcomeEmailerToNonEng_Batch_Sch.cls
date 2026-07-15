//This batch class should be run with batch size 1
global class WelcomeEmailerToNonEng_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        WelcomeEmailerToNonEng_Batch sch = new WelcomeEmailerToNonEng_Batch();
        Database.executeBatch(sch,1);
    }
}