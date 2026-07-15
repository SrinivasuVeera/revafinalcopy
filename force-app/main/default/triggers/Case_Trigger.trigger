trigger Case_Trigger on Case (after insert) 
{
    if(Trigger.isAfter && Trigger.Isinsert)
    {
        REVA_CaseTrigger_Handler.CaseAssignment(Trigger.new,trigger.OldMap);
    }
}