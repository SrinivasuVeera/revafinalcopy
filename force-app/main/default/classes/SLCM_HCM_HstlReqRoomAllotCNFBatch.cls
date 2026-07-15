global class SLCM_HCM_HstlReqRoomAllotCNFBatch implements  Database.Batchable<sObject>,Database.AllowsCallouts {
    Set<Id> hostelReqIds = new Set<Id>();
    List<Reva_Hostel_Request__c> sendNotificationTohstleReq = new List<Reva_Hostel_Request__c>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Hostel_Room_Request_For__r.Employee_Number__c, Employee_Salary__c,Reva_Hostel_JoiningDate__c
                                         FROM Reva_Hostel_Request__c 
                                         WHERE Status__c = 'Approved'  
                                         AND (Room_Request_Type__c = 'Non Teaching' OR Room_Request_Type__c = 'Professor')
                                         AND Hostel_Room_Request_For__c != null
                                         AND Hostel_Room_Request_For__r.Employee_Number__c != null 
                                         AND Is_HCM_Salary_Deduction_CNF__c = false
                                         AND Employee_Salary__c != null 
                                         AND HCM_Approval_Status__c = 'Deduction Approved' 
                                         AND Approved_by_Hostel_Office__c = true
                                         AND Reva_Hostel_JoiningDate__c = Today]);
    }
    
    global void execute(Database.BatchableContext bc, List<Reva_Hostel_Request__c> lst_requests) {
        system.debug('lst_Contacts'+lst_requests);
        
        if(!lst_requests.isEmpty()) {
            for (Reva_Hostel_Request__c req : lst_requests) {
                hostelReqIds.add(req.Id);
            } 
            
        }
        
        
        if(!hostelReqIds.isEmpty()) {
            
            sendNotificationTohstleReq = SLCM_HCMHostelCNFAPI.sendApprovedConfirmationHCM(hostelReqIds);
        }
        System.debug('reqTosendNotification ---'+sendNotificationTohstleReq);
        if (!sendNotificationTohstleReq.isEmpty()) {
            Set<Id> requestIds = new Set<Id>();
            for (Reva_Hostel_Request__c req : sendNotificationTohstleReq) {
                requestIds.add(req.Id);
            }
            System.debug('requestIds ---'+requestIds);
            HostelRequestStaffNotifications.sendBulkWhatsappNotifications(requestIds);
            
        }
        
        
    }
    
    
    global void finish(Database.BatchableContext bc) {
        
        system.debug('batch job id = '+bc.getJobId());
    }
    
}