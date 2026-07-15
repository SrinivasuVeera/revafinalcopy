public without sharing class RevaHosteLeaveRequestController {
   /* @AuraEnabled(cacheable = true)
    public static List<ProcessInstanceStep> getApprovalHistory(string targetObjectId){
      System.debug('targetObjectId---------------'+targetObjectId);
     List<ProcessInstance> processInstances = [SELECT Status, TargetObjectId, Id, CompletedDate 
                                 FROM ProcessInstance
                                 WHERE TargetObjectId =: targetObjectId];
  
     return [SELECT Id, ProcessInstanceId, StepStatus, Comments, StepNodeId, CreatedDate, Actor.Name 
             FROM ProcessInstanceStep
             WHERE ProcessInstanceId IN: processInstances AND StepStatus != 'Started'
             ORDER BY CreatedDate ASC];
  
    }
  
  
    
  } */
  @AuraEnabled(cacheable = true)
  public static List<ApprovalHistoryWrapper> getApprovalHistory(String targetObjectId) {
    // Query the process instances for the target object
    List<ProcessInstance> processInstances = [
        SELECT Id, Status, TargetObjectId, CompletedDate 
        FROM ProcessInstance 
        WHERE TargetObjectId = :targetObjectId
    ];
  
    System.debug('processInstances--------'+processInstances);
  
    // Retrieve completed steps
    List<ProcessInstanceStep> completedSteps = [
        SELECT Id, ProcessInstanceId, StepStatus, Comments, StepNodeId, CreatedDate, Actor.Name 
        FROM ProcessInstanceStep 
        WHERE ProcessInstanceId IN :processInstances AND StepStatus != 'Started'
        ORDER BY CreatedDate ASC
    ];
    System.debug('completedSteps--------'+completedSteps);
    // Retrieve pending approvals using ProcessInstanceWorkItem
    List<ProcessInstanceWorkItem> pendingWorkItems = [
        SELECT Id, ActorId, OriginalActor.Name, ProcessInstanceId, CreatedDate 
        FROM ProcessInstanceWorkItem 
        WHERE ProcessInstanceId IN :processInstances
    ];
    System.debug('pendingWorkItems--------'+pendingWorkItems);
    // Combine completed and pending steps into a wrapper list
    List<ApprovalHistoryWrapper> approvalHistory = new List<ApprovalHistoryWrapper>();
  
    // Add completed steps to the wrapper
    for (ProcessInstanceStep step : completedSteps) {
        approvalHistory.add(new ApprovalHistoryWrapper(
            step.Actor != null ? step.Actor.Name : 'System',
            step.StepStatus,
            step.Comments,
            step.CreatedDate
        ));
    }
    System.debug('approvalHistory- 1-------'+approvalHistory);
    // Add pending work items to the wrapper
    for (ProcessInstanceWorkItem workItem : pendingWorkItems) {
        approvalHistory.add(new ApprovalHistoryWrapper(
            workItem.OriginalActor != null ? workItem.OriginalActor.Name : 'Unassigned',
            'Pending',
            null,
            workItem.CreatedDate
        ));
    }
    System.debug('approvalHistory-final-------'+approvalHistory);
    return approvalHistory;
  }
  
  // Wrapper class for approval history
  public class ApprovalHistoryWrapper {
    @AuraEnabled
    public String actorName { get; set; }
  
    @AuraEnabled
    public String status { get; set; }
  
    @AuraEnabled
    public String comments { get; set; }
  
    @AuraEnabled
    public DateTime createdDate { get; set; }
  
    public ApprovalHistoryWrapper(String actorName, String status, String comments, DateTime createdDate) {
        this.actorName = actorName;
        this.status = status;
        this.comments = comments;
        this.createdDate = createdDate;
    }
  }
  
  }