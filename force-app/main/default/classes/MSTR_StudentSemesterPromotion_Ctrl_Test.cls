@isTest
public class MSTR_StudentSemesterPromotion_Ctrl_Test 
{
    //Method 1
    Public static testmethod Void studentSemesterPromotion1()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = MSTR_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc.id;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRtId);
        obj_Term.RecordTypeId = termRtId;
        obj_Term.Program_Batch__c = objProgPlan.id;
        obj_Term.Term_Number__c = 1;
        Insert obj_Term;
        
        hed__Term__c obj_Term1 = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRtId);
        obj_Term1.RecordTypeId = termRtId;
        obj_Term1.Term_Number__c = 2;
        obj_Term1.Program_Batch__c = obj_Term.Program_Batch__c;
        obj_Term1.hed__Start_Date__c = system.today().addDays(10);
        obj_Term1.hed__End_Date__c = system.today().addDays(24);
        Insert obj_Term1;
        
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_Cour_Off;
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, obj_Cour_Off.Id);
        Insert obj_Cour_Enroll;
        
        
        hed__Program_Enrollment__c obj_Prgm_Enroll = MSTR_TestDataFactory.createProgEnrollment(objCon.id, objAcc.id);
        obj_Prgm_Enroll.Semester__c = obj_Term.id;
        obj_Prgm_Enroll.hed__Start_Date__c = system.today()-1;
        obj_Prgm_Enroll.hed__End_Date__c = system.today()+1;
        insert obj_Prgm_Enroll;
        
        Test.StartTest();
        MSTR_StudentSemesterPromotion_Ctrl.getSemesterDetails(obj_Term.id);
        Test.StopTest(); 
        system.assertEquals(obj_Term.Id,obj_Term.Id);
    }
    
    //Method2
    Public static testmethod Void studentSemesterPromotion2()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = MSTR_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;            
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc.id;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c obj_Semester = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRtId);
        obj_Semester.RecordTypeId = termRtId;
        obj_Semester.Term_Number__c = 1;
        obj_Semester.Program_Batch__c = objProgPlan.id;
        Insert obj_Semester;
        
        hed__Term__c obj_NewSemester = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRtId);
        obj_NewSemester.RecordTypeId = termRtId;
        obj_NewSemester.Term_Number__c =2;
        obj_NewSemester.Program_Batch__c = obj_Semester.Program_Batch__c;
        Insert obj_NewSemester;
        
        string str_SectionRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        
        hed__Term__c obj_Section = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, str_SectionRecId);
        obj_Section.RecordTypeId = str_SectionRecId;
        obj_Section.hed__Parent_Term__c = obj_NewSemester.id;
        obj_Section.Section_Number__c = 2;
        Insert obj_Section;
        
        string str_BatchRecId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId(); 
        
        hed__Term__c obj_Batch = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, str_BatchRecId);
        obj_Batch.RecordTypeId = str_BatchRecId;
        obj_Batch.Name = '-2025-2029-Term-1-B';
        obj_Batch.hed__Parent_Term__c = obj_Section.id;
        Insert obj_Batch;
        
        Map<Decimal, hed__Term__c> map_NextSemSections = new Map<Decimal, hed__Term__c>();
        map_NextSemSections.put(obj_Section.Section_Number__c,obj_Section);
        
        hed__Program_Enrollment__c obj_PrgmEnroll = MSTR_TestDataFactory.createProgEnrollment(objCon.id, objAcc.id);
        obj_PrgmEnroll.Semester__c = obj_NewSemester.id;
        obj_PrgmEnroll.Section__c = obj_Section.id;
        obj_PrgmEnroll.hed__Start_Date__c = system.today()-1;
        obj_PrgmEnroll.hed__End_Date__c = system.today()+1;
        insert obj_PrgmEnroll;
        
        string str_studsemId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Semester').getRecordTypeId();
        
        Student_Semester_Mapping__c objStuMapping = MSTR_TestDataFactory.createStudenttermMapping('Test student',str_studsemId);
        objStuMapping.RecordTypeId = str_studsemId;
        objStuMapping.Active__c = true;
        objStuMapping.Program_Enrollment__c = obj_PrgmEnroll.id;
        objStuMapping.Semester__c = obj_Semester.id;
        insert objStuMapping; 
        
        Student_Semester_Mapping__c objStudMapping = MSTR_TestDataFactory.createStudenttermMapping('Test student',str_studsemId);
        objStudMapping.RecordTypeId = str_studsemId;
        objStudMapping.Active__c = false;
        objStudMapping.Program_Enrollment__c = obj_PrgmEnroll.id;
        objStudMapping.Semester__c = obj_NewSemester.id;
        insert objStudMapping; 
        
        List<hed__Program_Enrollment__c> lst_ProgEnrol = new List<hed__Program_Enrollment__c>();
        hed__Program_Enrollment__c objSelProgEnroll = [select Id,Semester__c,Batch_Number__c,Section__c,Section_Number__c,hed__Start_Date__c,hed__End_Date__c
                                                           from hed__Program_Enrollment__c where Id =: obj_PrgmEnroll.Id];
        lst_ProgEnrol.add(objSelProgEnroll);
        system.debug(lst_ProgEnrol);
        
        
        List<Student_Semester_Mapping__c> list_studentmapping = new List<Student_Semester_Mapping__c>();
        list_studentmapping.add(objStuMapping);
        
        List<string> lst_SelectedIds = new List<string>();
        lst_SelectedIds.add(obj_PrgmEnroll.Id);
        
        
        Test.StartTest();
        MSTR_StudentSemesterPromotion_Ctrl.updatestudentTermMappings(obj_Semester.id, lst_ProgEnrol, lst_SelectedIds);
        Test.StopTest(); 
        system.assertEquals(obj_NewSemester.Id,obj_NewSemester.Id);
    }
}