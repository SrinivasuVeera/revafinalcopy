public class UpdateSyllabusCountHandler {
    @TestVisible
    private static Boolean isProcessed = false;
    
    public static void updateSemesterCourseCounts(Set<Id> semesterIds) {
        if (isProcessed) return;
        isProcessed = true;
        
        if (semesterIds.isEmpty() || semesterIds == null) {
            return;
        }

        Map<Id, Integer> newSemesterCourseCounts = new Map<Id, Integer>();
        
        for (Id semId : semesterIds) {
            newSemesterCourseCounts.put(semId, 0);
        }       
        
        List<hed__Plan_Requirement__c> relevantPlanRequirements = [
            SELECT Id, Semester__c,hed__Category__c, hed__Course__r.Total_Maximum_Marks_IA_External__c
            FROM hed__Plan_Requirement__c
            WHERE Semester__c IN :semesterIds
            AND hed__Plan_Requirement__c = NULL
        ];
        
        for (hed__Plan_Requirement__c pr : relevantPlanRequirements) { 
            
            Boolean shouldCount = false;
            String category = pr.hed__Category__c;
            
            if (category == 'Professional Elective' || category == 'Open Elective') {               
                shouldCount = true;
            } else if (pr.hed__Course__c != null) {                
                Decimal maxMarks = pr.hed__Course__r.Total_Maximum_Marks_IA_External__c;
                if (maxMarks != null && maxMarks != 0) {
                    shouldCount = true;
                }
            }
            
            if (shouldCount) {
                Integer currentCount = newSemesterCourseCounts.get(pr.Semester__c);
                newSemesterCourseCounts.put(pr.Semester__c, currentCount + 1);
            }
        }
        
        List<hed__Term__c> semestersToUpdate = new List<hed__Term__c>();
        
        for (Id semesterId : semesterIds) {
            Integer count = newSemesterCourseCounts.get(semesterId);
            
            semestersToUpdate.add(new hed__Term__c(
                Id = semesterId,
                No_of_Courses_Per_Student__c = count
            ));
        }
        
        if (!semestersToUpdate.isEmpty()) {
            update semestersToUpdate;
        }
    }
    @TestVisible
    public static void resetIsProcessed() {
        isProcessed = false;
    }
}