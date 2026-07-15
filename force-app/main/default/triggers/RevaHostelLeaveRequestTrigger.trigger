trigger RevaHostelLeaveRequestTrigger on REVA_Hostel_Leave_Request__c (after insert, after update) {
    if(trigger.isinsert){
        if(trigger.isafter){
           RevaHostelLeaveRequestTriggerHandler.leaveRequestNotification(Trigger.new);
           RevaHostelLeaveRequestTriggerHandler.leaveApprovalNotification(Trigger.new);

        }
    }
    if(trigger.isupdate){
        if(trigger.isafter){
            List<REVA_Hostel_Leave_Request__c> approvedLeaveRequests = new List<REVA_Hostel_Leave_Request__c>();
            
           
            for (REVA_Hostel_Leave_Request__c leaveRequest : Trigger.new) {
                REVA_Hostel_Leave_Request__c oldLeaveRequest = Trigger.oldMap.get(leaveRequest.Id);
                if (oldLeaveRequest.Status__c != leaveRequest.Status__c ) {
                    approvedLeaveRequests.add(leaveRequest); 
                }
                
                
            }
            if (!approvedLeaveRequests.isEmpty()) {
                RevaHostelLeaveRequestTriggerHandler.leaveRequestNotification(approvedLeaveRequests);
                RevaHostelLeaveRequestTriggerHandler.mealCancelIfLeaveOnSameDay(approvedLeaveRequests);
            }
        }
    }
}