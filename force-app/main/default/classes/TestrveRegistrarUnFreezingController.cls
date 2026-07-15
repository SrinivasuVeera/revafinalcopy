@isTest
public class TestrveRegistrarUnFreezingController {
    
    @TestSetup
    static void createData(){
      Recordtype Rec = [Select Id from RecordType where sobjectType='Account' and DeveloperName='University_Department'];
      Account acc = ASM_TestDataFactory.createAcc(1);
      acc.RecordTypeId=rec.id;
      insert acc;
        
      RecordType Rt = [Select Id from RecordType where sobjectType='Hed__Term__c' and developername='Semester' limit 1];
        Hed__Term__c ParentTerm = ASM_TestDataFactory.createTerm('Sem-2',acc.id,Rt.Id);
        insert parentTerm;
        Hed__Term__c childTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert childTerm;
        childTerm.hed__Parent_Term__c = ParentTerm.id;
        update childTerm;
    }
    
    @isTest
    static void getSchools(){
        rveRegistrarUnFreezingController.getSchools();
    }
    
    @isTest
    static void getRelatedProgramBatch(){
        Account acc = [Select Id from Account where name = 'Test Acc1'];
        rveRegistrarUnFreezingController.getRelatedProgramBatch(acc.id);
    }
    
     @isTest
    static void getRelatedSemester(){
        rveRegistrarUnFreezingController.getRelatedSemester('Test');
    }
    
    @isTest
    static void updateSchoolDirectorFreezingStatus(){
        hed__term__c term = [Select Id from hed__term__c where Name='Sem-1'];
        rveRegistrarUnFreezingController.updateSchoolDirectorFreezingStatus(term.id);
    }

}