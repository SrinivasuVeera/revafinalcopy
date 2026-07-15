trigger MM_TermTrigger on hed__Term__c (After Update,Before Update)
{
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            MM_TermTriggerHandler.mentorMapping(trigger.New,trigger.oldMap);
            ASM_TermTrigger_Handlr.PushIAMarksToLogisys(Trigger.New, Trigger.oldMap);

            //To freeze professor preferences once verical head diabled the Allow_Professors_for_Preferences__c
            List<hed__Term__c> termsToProcess = new List<hed__Term__c>();
            for(hed__Term__c term : Trigger.new){
                if(Trigger.oldMap.get(term.Id).Allow_Professors_for_Preferences__c != term.Allow_Professors_for_Preferences__c && term.Allow_Professors_for_Preferences__c == false) {
                    termsToProcess.add(term);

                }
            }

            if(!termsToProcess.isEmpty()){
                Database.executeBatch(new FreezeProfessorCoursePreferencesBatch(termsToProcess));
            }

        }
    }

    if(Trigger.isBefore)
    {
        if(Trigger.isUpdate)
        {
            MM_TermTriggerHandler.professorSubjectAlloEnabled(Trigger.new, Trigger.oldMap);
        }
    }
}