trigger UpdatePAFPaidDateTrigger on hed__Application__c (Before update) {
    ApplicationHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
}