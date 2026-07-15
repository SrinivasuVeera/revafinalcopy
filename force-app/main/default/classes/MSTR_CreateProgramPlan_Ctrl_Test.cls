@isTest
public class MSTR_CreateProgramPlan_Ctrl_Test 
{
    public static testMethod Void ProgramPlanMethod()
    {       
        string EducationRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',EducationRecId);
        objAccount1.RecordTypeid =EducationRecId  ;
        objAccount1.Program_Type__c = 'UG';
        insert objAccount1;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account Child',AcaRecId);
        objAccount.RecordTypeid = AcaRecId;
        objAccount.Parentid = objAccount1.id;
        objAccount.Program_Type__c ='UG';
        objAccount.Number_of_Batches__c= 2;
        objAccount.Intake__c = 1;
        objAccount.Intake_Per_Section__c = 2;
        objAccount.Number_of_Semesters__c =2;
        objAccount.No_of_Years__c =2;
        insert objAccount;
        
        list<Account> lst_Acc = new List<Account>();
        lst_Acc.add(objAccount); 
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id; 
        objProgPlan.hed__Start_Date__c = system.today();
        objProgPlan.Number_of_Years__c =4;
        insert objProgPlan;
        
        list<hed__Program_Plan__c>  lst_Program =  new list<hed__Program_Plan__c>();
        lst_Program.add(objProgPlan); 
        
        test.starttest();
        MSTR_CreateProgramPlan_Ctrl.DisplayFacultyRecords();
        MSTR_CreateProgramPlan_Ctrl.DisplayAccount('UG',objAccount1.id);
        MSTR_CreateProgramPlan_Ctrl.DisplayProgramPlan(lst_Acc,system.today());
        MSTR_CreateProgramPlan_Ctrl.CreateProgramPlan(lst_Program); 
        MSTR_CreateProgramPlan_Ctrl.getProgramType();
        MSTR_CreateProgramPlan_Ctrl.ExistingProgramPlan(lst_Program);
        test.stoptest();
        system.assertequals(objAccount1.Program_Type__c,'UG');
    }
}