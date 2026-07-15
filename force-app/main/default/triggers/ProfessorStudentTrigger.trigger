trigger ProfessorStudentTrigger on Professor_Student_Course_Preference__c (after insert,after update,after delete,after undelete)
{
    if(Trigger.isAfter)
    {
        if(Trigger.isinsert)
        {
            STOB_ProfessorStudentTriggerHandler.RollupPreference(trigger.new,null);
            STOB_ProfessorStudentTriggerHandler.rollupPreferenceForProfessor(trigger.new,null);
        }
        else if(Trigger.isupdate)
        {
            STOB_ProfessorStudentTriggerHandler.RollupPreference(trigger.new,trigger.oldmap);
            STOB_ProfessorStudentTriggerHandler.rollupPreferenceForProfessor(trigger.new,trigger.oldmap);
        }
        else if(Trigger.isdelete)
        {
            STOB_ProfessorStudentTriggerHandler.RollupPreference(trigger.old,null);
            STOB_ProfessorStudentTriggerHandler.rollupPreferenceForProfessor(trigger.old,null);
        }
        else if(Trigger.isundelete)
        {
            STOB_ProfessorStudentTriggerHandler.RollupPreference(trigger.new,null);
            STOB_ProfessorStudentTriggerHandler.rollupPreferenceForProfessor(trigger.new,null);
        }
    }
}