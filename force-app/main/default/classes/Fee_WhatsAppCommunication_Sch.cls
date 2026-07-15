global class Fee_WhatsAppCommunication_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        Fee_WhatsAppCommunication sch = new Fee_WhatsAppCommunication();
        Database.executeBatch(sch,1);
    }
}