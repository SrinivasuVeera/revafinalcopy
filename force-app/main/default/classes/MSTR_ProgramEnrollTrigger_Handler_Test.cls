@isTest
public class MSTR_ProgramEnrollTrigger_Handler_Test 
{
    public static testmethod void ProgramEnroll()
    {
        //Insert section
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();       
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId );
        objAccount.RecordTypeid = AcaRecId;
        insert objAccount;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;
        
        string sectiontermRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objSectionTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,sectiontermRtId);
        objSectionTerm.Program_Batch__c  = objProgPlan.id;
        insert objSectionTerm;   
                
        string BatchtermRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Batches).getRecordTypeId();
        hed__Term__c objBatchtermRt = MSTR_TestDataFactory.createTerm('test term',objAccount.id,BatchtermRtId);
        objBatchtermRt.Program_Batch__c  = objProgPlan.id;
        insert objBatchtermRt;   
        
        Contact objCon = MSTR_TestDataFactory.createContact('TestContact');
        objCon.AccountId = objAccount.Id;
        insert objCon;
        
        hed__Program_Enrollment__c objProgEnrol =  MSTR_TestDataFactory.createProgEnrollment(objCon.id, objAccount.Id);
        objProgEnrol.Batch__c = objBatchtermRt.id;
        objProgEnrol.hed__Start_Date__c = system.today();
        objProgEnrol.hed__End_Date__c = system.today()+2;
        insert objProgEnrol;
        
        List<hed__Program_Enrollment__c> list_ProgEnrol = New List<hed__Program_Enrollment__c>();
        list_ProgEnrol.add(objProgEnrol);
        
        objProgEnrol.Section__c = objSectionTerm.id;
        update objProgEnrol;
                
        Map<id, hed__Program_Enrollment__c> Map_oldPrgmEnrol = New  Map<id, hed__Program_Enrollment__c>();
        Map_oldPrgmEnrol.put(objProgEnrol.id, objProgEnrol);
                
        Test.startTest();
        MSTR_ProgramEnrollmentTrigger_Handler.ProgramEnrollment(list_ProgEnrol, Map_oldPrgmEnrol);
        Test.stopTest();
        system.assertequals(objProgEnrol.Section__c,objSectionTerm.id);
        
    }
    
    
}