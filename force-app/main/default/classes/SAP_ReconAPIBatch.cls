global class SAP_ReconAPIBatch implements Schedulable,Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
  global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Integrated_with_SAP__c,Demand_Integration_Date__c,Reconciliation_Completed__c,Cancelled__c FROM Student_Fee__c WHERE Integrated_with_SAP__c =true AND 
                                        Reconciliation_Completed__c  = false AND Cancelled__c = false AND Demand_Integration_Date__c = TODAY]);
    }

    global void execute(Database.BatchableContext bc, List<Student_Fee__c> scope) {
        // process each batch of records
        List<Id> demandIds = new List<Id>();
        
        for(Student_Fee__c objStdFee:scope){
            demandIds.add(objStdFee.Id);
        }
        
        if(!demandIds.isEmpty()){
            SAP_ReconAPI.sendSLCMReconciliationRequest(demandIds);
        }
    }

    global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Integer  batchSize = Integer.valueOf(label.Recon_API_Batch_size);
        
        Database.executeBatch(new SAP_ReconAPIBatch(),batchSize);
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }
}