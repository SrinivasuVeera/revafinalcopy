trigger HostelAcademicYearTrigger on REVA_Hostel_Academic_Year__c (before insert, before update, before delete) {   
   HostelAcademicYearTriggerHandler.handleTrigger(Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}