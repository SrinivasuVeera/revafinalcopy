Global class WhatsAppFollowUp_LeadVerified_Scheduler implements Schedulable {
    Global void execute(SchedulableContext sc){          
            WhatsAppFollowUpBatch4 leadAssign4 = new WhatsAppFollowUpBatch4();
            Database.Executebatch(leadAssign4,2000);
    }
}