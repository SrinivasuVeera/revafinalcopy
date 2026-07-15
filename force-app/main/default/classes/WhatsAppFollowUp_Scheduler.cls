Global class WhatsAppFollowUp_Scheduler implements Schedulable{
    
    Global void execute(SchedulableContext sc){      
       
      
       // WhatsAppFollowUpBatch1 leadAssign1 = new WhatsAppFollowUpBatch1();
       // Database.Executebatch(leadAssign1,100);
        
    	WhatsAppFollowUpBatch2 leadAssign2 = new WhatsAppFollowUpBatch2();
       Database.Executebatch(leadAssign2,100);
	        
       // WhatsAppFollowUpBatch3 leadAssign3 = new WhatsAppFollowUpBatch3();
        //Database.executeBatch(leadAssign3,100);
        
    }

}