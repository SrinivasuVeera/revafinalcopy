global class SAP_DemandAPI_Batch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts  {
    private Set<Id> contactIds;
    private String feeYear;
    global SAP_DemandAPI_Batch(Set<Id> Ids,String fee_Year){
        contactIds = Ids;
        feeYear = fee_Year;
    }
     /* global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_DemandAPI_Batch(contactIds,feeYear),1);
    }*/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, (SELECT Id FROM Student_Fees__r WHERE Fee_Year__c =:feeYear AND Student_Status__c IN ('Pursuing', 'Year Back')
                                                     AND  Fee_Type__c IN ('University Fee', 'Tuition Fee')
                                                    ) FROM Contact WHERE Id IN:contactIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> lst_Contacts) {
        
        List<Id> DemandIds = new List<Id>();
        
       for(Contact con:lst_Contacts)
       {
           for(Student_Fee__c objStdFee:con.Student_Fees__r)
           {
               
               DemandIds.add(objStdFee.Id);
           }
       }
      
        if(!DemandIds.isEmpty())
        {
            SAP_DemandAPI.DemandCreationAPI(DemandIds);
        }
    }
   
    
    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    }
}