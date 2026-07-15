global class Fee_ReminderToMentors_Batch_Sch implements Schedulable
{
global void execute(SchedulableContext bc)
{
    Fee_ReminderToMentors_Batch sch = new Fee_ReminderTOMentors_Batch();
    Database.executebatch(sch,1);
}
}