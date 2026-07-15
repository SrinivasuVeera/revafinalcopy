Global with sharing class LeadAssignment_Scheduler implements Schedulable
{
    Global void execute(SchedulableContext sc) 
    {
        //  Instantiate batch class 
        LeadAssignment_Batch leadAssign = new LeadAssignment_Batch();
        Database.Executebatch(leadAssign,200);
    }
}