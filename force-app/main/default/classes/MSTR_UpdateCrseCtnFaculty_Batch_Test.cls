@IsTest
public class MSTR_UpdateCrseCtnFaculty_Batch_Test
{
    public static testmethod void CourseConnection()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact objCon = MSTR_TestDataFactory.createContact('Test');
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';            
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;            
        //objcon.hed__Preferred_Email__c='Personal Email';
        objcon.Student_Status__c ='Pursuing';
        objcon.Active__c = true;
        Insert objCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
         hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAcc.id;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objSemTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objSemTerm.Program_Batch__c  = objProgPlan.id;
        objSemTerm.hed__Start_Date__c = system.today()-15;
        objSemTerm.hed__End_Date__c =  system.today()+15;
        insert objSemTerm;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today().addDays(15);
        obj_Term.hed__End_Date__c = system.today().addDays(-15);
        obj_Term.hed__Parent_Term__c = objSemTerm.Id;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId = enrollRecTypeId;
        obj_Cour_Enroll.Section__c = obj_Term.Id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c = objCon.Id;
        Insert obj_Cour_Enroll;
       
        Id facRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_CoursEnroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_CoursEnroll.RecordTypeId = facRecTypeId;
        obj_CoursEnroll.Section__c = obj_Term.Id;
        obj_CoursEnroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_CoursEnroll.hed__Primary__c = true;
        Insert obj_CoursEnroll;
        
        List<hed__Course_Enrollment__c> list_Update = new List<hed__Course_Enrollment__c >();
        list_Update.add(obj_CoursEnroll);
        
        Map<string,List<hed__Course_Enrollment__c>> Map_studntcon = new Map<string,List<hed__Course_Enrollment__c>>();
        Map_studntcon.put(obj_Cour_Enroll.Section__c+'_'+obj_Cour_Enroll.hed__Course_Offering__c,new List<hed__Course_Enrollment__c>());
        
        Test.startTest();
        MSTR_UpdateCourseConnectionFaculty_Batch  btch = new MSTR_UpdateCourseConnectionFaculty_Batch();
        Database.executeBatch(btch,1);
        Test.stopTest();
        system.assertEquals( obj_CoursEnroll.hed__Primary__c,true);
               
    }
}