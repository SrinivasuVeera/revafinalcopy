Global class WhatsAppFollowUp_PAF_Scheduler implements Schedulable {
   Global void execute(SchedulableContext sc){          
            WhatsAppFollowUpBatch5 leadAssign5 = new WhatsAppFollowUpBatch5();
            Database.executeBatch(leadAssign5,100);
   }
}