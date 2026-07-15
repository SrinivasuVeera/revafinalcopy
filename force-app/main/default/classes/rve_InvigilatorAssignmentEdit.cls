public class rve_InvigilatorAssignmentEdit {
     @AuraEnabled
public static List<rve_Invigilator_Assignment__c> getInvigilatorAssignments() {
    // Get current time in UTC
    DateTime currentTime = System.now();
    Time currentLocalTime = currentTime.time();
    
    // Debugging to verify current time in IST
    System.debug('Current Time in IST: ' + currentLocalTime);
     System.debug('Current : ' + currentTime);
     // System.debug('Current timezone : ' + Timezone.getTimeZone('Asia/Kolkata'));
    
    // Query for invigilator assignments
    List<rve_Invigilator_Assignment__c> existingAssignments = [
     SELECT Id, rve_Date__c, rve_Shift__c, rve_Professor__r.Name, rve_Exam_Time__c, Name
FROM rve_Invigilator_Assignment__c
WHERE (rve_Date__c > TODAY OR 
       (rve_Date__c = TODAY AND rve_Exam_Time__c > :currentLocalTime))
      AND rve_Professor__r.Name != null

    ];
    
    // Debugging to verify the number of invigilator assignments retrieved
    System.debug('Number of invigilator assignments: ' + existingAssignments.size());
    
    return existingAssignments;
}
 

 
    

   @AuraEnabled
    public static void updateProfessor(String assignmentId, String professorId) {
        rve_Invigilator_Assignment__c assignment = [SELECT Id, rve_Professor__c FROM rve_Invigilator_Assignment__c  WHERE Id = :assignmentId LIMIT 1];
        if (assignment != null) {
            assignment.rve_Professor__c = professorId;
            update assignment;
        
    }}}