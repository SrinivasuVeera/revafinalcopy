trigger UpdateSyllabusCount on hed__Plan_Requirement__c (after insert, after update, after delete, after undelete) {
    Set<Id> semesterIds = new Set<Id>();
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (hed__Plan_Requirement__c s : Trigger.new) {
            if (s.Semester__c != null) {
                semesterIds.add(s.Semester__c);
            }
        }
    }
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (hed__Plan_Requirement__c s : Trigger.old) {
            if (s.Semester__c != null) {
                semesterIds.add(s.Semester__c);
            }
        }
    }
    
     if (!semesterIds.isEmpty()) {
        UpdateSyllabusCountHandler.updateSemesterCourseCounts(semesterIds);
    }
}