global class SLCM_HCM_QuarterReqRoomAllotCNFBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    List<Staff_Quarters_Request__c> senNotificationForStaffReq = new List<Staff_Quarters_Request__c>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Quarter_Request_For__r.Employee_Number__c, Employee_Salary__c
                                         FROM Staff_Quarters_Request__c 
                                         WHERE Quarter_Request_For__r.Employee_Number__c != null  
                                         AND Employee_Salary__c != null 
                                         AND HCM_Approval_Status__c = 'Deduction Approved' 
                                         AND Approved_by_Hostel_Office__c = true
                                         AND Staff_Quarters_Joining_Date__c != null 
                                         AND Status__c ='Approved'
                                         AND Staff_Quarters_Joining_Date__c = today]);
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
            senNotificationForStaffReq = SLCM_HCMQuarterCNFAPI.sendApprovedConfirmationHCM(quarterReqIds);
        }
        
        System.debug('senNotificationForStaffReq ---'+senNotificationForStaffReq);
        if (!senNotificationForStaffReq.isEmpty()) {
            Set<Id> requestIds = new Set<Id>();
            for (Staff_Quarters_Request__c req : senNotificationForStaffReq) {
                requestIds.add(req.Id);
            }
            System.debug('requestIds ---'+requestIds);
            QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(requestIds);
            
        }
    }
    
    
    global void finish(Database.BatchableContext bc) {
        system.debug('batch job id = '+bc.getJobId());
    }
}