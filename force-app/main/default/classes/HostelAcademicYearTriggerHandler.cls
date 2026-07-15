public class HostelAcademicYearTriggerHandler {
    public static void handleTrigger(
        Boolean isInsert, 
        Boolean isUpdate, 
        Boolean isDelete, 
        List<REVA_Hostel_Academic_Year__c> newList, 
        List<REVA_Hostel_Academic_Year__c> oldList,
        Map<Id, REVA_Hostel_Academic_Year__c> newMap,
        Map<Id, REVA_Hostel_Academic_Year__c> oldMap
    ) {
        if (isInsert || isUpdate) {
            validateAcademicYearActivation(newList, oldMap);
        }
        if (isDelete) {
            preventActiveAcademicYearDeletion(oldList);
        }
    }
    
    private static void validateAcademicYearActivation(List<REVA_Hostel_Academic_Year__c> newList, Map<Id, REVA_Hostel_Academic_Year__c> oldMap) {
        List<REVA_Hostel_Academic_Year__c> existingActiveYears = [
            SELECT Id FROM REVA_Hostel_Academic_Year__c 
            WHERE Is_Active_Academic__c = TRUE AND Id NOT IN :newList
        ];
        
        Map<Id, Integer> academicYearChildCountMap = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT REVA_Hostel_Academic_Year__c Id, COUNT(Id) totalCount 
            FROM Hostel_Fee_Structure__c 
            WHERE REVA_Hostel_Academic_Year__c IN :newList
            GROUP BY REVA_Hostel_Academic_Year__c
        ]) {
            academicYearChildCountMap.put((Id) ar.get('Id'), (Integer) ar.get('totalCount'));
        }
        
        for (REVA_Hostel_Academic_Year__c academicYear : newList) {
            //Boolean oldActiveStatus = oldMap.get(academicYear.Id)?.Is_Active_Academic__c;
            
            if (academicYear.Is_Active_Academic__c == true ) {
                if (!existingActiveYears.isEmpty()) {
                    academicYear.addError('Another academic year is already active. Please deactivate it before activating a new one.');
                }
                
                else if (!academicYearChildCountMap.containsKey(academicYear.Id) || academicYearChildCountMap.get(academicYear.Id) == 0) {
                    academicYear.addError('Cannot activate this academic year as there are no associated Hostel Fee Structures.');
                }
            }
        }
    }
    
    private static void preventActiveAcademicYearDeletion(List<REVA_Hostel_Academic_Year__c> oldList) {
        for (REVA_Hostel_Academic_Year__c academicYear : oldList) {
            if (academicYear.Is_Active_Academic__c) {
                academicYear.addError('Deletion not allowed for an active academic year. Please deactivate it first, then activate another academic year before deleting.');
            }
        }
    }
}