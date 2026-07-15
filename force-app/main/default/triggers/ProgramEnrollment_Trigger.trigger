trigger ProgramEnrollment_Trigger on hed__Program_Enrollment__c (before Delete,after insert, after update) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.isDelete)
        {
            STOB_ProgramEnrollmentTrg_Handler.AddValidationONProgramEnrollment(Trigger.old);
        }
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
             MSTR_ProgramEnrollmentTrigger_Handler.ProgramEnrollment(Trigger.New, Trigger.oldMap);
        }
    }
}