global class SLCM_HCM_QuarterReqCancelCNFBatch implements Database.Batchable<sObject>,Database.AllowsCallouts  {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id
                                         FROM Staff_Quarters_Request__c  
                                         WHERE Vacation_Date__c != null
                                         AND Quarter_Request_For__r.Employee_Number__c != null 
                                         AND Is_HCM_Salary_Deduction_CNF__c = true
                                         AND Employee_Salary__c != null 
                                         AND Status__c = 'Vacation Approved' 
                                         AND Approved_by_Hostel_Office__c = true
                                         AND Staff_Quarters_Joining_Date__c != null
                                         AND Vacation_Date__c = today]);
    }
    
    global void execute(Database.BatchableContext bc, List<Staff_Quarters_Request__c> lst_requests) {
        system.debug('lst_Contacts '+lst_requests);
        Set<Id> quarterReqIds = new Set<Id>();
        if(!lst_requests.isEmpty()) {
            for (Staff_Quarters_Request__c req : lst_requests) {
                quarterReqIds.add(req.Id);
            } 
            
        }
        
        
        if(!quarterReqIds.isEmpty()) {
            SLCM_HCMQuarterCancellationAPI.sendApprovedCancellationToHCM(quarterReqIds);        }
    }
    
    
    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    }
    
    
}