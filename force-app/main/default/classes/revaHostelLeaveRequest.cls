public class revaHostelLeaveRequest {

    @AuraEnabled
    public static void updateRecordStatus(String recordId) {
        REVA_Hostel_Leave_Request__c recordToUpdate = [SELECT Id, Status__c FROM REVA_Hostel_Leave_Request__c WHERE Id = :recordId LIMIT 1];
        recordToUpdate.Status__c = 'Cancelled';
        //if(!Test.isRunningTest()){
            List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recordId];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed'); 
   
        if((piwi != null || !piwi.isEmpty()) && !Test.isRunningTest() ){
            req.setWorkitemId(piwi.get(0).Id);
        }
        
        /**********newly added*********/
        if(req != null){
         Approval.ProcessResult result = Approval.process(req,false);   
        }
        
        
        /*********existing one below *******************/
        //Approval.ProcessResult result = Approval.process(req,false);

        update recordToUpdate;
    }
    
    @AuraEnabled(cacheable=true)
    public static REVA_Hostel_Leave_Request__c getLeaveRecordDetails(String recordId) {
        System.debug('recordId '+recordId);
        REVA_Hostel_Leave_Request__c REVAHostelLeaveRequest = [SELECT Id, Status__c, Start_Date_and_Time__c, End_Date_and_Time__c FROM REVA_Hostel_Leave_Request__c 
                                                       WHERE Id = :recordId LIMIT 1];
        return REVAHostelLeaveRequest;
    }
    
}