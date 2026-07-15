global class SAP_SRN_PushtoSAPBatch implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
  global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, FirstName, LastName
            FROM Contact WHERE Id IN (
            SELECT ContactId FROM ContactHistory WHERE Field='SRN_Number__c' AND CreatedDate = TODAY) 
        ]);
    }
     global void execute(Database.BatchableContext bc,  List<Contact> lst_Contacts) {
          system.debug('lst_Contacts '+lst_Contacts);
         List<Id> ContactIds = new List<Id>();
       for(Contact con:lst_Contacts)
       {
            ContactIds.add(con.Id);
       }
         
        if(!ContactIds.isEmpty())
        {
            SAP_SRN_PushtoSAPBatchAPIHandler.StudentMasterCreationMethod(ContactIds);
        }  
     }
      global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_SRN_PushtoSAPBatch(),10);
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }

}