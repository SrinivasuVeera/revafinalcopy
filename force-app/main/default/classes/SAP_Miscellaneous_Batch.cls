global class SAP_Miscellaneous_Batch implements Schedulable,Database.Batchable<sObject>,Database.AllowsCallouts  {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> feeTypes = new List<String>{'University Fee','Tuition Fee'};
            return Database.getQueryLocator([
                SELECT Id, Name, Fee_Type__c,Parent_Student_Fee__c FROM Student_Fee__c  
                WHERE CreatedDate = TODAY AND Integrated_with_SAP__c = FALSE AND (NOT Name LIKE 'Caution Deposit%')
                AND (Fee_Type__c NOT IN :feeTypes OR (Fee_Type__c IN :feeTypes AND Parent_Student_Fee__c != NULL))]);
    }
    
    
    global void execute(Database.BatchableContext bc, List<Student_Fee__c> scope) {
        List<Id> DemandIds = new List<Id>();
        for (Student_Fee__c fee : scope) {
            DemandIds.add(fee.Id);
        }
        If(!DemandIds.Isempty()){
            SAP_DemandAPI.DemandCreationAPI(DemandIds);
        }
    }
    
    global void execute(SchedulableContext ctx){
        // execute Schedule Class
        Database.executeBatch(new SAP_Miscellaneous_Batch(),1);
    }
    
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients,
    }
}