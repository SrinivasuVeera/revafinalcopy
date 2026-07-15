global class SLCM_HCM_HstlReqRoomCancelCNFBatch implements  Database.Batchable<sObject>,Database.AllowsCallouts  {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Hostel_Room_Request_For__r.Employee_Number__c, Employee_Salary__c,Reva_Hostel_JoiningDate__c
                                         FROM Reva_Hostel_Request__c 
                                         WHERE Vacating_Request__c = 'Approved'
                                         AND Status__c = 'Vacate Approved'
                                         AND (Room_Request_Type__c = 'Non Teaching' OR Room_Request_Type__c = 'Professor')
                                         AND Hostel_Room_Request_For__c != null
                                         AND Hostel_Room_Request_For__r.Employee_Number__c != null 
                                         AND Is_HCM_Salary_Deduction_CNF__c = true
                                         AND Employee_Salary__c != null 
                                         AND HCM_Approval_Status__c = 'Deduction Approved' 
                                         AND Approved_by_Hostel_Office__c = true
                                         AND Reva_Hostel_Room__c != null
                                         AND Reva_Hostel_JoiningDate__c != null
                                         AND Is_HCM_Salary_Deduction_Cancelled__c = false
                                         AND RevaHostelVacatingDate__c = today]);
    }
    
    global void execute(Database.BatchableContext bc, List<Reva_Hostel_Request__c> lst_requests) {
        system.debug('lst_Contacts '+lst_requests);
        Set<Id> hostelReqIds = new Set<Id>();
        if(!lst_requests.isEmpty()) {
            for (Reva_Hostel_Request__c req : lst_requests) {
                hostelReqIds.add(req.Id);
            } 
            
        }
        
        
        if(!hostelReqIds.isEmpty()) {
            SLCM_HCMHostelCancellationAPI.sendApprovedCancellationToHCM(hostelReqIds);
        }
    }
    
    
    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    }
    
}