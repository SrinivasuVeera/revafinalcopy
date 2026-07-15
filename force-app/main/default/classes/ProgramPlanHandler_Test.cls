@isTest
public class ProgramPlanHandler_Test 
{
    public static testMethod Void PlanMethod()
    {
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        insert objProgPlan;
        
        map<id,hed__Program_Plan__c> map_prog = new map<id,hed__Program_Plan__c>();
        map_prog.put(objProgPlan.id,objProgPlan); 
        
        objProgPlan.name='plan test';
        update objProgPlan;
        
        list<hed__Program_Plan__c> lst_prog = new list<hed__Program_Plan__c>();
        lst_prog.add(objProgPlan); 
        
        test.starttest();
        ProgramPlanHandler.updateProgramPlanName(lst_prog,null);
        ProgramPlanHandler.updateProgramPlanName(lst_prog,map_prog);
        test.stoptest();
        
    }
}