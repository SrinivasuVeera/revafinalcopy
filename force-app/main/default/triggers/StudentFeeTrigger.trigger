trigger StudentFeeTrigger on Student_Fee__c (before insert,before update, After update,After Insert) 
{
    System.debug('LINE#32 StudentFeeTrigger');
    if(trigger.IsBefore)
    {
        if(trigger.IsInsert)
        {
            FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(trigger.new,null);
            FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(trigger.new,null);
            FEE_StudentFeeTriggerHandler.displayOrderNoMapping(trigger.new);
            //FEE_StudentFeeTriggerHandler.updateFeeRecords(Trigger.new);
        }
        if(trigger.IsUpdate)
        {
            FEE_StudentFeeTriggerHandler.updateFeePaymentCriteria(trigger.new,trigger.oldmap);
           // FEE_StudentFeeTriggerHandler.updateStudentFeeProgramEnrollment(trigger.new,trigger.oldmap);
             //FEE_StudentFeeTriggerHandler.updateFeeRecords(Trigger.new);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
                //List<Id> contIdList = new List<Id>();
				//for(Student_Fee__c sf: trigger.new){
                // contIdList.add(sf.Contact__c);
               // }
               // ChangeBalanceFee.InsertStudentFeePay(contIdList);
            System.debug('Calling after update');
            List<Student_Fee__c> hstlStuFee = new List<Student_Fee__c>();
            for(Student_Fee__c sf: trigger.new){
                if(sf.Fee_Type__c =='Hostel Fee' && sf.Amount_Paid__c > 0 ){
                    //FEE_StudentFeeTriggerHandler.updateHostelRequest(Trigger.new);
                    hstlStuFee.add(sf);

                }
            }
            if(hstlStuFee.size() > 0){
            FEE_StudentFeeTriggerHandler.updateHostelRequest(hstlStuFee);
        }
            // FEE_StudentFeeTriggerHandler.EligibilityForScholarship(trigger.new);
            //  FEE_StudentPaymentEmail_TriggerHandler.StudentPaymentEmail(trigger.new, trigger.oldMap);
            Set<Id> stufeeIdSet = new Set<Id>();
           // List<Student_Fee__c> StuFeeList = [Select Id,name,Initiate_demand_cancellation_Integration__c,Contact__c,Contact__r.Cancellation_Approval_Status__c,Calculated_Amount_Pending__c,Calculated_Total_Amount__c,Fee_Type__c,Refunded_Amount__c,Cancelled__c from Student_Fee__c Where ID IN :Trigger.New];
            for(Student_Fee__c objStdFee:Trigger.New){
                Student_Fee__c oldStdFee = Trigger.oldMap.get(objStdFee.Id);//Newly added on 06-01-2025 by veera
                if (objStdFee.Calculated_Amount_Pending__c != oldStdFee.Calculated_Amount_Pending__c ||
                    objStdFee.Calculated_Total_Amount__c != oldStdFee.Calculated_Total_Amount__c) {
                        if (objStdFee.Initiate_demand_cancellation_Integration__c == FALSE && objStdFee.Cancelled__c == False){
                          
                        stufeeIdSet.add(objStdFee.Id);
                    }
                }
               // /*if(objStdFee.Calculated_Amount_Pending__c != (Trigger.oldMap.get(objStdFee.Id)).Calculated_Amount_Pending__c ||
                //   objStdFee.Calculated_Total_Amount__c != (Trigger.oldMap.get(objStdFee.Id)).Calculated_Total_Amount__c){
                    //   stufeeIdSet.add(objStdFee.Id);
                  // } working one*/
            }
            if(stufeeIdSet.size() > 0){
                System.debug('LINE#32 StudentFeeTrigger - Calling updateStudentFeePending');
                FEE_StudentFeeTriggerHandler.updateStudentFeePending(stufeeIdSet);
            }
            
            
            //SAP Code Added with respect to REVA UAT org by ePeople Team
            List<Id> demandIds = new List<Id>();
            List<Id> demandsIds2 = new List<Id>();
            for(Student_Fee__c objStdFee:Trigger.new)
            {
                /*if(objStdFee.Integrated_with_SAP__c == false && objStdFee.Amount_Pending__c == 0 && objStdFee.Fee_Type__c == 'Application Fee' && Trigger.OldMap.get(objStdFee.Id).Amount_Pending__c > 0){
                    demandIds.add(objStdFee.Id);
                }*/
                if(objStdFee.Pushed_to_SAP__c == true && trigger.OldMap.get(objStdFee.Id).Pushed_to_SAP__c != objStdFee.Pushed_to_SAP__c)
                {
                    demandIds.add(objStdFee.Id);
                }
                if(objStdFee.Fee_structure_change_Integration__c == true && trigger.OldMap.get(objStdFee.Id).Fee_structure_change_Integration__c != objStdFee.Fee_structure_change_Integration__c){
                    demandIds.add(objStdFee.Id);
                }
                if(objStdFee.Initiate_demand_cancellation_Integration__c == true && trigger.OldMap.get(objStdFee.Id).Initiate_demand_cancellation_Integration__c != objStdFee.Initiate_demand_cancellation_Integration__c){
                    demandsIds2.add(objStdFee.Id);
                }
            }
            if(!demandIds.isEmpty())
            {
               // SAP_DemandAPI_Handler.createDemands(demandIds);
             System.enqueueJob(new SAP_DemandAPI_Handler(new List<Id>(demandIds)));
            }  
            
            if(!demandsIds2.isEmpty()){
               // SAP_DemandCancellationAPI.DemandCancellation_APIMethod(demandsIds2);
                System.enqueueJob(new SAP_DemandCancellationAPI_Handler(demandsIds2));

            } 
        }
       
    if(trigger.isInsert)
        {
            List<Id> demandIds = new List<Id>();
            Set<Id> stufeeIdSet = new Set<Id>();
            for(Student_Fee__c objStdFee:Trigger.new)
            {
                if(objStdFee.Fee_Type__c !='University Fee' && objStdFee.Fee_Type__c !='Tuition Fee' && !objStdFee.Name.contains('Caution Deposit')){
                    demandIds.add(objStdFee.Id);
                } 
                if(objStdFee.Amount_Pending__c != objStdFee.Calculated_Amount_Pending__c){
                    stufeeIdSet.add(objStdFee.Id);
                }
            }
            if(!demandIds.isEmpty())
            {
              //  SAP_DemandAPI_Handler.createDemands(demandIds);
                 System.enqueueJob(new SAP_DemandAPI_Handler(new List<Id>(demandIds)));
            } 
            if(stufeeIdSet.size() > 0){
                System.debug('Hello');
                FEE_StudentFeeTriggerHandler.updateStudentFeePending(stufeeIdSet);
            }
        }
    }
    
}