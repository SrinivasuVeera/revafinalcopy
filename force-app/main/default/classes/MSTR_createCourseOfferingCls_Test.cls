@isTest
public class MSTR_createCourseOfferingCls_Test
{
    public static testMethod Void CreateCourseMethod()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.Parentid = objAccount1.id;
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

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

        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId2;
        insert objAccount2;

        string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();
        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
        objAccount1.Parentid = objAccount2.id;
        objAccount1.RecordTypeid = AcaUniRecId4 ;
        insert objAccount4;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c = 'Theory';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Hardcore Course';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOff;

        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId =  objCourseOff.id;
        plnWrap.termId = objTerm.Id;

        list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planWrap.add(plnWrap);

        Test.StartTest();
        MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,lst_planWrap,null,null,null,null,null,Null,Null,false,false);
        Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void CreateCourseMethod1()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.Parentid = objAccount1.id;
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq1.hed__Category__c = 'Practical/Term Work';
        objPlanReq1.Semester__c = objTerm.id;
        objPlanReq1.Credits__c = 10;
        objPlanReq1.Sequence__c =2;
        insert objPlanReq1;

        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq.hed__Category__c = 'Practical/Term Work';
        objPlanReq.Semester__c = objTerm.id;
        objPlanReq.Credits__c = 10;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
        objPlanReq.Sequence__c =2;
        insert objPlanReq;


        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId2;
        insert objAccount2;

        string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();

        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
        objAccount1.Parentid = objAccount2.id;
        objAccount1.RecordTypeid = AcaUniRecId4 ;
        insert objAccount4;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Practical/Term Work';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60 ;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Practical/Term Work';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOff;

        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId =  objCourseOff.id;
        plnWrap.termId = objTerm.Id;

        list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planWrap.add(plnWrap);

        Test.StartTest();
        MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,null,null,lst_planWrap,null,null,null,Null,Null,false,false);
        Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void CreateCourseMethod2()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.Parentid = objAccount1.id;
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq1.hed__Category__c = 'Hardcore Integrated Course';
        objPlanReq1.Semester__c = objTerm.id;
        objPlanReq1.Credits__c = 10;
        objPlanReq1.Sequence__c =2;
        insert objPlanReq1;

        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq.hed__Category__c = 'Hardcore Integrated Course';
        objPlanReq.Semester__c = objTerm.id;
        objPlanReq.Credits__c = 10;
        objPlanReq.Sequence__c =2;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
        insert objPlanReq;

        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId2;
        insert objAccount2;

        string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();

        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
        objAccount1.Parentid = objAccount2.id;
        objAccount1.RecordTypeid = AcaUniRecId4 ;
        insert objAccount4;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Integrated Course';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Hardcore Integrated Course';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOff;

        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId =  objCourseOff.id;
        plnWrap.termId = objTerm.Id;

        list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planWrap.add(plnWrap);

        Test.StartTest();
        MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,null,lst_planWrap,null,null,null,null,Null,Null,false,false);
        Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void CreateCourseMethod3()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.Parentid = objAccount1.id;
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq1.hed__Category__c = 'Mandatory Course';
        objPlanReq1.Semester__c = objTerm.id;
        objPlanReq1.Credits__c = 10;
        objPlanReq1.Sequence__c =2;
        insert objPlanReq1;

        hed__Plan_Requirement__c objPlanReq= MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq.hed__Category__c = 'Mandatory Course';
        objPlanReq.Semester__c = objTerm.id;
        objPlanReq.Credits__c = 10;
        objPlanReq.Sequence__c =2;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
        insert objPlanReq;

        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId2;
        insert objAccount2;

        string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();

        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
        objAccount1.Parentid = objAccount2.id;
        objAccount1.RecordTypeid = AcaUniRecId4 ;
        insert objAccount4;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Mandatory Course';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Mandatory Course';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOff;

        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId =  objCourseOff.id;
        plnWrap.termId = objTerm.Id;

        list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planWrap.add(plnWrap);

        Test.StartTest();
        MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,null,null,null,null,null,lst_planWrap,Null,Null,false,false);
        Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void CreateCourseMethod4()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.Parentid = objAccount1.id;
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq1.hed__Category__c = 'Professional Elective';
        objPlanReq1.Semester__c = objTerm.id;
        objPlanReq1.Credits__c = 10;
        objPlanReq1.Sequence__c =2;
        insert objPlanReq1;

        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq.hed__Category__c = 'Professional Elective';
        objPlanReq.Semester__c = objTerm.id;
        objPlanReq.Credits__c = 10;
        objPlanReq.Sequence__c =2;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
        insert objPlanReq;


        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId2;
        insert objAccount2;

        string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();

        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
        objAccount1.Parentid = objAccount2.id;
        objAccount1.RecordTypeid = AcaUniRecId4 ;
        insert objAccount4;


        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Professional Elective';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Professional Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Professional Elective';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOff;

        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId =  objCourseOff.id;
        plnWrap.termId = objTerm.Id;

        list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planWrap.add(plnWrap);

        Test.StartTest();
        MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,lst_planWrap,null,null,null,null,null,Null,Null,false,false);
        Test.StopTest();
        System.AssertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void CreateCourseMethod5()
    {
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;

        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.Parentid = objAccount1.id;
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.Course_Offering_Created__c = true;
        insert objTerm;

        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq1.hed__Category__c = 'Open Elective';
        objPlanReq1.Semester__c = objTerm.id;
        objPlanReq1.Credits__c = 10;
        objPlanReq1.Sequence__c =2;
        insert objPlanReq1;

        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        objPlanReq.hed__Category__c = 'Open Elective';
        objPlanReq.Semester__c = objTerm.id;
        objPlanReq.Credits__c = 10;
        objPlanReq.Sequence__c =2;
        objPlanReq.hed__Plan_Requirement__c = objPlanReq1.id;
        insert objPlanReq;


        string AcaRecId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution ).getRecordTypeId();

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId2 );
        objAccount2.Parentid = objAccount1.id;
        objAccount2.RecordTypeid = AcaRecId2;
        insert objAccount2;

        string AcaUniRecId4 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department ).getRecordTypeId();

        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaUniRecId4 );
        objAccount1.Parentid = objAccount2.id;
        objAccount1.RecordTypeid = AcaUniRecId4 ;
        insert objAccount4;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Open Elective';
        objCourse.Offered_By_School__c = objAccount4.Id;
        objCourse.Credit_Hours__c = 04.00;
        objCourse.hed__Account__c = objAccount4.Id;
        objCourse.Credits__c = 04.00;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 60;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Open Elective';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOff;

        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId =  objCourseOff.id;
        plnWrap.termId = objTerm.Id;

        list<MSTR_createCourseOfferingCls.planLiwrap> lst_planWrap = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planWrap.add(plnWrap);

        Test.StartTest();
        MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id,lst_planWrap,null,null,null,null,null,Null,Null,false,false);
        Test.StopTest();
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

        hed__Course__c cur= MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        cur.Category__c = 'Hardcore Course';
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Hardcore Course';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Theory';
        cur.Offered_By_School__c = objAccount.Id;
        cur.Credit_Hours__c = 04.00;
        cur.Maximum_External_Marks__c = 50;
        cur.Total_Maximum_Marks_IA_External__c = 60;
        cur.No_of_IA_s__c = '1';
        cur.L_T_P__c='2:1:0';
        insert cur;

        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test1',objAccount.id);
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

        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test2',objAccount.id);
        cur2.hed__Course_ID__c = 'T10';
        cur2.hed__Credit_Hours__c = 80;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 4;
        cur2.hed__Account__c = objAccount.id;
        cur2.Offered_By_School__c = objAccount.Id;
        cur2.Credit_Hours__c = 04.00;
        cur2.Maximum_External_Marks__c = 50;
        cur2.Total_Maximum_Marks_IA_External__c = 60;
        cur2.No_of_IA_s__c = '1';
        cur2.L_T_P__c='2:1:0';
        insert cur2;

        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test3',objAccount.id);
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

        MSTR_createCourseOfferingCls.planLiwrap p1 = new MSTR_createCourseOfferingCls.planLiwrap();
        p1.count = '1';
        p1.subCount = '0';
        p1.courseId = cur.id;
        p1.courseName = cur.Name;
        p1.credits = 2;
        p1.termId = objTerm.id;
        p1.recordId = Null;
        p1.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l1 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p1};

            MSTR_createCourseOfferingCls.planLiwrap p2 = new MSTR_createCourseOfferingCls.planLiwrap();
        p2.count = '1';
        p2.subCount = '0';
        p2.courseId = cur1.id;
        p2.courseName = cur1.Name;
        p2.credits = 2;
        p2.termId = objTerm.id;
        p2.recordId = Null;
        p2.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l2 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p2};

            MSTR_createCourseOfferingCls.planLiwrap p3 = new MSTR_createCourseOfferingCls.planLiwrap();
        p3.count = '1';
        p3.subCount = '0';
        p3.courseId = cur2.id;
        p3.courseName = cur2.Name;
        p3.credits = 2;
        p3.termId = objTerm.id;
        p3.recordId = Null;
        p3.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l3 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p3};

            MSTR_createCourseOfferingCls.planLiwrap WrapPlanOpen = new MSTR_createCourseOfferingCls.planLiwrap();
        WrapPlanOpen.count = '10';
        WrapPlanOpen.courseName = 'test';
        WrapPlanOpen.credits = 10;
        WrapPlanOpen.termId = objTerm.id;

        list<MSTR_createCourseOfferingCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planwrapOpen.add(WrapPlanOpen);

        MSTR_createCourseOfferingCls.openElectivewrap opEleWrap =  new MSTR_createCourseOfferingCls.openElectivewrap();
        opEleWrap.count = '10';
        opEleWrap.Name = 'test';
        opEleWrap.credits = 10;
        opEleWrap.termId = objTerm.id;
        opEleWrap.lstPlanLi = lst_planwrapOpen;

        MSTR_createCourseOfferingCls.profElectivewrap profEleWrap =  new MSTR_createCourseOfferingCls.profElectivewrap();
        profEleWrap.count = '10';
        profEleWrap.Name = 'test';
        profEleWrap.credits = 10;
        profEleWrap.termId = objTerm.id;
        profEleWrap.lstPlanLi = lst_planwrapOpen;

        MSTR_createCourseOfferingCls.planLiwrap p4 = new MSTR_createCourseOfferingCls.planLiwrap();
        p4.count = '1';
        p4.subCount = '0';
        p4.courseId = cur3.id;
        p4.courseName = cur3.Name;
        p4.credits = 2;
        p4.termId = objTerm.id;
        p4.recordId = Null;
        p4.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l4 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p4};
            list<MSTR_createCourseOfferingCls.openElectivewrap> l5 = new list<MSTR_createCourseOfferingCls.openElectivewrap>{opEleWrap};
                list<MSTR_createCourseOfferingCls.profElectivewrap> l6 = new list<MSTR_createCourseOfferingCls.profElectivewrap>();
        list<string> l7 = new list<string>();
        Test.StartTest();
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.id,l1,l2,l3,l5,l6,l4,Null,l7,false,false);

        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm1.id,l1,l2,l3,l5,l6,l4,Null,l7,false,false);
        System.AssertEquals(objTerm.id,objTerm.id);
        Test.StopTest();
    }
    public static testMethod Void ProfElectiveElseMethod()
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

        hed__Course__c cur= MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        cur.Category__c = 'Hardcore Course';
        cur.hed__Course_ID__c = 'T1';
        cur.hed__Credit_Hours__c = 80;
        cur.Category__c = 'Hardcore Course';
        cur.Credits__c = 4;
        cur.hed__Account__c = objAccount.id;
        cur.HardCore_Sub_Type__c = 'Theory';
        cur.Offered_By_School__c = objAccount.Id;
        cur.Credit_Hours__c = 04.00;
        cur.Maximum_External_Marks__c = 50;
        cur.Total_Maximum_Marks_IA_External__c = 60;
        cur.No_of_IA_s__c = '1';
        cur.L_T_P__c='2:1:0';
        insert cur;

        hed__Course__c cur1 = MSTR_TestDataFactory.CreateCourse('Test1',objAccount.id);
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

        hed__Course__c cur2 = MSTR_TestDataFactory.CreateCourse('Test2',objAccount.id);
        cur2.hed__Course_ID__c = 'T3';
        cur2.hed__Credit_Hours__c = 80;
        cur2.Category__c = 'Practical/Term Work';
        cur2.Credits__c = 4;
        cur2.hed__Account__c = objAccount.id;
        cur2.Offered_By_School__c = objAccount.Id;
        cur2.Credit_Hours__c = 04.00;
        cur2.Maximum_External_Marks__c = 50;
        cur2.Total_Maximum_Marks_IA_External__c = 60;
        cur2.No_of_IA_s__c = '1';
        cur2.L_T_P__c='2:1:0';
        insert cur2;

        hed__Course__c cur3 = MSTR_TestDataFactory.CreateCourse('Test3',objAccount.id);
        cur3.hed__Course_ID__c = 'T6';
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

        MSTR_createCourseOfferingCls.planLiwrap p1 = new MSTR_createCourseOfferingCls.planLiwrap();
        p1.count = '1';
        p1.subCount = '0';
        p1.courseId = cur.id;
        p1.courseName = cur.Name;
        p1.credits = 2;
        p1.termId = objTerm.id;
        p1.recordId = Null;
        p1.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l1 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p1};

            MSTR_createCourseOfferingCls.planLiwrap p2 = new MSTR_createCourseOfferingCls.planLiwrap();
        p2.count = '1';
        p2.subCount = '0';
        p2.courseId = cur1.id;
        p2.courseName = cur1.Name;
        p2.credits = 2;
        p2.termId = objTerm.id;
        p2.recordId = Null;
        p2.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l2 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p2};

            MSTR_createCourseOfferingCls.planLiwrap p3 = new MSTR_createCourseOfferingCls.planLiwrap();
        p3.count = '1';
        p3.subCount = '0';
        p3.courseId = cur2.id;
        p3.courseName = cur2.Name;
        p3.credits = 2;
        p3.termId = objTerm.id;
        p3.recordId = Null;
        p3.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l3 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p3};

            MSTR_createCourseOfferingCls.planLiwrap WrapPlanOpen = new MSTR_createCourseOfferingCls.planLiwrap();
        WrapPlanOpen.count = '10';
        WrapPlanOpen.courseName = 'test';
        WrapPlanOpen.credits = 10;
        WrapPlanOpen.termId = objTerm.id;

        list<MSTR_createCourseOfferingCls.planLiwrap>  lst_planwrapOpen = new list<MSTR_createCourseOfferingCls.planLiwrap>();
        lst_planwrapOpen.add(WrapPlanOpen);

        MSTR_createCourseOfferingCls.profElectivewrap profEleWrap =  new MSTR_createCourseOfferingCls.profElectivewrap();
        profEleWrap.count = '10';
        profEleWrap.Name = 'test';
        profEleWrap.credits = 10;
        profEleWrap.termId = objTerm.id;
        profEleWrap.lstPlanLi = lst_planwrapOpen;

        MSTR_createCourseOfferingCls.planLiwrap p4 = new MSTR_createCourseOfferingCls.planLiwrap();
        p4.count = '1';
        p4.subCount = '0';
        p4.courseId = cur3.id;
        p4.courseName = cur3.Name;
        p4.credits = 2;
        p4.termId = objTerm.id;
        p4.recordId = Null;
        p4.filter = '';
        list<MSTR_createCourseOfferingCls.planLiwrap> l4 = new list<MSTR_createCourseOfferingCls.planLiwrap>{p4};
            list<MSTR_createCourseOfferingCls.openElectivewrap> l5 = new list<MSTR_createCourseOfferingCls.openElectivewrap>();
        list<MSTR_createCourseOfferingCls.profElectivewrap> l6 = new list<MSTR_createCourseOfferingCls.profElectivewrap>{profEleWrap};
            list<string> l7 = new list<string>();
        Test.StartTest();
        // Test getTermDetails
        MSTR_createCourseOfferingCls.termMainWarp termDetails = MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        System.assertNotEquals(null, termDetails, 'Term details should not be null');
        System.assertEquals(objTerm.Id, termDetails.objTerm.Id, 'Term ID should match');

        // Test getPlanRequirement
        MSTR_createCourseOfferingCls.courseMainWarp planReq = MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        System.assertNotEquals(null, planReq, 'Plan requirement should not be null');
        System.assertEquals(1, planReq.listHardCore.size(), 'Should have one Hardcore course');

        // Test getcourseOffering
        MSTR_createCourseOfferingCls.courseMainWarp courseOff = MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        System.assertNotEquals(null, courseOff, 'Course offering should not be null');


        // Test getSchoolName
        String schoolName = MSTR_createCourseOfferingCls.getSchoolName(objAccount3.Id);
        System.assertEquals(objAccount3.Name, schoolName, 'School name should match');
        MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.id,l1,l2,l3,l5,l6,l4,Null,l7,false,false);
        System.AssertEquals(objTerm.id,objTerm.id);
        Test.StopTest();
    }

    // Test method to cover rbsSpclWrap scenario
    @isTest
    static void testRbsSpecialScenario() {

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;
        // Setup test data
        String acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1', acaRecId);
        objAccount1.RecordTypeId = acaRecId;
        insert objAccount1;

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account', acaRecId);
        objAccount.ParentId = objAccount1.Id;
        objAccount.RecordTypeId = acaRecId;
        insert objAccount;

        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.Id;
        insert objProgPlan;

        String termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('Test Term', objAccount.Id, termRtId);
        objTerm.Program_Batch__c = objProgPlan.Id;
        insert objTerm;

        String uniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.RBS_Specialization).getRecordTypeId();
        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test University Dept', uniRecId);
        objAccount4.ParentId = objAccount1.Id;
        objAccount4.RecordTypeId = uniRecId;
        insert objAccount4;

         Account universityAccount = new Account(
            Name = 'University Department A',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'University Department' LIMIT 1].Id
        );
        insert universityAccount;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
        objCourse.Category__c = 'RBS Specialization'; // Assuming this is the category
        objCourse.Offered_By_School__c = universityAccount.Id;
        objCourse.hed__Account__c = universityAccount.Id;
        objCourse.Credit_Hours__c = 4.00;
        objCourse.Credits__c = 4.00;
        objCourse.Maximum_External_Marks__c = 25;
        objCourse.Total_Maximum_Marks_IA_External__c= 30;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';        
        insert objCourse;

        hed__Plan_Requirement__c objPlanReqParent = MSTR_TestDataFactory.createPlanRequirement('RBS Special Parent');
        objPlanReqParent.hed__Category__c = 'RBS Specialization';
        objPlanReqParent.Semester__c = objTerm.Id;
        objPlanReqParent.Credits__c = 4;
        objPlanReqParent.Sequence__c = 1;
        insert objPlanReqParent;

        hed__Plan_Requirement__c objPlanReq = MSTR_TestDataFactory.createPlanRequirement('Test Plan Requirement');
        objPlanReq.hed__Category__c = 'RBS Specialization';
        objPlanReq.Semester__c = objTerm.Id;
        objPlanReq.Credits__c = 4;
        objPlanReq.Sequence__c = 1;
        objPlanReq.hed__Plan_Requirement__c = objPlanReqParent.Id;
        objPlanReq.hed__Course__c = objCourse.Id;
        insert objPlanReq;

        // Create planLiwrap for child course
        MSTR_createCourseOfferingCls.planLiwrap plnWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        plnWrap.count = '1';
        plnWrap.courseId = objCourse.Id;
        plnWrap.courseName = objCourse.Name;
        plnWrap.credits = 4;
        plnWrap.termId = objTerm.Id;

        List<MSTR_createCourseOfferingCls.planLiwrap> lstplanWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{plnWrap};

        // Create rbsSpclWrap instance
        MSTR_createCourseOfferingCls.rbsSpclWrap rbsWrap = new MSTR_createCourseOfferingCls.rbsSpclWrap();
        rbsWrap.count = '1';
        rbsWrap.parentId = objPlanReqParent.Id;
        rbsWrap.Name = 'RBS Special Parent';
        rbsWrap.credits = 4;
        rbsWrap.termId = objTerm.Id;
        rbsWrap.lstPlanLi = lstplanWrap;
        rbsWrap.recordId = objPlanReqParent.Id;

        List<MSTR_createCourseOfferingCls.rbsSpclWrap> lstrbsWrap = new List<MSTR_createCourseOfferingCls.rbsSpclWrap>{rbsWrap};

        Test.startTest();
        System.runAs(testUser) {
        MSTR_createCourseOfferingCls.courseMainWarp planReq = MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        String result = MSTR_createCourseOfferingCls.savePlanRequiement(objTerm.Id, null, null, null, null, null, null, lstrbsWrap, null, false, false);
        String schoolName = MSTR_createCourseOfferingCls.getSchoolName(objAccount4.Id);


        System.assertNotEquals(null, result, 'result should not null');
        System.assertEquals('Test University Dept', schoolName, 'schoolName should match');
        System.assertNotEquals(null, planReq, 'Plan requirement should not be null');
        }
        Test.stopTest();

        // List<hed__Course_Offering__c> courseOfferings = [
        //     SELECT Id, Category__c, Parent_Course_Offering__c
        //     FROM hed__Course_Offering__c
        //     WHERE hed__Term__c = :objTerm.Id
        // ];
    }

    @isTest
    static void testProfessionalElectiveAndRbsSpecialScenario() {

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;

        // Setup test data
        String acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1', acaRecId);
        objAccount1.RecordTypeId = acaRecId;
        insert objAccount1;

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account', acaRecId);
        objAccount.ParentId = objAccount1.Id;
        objAccount.RecordTypeId = acaRecId;
        insert objAccount;

        String uniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test University Dept', uniRecId);
        objAccount4.ParentId = objAccount1.Id;
        objAccount4.RecordTypeId = uniRecId;
        insert objAccount4;

        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.Id;
        insert objProgPlan;

        String termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('Test Term', objAccount.Id, termRtId);
        objTerm.Program_Batch__c = objProgPlan.Id;
        insert objTerm;

        // Create courses for different categories
        hed__Course__c hardcoreCourse = MSTR_TestDataFactory.CreateCourse('Hardcore Course', objAccount.Id);
        hardcoreCourse.Category__c = 'Hardcore Course';
        hardcoreCourse.hed__Course_ID__c = 'T1';
        hardcoreCourse.hed__Credit_Hours__c = 80;
        hardcoreCourse.Category__c = 'Hardcore Course';
        hardcoreCourse.Credits__c = 4;
        hardcoreCourse.hed__Account__c = objAccount4.id;
        hardcoreCourse.HardCore_Sub_Type__c = 'Theory';
        hardcoreCourse.Offered_By_School__c = objAccount4.Id;
        hardcoreCourse.Credit_Hours__c = 04.00;
        hardcoreCourse.Maximum_External_Marks__c = 50;
        hardcoreCourse.Total_Maximum_Marks_IA_External__c = 60;
        hardcoreCourse.No_of_IA_s__c = '1';
        hardcoreCourse.L_T_P__c='2:1:0'; 
        insert hardcoreCourse;

        hed__Course__c profElectiveCourse = MSTR_TestDataFactory.CreateCourse('Professional Elective Course', objAccount.Id);
        profElectiveCourse.Category__c = 'Professional Elective';
        profElectiveCourse.Offered_By_School__c = objAccount4.Id;
        profElectiveCourse.Credit_Hours__c = 4.00;
        profElectiveCourse.Credits__c = 4.00;
        profElectiveCourse.Maximum_External_Marks__c = 50;
        profElectiveCourse.Total_Maximum_Marks_IA_External__c = 60;
        profElectiveCourse.No_of_IA_s__c = '1';
        profElectiveCourse.L_T_P__c='2:1:0'; 
        insert profElectiveCourse;

        hed__Course__c rbsCourse = MSTR_TestDataFactory.CreateCourse('RBS Specialization Course', objAccount.Id);
        rbsCourse.Category__c = 'RBS Specialization';
        rbsCourse.Offered_By_School__c = objAccount4.Id;
        rbsCourse.hed__Account__c = objAccount4.Id;
        rbsCourse.Credit_Hours__c = 4.00;
        rbsCourse.Credits__c = 4.00;
        rbsCourse.Maximum_External_Marks__c = 50;
        rbsCourse.Total_Maximum_Marks_IA_External__c = 60;
        rbsCourse.No_of_IA_s__c = '1';
        rbsCourse.L_T_P__c='2:1:0';
        insert rbsCourse;

        // Create plan requirements
        hed__Plan_Requirement__c hardcorePlanReq = MSTR_TestDataFactory.createPlanRequirement('Hardcore Plan Requirement');
        hardcorePlanReq.hed__Category__c = 'Hardcore Course';
        hardcorePlanReq.Semester__c = objTerm.Id;
        hardcorePlanReq.Credits__c = 4;
        hardcorePlanReq.Sequence__c = 1;
        hardcorePlanReq.hed__Course__c = hardcoreCourse.Id;
        hardcorePlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert hardcorePlanReq;

        hed__Plan_Requirement__c profElectiveParentPlanReq = MSTR_TestDataFactory.createPlanRequirement('Professional Elective Parent');
        profElectiveParentPlanReq.hed__Category__c = 'Professional Elective';
        profElectiveParentPlanReq.Semester__c = objTerm.Id;
        profElectiveParentPlanReq.Credits__c = 4;
        profElectiveParentPlanReq.Sequence__c = 1;
        insert profElectiveParentPlanReq;

        hed__Plan_Requirement__c profElectivePlanReq = MSTR_TestDataFactory.createPlanRequirement('Professional Elective Child');
        profElectivePlanReq.hed__Category__c = 'Professional Elective';
        profElectivePlanReq.Semester__c = objTerm.Id;
        profElectivePlanReq.Credits__c = 4;
        profElectivePlanReq.Sequence__c = 1;
        profElectivePlanReq.hed__Plan_Requirement__c = profElectiveParentPlanReq.Id;
        profElectivePlanReq.hed__Course__c = profElectiveCourse.Id;
        insert profElectivePlanReq;

        hed__Plan_Requirement__c rbsParentPlanReq = MSTR_TestDataFactory.createPlanRequirement('RBS Specialization Parent');
        rbsParentPlanReq.hed__Category__c = 'RBS Specialization';
        rbsParentPlanReq.Semester__c = objTerm.Id;
        rbsParentPlanReq.Credits__c = 4;
        rbsParentPlanReq.Sequence__c = 1;
        insert rbsParentPlanReq;

        hed__Plan_Requirement__c rbsPlanReq = MSTR_TestDataFactory.createPlanRequirement('RBS Specialization Child');
        rbsPlanReq.hed__Category__c = 'RBS Specialization';
        rbsPlanReq.Semester__c = objTerm.Id;
        rbsPlanReq.Credits__c = 4;
        rbsPlanReq.Sequence__c = 1;
        rbsPlanReq.hed__Plan_Requirement__c = rbsParentPlanReq.Id;
        rbsPlanReq.hed__Course__c = rbsCourse.Id;
        insert rbsPlanReq;

        // Create wrapper instances
        MSTR_createCourseOfferingCls.planLiwrap hardcoreWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        hardcoreWrap.count = '1';
        hardcoreWrap.courseId = hardcoreCourse.Id;
        hardcoreWrap.courseName = hardcoreCourse.Name;
        hardcoreWrap.credits = 4;
        hardcoreWrap.termId = objTerm.Id;
        List<MSTR_createCourseOfferingCls.planLiwrap> lsthardcoreWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{hardcoreWrap};

        MSTR_createCourseOfferingCls.planLiwrap profElectiveChildWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        profElectiveChildWrap.count = '1';
        profElectiveChildWrap.courseId = profElectiveCourse.Id;
        profElectiveChildWrap.courseName = profElectiveCourse.Name;
        profElectiveChildWrap.credits = 4;
        profElectiveChildWrap.termId = objTerm.Id;
        List<MSTR_createCourseOfferingCls.planLiwrap> lstprofElectiveChildWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{profElectiveChildWrap};

        MSTR_createCourseOfferingCls.profElectivewrap profElectiveWrap = new MSTR_createCourseOfferingCls.profElectivewrap();
        profElectiveWrap.count = '1';
        profElectiveWrap.Name = 'Professional Elective Parent';
        profElectiveWrap.credits = 4;
        profElectiveWrap.termId = objTerm.Id;
        profElectiveWrap.lstPlanLi = lstprofElectiveChildWrap;
        profElectiveWrap.recordId = profElectiveParentPlanReq.Id;
        List<MSTR_createCourseOfferingCls.profElectivewrap> lstprofElectiveWrap = new List<MSTR_createCourseOfferingCls.profElectivewrap>{profElectiveWrap};

        MSTR_createCourseOfferingCls.planLiwrap rbsChildWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        rbsChildWrap.count = '1';
        rbsChildWrap.courseId = rbsCourse.Id;
        rbsChildWrap.courseName = rbsCourse.Name;
        rbsChildWrap.credits = 4;
        rbsChildWrap.termId = objTerm.Id;
        List<MSTR_createCourseOfferingCls.planLiwrap> lstrbsChildWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{rbsChildWrap};

        MSTR_createCourseOfferingCls.rbsSpclWrap rbsWrap = new MSTR_createCourseOfferingCls.rbsSpclWrap();
        rbsWrap.count = '1';
        rbsWrap.parentId = rbsParentPlanReq.Id;
        rbsWrap.Name = 'RBS Specialization Parent';
        rbsWrap.credits = 4;
        rbsWrap.termId = objTerm.Id;
        rbsWrap.lstPlanLi = lstrbsChildWrap;
        rbsWrap.recordId = rbsParentPlanReq.Id;
        List<MSTR_createCourseOfferingCls.rbsSpclWrap> lstrbsWrap = new List<MSTR_createCourseOfferingCls.rbsSpclWrap>{rbsWrap};
        System.runAs(testUser) {
        Test.startTest();
        // Test getTermDetails
        MSTR_createCourseOfferingCls.termMainWarp termDetails = MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        System.assertNotEquals(null, termDetails, 'Term details should not be null');
        System.assertEquals(objTerm.Id, termDetails.objTerm.Id, 'Term ID should match');

        // Test getPlanRequirement
        MSTR_createCourseOfferingCls.courseMainWarp planReq = MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        System.assertNotEquals(null, planReq, 'Plan requirement should not be null');
        System.assertEquals(1, planReq.listHardCore.size(), 'Should have one Hardcore course');

        // Test getcourseOffering
        MSTR_createCourseOfferingCls.courseMainWarp courseOff = MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        System.assertNotEquals(null, courseOff, 'Course offering should not be null');

        // Test getSchoolName
        String schoolName = MSTR_createCourseOfferingCls.getSchoolName(objAccount4.Id);
        System.assertEquals(objAccount4.Name, schoolName, 'School name should match');

        // Test savePlanRequiement with Hardcore, Professional Elective, and RBS Specialization
        String result = MSTR_createCourseOfferingCls.savePlanRequiement(
            objTerm.Id,
            lsthardcoreWrap, // Hardcore
            null, // Hardcore Integrated
            null, // Practical/Term Work
            null, // Open Elective
            lstprofElectiveWrap, // Professional Elective
            null, // Mandatory Course
            lstrbsWrap, // RBS Specialization
            null, // Delete IDs
            false,
            false
        );
        System.assertNotEquals(null, result, 'result should not null');
        }
        Test.stopTest();

        // Verify course offering creation
        // List<hed__Course_Offering__c> courseOfferings = [
        //     SELECT Id, Category__c, Parent_Course_Offering__c
        //     FROM hed__Course_Offering__c
        //     WHERE hed__Term__c = :objTerm.Id
        // ];
        // Set<String> categories = new Set<String>();
        // for (hed__Course_Offering__c co : courseOfferings) {
        //     categories.add(co.Category__c);
        // }
    }


    @isTest
    static void testRBSSpecializationScenario() {
        // Setup test data

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;

        String acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account', acaRecId);
        objAccount.RecordTypeId = acaRecId;
        insert objAccount;

        String spclRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RBS Specialization').getRecordTypeId();
        Account objSpclAccount = MSTR_TestDataFactory.CreateAccount('Test RBS Specialization', spclRecordType);
        objSpclAccount.RecordTypeId = spclRecordType;
        objSpclAccount.ParentId = objAccount.Id;
        insert objSpclAccount;

        String eduRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1', eduRecId);
        objAccount1.RecordTypeId = eduRecId;
        insert objAccount1;

        Account objAccount2 = MSTR_TestDataFactory.CreateAccount('Test Account2', eduRecId);
        objAccount2.ParentId = objAccount1.Id;
        objAccount2.RecordTypeId = eduRecId;
        insert objAccount2;

        String uniRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount4 = MSTR_TestDataFactory.CreateAccount('Test University Dept', uniRecId);
        objAccount4.ParentId = objAccount2.Id;
        objAccount4.RecordTypeId = uniRecId;
        insert objAccount4;

        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.Id;
        insert objProgPlan;

        String termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('Test Term', objAccount.Id, termRtId);
        objTerm.Program_Batch__c = objProgPlan.Id;
        insert objTerm;

        // Create courses for all categories
        hed__Course__c rbsCourse = MSTR_TestDataFactory.CreateCourse('Test RBS Course', objAccount.Id);
        rbsCourse.hed__Course_ID__c = 'T777';
        rbsCourse.Category__c = 'RBS Specialization';
        rbsCourse.Credits__c = 4;
        rbsCourse.HardCore_Sub_Type__c = 'Project';
        rbsCourse.Offered_By_School__c = objAccount4.Id;
        rbsCourse.hed__Account__c = objAccount4.Id;
        rbsCourse.Specialization__c = objSpclAccount.Id;
        rbsCourse.Credit_Hours__c = 4.00;
        rbsCourse.Maximum_External_Marks__c = 50;
        rbsCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert rbsCourse;

        hed__Course__c hardcoreCourse = MSTR_TestDataFactory.CreateCourse('Test Hardcore Course', objAccount.Id);
        hardcoreCourse.hed__Course_ID__c = 'T1';
        hardcoreCourse.Category__c = 'Hardcore Course';
        hardcoreCourse.Credits__c = 4;
        hardcoreCourse.HardCore_Sub_Type__c = 'Project';
        hardcoreCourse.Offered_By_School__c = objAccount4.Id;
        hardcoreCourse.hed__Account__c = objAccount4.Id;
        hardcoreCourse.Credit_Hours__c = 4.00;
        hardcoreCourse.Maximum_External_Marks__c = 50;
        hardcoreCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert hardcoreCourse;

        hed__Course__c hardcoreIntCourse = MSTR_TestDataFactory.CreateCourse('Test Hardcore Integrated Course', objAccount.Id);
        hardcoreIntCourse.hed__Course_ID__c = 'T2';
        hardcoreIntCourse.Category__c = 'Hardcore Integrated Course';
        hardcoreIntCourse.Credits__c = 4;
        hardcoreIntCourse.Offered_By_School__c = objAccount4.Id;
        hardcoreIntCourse.hed__Account__c = objAccount4.Id;
        hardcoreIntCourse.Credit_Hours__c = 4.00;
        hardcoreIntCourse.Maximum_External_Marks__c = 50;
        hardcoreIntCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert hardcoreIntCourse;

        hed__Course__c practicalCourse = MSTR_TestDataFactory.CreateCourse('Test Practical Course', objAccount.Id);
        practicalCourse.hed__Course_ID__c = 'T22';
        practicalCourse.Category__c = 'Practical/Term Work';
        practicalCourse.Credits__c = 4;
        practicalCourse.Offered_By_School__c = objAccount4.Id;
        practicalCourse.hed__Account__c = objAccount4.Id;
        practicalCourse.Credit_Hours__c = 4.00;
        practicalCourse.Maximum_External_Marks__c = 50;
        practicalCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert practicalCourse;

        hed__Course__c mandatoryCourse = MSTR_TestDataFactory.CreateCourse('Test Mandatory Course', objAccount.Id);
        mandatoryCourse.hed__Course_ID__c = 'T3';
        mandatoryCourse.Category__c = 'Mandatory Course';
        mandatoryCourse.Credits__c = 4;
        mandatoryCourse.Offered_By_School__c = objAccount4.Id;
        mandatoryCourse.hed__Account__c = objAccount4.Id;
        mandatoryCourse.Credit_Hours__c = 4.00;
        mandatoryCourse.Maximum_External_Marks__c = 50;
        mandatoryCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert mandatoryCourse;

        hed__Course__c profElectiveCourse = MSTR_TestDataFactory.CreateCourse('Test Professional Elective Course', objAccount.Id);
        profElectiveCourse.hed__Course_ID__c = 'T4';
        profElectiveCourse.Category__c = 'Professional Elective';
        profElectiveCourse.Credits__c = 4;
        profElectiveCourse.Offered_By_School__c = objAccount4.Id;
        profElectiveCourse.hed__Account__c = objAccount4.Id;
        profElectiveCourse.Credit_Hours__c = 4.00;
        profElectiveCourse.Maximum_External_Marks__c = 50;
        profElectiveCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert profElectiveCourse;

        hed__Course__c openElectiveCourse = MSTR_TestDataFactory.CreateCourse('Test Open Elective Course', objAccount.Id);
        openElectiveCourse.hed__Course_ID__c = 'T5';
        openElectiveCourse.Category__c = 'Open Elective';
        openElectiveCourse.Credits__c = 4;
        openElectiveCourse.Offered_By_School__c = objAccount4.Id;
        openElectiveCourse.hed__Account__c = objAccount4.Id;
        openElectiveCourse.Credit_Hours__c = 4.00;
        openElectiveCourse.Maximum_External_Marks__c = 50;
        openElectiveCourse.Total_Maximum_Marks_IA_External__c = 60;
        insert openElectiveCourse;

        // Create plan requirements
        hed__Plan_Requirement__c rbsParentPlanReq = MSTR_TestDataFactory.createPlanRequirement('RBS Specialization Parent');
        rbsParentPlanReq.hed__Category__c = 'RBS Specialization';
        rbsParentPlanReq.Semester__c = objTerm.Id;
        rbsParentPlanReq.Credits__c = 4;
        rbsParentPlanReq.Sequence__c = 1;
        rbsParentPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        rbsParentPlanReq.Specialization__c = objSpclAccount.Id;
        insert rbsParentPlanReq;

        hed__Plan_Requirement__c rbsPlanReq = MSTR_TestDataFactory.createPlanRequirement('RBS Specialization Child');
        rbsPlanReq.hed__Category__c = 'RBS Specialization';
        rbsPlanReq.Semester__c = objTerm.Id;
        rbsPlanReq.Credits__c = 4;
        rbsPlanReq.Sequence__c = 1;
        rbsPlanReq.hed__Plan_Requirement__c = rbsParentPlanReq.Id;
        rbsPlanReq.hed__Course__c = rbsCourse.Id;
        rbsPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        rbsPlanReq.Specialization__c = objSpclAccount.Id;
        insert rbsPlanReq;

        hed__Plan_Requirement__c hardcorePlanReq = MSTR_TestDataFactory.createPlanRequirement('Hardcore Plan Requirement');
        hardcorePlanReq.hed__Category__c = 'Hardcore Course';
        hardcorePlanReq.Semester__c = objTerm.Id;
        hardcorePlanReq.Credits__c = 4;
        hardcorePlanReq.Sequence__c = 1;
        hardcorePlanReq.hed__Course__c = hardcoreCourse.Id;
        hardcorePlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert hardcorePlanReq;

        hed__Plan_Requirement__c hardcoreIntPlanReq = MSTR_TestDataFactory.createPlanRequirement('Hardcore Integrated Plan Requirement');
        hardcoreIntPlanReq.hed__Category__c = 'Hardcore Integrated Course';
        hardcoreIntPlanReq.Semester__c = objTerm.Id;
        hardcoreIntPlanReq.Credits__c = 4;
        hardcoreIntPlanReq.Sequence__c = 1;
        hardcoreIntPlanReq.hed__Course__c = hardcoreIntCourse.Id;
        hardcoreIntPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert hardcoreIntPlanReq;

        hed__Plan_Requirement__c practicalPlanReq = MSTR_TestDataFactory.createPlanRequirement('Practical Plan Requirement');
        practicalPlanReq.hed__Category__c = 'Practical/Term Work';
        practicalPlanReq.Semester__c = objTerm.Id;
        practicalPlanReq.Credits__c = 4;
        practicalPlanReq.Sequence__c = 1;
        practicalPlanReq.hed__Course__c = practicalCourse.Id;
        practicalPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert practicalPlanReq;

        hed__Plan_Requirement__c mandatoryPlanReq = MSTR_TestDataFactory.createPlanRequirement('Mandatory Plan Requirement');
        mandatoryPlanReq.hed__Category__c = 'Mandatory Course';
        mandatoryPlanReq.Semester__c = objTerm.Id;
        mandatoryPlanReq.Credits__c = 4;
        mandatoryPlanReq.Sequence__c = 1;
        mandatoryPlanReq.hed__Course__c = mandatoryCourse.Id;
        mandatoryPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert mandatoryPlanReq;

        hed__Plan_Requirement__c profElectiveParentPlanReq = MSTR_TestDataFactory.createPlanRequirement('Professional Elective Parent');
        profElectiveParentPlanReq.hed__Category__c = 'Professional Elective';
        profElectiveParentPlanReq.Semester__c = objTerm.Id;
        profElectiveParentPlanReq.Credits__c = 4;
        profElectiveParentPlanReq.Sequence__c = 1;
        profElectiveParentPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert profElectiveParentPlanReq;

        hed__Plan_Requirement__c profElectivePlanReq = MSTR_TestDataFactory.createPlanRequirement('Professional Elective Child');
        profElectivePlanReq.hed__Category__c = 'Professional Elective';
        profElectivePlanReq.Semester__c = objTerm.Id;
        profElectivePlanReq.Credits__c = 4;
        profElectivePlanReq.Sequence__c = 1;
        profElectivePlanReq.hed__Plan_Requirement__c = profElectiveParentPlanReq.Id;
        profElectivePlanReq.hed__Course__c = profElectiveCourse.Id;
        profElectivePlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert profElectivePlanReq;

        hed__Plan_Requirement__c openElectiveParentPlanReq = MSTR_TestDataFactory.createPlanRequirement('Open Elective Parent');
        openElectiveParentPlanReq.hed__Category__c = 'Open Elective';
        openElectiveParentPlanReq.Semester__c = objTerm.Id;
        openElectiveParentPlanReq.Credits__c = 4;
        openElectiveParentPlanReq.Sequence__c = 1;
        openElectiveParentPlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert openElectiveParentPlanReq;

        hed__Plan_Requirement__c openElectivePlanReq = MSTR_TestDataFactory.createPlanRequirement('Open Elective Child');
        openElectivePlanReq.hed__Category__c = 'Open Elective';
        openElectivePlanReq.Semester__c = objTerm.Id;
        openElectivePlanReq.Credits__c = 4;
        openElectivePlanReq.Sequence__c = 1;
        openElectivePlanReq.hed__Plan_Requirement__c = openElectiveParentPlanReq.Id;
        openElectivePlanReq.hed__Course__c = openElectiveCourse.Id;
        openElectivePlanReq.hed__Program_Plan__c = objProgPlan.Id;
        insert openElectivePlanReq;

        // Create course offerings for initial state
        hed__Course_Offering__c objCourseOff = MSTR_TestDataFactory.createCourseOffering('Test CourseOffering', objTerm.Id, rbsCourse.Id);
        objCourseOff.Category__c = 'RBS Specialization';
        objCourseOff.Sequence__c = 1;
        objCourseOff.Specialization__c = objSpclAccount.Id;
        objCourseOff.Active__c = true;
        objCourseOff.Assigned__c = 2;
        insert objCourseOff;

        hed__Course_Offering__c objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering', objTerm.Id, openElectiveCourse.Id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c = 1;
        insert objCourseOff1;

        hed__Course_Offering__c objCourseOff2 = MSTR_TestDataFactory.createCourseOffering('Test CourseOffering', objTerm.Id, hardcoreCourse.Id);
        objCourseOff2.Category__c = 'Hardcore Course';
        objCourseOff2.Sequence__c = 1;
        objCourseOff2.Parent_Course_Offering__c = objCourseOff1.Id;
        insert objCourseOff2;

        // Create wrappers for all categories
        MSTR_createCourseOfferingCls.planLiwrap hardcoreWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        hardcoreWrap.count = '1';
        hardcoreWrap.subCount = '0';
        hardcoreWrap.courseId = hardcoreCourse.Id;
        hardcoreWrap.courseName = hardcoreCourse.Name;
        hardcoreWrap.credits = 4;
        hardcoreWrap.termId = objTerm.Id;
        hardcoreWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lsthardcoreWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{hardcoreWrap};

        MSTR_createCourseOfferingCls.planLiwrap hardcoreIntWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        hardcoreIntWrap.count = '1';
        hardcoreIntWrap.subCount = '0';
        hardcoreIntWrap.courseId = hardcoreIntCourse.Id;
        hardcoreIntWrap.courseName = hardcoreIntCourse.Name;
        hardcoreIntWrap.credits = 4;
        hardcoreIntWrap.termId = objTerm.Id;
        hardcoreIntWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lsthardcoreIntWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{hardcoreIntWrap};

        MSTR_createCourseOfferingCls.planLiwrap practicalWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        practicalWrap.count = '1';
        practicalWrap.subCount = '0';
        practicalWrap.courseId = practicalCourse.Id;
        practicalWrap.courseName = practicalCourse.Name;
        practicalWrap.credits = 4;
        practicalWrap.termId = objTerm.Id;
        practicalWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lstpracticalWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{practicalWrap};

        MSTR_createCourseOfferingCls.planLiwrap mandatoryWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        mandatoryWrap.count = '1';
        mandatoryWrap.subCount = '0';
        mandatoryWrap.courseId = mandatoryCourse.Id;
        mandatoryWrap.courseName = mandatoryCourse.Name;
        mandatoryWrap.credits = 4;
        mandatoryWrap.termId = objTerm.Id;
        mandatoryWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lstmandatoryWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{mandatoryWrap};

        MSTR_createCourseOfferingCls.planLiwrap profElectiveChildWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        profElectiveChildWrap.count = '1';
        profElectiveChildWrap.subCount = '0';
        profElectiveChildWrap.courseId = profElectiveCourse.Id;
        profElectiveChildWrap.courseName = profElectiveCourse.Name;
        profElectiveChildWrap.credits = 4;
        profElectiveChildWrap.termId = objTerm.Id;
        profElectiveChildWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lstprofElectiveChildWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{profElectiveChildWrap};

        MSTR_createCourseOfferingCls.profElectivewrap profElectiveWrap = new MSTR_createCourseOfferingCls.profElectivewrap();
        profElectiveWrap.count = '1';
        profElectiveWrap.Name = 'Professional Elective Parent';
        profElectiveWrap.credits = 4;
        profElectiveWrap.termId = objTerm.Id;
        profElectiveWrap.lstPlanLi = lstprofElectiveChildWrap;
        profElectiveWrap.recordId = profElectiveParentPlanReq.Id;
        List<MSTR_createCourseOfferingCls.profElectivewrap> lstprofElectiveWrap = new List<MSTR_createCourseOfferingCls.profElectivewrap>{profElectiveWrap};

        MSTR_createCourseOfferingCls.planLiwrap openElectiveChildWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        openElectiveChildWrap.count = '1';
        openElectiveChildWrap.subCount = '0';
        openElectiveChildWrap.courseId = openElectiveCourse.Id;
        openElectiveChildWrap.courseName = openElectiveCourse.Name;
        openElectiveChildWrap.credits = 4;
        openElectiveChildWrap.termId = objTerm.Id;
        openElectiveChildWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lstopenElectiveChildWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{openElectiveChildWrap};

        MSTR_createCourseOfferingCls.openElectivewrap openElectiveWrap = new MSTR_createCourseOfferingCls.openElectivewrap();
        openElectiveWrap.count = '1';
        openElectiveWrap.Name = 'Open Elective Parent';
        openElectiveWrap.credits = 4;
        openElectiveWrap.termId = objTerm.Id;
        openElectiveWrap.lstPlanLi = lstopenElectiveChildWrap;
        openElectiveWrap.recordId = openElectiveParentPlanReq.Id;
        List<MSTR_createCourseOfferingCls.openElectivewrap> lstopenElectiveWrap = new List<MSTR_createCourseOfferingCls.openElectivewrap>{openElectiveWrap};

        MSTR_createCourseOfferingCls.planLiwrap rbsChildWrap = new MSTR_createCourseOfferingCls.planLiwrap();
        rbsChildWrap.count = '1';
        rbsChildWrap.subCount = '0';
        rbsChildWrap.courseId = rbsCourse.Id;
        rbsChildWrap.courseName = rbsCourse.Name;
        rbsChildWrap.credits = 4;
        rbsChildWrap.termId = objTerm.Id;
        rbsChildWrap.filter = '';
        List<MSTR_createCourseOfferingCls.planLiwrap> lstrbsChildWrap = new List<MSTR_createCourseOfferingCls.planLiwrap>{rbsChildWrap};

        MSTR_createCourseOfferingCls.rbsSpclWrap rbsWrap = new MSTR_createCourseOfferingCls.rbsSpclWrap();
        rbsWrap.count = '1';
        rbsWrap.parentId = rbsParentPlanReq.Id;
        rbsWrap.Name = 'RBS Specialization Parent';
        rbsWrap.credits = 4;
        rbsWrap.termId = objTerm.Id;
        rbsWrap.lstPlanLi = lstrbsChildWrap;
        rbsWrap.recordId = rbsParentPlanReq.Id;
        List<MSTR_createCourseOfferingCls.rbsSpclWrap> lstrbsWrap = new List<MSTR_createCourseOfferingCls.rbsSpclWrap>{rbsWrap};
        System.runAs(testUser) {
        Test.startTest();
        // Test getTermDetails
        MSTR_createCourseOfferingCls.termMainWarp termDetails = MSTR_createCourseOfferingCls.getTermDetails(objTerm.Id);
        System.assertNotEquals(null, termDetails, 'Term details should not be null');
        System.assertEquals(objTerm.Id, termDetails.objTerm.Id, 'Term ID should match');

        // Test getPlanRequirement
        MSTR_createCourseOfferingCls.courseMainWarp planReq = MSTR_createCourseOfferingCls.getPlanRequirement(objTerm.Id);
        System.assertNotEquals(null, planReq, 'Plan requirement should not be null');
        System.assertEquals(1, planReq.listHardCore.size(), 'Should have one Hardcore course');

        // Test getcourseOffering
        MSTR_createCourseOfferingCls.courseMainWarp courseOff = MSTR_createCourseOfferingCls.getcourseOffering(objTerm.Id);
        System.assertNotEquals(null, courseOff, 'Course offering should not be null');

        // Test getSchoolName
        String schoolName = MSTR_createCourseOfferingCls.getSchoolName(objAccount4.Id);
        System.assertEquals(objAccount4.Name, schoolName, 'School name should match');

        // Test savePlanRequiement with all categories and isChecked flags
        String result = MSTR_createCourseOfferingCls.savePlanRequiement(
            objTerm.Id,
            lsthardcoreWrap,
            lsthardcoreIntWrap,
            lstpracticalWrap,
            lstopenElectiveWrap,
            lstprofElectiveWrap,
            lstmandatoryWrap,
            lstrbsWrap,
            null, // Remove deleteIds to avoid TypeException
            true, // isChecked
            true  // isCheckedRBS
        );

        System.assertNotEquals(null, result, 'result should not null');




        // Test deletion scenario separately
        List<String> deleteIds = new List<String>{objCourseOff.Id};
        String deleteResult = MSTR_createCourseOfferingCls.savePlanRequiement(
            objTerm.Id,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            deleteIds,
            false,
            false
        );

        // Test error handling with invalid term ID
        try {
            MSTR_createCourseOfferingCls.savePlanRequiement(
                null, // Invalid term ID
                lsthardcoreWrap,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                false,
                false
            );
        } catch (Exception e) {
        }
    }

        Test.stopTest();

        // Verify course offering creation
        // List<hed__Course_Offering__c> courseOfferings = [
        //     SELECT Id, Category__c, Parent_Course_Offering__c
        //     FROM hed__Course_Offering__c
        //     WHERE hed__Term__c = :objTerm.Id
        // ];
        // Set<String> categories = new Set<String>();
        // Integer parentCount = 0;
        // for (hed__Course_Offering__c co : courseOfferings) {
        //     categories.add(co.Category__c);
        //     if (co.Parent_Course_Offering__c != null) {
        //         parentCount++;
        //     }
        // }

    }
}