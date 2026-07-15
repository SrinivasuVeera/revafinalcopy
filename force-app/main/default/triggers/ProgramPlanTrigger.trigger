trigger ProgramPlanTrigger on hed__Program_Plan__c (before insert,before update,After insert, after update) 
{
    if(trigger.isbefore)
    {
        if(trigger.isinsert)
        {
            ProgramPlanHandler.updateProgramPlanName(Trigger.new,null);
        }
        else if(trigger.isupdate)
        {
            ProgramPlanHandler.updateProgramPlanName(Trigger.new,trigger.oldmap);
        }
    }
    if(Trigger.isInsert && Trigger.isAfter && RecursiveTriggerHandler.isFirstTime)
    {
        list<id> programBatchIds = new List<id>();
        for(hed__Program_Plan__c objProjPlan:Trigger.New)
        {
            programBatchIds.add(objProjPlan.Id);
        }
         if (!programBatchIds.isEmpty()) {
           SAP_ProgramBatchMasterCreationAPI.ProgramBatchMasterCreationMethod(programBatchIds);
        }
    }
    //update push to sap == true 
    if(Trigger.isUpdate && Trigger.isAfter && RecursiveTriggerHandler.isFirstTime)
    {
          list<id> programBatchIds = new List<id>();
        for(hed__Program_Plan__c objProgplan : trigger.new)
        {
            if(objProgplan.Push_to_SAP__c == true && trigger.OldMap.get(objProgplan.Id).Push_to_SAP__c != objProgplan.Push_to_SAP__c){
                programBatchIds.add(objProgplan.Id);
            }
        }
         if (!programBatchIds.isEmpty()) {
           SAP_ProgramBatchMasterCreationAPI.ProgramBatchMasterCreationMethod(programBatchIds);
        }
    }
}