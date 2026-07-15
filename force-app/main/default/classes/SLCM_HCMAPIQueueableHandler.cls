global class SLCM_HCMAPIQueueableHandler {
    
    //Salary Range API  : To get salary ranges from HCM, expect hostel single sharing 
    public class HostelRequestSalaryRangeAPIQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> reqIds = new Set<Id>();
        public HostelRequestSalaryRangeAPIQueueable(Set<Id> reqIds) {
            System.debug('reqIds----HostelRequestSalaryRangeAPIQueueable---------'+reqIds);
            this.reqIds = reqIds;
        }
        
        public void execute(QueueableContext context) {
            if (!reqIds.isEmpty()) {
                SLCM_HCMHostelSalaryRangeAPI.salaryRangeCreationMethod(reqIds);
            }
        }
    }
    
    // Approval Hierarchy API  : To get Approval List fpr apprval process from HCM 
    public class HostelRequestApprovalHierarchyAPIQueueable implements Queueable, Database.AllowsCallouts {
        List<Reva_Hostel_Request__c> successfulUpdates = new List<Reva_Hostel_Request__c>();
        private Set<Id> reqIdsApp = new Set<Id>();
        public HostelRequestApprovalHierarchyAPIQueueable(Set<Id> reqIdsApp) {
            System.debug('reqIds----HostelRequestApprovalHierarchyAPIQueueable---------'+reqIdsApp);
            this.reqIdsApp = reqIdsApp;
        }
        
        public void execute(QueueableContext context) {
            if (!reqIdsApp.isEmpty()) {
                successfulUpdates = SLCM_HCMHostelApprovalHierarchyAPI.approvalHierarchyCreationMethod(reqIdsApp);
            }
            
            System.debug('successfulUpdates ---'+successfulUpdates);
            if (!successfulUpdates.isEmpty()) {
                Set<Id> requestIds = new Set<Id>();
                for (Reva_Hostel_Request__c req : successfulUpdates) {
                    requestIds.add(req.Id);
                }
                System.debug('requestIds ---'+requestIds);
                //whatsapp notification
                HostelRequestStaffNotifications.sendBulkWhatsappNotifications(requestIds);
                
            }
        }
    }
    
    // To send revised salary to HCM
    public class HostelRequestSalaeyRevisedQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> reqIdsApp = new Set<Id>();
        public HostelRequestSalaeyRevisedQueueable(Set<Id> reqIdsApp) {
            System.debug('reqIds----HostelRequestRoomCancellationAPIQueueable---------'+reqIdsApp);
            this.reqIdsApp = reqIdsApp;
        }
        
        public void execute(QueueableContext context) {
            if (!reqIdsApp.isEmpty()) {
                SLCM_HCMHostelCNFAPI.sendApprovedConfirmationHCM(reqIdsApp);
            }
        }
    }
    
    //********************************************************************************************************************* */
    
    // Approval Hierarchy API 
    public class QuarterRequestApprovalHierarchyAPIQueueable implements Queueable, Database.AllowsCallouts {
        
        private Set<Id> reqIdsApp = new Set<Id>();
        List<Staff_Quarters_Request__c> successfulUpdates = new List<Staff_Quarters_Request__c>();
        
        // Constructor now only accepts a set of IDs
        public QuarterRequestApprovalHierarchyAPIQueueable(Set<Id> reqIdsApp) {
            this.reqIdsApp = reqIdsApp;
        }
        
        public void execute(QueueableContext context) {
            if(TriggerControl.isHCMTrggerDisable){
                return ;
            }
            if (!reqIdsApp.isEmpty()) {
                successfulUpdates = SLCM_HCMQuarterApprovalHierarchyAPI.approvalHierarchyCreationMethod(reqIdsApp);
            }
            
            
            System.debug('successfulUpdates ---'+successfulUpdates);
            if (!successfulUpdates.isEmpty() || successfulUpdates != null) {
                Set<Id> requestIds = new Set<Id>();
                for (Staff_Quarters_Request__c req : successfulUpdates) {
                    requestIds.add(req.Id);
                }
                System.debug('requestIds ---'+requestIds);
                //whatsapp notification
                QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(requestIds);
                
            }
        }
    } 
    // Staff quarters Employee Salry Revised  
    public class QuaterRequestSalaeyRevisedQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> reqIdsApp = new Set<Id>();
        public QuaterRequestSalaeyRevisedQueueable(Set<Id> reqIdsApp) {
            System.debug('reqIds----QuaterRequestSalaeyRevisedQueueable---------'+reqIdsApp);
            this.reqIdsApp = reqIdsApp;
        }
        
        public void execute(QueueableContext context) {
            if (!reqIdsApp.isEmpty()) {
                SLCM_HCMQuarterCNFAPI.sendApprovedConfirmationHCM(reqIdsApp);
            }
        }
    }
}