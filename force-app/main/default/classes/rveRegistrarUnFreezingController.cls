public with sharing class rveRegistrarUnFreezingController {
   
    @AuraEnabled(cacheable=true)
    public static list<Account> getSchools(){
        return [Select Id,name from Account where RecordType.DeveloperName = 'University_Department'];
    }

    @AuraEnabled(cacheable=true)
    public static List<hed__Program_Plan__c> getRelatedProgramBatch(String SchoolId){
        return [Select id,name from hed__Program_Plan__c where hed__Account__r.parent.id =: SchoolId];
    }

    @AuraEnabled(cacheable=true)
    public static List<hed__term__c> getRelatedSemester(String ProgramBatchId){
        try {
            List<hed__term__c>SemList = [Select id,name,SchoolDirectorFreeze__c from hed__term__c where Program_Batch__c =: ProgramBatchId and Active__c=true];
        return SemList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string updateSchoolDirectorFreezingStatus(String SemId){
        try {
            hed__term__c term = [Select id,SchoolDirectorFreeze__c from hed__term__c where id =: SemId];
            term.SchoolDirectorFreeze__c = false;
            update term;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}