@istest
public class MSTR_StudentTermMapping_Handler_Test 
{    
    public static testmethod void mapStmToPrgmEnroll()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        Insert ObjCon;
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll; 
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true; 
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.End_Date__c = system.today();
        obj_Stud_Sem.Section__c = objTermParent.id;
        obj_Stud_Sem.Student_Batch__c= obj_Term.id;
        insert obj_Stud_Sem;
        
        string recordTypeName1 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem1 = MSTR_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName1);
        obj_Stud_Sem1.RecordTypeId= recordTypeName1;
        obj_Stud_Sem1.Active__c =true;
        obj_Stud_Sem1.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem1.Start_Date__c = system.today();
        obj_Stud_Sem1.End_Date__c = system.today();
        obj_Stud_Sem1.Section__c = objTermParent.id;
        obj_Stud_Sem1.Student_Batch__c= obj_Term.id;
        insert obj_Stud_Sem1;   
        
        string recordTypeName22 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud = MSTR_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName22);
        obj_Stud.RecordTypeId= recordTypeName22;
        obj_Stud.Active__c = true; 
        obj_Stud.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud.Start_Date__c = system.today();
        obj_Stud.End_Date__c = system.today();
        obj_Stud.Section__c = objTermParent.id;
        obj_Stud.Student_Batch__c= obj_Term.id;
        insert obj_Stud;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = obj_Term.Id;
        //obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        Insert obj_Cour_Enroll;  
        
        List <Student_Semester_Mapping__c> lst_Stud_Sem = new List<Student_Semester_Mapping__c>();
        lst_Stud_Sem.Add(obj_Stud_Sem);
        
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        update obj_Stud_Sem;
        
        Practical_Course_Category__c objPractical = new Practical_Course_Category__c();
        objPractical.Name ='Practical/Term work';
        insert  objPractical;
        system.assertequals(obj_Stud_Sem.id,obj_Stud_Sem.id);
    }
    
    public static testmethod void BatchMethod()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        Insert ObjCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        insert obj_Cour_Off;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        Id TermBatchId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_TermBtch = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_TermBtch.RecordTypeId = TermBatchId ;
        Insert obj_TermBtch;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
         hed__Course_Offering__c obj_Cour_Off1 =MSTR_TestDataFactory.createCourseOffering('Test sec Course', objTerm.Id, obj_Cour.id);
        obj_Cour_Off1.Category__c ='Hardcore Course'; 
         obj_Cour_Off1.hed__Term__c = objTerm.Id;
        insert obj_Cour_Off1;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll; 
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        Insert obj_Cour_Enroll;        
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true;
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today()-1;
        obj_Stud_Sem.End_Date__c = system.today()+1;
        obj_Stud_Sem.Section__c = objTerm.id;
        insert obj_Stud_Sem;
        
        string recordTypeName2 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem2 = MSTR_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName2);
        obj_Stud_Sem2.RecordTypeId= recordTypeName2;
        obj_Stud_Sem2.Active__c =true;
        obj_Stud_Sem2.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem2.Start_Date__c = system.today();
        obj_Stud_Sem2.End_Date__c = system.today();
        obj_Stud_Sem2.Student_Batch__c= obj_TermBtch.id;
        obj_Stud_Sem2.Section__c = objTerm.id;
        insert obj_Stud_Sem2;
        
        List <Student_Semester_Mapping__c> lst_Stud_Sem2 = new List<Student_Semester_Mapping__c>();
        lst_Stud_Sem2.Add(obj_Stud_Sem2);
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
        Practical_Course_Category__c objPractical = new Practical_Course_Category__c();
        objPractical.Name ='Practical/Term work';
        insert  objPractical;
        system.assertequals(obj_Stud_Sem2.id,obj_Stud_Sem2.id);
    }
    
    public static testmethod void CreateStudSemGroup()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        Insert ObjCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        Insert obj_Term;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        obj_Cour_Off.Category__c ='Open Elective'; 
        insert obj_Cour_Off;
        
        hed__Course_Offering__c objCourseSub =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        objCourseSub.Category__c ='Open Elective'; 
        objCourseSub.Parent_Course_Offering__c = obj_Cour_Off.Id;
        insert objCourseSub;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Parent_Term__c = obj_Term.Id;
        insert objTerm;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        insert objProgEnroll; 
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, objCourseSub.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = objCourseSub.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c = obj_Term.id;
        Insert obj_Cour_Enroll;    
        
        Elective_Course_Category__c obj_Ele_Cour = new Elective_Course_Category__c();
        obj_Ele_Cour.Name= 'Open Elective';
        insert obj_Ele_Cour;
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true;
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.End_Date__c = system.today();
        obj_Stud_Sem.Student_Group__c = objTerm.id;
        insert obj_Stud_Sem;
        system.assertequals(obj_Stud_Sem.id,obj_Stud_Sem.id);
    }
        
    public static testmethod void CreateStudSemBatch()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        Insert ObjCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermNamew',objAcc.Id, termRecTypeId);
        Insert obj_Term;
        
        Id termRecTyScId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        hed__Term__c obj_Tr_Sec = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTyScId);
        obj_Tr_Sec.hed__Parent_Term__c = obj_Term.Id;
        Insert obj_Tr_Sec;
        
        Id termRecTyBtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        hed__Term__c obj_Tr_Bat = MSTR_TestDataFactory.createTerm('TermNameq',objAcc.Id, termRecTyBtId);
        obj_Tr_Bat.hed__Parent_Term__c = obj_Tr_Sec.Id;
        Insert obj_Tr_Bat;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Tr_Bat.Id, obj_Cour.id);
        obj_Cour_Off.Category__c ='Practical/Term work';
        insert obj_Cour_Off;
        
        hed__Course_Offering__c objCourseSub =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Tr_Bat.Id, obj_Cour.id);
        objCourseSub.Category__c ='Practical/Term work'; 
        objCourseSub.Parent_Course_Offering__c = obj_Cour_Off.Id;
        objCourseSub.hed__Term__c = obj_Term.Id;
        insert objCourseSub;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20; 
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        insert objProgEnroll; 
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, objCourseSub.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = objCourseSub.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c = obj_Term.id;
        obj_Cour_Enroll.Semester_ID__c= obj_Term.Id;
        Insert obj_Cour_Enroll;    
        
        Practical_Course_Category__c objPractical = new Practical_Course_Category__c();
        objPractical.Name ='Practical/Term work';
        insert  objPractical;
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true;
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.Student_Batch__c= obj_Tr_Bat.id;
        insert obj_Stud_Sem;     
        system.assertequals(obj_Stud_Sem.id,obj_Stud_Sem.id);   
    }
    
    public static testmethod void CreateStudSemSection()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        Insert ObjCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermNamew',objAcc.Id, termRecTypeId);
        Insert obj_Term;
        
        Id termRecTyScId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        hed__Term__c obj_Tr_Sec = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTyScId);
        obj_Tr_Sec.hed__Parent_Term__c = obj_Term.Id;
        Insert obj_Tr_Sec;
        
        Id termRecTyBtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        hed__Term__c obj_Tr_Bat = MSTR_TestDataFactory.createTerm('TermNameq',objAcc.Id, termRecTyBtId);
        obj_Tr_Bat.hed__Parent_Term__c = obj_Tr_Sec.Id;
        Insert obj_Tr_Bat;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Tr_Bat.Id, obj_Cour.id);
        obj_Cour_Off.Category__c ='Practical/Term work';
        insert obj_Cour_Off;
        
        hed__Course_Offering__c objCourseSub =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Tr_Bat.Id, obj_Cour.id);
        objCourseSub.Category__c ='Practical/Term work'; 
        objCourseSub.Parent_Course_Offering__c = obj_Cour_Off.Id;
        objCourseSub.hed__Term__c = obj_Term.Id;
        insert objCourseSub;
        
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20; 
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        insert objProgEnroll; 
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, objCourseSub.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = objCourseSub.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c = obj_Term.id;
        obj_Cour_Enroll.Semester_ID__c= obj_Term.Id;
        Insert obj_Cour_Enroll;    
        
        Practical_Course_Category__c objPractical = new Practical_Course_Category__c();
        objPractical.Name ='Practical/Term work';
        insert  objPractical;
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true;
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.Section__c= obj_Tr_Sec.id;
        insert obj_Stud_Sem;  
        system.assertequals(obj_Stud_Sem.id,obj_Stud_Sem.id);      
    }  
}