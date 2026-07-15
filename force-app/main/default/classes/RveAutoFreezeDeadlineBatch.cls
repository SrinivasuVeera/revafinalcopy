public class RveAutoFreezeDeadlineBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {       
        return Database.getQueryLocator([
            SELECT Id, IA_2_Result_Date__c, ExamVerticalHeadFreeze__c, ExamVHAcknowledged__c 
            FROM hed__term__c WHERE ExamVerticalHeadFreeze__c = false AND IA_2_Result_Date__c != null
            AND Active__c = true and RecordType.Name ='Semester']);
    }

    public void execute(Database.BatchableContext bc, List<hed__term__c> scope) {
        // Get the deadline offset from your Custom Label
        Integer daysOffset = 0;
        try {
            daysOffset = Integer.valueOf(System.Label.FreezeExaminationVerticalHead);
        } catch(Exception e) {
            daysOffset = 0; // Default if label is missing or invalid
        }

        Date today = Date.today();
        List<hed__term__c> semestersToUpdate = new List<hed__term__c>();
        Set<Id> semesterIdsToProcess = new Set<Id>();

        // 1. Filter semesters where the deadline has actually passed
        for (hed__term__c sem : scope) {
            Date deadlineDate = sem.IA_2_Result_Date__c.addDays(daysOffset);
            
            if (today > deadlineDate) {
                sem.ExamVerticalHeadFreeze__c = true;
                sem.ExamVHAcknowledged__c = 'Verified by System';
                semestersToUpdate.add(sem);
                semesterIdsToProcess.add(sem.Id);
            }
        }

        if (!semestersToUpdate.isEmpty()) {
            // 2. Update the Semesters
            update semestersToUpdate;

            // 3. Update related Course Enrollments (Faculty) that are 'Locked'
            List<hed__Course_Enrollment__c> enrollments = [
                SELECT Id, RVE_Professor_freeze__c, RVE_Exam_Vertical_Head_Freeze__c, Acknowledged__c 
                FROM hed__Course_Enrollment__c 
                WHERE (Section__r.hed__Parent_Term__r.hed__Parent_Term__c IN :semesterIdsToProcess 
                       OR Section__r.hed__Parent_Term__c IN :semesterIdsToProcess)
                AND IA_Marks_Entry_Status__c = 'Locked' 
                AND RecordType.Name = 'Faculty'
            ];

            if (!enrollments.isEmpty()) {
                for (hed__Course_Enrollment__c ce : enrollments) {
                    ce.RVE_Professor_freeze__c = true;
                    ce.RVE_Exam_Vertical_Head_Freeze__c = true;
                    //ce.Acknowledged__c = 'Frozen by System';
                }
                update enrollments;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Auto-Freeze Batch Processing Completed.');
    }
}