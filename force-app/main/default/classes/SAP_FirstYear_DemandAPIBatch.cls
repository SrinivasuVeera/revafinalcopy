global class SAP_FirstYear_DemandAPIBatch implements Schedulable,Database.Batchable<sObject>,Database.AllowsCallouts {
  global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, FirstName, LastName
                
            FROM Contact WHERE Id IN (
            SELECT ContactId FROM ContactHistory WHERE Field='SRN_Number__c' AND CreatedDate = TODAY) 
        ]);
    }

    global void execute(Database.BatchableContext bc,  List<Contact> lst_Contacts) {
       
        List<Id> DemandIds = new List<Id>();
         List<Id> ContactIds = new List<Id>();
       for(Contact con:lst_Contacts)
       {
            ContactIds.add(con.Id);
         
       }
        for(Student_Fee__c stdFee:[SELECT Id,Integrated_with_SAP__c,Contact__c,Fee_Year__c,Student_Status__c  FROM Student_Fee__c WHERE Fee_Type__c IN ('University Fee', 'Tuition Fee') AND Integrated_with_SAP__c  = FALSE AND Contact__c IN:lst_Contacts AND Fee_Year__c ='1st Year' AND Student_Status__c IN ('Pursuing', 'Year Back')] )
        {
            DemandIds.add(stdFee.Id);
        }
        
       
        if(!DemandIds.isEmpty())
        {
            SAP_DemandAPI.DemandCreationAPI(DemandIds);
        }
    }

    global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_FirstYear_DemandAPIBatch(),1);
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }
}