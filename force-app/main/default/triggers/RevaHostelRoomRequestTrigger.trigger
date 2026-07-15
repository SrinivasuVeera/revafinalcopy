//**************Existing code*******************//
/*trigger RevaHostelRoomRequestTrigger on Reva_Hostel_Request__c (Before Update) {
if (Trigger.isBefore && Trigger.isUpdate) {
RevaRoomRequestTriggerHandler.TeachingStaffRoomAllocation(Trigger.new);
RevaRoomRequestTriggerHandler.FirstYearStudentRoomAllocation(Trigger.newMap, Trigger.oldMap);
}
}*/
trigger RevaHostelRoomRequestTrigger on Reva_Hostel_Request__c (before update, after insert, after update) {
    Set<Id> salaryRangeAPIIds = new Set<Id>();
    Set<Id> approvalHierarchyAPIIds = new Set<Id>();
    Set<Id> revisedSalaryReqIds = new Set<Id>();
    
    Set<Id> sendNotificationReqIds = new Set<Id>();
    HostelDisableTriggers__c disableTriggerSetting = HostelDisableTriggers__c.getInstance('RevaHostelRoomRequestTrigger'); 
    if (disableTriggerSetting != null && disableTriggerSetting.IsRevaHostelRoomRequestTrigger__c) {
        // Trigger logic is disabled, so exit the trigger
        return;
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        RevaRoomRequestTriggerHandler.TeachingStaffRoomAllocation(Trigger.new);
        RevaRoomRequestTriggerHandler.FirstYearStudentRoomAllocation(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            RevaRoomRequestTriggerHandler.sendEmailWhenRequestIsCreated(Trigger.new);
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotification(Trigger.new);
            
            //RevaRoomRequestTriggerHandler.getSalaryRange(Trigger.new);
            
            //  SLCM-HCM Integration   Added By Devender
            // Salary Range API Integration
            for (Reva_Hostel_Request__c hstleReq : Trigger.new) {
                
                if (hstleReq.Hostel_Room_Request_For__c != null  && hstleReq.HCM_Approval_Status__c == 'Deduction Request Initiated'&& hstleReq.Type__c != '1' && (hstleReq.Room_Request_Type__c == 'Non Teaching' || hstleReq.Room_Request_Type__c == 'Professor')) {
                    System.debug('trigger salry range-----'+hstleReq);
                    salaryRangeAPIIds.add(hstleReq.Id);
                }
            }
            
            if (!salaryRangeAPIIds.isEmpty()) {
                if (TriggerControl.isHCMQueueableRun) {
                    
                    System.enqueueJob(new SLCM_HCMAPIQueueableHandler.HostelRequestSalaryRangeAPIQueueable(salaryRangeAPIIds));
                }
            }
            
            // ended by Devender
            
        }
        if (Trigger.isUpdate) {
            System.debug('his after Update==');
            RevaRoomRequestTriggerHandler.sendEmailWhenRoomAllocated(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.HostelRoomRequestUpdate(Trigger.new);
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotificationOnChange(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.updateJoiningDateInStudentFee(Trigger.new, Trigger.oldMap);
            RevaRoomRequestTriggerHandler.createStudentHostelAttachment(Trigger.new);
            UpdateWardenUser.GetCustomWardenUser(Trigger.new);
            //SLCM-HCM Integration   Added By Devender
           
            for (Reva_Hostel_Request__c hstleReq : Trigger.new) {
                if (hstleReq.Hostel_Room_Request_For__c != null && hstleReq.Employee_Salary__c != null && (hstleReq.Room_Request_Type__c == 'Non Teaching' || hstleReq.Room_Request_Type__c == 'Professor')) {
                    if( hstleReq.HR_Lead__c == null && hstleReq.Admin_Director__c == null&& hstleReq.Reporting_Manager__c  == null&& hstleReq.HCM_Approval_Status__c == 'Deduction Request Initiated' ){
                        System.debug('----Trigger Approval---------');
                        approvalHierarchyAPIIds.add(hstleReq.Id); 
                    }
                    else if(hstleReq.Status__c =='Booked' 
                            && ((hstleReq.Approved_by_ReportingManager__c == true
                                   && Trigger.oldMap.get(hstleReq.Id).Approved_by_ReportingManager__c != hstleReq.Approved_by_ReportingManager__c)
                                || (hstleReq.Approved_by_AdminDirector__c == true
                                   && Trigger.oldMap.get(hstleReq.Id).Approved_by_AdminDirector__c != hstleReq.Approved_by_AdminDirector__c)
                                || (hstleReq.Approved_by_HR_Lead__c == true
                                   && Trigger.oldMap.get(hstleReq.Id).Approved_by_HR_Lead__c != hstleReq.Approved_by_HR_Lead__c)))
                    {
                        sendNotificationReqIds.add(hstleReq.Id);
                    }
                    
                }
                
                
                
                // Salary Revised Logic
                if (hstleReq.Hostel_Room_Request_For__c != null && hstleReq.Salary_Last_Revised_Date__c != null 
                    && hstleReq.Salary_Last_Revised_Date__c != null 
                    && hstleReq.Employee_Salary__c != null && hstleReq.Employee_Salary__c != Trigger.oldMap.get(hstleReq.Id).Employee_Salary__c 
                    && hstleReq.HCM_Approval_Status__c == 'Deduction Approved' && hstleReq.Status__c == 'Room Allotted' &&   hstleReq.Status__c != 'Vacating Initiated'
                    && hstleReq.Reva_Hostel_JoiningDate__c != null && hstleReq.Approved_by_HR_Lead__c == true 
                    && hstleReq.Is_HCM_Salary_Deduction_CNF__c == true 
                    && (hstleReq.Room_Request_Type__c == 'Non Teaching' || hstleReq.Room_Request_Type__c == 'Professor')) {
                        System.debug('----Trigger req cnf---------');
                        revisedSalaryReqIds.add(hstleReq.Id);
                    }
                
                
            }
            //Approval Hierarchy API Integration
            if (!approvalHierarchyAPIIds.isEmpty()) {
                if (TriggerControl.isHCMQueueableRun) {
                    System.enqueueJob(new SLCM_HCMAPIQueueableHandler.HostelRequestApprovalHierarchyAPIQueueable(approvalHierarchyAPIIds));
                }
            }
            
            
            
            // revised Salary Logic
            if (!revisedSalaryReqIds.isEmpty()) {
                if (TriggerControl.isHCMQueueableRun) {
                    System.debug('revisedSalaryReqIds= if can'+revisedSalaryReqIds);
                    System.enqueueJob(new SLCM_HCMAPIQueueableHandler.HostelRequestSalaeyRevisedQueueable(revisedSalaryReqIds));
                }
            }
            
             if (!sendNotificationReqIds.isEmpty()) {
                
                    System.debug(' sendNotificationReqIds --'+sendNotificationReqIds);
                   HostelRequestStaffNotifications.sendBulkWhatsappNotifications(sendNotificationReqIds);
              
            } 
            // Ended By Devender
        }
    }
    
}