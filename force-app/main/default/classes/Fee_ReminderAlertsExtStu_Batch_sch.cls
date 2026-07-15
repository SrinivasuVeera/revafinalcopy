//This batch class should be run with batch size 1
global class Fee_ReminderAlertsExtStu_Batch_sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        Fee_ReminderAlertsExtStu_Batch sch = new Fee_ReminderAlertsExtStu_Batch();
        Database.executeBatch(sch,1);
    }
}