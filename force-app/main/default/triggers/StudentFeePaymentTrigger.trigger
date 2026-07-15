trigger StudentFeePaymentTrigger on Student_Fee_Payment__c (After Insert,After Update,after delete,after undelete) 
{
    if(trigger.isafter)
    {
        if(trigger.isInsert)
        {
            
            
            // This method we are stopping to execute when records are created from NPF integration
            if(Utility.NPF_API_To_Stop_Rollup == false) 
            {
                FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.new,Null);
                FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(trigger.new,null);
            }
            
            // This method we are execute when records are created from NPF integration to update the installments
            if(Utility.NPF_API_To_Stop_Rollup == true) FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(trigger.new,null);
            
            for (Student_Fee_Payment__c sp : Trigger.New) {	    
                if(sp.Line_Item_Payment_Status__c == 'Payment Link Created' ){ 
                    GuestHouseNotificationsWhatsApp.HandlePaymentMethod(Trigger.New);
                    system.debug('check');
                }
            }
            
        }
        else if(trigger.isupdate)
        {
            
            
            FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.new,trigger.oldmap);
            FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(trigger.new,trigger.oldmap);
            if(utility.LogisysAPI == true) FEE_StudentFeePaymentTriggerHandler.PushExamFeeToLogisys(Trigger.New, Trigger.Oldmap);
            if(RecursiveTriggerHandler.isFirstTime)
            {
                //AddedbyRajashekar
                RecursiveTriggerHandler.isFirstTime = false;
                //endshere
                List<Id> Student_Fee_Pay_Ids = new List<Id>();
                for(Student_Fee_Payment__c objStdFeePay:trigger.new)
                {
                    if(objStdFeePay.Line_Item_Payment_Status__c == 'Success' && objStdFeePay.Integrated_with_SAP__c == false && objStdFeePay.Mode_of_Payment__c	== 'Online' 
                       && objStdFeePay.Push_to_SAP__c == True && trigger.OldMap.get(objStdFeePay.Id).Push_to_SAP__c != objStdFeePay.Push_to_SAP__c)
                    {
                        Student_Fee_Pay_Ids.add(objStdFeePay.Id);
                    }
                }
                if(!Student_Fee_Pay_Ids.isEmpty())
                {
                    //SAP_OnlineAPI.OnlineAPIMethod(Student_Fee_Pay_Ids);
                    SAP_OnlineAPI_Helper.sapApiMethod(Student_Fee_Pay_Ids);
                }
            }
            // FEE_StudentFeePaymentTriggerHandler.sendPaymentNotifications(Trigger.new);
        }
        else if(trigger.isdelete)
        {
            FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.old,null);
        }
        else if(trigger.isundelete)
        {
            FEE_StudentFeePaymentTriggerHandler.RollupAmount(trigger.new,null);
        }
    }
}