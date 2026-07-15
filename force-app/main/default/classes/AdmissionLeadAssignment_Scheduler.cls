global class AdmissionLeadAssignment_Scheduler implements Schedulable
{
    Global void execute(SchedulableContext sc) 
    {
        //  Instantiate batch class 
        AdmissionLeadAssignment_Batch leadAssign = new AdmissionLeadAssignment_Batch();
        Database.Executebatch(leadAssign,200);
    }
}