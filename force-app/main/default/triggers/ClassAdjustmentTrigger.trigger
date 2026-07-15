trigger ClassAdjustmentTrigger on Class_Adjustment__c (after update) 
{ 
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
         //  LMS_ClassAdjustmentTriggerHandler.updateClassAdjustment(trigger.new,trigger.oldmap);
        }
    }
}