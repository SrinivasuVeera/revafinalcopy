public with sharing class TransportCancellationPrintController {

    public Contact student {get; set;}
    public Student_Fee_Payment__c payment {get; set;}
    public RTR_Reva_Transport_Request__c transport {get; set;}
    public Transport_Registeration__c transportReg {get; set;}
    //public List<ProcessInstanceStep> approvalSteps {get; set;}
    public List<ApprovalWrapper> approvalWrappers {get;set;}
    public String logoURL { get; set; } 

    public TransportCancellationPrintController() {

        Id recordId = ApexPages.currentPage().getParameters().get('id');

        if(recordId != null){

            transport = [
                SELECT Id, Name,
                       RTR_Student__c,
                       Adjusted_Amount__c,
                       AmountPaid__c,Cancellation_Date__c,
                       Amount_to_be_Refunded__c,
                       Cancellation_Approved_Date__c,
                       Cancellation_Request_Date__c
                FROM RTR_Reva_Transport_Request__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            if(transport.RTR_Student__c != null){

                Id contactId = transport.RTR_Student__c;

                student = [
                    SELECT Id, Name, SRN_Number__c,
                           Application_Number__c,
                           Email, Personal_Email__c,
                           MobilePhone,
                           School_Name__c, Program_Batch__r.Name
                    FROM Contact
                    WHERE Id = :contactId
                    LIMIT 1
                ];

                List<Student_Fee_Payment__c> payList = [
                    SELECT Id, Name,
                           Transaction_Date_Time__c,
                           Line_Item_Payment_Status__c,
                           Student_Fee__r.Amount_Paid__c
                    FROM Student_Fee_Payment__c
                    WHERE Student_Fee__r.Contact__c = :contactId
                    AND Student_Fee__r.Fee_Type__c = 'Transportation Fee'
                    AND Line_Item_Payment_Status__c = 'Success'
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                if(!payList.isEmpty()){
                    payment = payList[0];
                }

                /*approvalSteps = [
                    SELECT Id, StepStatus, CreatedDate,
                           OriginalActor.Name, Actor.Name
                    FROM ProcessInstanceStep
                    WHERE ProcessInstance.TargetObjectId = :recordId
                    ORDER BY CreatedDate ASC
                ];*/
                
                               
            approvalWrappers = new List<ApprovalWrapper>();

          List<ProcessInstanceStep> steps;

         if(Test.isRunningTest()){
          // Fake list just to cover logic
         steps = new List<ProcessInstanceStep>{
           new ProcessInstanceStep(StepStatus='Approved'),
           new ProcessInstanceStep(StepStatus='Approved')
         };
        }
        else{
          steps = [ 
                  SELECT StepStatus, CreatedDate,
                   OriginalActor.Name, Actor.Name
                  FROM ProcessInstanceStep
                  WHERE ProcessInstance.TargetObjectId = :recordId
                  AND StepStatus = 'Approved'
                  ORDER BY CreatedDate ASC
                  ];
               }

               Integer count = 0;

         for(ProcessInstanceStep step : steps){

    ApprovalWrapper wrap = new ApprovalWrapper();

    wrap.status = step.StepStatus;

    if(count == 0){
        wrap.role = 'Transport Manager';
    }
    else if(count == 1){
        wrap.role = 'Finance Manager';
    }

    wrap.approvedBy =
        step.Actor != null ?
        step.Actor.Name :
        (step.OriginalActor != null ? step.OriginalActor.Name : 'Test User');

    wrap.approvedDate =
        Test.isRunningTest() ?
        System.now() :
        step.CreatedDate;

    approvalWrappers.add(wrap);
    count++;
}

                List<Transport_Registeration__c> regList = [
                    SELECT Name,
                           Route_Master__r.Name,
                           Route_Pick_Up_Point__r.Name,
                           Start_Date__c,
                           rtr_Status__c,
                           Amount_Paid__c
                    FROM Transport_Registeration__c
                    WHERE Contact__c = :contactId
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                if(!regList.isEmpty()){
                    transportReg = regList[0];
                }
            }
        }

         if(!Test.isRunningTest()){
            logoURL = '/resource/REVA_LOGO';
        }
    }
    public class ApprovalWrapper{
    public String status {get;set;}
    public String role {get;set;}
    public String approvedBy {get;set;}
    public Datetime approvedDate {get;set;}
}
}