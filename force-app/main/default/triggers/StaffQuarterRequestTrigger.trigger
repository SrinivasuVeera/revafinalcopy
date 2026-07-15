trigger StaffQuarterRequestTrigger on Staff_Quarters_Request__c (after insert,after update) {
    
    Set<Id> approvalHierarchyAPIIds = new Set<Id>();
    Set<Id> revisedSalaryReqIds = new Set<Id>();
    Set<Id> reqIdsforNotification = new Set<Id>();
    
    Set<Id> sendNotificationReqIds = new Set<Id>();
    
    /***********************************/
    StaffQuartersDisableTriggers__c disableTriggerSetting = StaffQuartersDisableTriggers__c.getInstance('StaffQuarterRequestTrigger'); 
    if (disableTriggerSetting != null && disableTriggerSetting.IsRevaStaffQuartersRequestTrigger__c) {
        // Trigger logic is disabled, so exit the trigger
        return;
    }
    /************************************/
    
    
    if(trigger.isafter){
        system.debug('afterinsert calling1');
        if(trigger.isInsert){
            system.debug('afterinsert calling');
            for (Staff_Quarters_Request__c quaReq : Trigger.new) {
                
                if (quaReq.Quarters_Request_Type__c != null && quaReq.Quarter_Request_For__c !=null && quaReq.Employee_Salary__c != null 
                    && quaReq.HCM_Approval_Status__c == 'Deduction Request Initiated' && quaReq.Status__c == 'Request Submitted' 
                    && quaReq.HR_Lead__c == null  && quaReq.Admin_Director__c == null && quaReq.Reporting_Manager__c  == null && quaReq.Approved_by_Hostel_Office__c == false) {
                        system.debug('approval calloutcalling'+quaReq);
                        approvalHierarchyAPIIds.add(quaReq.Id);  
                        
                    }
            }
            
            //Approval Hierarchy API Integration
            if (!approvalHierarchyAPIIds.isEmpty()) {
                System.enqueueJob(new SLCM_HCMAPIQueueableHandler.QuarterRequestApprovalHierarchyAPIQueueable(approvalHierarchyAPIIds));
            }
            
        }
        
        if(trigger.isupdate){
            System.debug('----Trigger if update--------');
            for(Staff_Quarters_Request__c quaterReq : Trigger.new){
                
                if ( quaterReq.Employee_Salary__c != null 
                    && quaterReq.HCM_Approval_Status__c == 'Deduction Approved' && (quaterReq.Status__c == 'Room Allotted' || quaterReq.Status__c == 'Approved')
                    && quaterReq.Staff_Quarters_Joining_Date__c != null 
                    && quaterReq.Approved_by_Hostel_Office__c == true && quaterReq.Is_HCM_Salary_Deduction_CNF__c == true) {
                        System.debug('----Trigger req cnf---------');
                        if(quaterReq.Employee_Salary__c != Trigger.oldMap.get(quaterReq.Id).Employee_Salary__c ){
                            revisedSalaryReqIds.add(quaterReq.Id);
                        }
                        else if(quaterReq.Status__c == 'Room Allotted' && Trigger.oldMap.get(quaterReq.Id).Status__c != quaterReq.Status__c) {
                            reqIdsforNotification.add(quaterReq.Id);
                        }
                        
                    }
                else if (quaterReq.Quarters_Request_Type__c != null 
                         && quaterReq.Quarter_Request_For__c != null 
                         && quaterReq.Employee_Salary__c != null 
                         && ((quaterReq.Status__c == 'Booked' 
                              && Trigger.oldMap.get(quaterReq.Id).Status__c != quaterReq.Status__c 
                              && (quaterReq.Approved_by_ReportingManager__c == true 
                                  && Trigger.oldMap.get(quaterReq.Id).Approved_by_ReportingManager__c != quaterReq.Approved_by_ReportingManager__c) 
                              || (quaterReq.Approved_by_AdminDirector__c == true  
                                  && Trigger.oldMap.get(quaterReq.Id).Approved_by_AdminDirector__c != quaterReq.Approved_by_AdminDirector__c) 
                              || (quaterReq.Approved_by_HR_Lead__c == true  
                                  && Trigger.oldMap.get(quaterReq.Id).Approved_by_HR_Lead__c != quaterReq.Approved_by_HR_Lead__c)) 
                              || (quaterReq.Status__c == 'Approved' 
                                 && (quaterReq.Approved_by_Hostel_Office__c == true 
                                     && Trigger.oldMap.get(quaterReq.Id).Approved_by_Hostel_Office__c != quaterReq.Approved_by_Hostel_Office__c)
                                 && quaterReq.Is_HCM_Salary_Deduction_CNF__c == true))) 
                {
                    sendNotificationReqIds.add(quaterReq.Id);
                }
            }
            
            
            // revised Salary Logic
            if (!revisedSalaryReqIds.isEmpty()) {
                if (TriggerControl.isHCMQueueableRun) {
                    System.debug(' revised n'+revisedSalaryReqIds);
                    System.enqueueJob(new SLCM_HCMAPIQueueableHandler.QuaterRequestSalaeyRevisedQueueable(revisedSalaryReqIds));
                }
            } 
            // send whatsapp and sms notifications for staff
            if (!reqIdsforNotification.isEmpty()) {
                if (TriggerControl.isHCMQueueableRun) {
                    System.debug(' reqIdsforNotification n'+reqIdsforNotification);
                    QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(reqIdsforNotification);
                }
            } 
            
            if (!sendNotificationReqIds.isEmpty()) {
                
                System.debug(' sendNotificationReqIds --'+sendNotificationReqIds);
                QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(sendNotificationReqIds);
                
            } 
            
            system.debug('queue afterinsert update calling');
            StaffQuarterRequestTriggerHandler.createAttachment(trigger.New);
            
        }
    }
}