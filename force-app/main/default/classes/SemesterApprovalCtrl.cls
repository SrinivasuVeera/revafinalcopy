public with sharing class SemesterApprovalCtrl {
    
    @AuraEnabled(cacheable=true)
    public static List<ApprovalStep> getApprovalSteps(Id recordId) {
        List<ProcessInstance> instances = [
            SELECT Id, (SELECT Id, StepStatus, Actor.Name, OriginalActor.Name,
                        ProcessNode.Name, Comments, CreatedDate, ActorId
                        FROM StepsAndWorkitems ORDER BY CreatedDate DESC)
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId ORDER BY CreatedDate DESC
        ];        
        return processApprovalSteps(instances);
    }
    @TestVisible 
    private static List<ApprovalStep> processApprovalSteps(List<ProcessInstance> instances) {
        List<ApprovalStep> steps = new List<ApprovalStep>();
        for (ProcessInstance pi : instances) { 
            for (SObject wi : pi.StepsAndWorkitems) {
                ApprovalStep step = new ApprovalStep();
                step.id             = (Id)wi.get('Id');
                SObject processNode = wi.getSObject('ProcessNode');
                step.stepName       = processNode != null ? (String)processNode.get('Name') : null;
                String stepStatus = (String)wi.get('StepStatus');
                step.status         = stepStatus;
                step.createdDate    = (Datetime)wi.get('CreatedDate');
                step.comments       = (String)wi.get('Comments');                
                SObject originalActor = wi.getSObject('OriginalActor');
                step.assignedTo     = originalActor != null ? (String)originalActor.get('Name') : null;
                SObject actor = wi.getSObject('Actor');
                step.actualApprover = actor != null ? (String)actor.get('Name') : null;
                
                if (stepStatus == 'Pending') {
                    step.workItemId = (Id)wi.get('Id');
                }
                steps.add(step);
            }
        }
        steps.sort();
        return steps;
        
    }
    @AuraEnabled(cacheable=true)
    public static List<CourseWrapper> getCourseOfferings(Id semesterId) {
        List<CourseWrapper> wrappers = new List<CourseWrapper>();
        
        for (hed__Course_Offering__c co : [
            SELECT Id, Name,
            hed__Course__r.hed__Course_ID__c,
            hed__Course__r.Name,
            hed__Course__r.Category__c,
            hed__Course__r.Lcoursetype__c,
            hed__Course__r.HardCore_Sub_Type__c,
            hed__Course__r.Lmandatory__c,                   
            hed__Course__r.L_T_P__c,
            hed__Course__r.Credits__c,
            hed__Course__r.Credit_Hours__c,
            hed__Course__r.No_of_IA_s__c,
            hed__Course__r.Theory_Maximum_Marks__c,
            hed__Course__r.Seminar_Maximum_Marks__c,
            hed__Course__r.Quiz_Maximum_Marks__c,
            hed__Course__r.Results_Max_Marks__c,
            hed__Course__r.Continuous_Learning_Max_Marks__c,
            hed__Course__r.Maximum_Internal_Marks__c,
            hed__Course__r.Maximum_External_Marks__c,
            hed__Course__r.Total_Maximum_Marks_IA_External__c,
            hed__Course__r.Lsubtype__c
            FROM hed__Course_Offering__c
            WHERE hed__Term__c = :semesterId
            ORDER BY hed__Course__r.hed__Course_ID__c
        ]) {
            CourseWrapper w = new CourseWrapper();
            w.id                = co.Id;
            w.courseOfferingId  = co.Name;
            w.courseId          = co.hed__Course__r?.hed__Course_ID__c;
            w.courseName        = co.hed__Course__r?.Name;
            w.category          = co.hed__Course__r?.Category__c;
            w.lcoursetype       = co.hed__Course__r?.Lcoursetype__c;
            w.subType           = co.hed__Course__r?.HardCore_Sub_Type__c;
            w.lmandatory        = co.hed__Course__r?.Lmandatory__c;
            w.ltp               = co.hed__Course__r?.L_T_P__c;
            w.credits           = co.hed__Course__r?.Credits__c;
            w.creditsHours      = co.hed__Course__r?.Credit_Hours__c;
            w.noOfIAs           = co.hed__Course__r?.No_of_IA_s__c;
            w.theoryMarks       = co.hed__Course__r?.Theory_Maximum_Marks__c;
            w.seminarMarks      = co.hed__Course__r?.Seminar_Maximum_Marks__c;
            w.quizMarks         = co.hed__Course__r?.Quiz_Maximum_Marks__c;
            w.resultsMarks      = co.hed__Course__r?.Results_Max_Marks__c;
            w.continuousMarks   = co.hed__Course__r?.Continuous_Learning_Max_Marks__c;
            w.Maxinternal       = co.hed__Course__r?.Maximum_Internal_Marks__c;
            w.Maxexternal       = co.hed__Course__r?.Maximum_External_Marks__c;
            w.totalmaxmarks     = co.hed__Course__r?.Total_Maximum_Marks_IA_External__c;
            w.lsubtype          = co.hed__Course__r?.Lsubtype__c;
            
            wrappers.add(w);
        }
        return wrappers;
    }
    
    @AuraEnabled
    public static void processAction(Id workItemId, String action, String comments) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setWorkitemId(workItemId);
        req.setAction(action);
        if (String.isNotBlank(comments)) req.setComments(comments);
        Approval.process(req);
    }
    
    public class ApprovalStep implements Comparable {
        @AuraEnabled public Id     id;
        @AuraEnabled public String stepName;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String assignedTo;
        @AuraEnabled public String actualApprover;
        @AuraEnabled public String comments;
        @AuraEnabled public Id     workItemId;
        
        
        public Integer compareTo(Object obj) {
            ApprovalStep other = (ApprovalStep)obj;
            
            if (this.createdDate == null && other.createdDate == null) return 0;
            if (this.createdDate == null) return 1; // Treat null as oldest/last
            if (other.createdDate == null) return -1; // Treat null as oldest/last
            
            // Compare times (milliseconds since epoch) for descending order (newest first)
            Long thisTime = this.createdDate.getTime();
            Long otherTime = other.createdDate.getTime();
            
            if (thisTime > otherTime) {
                return -1; 
            } else if (thisTime < otherTime) {
                return 1; 
            } else {
                return 0;
            }
        }
    }
    
    public class CourseWrapper {
        @AuraEnabled public Id     id;
        @AuraEnabled public String courseOfferingId;    
        @AuraEnabled public String courseId;             
        @AuraEnabled public String courseName;           
        @AuraEnabled public String category;            
        @AuraEnabled public String subType;            
        @AuraEnabled public String ltp;               
        @AuraEnabled public Decimal credits;             
        @AuraEnabled public string noOfIAs;          
        @AuraEnabled public Decimal theoryMarks;         
        @AuraEnabled public Decimal seminarMarks;       
        @AuraEnabled public Decimal quizMarks;
        @AuraEnabled public Decimal resultsMarks;        
        @AuraEnabled public Decimal continuousMarks;     
        @AuraEnabled public String lcoursetype;
        @AuraEnabled public String lmandatory;
        @AuraEnabled public String lsubtype;
        @AuraEnabled public Decimal creditsHours; 
        @AuraEnabled public Decimal Maxinternal; 
        @AuraEnabled public Decimal Maxexternal; 
        @AuraEnabled public Decimal totalmaxmarks; 
    }
}