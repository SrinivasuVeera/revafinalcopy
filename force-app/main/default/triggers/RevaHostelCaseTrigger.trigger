trigger RevaHostelCaseTrigger on Case (after insert, after update) {
    if(trigger.isafter){
        if(Trigger.isInsert){
            for (Case c : Trigger.new) {
                
                if (c.Record_Type_Name__c  == 'REVA Hostel Support Request') {
                    RevaHostelCaseTriggerHandler.updateStudentContact(Trigger.New);
                    RevaHostelCaseTriggerHandler.notifyStudentOnCaseCreation(Trigger.New);
                }
            }
        }if(trigger.isupdate){     
            for (Case c : Trigger.new) {
                
                if (c.Record_Type_Name__c  == 'REVA Hostel Support Request') {
                    
                    RevaHostelCaseTriggerHandler.notifyStudentOnStatusChange(Trigger.New, Trigger.OldMap);
                    RevaHostelCaseTriggerHandler.handleOwnerChangeContact(Trigger.New, Trigger.OldMap);
                    /*********Newly added**********/
                    
                    RevaHostelCaseTriggerHandler.shareCasesAfterOwnershipChange(Trigger.New, Trigger.OldMap);
                    break; // call once for efficiency
                }
            }
            /*************************/
        }
    }
}