@isTest
public class ASM_IAMarksTrgHandlerTest {
    static testmethod void exe(){
        //User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            if(i < 3){
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
            }else{
                hed__Course__c proj = ASM_TestDataFactory.CreateCourse(i, objAcc.Id, 'Hardcore Course');
                proj.HardCore_Sub_Type__c = 'Project';
                list_Crs.add(proj);
            }
            
        }
        list_Crs[0].hed__Course_ID__c = 'SUB01';
        Insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        ObjCon.Active_Semester__c = objTerm.Id;
        //Update ObjCon;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        objProgEnroll.Semester__c = objTermParent.id;
        insert objProgEnroll; 
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = ASM_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true; 
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.End_Date__c = system.today();
        obj_Stud_Sem.Section__c = objTermParent.id;
        obj_Stud_Sem.Student_Batch__c= obj_Term.id;
        insert obj_Stud_Sem;
        
        string recordTypeName1 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem1 = ASM_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName1);
        obj_Stud_Sem1.RecordTypeId= recordTypeName1;
        obj_Stud_Sem1.Active__c =true;
        obj_Stud_Sem1.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem1.Start_Date__c = system.today();
        obj_Stud_Sem1.End_Date__c = system.today();
        obj_Stud_Sem1.Section__c = objTermParent.id;
        obj_Stud_Sem1.Student_Batch__c= obj_Term.id;
        insert obj_Stud_Sem1;   
        
        string recordTypeName22 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud = ASM_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName22);
        obj_Stud.RecordTypeId= recordTypeName22;
        obj_Stud.Active__c = true; 
        obj_Stud.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud.Start_Date__c = system.today();
        obj_Stud.End_Date__c = system.today();
        obj_Stud.Section__c = objTermParent.id;
        obj_Stud.Student_Batch__c= obj_Term.id;
        insert obj_Stud;
        
        Account schAcc = ASM_TestDataFactory.createSchoolAcc(1);
        Insert schAcc;
        
        List<hed__Course_Offering__c> list_crsff = new List<hed__Course_Offering__c>();
        for(hed__Course__c crs : list_Crs){
            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, crs.id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = obj_Term.Id;
            obj_Cour_Off.hed__Term__c = objTermParent.Id;
            obj_Cour_Off.Offered_By_School__c = schAcc.Id;
            list_crsff.add(obj_Cour_Off);
        }
        
        //obj_Cour_Off.Publish_to_Students__c = true;
        insert list_crsff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        List<hed__Course_Enrollment__c> list_crsCon = new List<hed__Course_Enrollment__c>();
        for(hed__Course_Offering__c cOf : list_crsff){
            hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, cOf.Id);
            obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
            obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
            obj_Cour_Enroll.hed__Course_Offering__c = cOf.Id;
            obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
            list_crsCon.add(obj_Cour_Enroll);
        }
        
        Insert list_crsCon;
        List<IA_Marks__c> list_Iams1 = new List<IA_Marks__c>();
        
        IA_Marks__c objIamMarks = ASM_TestDataFactory.createIAMarks(list_crsCon[0].Id,list_crsff[0].Id,'IA2');
        objIamMarks.Logisys_Integration__c ='Yes';
        objIamMarks.Independent_Learning_Secured_Marks__c = 2;
        insert objIamMarks;
        
        list_Iams1.add(objIamMarks); 
        
        objIamMarks.Logisys_Integration__c ='No';
        update  objIamMarks;
        
        map<id,IA_Marks__c> Map_Iams = new map<id,IA_Marks__c>();
        Map_Iams.put(objIamMarks.id,objIamMarks);
        
        List<IA_Marks__c> list_Iams = new List<IA_Marks__c>();
        for(integer i=0;i<3;i++){
            list_Iams.add(ASM_TestDataFactory.createIAMarks(list_crsCon[i].Id,list_crsff[i].Id,'IA1'));
        }
        Test.startTest();
        ASM_IAMarksTrgHandler.rollupCountUpdate = false;
        Insert list_Iams;
        Delete list_Iams;
        Undelete list_Iams;
        Test.stopTest();
    }
}