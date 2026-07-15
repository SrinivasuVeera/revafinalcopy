@isTest
public class ASM_TermTrigger_Handlr_Test 
{
    static testmethod void MarktoLogisysMethod()
    {        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.hed__WorkEmail__c = 'hhhh@gmail.com';
        Insert ObjCon;
        
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
        objTerm.Push_to_Logisys__c =false;
        objTerm.Publish_to_Students__c =true;
        objTerm.IA_2_Publish_to_Students__c  =true;
        insert objTerm;
        
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
        
        IA_Marks__c objIamMarks = ASM_TestDataFactory.createIAMarks(list_crsCon[0].Id,list_crsff[0].Id,'IA2');
        objIamMarks.Logisys_Integration__c ='No';
        objIamMarks.Independent_Learning_Secured_Marks__c = 2;
        insert objIamMarks;
        
        objTerm.Push_to_Logisys__c =true;
        update objTerm;       
    }
}