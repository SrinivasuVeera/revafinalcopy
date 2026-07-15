//This batch class should be run with batch size 1
global class Fee_EmailAlertExtStu_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        Fee_EmailAlertExtStu_Batch sch = new Fee_EmailAlertExtStu_Batch();
        Database.executeBatch(sch,1);
    }
}