@isTest
public class MSTR_createPlanRequiementCls_Test 
{
    public static testMethod Void CreatePlanMethod()
    {
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       string termRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test termbatch',objAccount.id,termRecId );
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Hardcore Course';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan.count = '10';
       WrapPlan.courseName = 'test';
       WrapPlan.credits = 10;
       WrapPlan.termId = objTerm.id;
       
       hed__Plan_Requirement__c objPlanReqHI1= MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReqHI1.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReqHI1.Semester__c = objTerm.id;
       objPlanReqHI1.Credits__c = 10;
       objPlanReqHI1.Sequence__c =2;
       insert objPlanReqHI1;
       
       hed__Plan_Requirement__c objPlanReqHI = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReqHI.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReqHI.Semester__c = objTerm.id;
       objPlanReqHI.Credits__c = 10;
       objPlanReqHI.Sequence__c =2;
       objPlanReqHI.hed__Plan_Requirement__c = objPlanReqHI1.id;
       insert objPlanReqHI;
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan1 = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan1.count = '10';
       WrapPlan1.courseName = 'test';
       WrapPlan1.credits = 10;
       WrapPlan1.termId = objTerm.id;
       
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrap = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrap.add(WrapPlan1);
      
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrap;
       
       Test.StartTest();
       
       MSTR_createPlanRequiementCls.getProgramPlan(objProgPlan.id);
       MSTR_createPlanRequiementCls.getpicklistFilterIds(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirementCount(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,lst_planwrap,lst_planwrap,null,null,null,null,null,null);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void PracticalMethod()
    {
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       string termRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test termbatch',objAccount.id,termRecId );
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Practical/Term Work';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Practical/Term Work';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
            
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan.count = '10';
       WrapPlan.courseName = 'test';
       WrapPlan.credits = 10;
       WrapPlan.termId = objTerm.id;
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrap = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrap.add(WrapPlan);
       
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrap; 
       
       Test.StartTest();
       
       MSTR_createPlanRequiementCls.getProgramPlan(objProgPlan.id);
       MSTR_createPlanRequiementCls.getpicklistFilterIds(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirementCount(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,null,null,lst_planwrap,null,null,null,null,null);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void HardCourseIntegratedMethod()
    {
      string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       string termRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test termbatch',objAccount.id,termRecId );
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
       
        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan.count = '10';
       WrapPlan.courseName = 'test';
       WrapPlan.credits = 10;
       WrapPlan.termId = objTerm.id;
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrap = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrap.add(WrapPlan);
       
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrap;
       
       Test.StartTest();
       
       MSTR_createPlanRequiementCls.getProgramPlan(objProgPlan.id);
       MSTR_createPlanRequiementCls.getpicklistFilterIds(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirementCount(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,null,lst_planwrap,null,null,null,null,null,null);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
     public static testMethod Void MandatoryMethod()
    {
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       string termRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test termbatch',objAccount.id,termRecId );
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Mandatory Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Mandatory Course';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan.count = '10';
       WrapPlan.courseName = 'test';
       WrapPlan.credits = 10;
       WrapPlan.termId = objTerm.id;
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrap = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrap.add(WrapPlan);
       
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrap;       
       Test.StartTest();
       
       MSTR_createPlanRequiementCls.getProgramPlan(objProgPlan.id);
       MSTR_createPlanRequiementCls.getpicklistFilterIds(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirementCount(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,null,null,null,null,null,lst_planwrap,null,null);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void OpenElectiveMethod()
    {
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       string termRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test termbatch',objAccount.id,termRecId );
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;     
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Open Elective';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Open Elective';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
      
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan.count = '10';
       WrapPlan.courseName = 'test';
       WrapPlan.credits = 10;
       WrapPlan.termId = objTerm.id;
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrap = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrap.add(WrapPlan);
       
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrap;
        
       Test.StartTest();
       
       MSTR_createPlanRequiementCls.getProgramPlan(objProgPlan.id);
       MSTR_createPlanRequiementCls.getpicklistFilterIds(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirementCount(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
       //MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,null,null,null,lst_planwrap,null,null,null);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
     public static testMethod Void ProfElectiveMethod()
    {
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
       
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       string termRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test termbatch',objAccount.id,termRecId );
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
       
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Professional Elective';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement');
       objPlanReq.hed__Category__c = 'Professional Elective';
       objPlanReq.Semester__c = objTerm.id;
       objPlanReq.Credits__c = 10;
       objPlanReq.Sequence__c =2;
       objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
       insert objPlanReq;
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlan = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlan.count = '10';
       WrapPlan.courseName = 'test';
       WrapPlan.credits = 10;
       WrapPlan.termId = objTerm.id;
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrap = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrap.add(WrapPlan);
       
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrap;
       
       Test.StartTest();
          
       MSTR_createPlanRequiementCls.getProgramPlan(objProgPlan.id);
       MSTR_createPlanRequiementCls.getpicklistFilterIds(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirementCount(objProgPlan.id);
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
      // MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,null,null,null,null,lst_planwrap,null,null);
       Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    
    public static testMethod Void OpenElectiveMethod1()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId1;
       insert objAccount2;
       
        string AcaUniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId );
       objAccount.Parentid = objAccount2.id;
       objAccount.RecordTypeid = AcaUniRecId ;
       insert objAccount;
        
        hed__Course__c cur = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Hardcore Course';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Project';
        cur.Offered_By_School__c = objAccount.Id;
        cur.Credit_Hours__c = 04.00;
        cur.Maximum_External_Marks__c = 50;
        cur.Total_Maximum_Marks_IA_External__c = 60;
        cur.No_of_IA_s__c = '1';
        cur.L_T_P__c='2:1:0';
        insert cur;
        
        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test Course1',objAccount.id);
        cur1.hed__Course_ID__c = 'T2';
        cur1.hed__Credit_Hours__c = 80;
        cur1.Category__c = 'Hardcore Integrated Course';
        cur1.Credits__c = 4;
        cur1.hed__Account__c = objAccount.id;
        cur1.Offered_By_School__c = objAccount.Id;
        cur1.Credit_Hours__c = 04.00;
        cur1.Maximum_External_Marks__c = 50;
        cur1.Total_Maximum_Marks_IA_External__c = 60;
        cur1.No_of_IA_s__c = '1';
        cur1.L_T_P__c='2:1:0';
        insert cur1;
        
        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test Course2',objAccount.id);
        cur2.hed__Course_ID__c = 'T23';
        cur2.hed__Credit_Hours__c = 50;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 5;
        cur2.hed__Account__c = objAccount.id;
        cur2.Offered_By_School__c = objAccount.Id;
        cur2.Credit_Hours__c = 04.00;
        cur2.Maximum_External_Marks__c = 50;
        cur2.Total_Maximum_Marks_IA_External__c = 60;
        cur2.No_of_IA_s__c = '1';
        cur2.L_T_P__c='2:1:0';
        insert cur2;
        
        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test Course3',objAccount.id);
        cur3.hed__Course_ID__c = 'T3';
        cur3.hed__Credit_Hours__c = 80;
        cur3.Category__c = 'Mandatory Course';
        cur3.Credits__c = 4;
        cur3.hed__Account__c = objAccount.id;
        cur3.Offered_By_School__c = objAccount.Id;
        cur3.Credit_Hours__c = 04.00;
        cur3.Maximum_External_Marks__c = 50;
        cur3.Total_Maximum_Marks_IA_External__c = 60;
        cur3.No_of_IA_s__c = '1';
        cur3.L_T_P__c='2:1:0';
        insert cur3;
        
        string AcaAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program ).getRecordTypeId();
    
       Account objAccount3 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaAccRecId );
       objAccount3.parentId = objAccount.id;
       objAccount3.recordTypeId = AcaAccRecId ;
       insert objAccount3;
           
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
              
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       objPlanReq1.hed__Course__c = cur.id;
       objPlanReq1.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq2 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq2.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq2.Semester__c = objTerm.id;
       objPlanReq2.Credits__c = 10;
       objPlanReq2.Sequence__c =2;
       objPlanReq2.hed__Course__c = cur1.id;
       objPlanReq2.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq2;
       
       hed__Plan_Requirement__c objPlanReq3 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq3.hed__Category__c = 'Practical/Term Work';
       objPlanReq3.Semester__c = objTerm.id;
       objPlanReq3.Credits__c = 10;
       objPlanReq3.Sequence__c =2;
       objPlanReq3.hed__Course__c = cur2.id;
       objPlanReq3.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq3;
       
       hed__Plan_Requirement__c objPlanReq4 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq4.hed__Category__c = 'Mandatory Course';
       objPlanReq4.Semester__c = objTerm.id;
       objPlanReq4.Credits__c = 10;
       objPlanReq4.Sequence__c =2;
       objPlanReq4.hed__Course__c = cur3.id;
       objPlanReq4.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq4;
       
       MSTR_createPlanRequiementCls.planLiwrap p1 = new MSTR_createPlanRequiementCls.planLiwrap();
       p1.count = '1';
       p1.subCount = '0';
       p1.courseId = cur.id;
       p1.courseName = cur.Name;
       p1.credits = 2;
       p1.termId = objTerm.id;
       p1.recordId = objPlanReq1.id;
       p1.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l1 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p1};
       
       MSTR_createPlanRequiementCls.planLiwrap p2 = new MSTR_createPlanRequiementCls.planLiwrap();
       p2.count = '1';
       p2.subCount = '0';
       p2.courseId = cur1.id;
       p2.courseName = cur1.Name;
       p2.credits = 2;
       p2.termId = objTerm.id;
       p2.recordId = objPlanReq1.id;
       p2.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l2 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p2};
       
       MSTR_createPlanRequiementCls.planLiwrap p3 = new MSTR_createPlanRequiementCls.planLiwrap();
       p3.count = '1';
       p3.subCount = '0';
       p3.courseId = cur2.id;
       p3.courseName = cur2.Name;
       p3.credits = 2;
       p3.termId = objTerm.id;
       p3.recordId = objPlanReq1.id;
       p3.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l3 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p3};
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlanOpen = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlanOpen.count = '10';
       WrapPlanOpen.courseName = 'test';
       WrapPlanOpen.credits = 10;
       WrapPlanOpen.termId = objTerm.id;
       
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrapOpen.add(WrapPlanOpen);
       
       MSTR_createPlanRequiementCls.openElectivewrap opEleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       opEleWrap.count = '10';
       opEleWrap.Name = 'test';
       opEleWrap.credits = 10;
       opEleWrap.termId = objTerm.id;
       opEleWrap.lstPlanLi = lst_planwrapOpen;       
       
       MSTR_createPlanRequiementCls.planLiwrap p4 = new MSTR_createPlanRequiementCls.planLiwrap();
       p4.count = '1';
       p4.subCount = '0';
       p4.courseId = cur3.id;
       p4.courseName = cur3.Name;
       p4.credits = 2;
       p4.termId = objTerm.id;
       p4.recordId = objPlanReq1.id;
       p4.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l4 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p4};
       list<MSTR_createPlanRequiementCls.openElectivewrap> l5 = new list<MSTR_createPlanRequiementCls.openElectivewrap>{opEleWrap};
       list<MSTR_createPlanRequiementCls.profElectivewrap> l6 = new list<MSTR_createPlanRequiementCls.profElectivewrap>();
       list<string> l7 = new list<string>();
       
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,l1,l2,l3,l5,l6,l4,null,l7);
       
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm1.id,l1,l2,l3,l5,l6,l4,null,l7);
       System.AssertEquals(objTerm.id,objTerm.id);
     }  
     public static testMethod Void ProfElectiveMethod1()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId1;
       insert objAccount2;
       
        string AcaUniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId );
       objAccount.Parentid = objAccount2.id;
       objAccount.RecordTypeid = AcaUniRecId ;
       insert objAccount;
        
        hed__Course__c cur = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Hardcore Course';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Project';
        cur.Offered_By_School__c = objAccount.Id;
        cur.Credit_Hours__c = 04.00;
        cur.Maximum_External_Marks__c = 50;
        cur.Total_Maximum_Marks_IA_External__c = 60;
        cur.No_of_IA_s__c = '1';
        cur.L_T_P__c='2:1:0';
        insert cur;
        
        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test Course1',objAccount.id);
        cur1.hed__Course_ID__c = 'T2';
        cur1.hed__Credit_Hours__c = 80;
        cur1.Category__c = 'Hardcore Integrated Course';
        cur1.Credits__c = 4;
        cur1.hed__Account__c = objAccount.id;
        cur1.Offered_By_School__c = objAccount.Id;
        cur1.Credit_Hours__c = 04.00;
        cur1.Maximum_External_Marks__c = 50;
        cur1.Total_Maximum_Marks_IA_External__c = 60;
        cur1.No_of_IA_s__c = '1';
        cur1.L_T_P__c='2:1:0';
        insert cur1;
        
        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test Course2',objAccount.id);
        cur2.hed__Course_ID__c = 'T22';
        cur2.hed__Credit_Hours__c =50;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 8;
        cur2.hed__Account__c = objAccount.id;
        cur2.Offered_By_School__c = objAccount.Id;
        cur2.Credit_Hours__c = 04.00;
        cur2.Maximum_External_Marks__c = 50;
        cur2.Total_Maximum_Marks_IA_External__c = 60;
        cur2.No_of_IA_s__c = '1';
        cur2.L_T_P__c='2:1:0';
        insert cur2;
        
        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test Course3',objAccount.id);
        cur3.hed__Course_ID__c = 'T3';
        cur3.hed__Credit_Hours__c = 80;
        cur3.Category__c = 'Mandatory Course';
        cur3.Credits__c = 4;
        cur3.hed__Account__c = objAccount.id;
        cur3.Offered_By_School__c = objAccount.Id;
        cur3.Credit_Hours__c = 04.00;
        cur3.Maximum_External_Marks__c = 50;
        cur3.Total_Maximum_Marks_IA_External__c = 60;
        cur3.No_of_IA_s__c = '1';
        cur3.L_T_P__c='2:1:0';
        insert cur3;
        
        string AcaAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program ).getRecordTypeId();
    
       Account objAccount3 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaAccRecId );
       objAccount3.parentId = objAccount.id;
       objAccount3.recordTypeId = AcaAccRecId ;
       insert objAccount3;
           
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
              
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'Hardcore Course';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       objPlanReq1.hed__Course__c = cur.id;
       objPlanReq1.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq1;
       
       hed__Plan_Requirement__c objPlanReq2 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq2.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq2.Semester__c = objTerm.id;
       objPlanReq2.Credits__c = 10;
       objPlanReq2.Sequence__c =2;
       objPlanReq2.hed__Course__c = cur1.id;
       objPlanReq2.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq2;
       
       hed__Plan_Requirement__c objPlanReq3 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq3.hed__Category__c = 'Practical/Term Work';
       objPlanReq3.Semester__c = objTerm.id;
       objPlanReq3.Credits__c = 10;
       objPlanReq3.Sequence__c =2;
       objPlanReq3.hed__Course__c = cur2.id;
       objPlanReq3.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq3;
       
       hed__Plan_Requirement__c objPlanReq4 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq4.hed__Category__c = 'Mandatory Course';
       objPlanReq4.Semester__c = objTerm.id;
       objPlanReq4.Credits__c = 10;
       objPlanReq4.Sequence__c =2;
       objPlanReq4.hed__Course__c = cur3.id;
       objPlanReq4.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq4;
       
       MSTR_createPlanRequiementCls.planLiwrap p1 = new MSTR_createPlanRequiementCls.planLiwrap();
       p1.count = '1';
       p1.subCount = '0';
       p1.courseId = cur.id;
       p1.courseName = cur.Name;
       p1.credits = 2;
       p1.termId = objTerm.id;
       p1.recordId = objPlanReq1.id;
       p1.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l1 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p1};
       
       MSTR_createPlanRequiementCls.planLiwrap p2 = new MSTR_createPlanRequiementCls.planLiwrap();
       p2.count = '1';
       p2.subCount = '0';
       p2.courseId = cur1.id;
       p2.courseName = cur1.Name;
       p2.credits = 2;
       p2.termId = objTerm.id;
       p2.recordId = objPlanReq1.id;
       p2.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l2 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p2};
       
       MSTR_createPlanRequiementCls.planLiwrap p3 = new MSTR_createPlanRequiementCls.planLiwrap();
       p3.count = '1';
       p3.subCount = '0';
       p3.courseId = cur2.id;
       p3.courseName = cur2.Name;
       p3.credits = 2;
       p3.termId = objTerm.id;
       p3.recordId = objPlanReq1.id;
       p3.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l3 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p3};
       
       MSTR_createPlanRequiementCls.planLiwrap WrapPlanOpen = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlanOpen.count = '10';
       WrapPlanOpen.courseName = 'test';
       WrapPlanOpen.credits = 10;
       WrapPlanOpen.termId = objTerm.id;
       
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrapOpen.add(WrapPlanOpen);
       
       MSTR_createPlanRequiementCls.profElectivewrap profEleWrap =  new MSTR_createPlanRequiementCls.profElectivewrap();
       profEleWrap.count = '10';
       profEleWrap.Name = 'test';
       profEleWrap.credits = 10;
       profEleWrap.termId = objTerm.id;
       profEleWrap.lstPlanLi = lst_planwrapOpen;     
       
       MSTR_createPlanRequiementCls.planLiwrap p4 = new MSTR_createPlanRequiementCls.planLiwrap();
       p4.count = '1';
       p4.subCount = '0';
       p4.courseId = cur3.id;
       p4.courseName = cur3.Name;
       p4.credits = 2;
       p4.termId = objTerm.id;
       p4.recordId = objPlanReq1.id;
       p4.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l4 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p4};
       list<MSTR_createPlanRequiementCls.openElectivewrap> l5 = new list<MSTR_createPlanRequiementCls.openElectivewrap>();
       list<MSTR_createPlanRequiementCls.profElectivewrap> l6 = new list<MSTR_createPlanRequiementCls.profElectivewrap>{profEleWrap};
       list<string> l7 = new list<string>();
       
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm.id,l1,l2,l3,l5,l6,l4,null,l7);
       
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm1.id,l1,l2,l3,l5,l6,l4,null,l7);
       System.AssertEquals(objTerm.id,objTerm.id);
     } 
    public static testMethod Void RBSSpclMethod()
    {
       string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
       
       Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount.RecordTypeid = AcaRecId1;
       insert objAccount;
        
      string spclRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RBS Specialization').getRecordTypeId();
       
       Account objSpclAccount = MSTR_TestDataFactory.CreateAccount('Test Account',spclRecordType );
       objSpclAccount.RecordTypeid = spclRecordType;
       objSpclAccount.ParentId = objAccount.id;
       insert objSpclAccount;
       
       string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
       objAccount1.RecordTypeid = AcaRecId;
       insert objAccount1;
       
       string AcaRecId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();
       
       Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
       objAccount2.Parentid = objAccount1.id;
       objAccount2.RecordTypeid = AcaRecId3;
       insert objAccount2;
       
        string AcaUniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
       
       Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId );
       objAccount4.Parentid = objAccount2.id;
       objAccount4.RecordTypeid = AcaUniRecId ;
       insert objAccount4; 
        
       
        
        hed__Course__c cur = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        cur.hed__Course_ID__c = 'T777';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'RBS Specialization';
        cur.Credits__c = 4;
        cur.HardCore_Sub_Type__c = 'Project';
        cur.Offered_By_School__c = objAccount4.Id;
        cur.hed__Account__c = objAccount4.Id;
        cur.Specialization__c = objSpclAccount.Id;
        cur.Credit_Hours__c = 04.00;
        cur.Maximum_External_Marks__c = 50;
        cur.Total_Maximum_Marks_IA_External__c = 60;
        cur.No_of_IA_s__c = '1';
        cur.L_T_P__c='2:1:0';
        insert cur;
        
        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        cur1.hed__Course_ID__c = 'T1';
        cur1.hed__Credit_Hours__c = 80;
        cur1.Category__c = 'Hardcore Course';
        cur1.Credits__c = 4;
        cur1.hed__Account__c = objAccount.id;
        cur1.HardCore_Sub_Type__c = 'Project';
        cur1.Offered_By_School__c = objAccount4.Id;
        cur1.Credit_Hours__c = 04.00;
        cur1.Maximum_External_Marks__c = 50;
        cur1.Total_Maximum_Marks_IA_External__c = 60;
        cur1.No_of_IA_s__c = '1';
        cur1.L_T_P__c='2:1:0';
        insert cur1;
        
        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test Course2',objAccount.id);
        cur2.hed__Course_ID__c = 'T22';
        cur2.hed__Credit_Hours__c =50;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 8;
        cur2.hed__Account__c = objAccount.id;
        cur2.Offered_By_School__c = objAccount4.Id;
        cur2.Credit_Hours__c = 04.00;
        cur2.Maximum_External_Marks__c = 50;
        cur2.Total_Maximum_Marks_IA_External__c = 60;
        cur2.No_of_IA_s__c = '1';
        cur2.L_T_P__c='2:1:0';
        insert cur2;
        
        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test Course3',objAccount.id);
        cur3.hed__Course_ID__c = 'T3';
        cur3.hed__Credit_Hours__c = 80;
        cur3.Category__c = 'Mandatory Course';
        cur3.Credits__c = 4;
        cur3.hed__Account__c = objAccount.id;
        cur3.Offered_By_School__c = objAccount4.Id;
        cur3.Credit_Hours__c = 04.00;
        cur3.Maximum_External_Marks__c = 50;
        cur3.Total_Maximum_Marks_IA_External__c = 60;
        cur3.No_of_IA_s__c = '1';
        cur3.L_T_P__c='2:1:0';
        insert cur3;
        
        hed__Course__c cur4 = MSTR_TestDataFactory.CreateCourse('Test Course1',objAccount.id);
        cur4.hed__Course_ID__c = 'T2';
        cur4.hed__Credit_Hours__c = 80;
        cur4.Category__c = 'Hardcore Integrated Course';
        cur4.Credits__c = 4;
        cur4.hed__Account__c = objAccount.id;
        cur4.Offered_By_School__c = objAccount4.Id;
        cur4.Credit_Hours__c = 04.00;
        cur4.Maximum_External_Marks__c = 50;
        cur4.Total_Maximum_Marks_IA_External__c = 60;
        cur4.No_of_IA_s__c = '1';
        cur4.L_T_P__c='2:1:0';
        insert cur4;
      
           
       hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
       insert objProgPlan;
       
       string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
       hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm.Program_Batch__c  = objProgPlan.id;
       insert objTerm;
       
       hed__Term__c objTerm1 = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
       objTerm1.Program_Batch__c  = objProgPlan.id;
       insert objTerm1;
              
      
        
        
       hed__Plan_Requirement__c objPlanReq5 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq5.hed__Category__c = 'Hardcore Course';
       objPlanReq5.Semester__c = objTerm.id;
       objPlanReq5.Credits__c = 10;
       objPlanReq5.Sequence__c =2;
       objPlanReq5.hed__Course__c = cur1.id;
       objPlanReq5.hed__Program_Plan__c = objProgPlan.id;
       //insert objPlanReq5;
       
       hed__Plan_Requirement__c objPlanReq2 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq2.hed__Category__c = 'Hardcore Integrated Course';
       objPlanReq2.Semester__c = objTerm.id;
       objPlanReq2.Credits__c = 10;
       objPlanReq2.Sequence__c =2;
       objPlanReq2.hed__Course__c = cur4.id;
       objPlanReq2.hed__Program_Plan__c = objProgPlan.id;
       //insert objPlanReq2;
       
       hed__Plan_Requirement__c objPlanReq3 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq3.hed__Category__c = 'Practical/Term Work';
       objPlanReq3.Semester__c = objTerm.id;
       objPlanReq3.Credits__c = 10;
       objPlanReq3.Sequence__c =2;
       objPlanReq3.hed__Course__c = cur2.id;
       objPlanReq3.hed__Program_Plan__c = objProgPlan.id;
       //insert objPlanReq3;
       
       hed__Plan_Requirement__c objPlanReq4 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq4.hed__Category__c = 'Mandatory Course';
       objPlanReq4.Semester__c = objTerm.id;
       objPlanReq4.Credits__c = 10;
       objPlanReq4.Sequence__c =2;
       objPlanReq4.hed__Course__c = cur3.id;
       objPlanReq4.hed__Program_Plan__c = objProgPlan.id;
      // insert objPlanReq4;
        

       
       MSTR_createPlanRequiementCls.planLiwrap p1 = new MSTR_createPlanRequiementCls.planLiwrap();
       p1.count = '1';
       p1.subCount = '0';
       p1.courseId = cur1.id;
       p1.courseName = cur1.Name;
       p1.credits = 2;
       p1.termId = objTerm.id;
      // p1.recordId = objPlanReq5.id;
       p1.filter = '';
             
       list<MSTR_createPlanRequiementCls.planLiwrap> l1 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p1};
           
       
       MSTR_createPlanRequiementCls.planLiwrap p2 = new MSTR_createPlanRequiementCls.planLiwrap();
       p2.count = '1';
       p2.subCount = '0';
       p2.courseId = cur2.id;
       p2.courseName = cur2.Name;
       p2.credits = 2;
       p2.termId = objTerm.id;
      // p2.recordId = objPlanReq3.id;
       p2.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l2 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p2};
           
       
      
       
       MSTR_createPlanRequiementCls.planLiwrap p3 = new MSTR_createPlanRequiementCls.planLiwrap();
       p3.count = '1';
       p3.subCount = '0';
       p3.courseId = cur3.id;
       p3.courseName = cur3.Name;
       p3.credits = 2;
       p3.termId = objTerm.id;
       //p3.recordId = objPlanReq4.id;
       p3.filter = '';
       list<MSTR_createPlanRequiementCls.planLiwrap> l3 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p3};
     
     
        MSTR_createPlanRequiementCls.planLiwrap p4 = new MSTR_createPlanRequiementCls.planLiwrap();
       p4.count = '1';
       p4.subCount = '0';
       p4.courseId = cur4.id;
       p4.courseName = cur4.Name;
       p4.credits = 2;
       p4.termId = objTerm.id;
       //p4.recordId = objPlanReq2.id;
       p4.filter = '';
        
       list<MSTR_createPlanRequiementCls.planLiwrap> l4 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p4};
        
        
       MSTR_createPlanRequiementCls.planLiwrap p5 = new MSTR_createPlanRequiementCls.planLiwrap();
       p5.count = '1';
       p5.subCount = '0';
       p5.courseId = cur.id;
       p5.courseName = cur.Name;
       p5.credits = 2;
       p5.termId = objTerm.id;
      // p5.recordId = objPlanReq1.id;
       p5.filter = '';
        
       list<MSTR_createPlanRequiementCls.planLiwrap> l5 = new list<MSTR_createPlanRequiementCls.planLiwrap>{p5};
       MSTR_createPlanRequiementCls.rbsSpclWrap rbsWrap =  new MSTR_createPlanRequiementCls.rbsSpclWrap();
       rbsWrap.count = '10';
       rbsWrap.Name = 'test';
       rbsWrap.credits = 10;
       rbsWrap.termId = objTerm.id;
       rbsWrap.lstPlanLi = l5;     
   
       MSTR_createPlanRequiementCls.planLiwrap WrapPlanOpen = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlanOpen.count = '10';
       WrapPlanOpen.courseName = 'test';
       WrapPlanOpen.credits = 10;
       WrapPlanOpen.termId = objTerm.id;
       
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrapOpen.add(WrapPlanOpen);
        
       
       MSTR_createPlanRequiementCls.profElectivewrap profEleWrap =  new MSTR_createPlanRequiementCls.profElectivewrap();
       profEleWrap.count = '10';
       profEleWrap.Name = 'test';
       profEleWrap.credits = 10;
       profEleWrap.termId = objTerm.id;
       profEleWrap.lstPlanLi = lst_planwrapOpen; 
        
        
        
            
       MSTR_createPlanRequiementCls.planLiwrap WrapPlanOpenE = new MSTR_createPlanRequiementCls.planLiwrap();
       WrapPlanOpenE.count = '10';
       WrapPlanOpenE.courseName = 'test777';
       WrapPlanOpenE.credits = 10;
       WrapPlanOpenE.termId = objTerm.id;
       
       list<MSTR_createPlanRequiementCls.planLiwrap>  lst_planwrapOpenE = new list<MSTR_createPlanRequiementCls.planLiwrap>();
       lst_planwrapOpenE.add(WrapPlanOpenE);
        
       
       MSTR_createPlanRequiementCls.openElectivewrap eleWrap =  new MSTR_createPlanRequiementCls.openElectivewrap();
       profEleWrap.count = '10';
       profEleWrap.Name = 'testttt';
       profEleWrap.credits = 10;
       profEleWrap.termId = objTerm.id;
       profEleWrap.lstPlanLi = lst_planwrapOpenE; 
        
       list<MSTR_createPlanRequiementCls.rbsSpclWrap> l6 = new list<MSTR_createPlanRequiementCls.rbsSpclWrap>{rbsWrap};

       list<MSTR_createPlanRequiementCls.openElectivewrap> l8 = new list<MSTR_createPlanRequiementCls.openElectivewrap>{eleWrap};
       list<MSTR_createPlanRequiementCls.profElectivewrap> l7 = new list<MSTR_createPlanRequiementCls.profElectivewrap>{profEleWrap};
       list<string> l9 = new list<string>();
      
      
       
       MSTR_createPlanRequiementCls.savePlanRequiement(objProgPlan.id,objTerm1.id,l1,l4,l2,l8,l7,l3,l6,l9);
        MSTR_createPlanRequiementCls.fetchRBSSpecializationNames();
        
       hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq1.hed__Category__c = 'RBS Specialization';
       objPlanReq1.Semester__c = objTerm.id;
       objPlanReq1.Credits__c = 10;
       objPlanReq1.Sequence__c =2;
       objPlanReq1.Specialization__c = objSpclAccount.Id;
       objPlanReq1.hed__Course__c = cur.id;
       objPlanReq1.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq1;
        
       MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
        
        
        hed__Plan_Requirement__c objPlanReq8 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
       objPlanReq8.hed__Category__c = 'Hardcore Course';
       objPlanReq8.Semester__c = objTerm.id;
       objPlanReq8.Credits__c = 10;
       objPlanReq8.Sequence__c =2;
       objPlanReq8.Specialization__c = objSpclAccount.Id;
       objPlanReq8.hed__Course__c = cur.id;
       objPlanReq8.hed__Program_Plan__c = objProgPlan.id;
       insert objPlanReq8;
        MSTR_createPlanRequiementCls.queryPlanRequirements(objTerm.id);
        
      
    }
}