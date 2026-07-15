trigger Rpl_Interview_Trigger on Rpl_Interview__c (after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        	Rpl_InterviewTriggerHandler.updateStudentRegistrationDrive(Trigger.New);
        	Rpl_InterviewTriggerHandler.pullStudentsToNextRound(Trigger.New, Trigger.OldMap, false);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        Rpl_InterviewTriggerHandler.pullStudentsToNextRound(Trigger.New, Trigger.OldMap, true);
        Rpl_InterviewTriggerHandler.updateShortlistedStudents(Trigger.New, Trigger.OldMap);
    }
    
}