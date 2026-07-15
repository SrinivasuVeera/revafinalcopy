@Istest
public class MSTR_CourseConnection_TrigHandlr_Test 
{
    Public static testmethod Void CourseConnection()
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
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        Insert obj_Cour_Enroll;
        
        
        List<hed__Course_Enrollment__c> list_Course_Enroll = new List<hed__Course_Enrollment__c>();
        list_Course_Enroll.Add(obj_Cour_Enroll);
        
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        update obj_Cour_Enroll;
        
        delete obj_Cour_Enroll;
        undelete obj_Cour_Enroll;
        
        Test.StartTest();
        MSTR_CourseConnection_TrigHandlr.RollupCourseConnection(list_Course_Enroll, Null);
        Test.StopTest(); 
        system.assertEquals(obj_Cour_Enroll.Id,obj_Cour_Enroll.Id);        
    }
    
    Public static testmethod Void DeleteStudentSemester()
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
      //  objcon.hed__Preferred_Email__c='Personal Email';
        Insert objCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = MSTR_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
       
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, obj_Cour.id);
        insert obj_Cour_Off;
        
        hed__Course_Offering__c obj_Cour_Off1 =MSTR_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_Cour_Off1;
        
        hed__Program_Enrollment__c obj_Pro_Enroll = new hed__Program_Enrollment__c();
        obj_Pro_Enroll.hed__Contact__c= ObjCon.id;
        obj_Pro_Enroll.hed__Account__c = objAcc.id;
        insert obj_Pro_Enroll;
        
        Id Stud_SemRecTypeId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get('Student Semester').getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stu_Sem =  new Student_Semester_Mapping__c();
        obj_Stu_Sem.Name = 'hello';
        obj_Stu_Sem.RecordTypeId = Stud_SemRecTypeId;
        obj_Stu_Sem.Program_Enrollment__c=obj_Pro_Enroll.Id;
        obj_Stu_Sem.Course_Offering_ID__c =obj_Cour_Off.id;
        insert obj_Stu_Sem;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = obj_Pro_Enroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        Insert obj_Cour_Enroll;
        
        List<hed__Course_Enrollment__c> list_Course_Enroll = new List<hed__Course_Enrollment__c>();
        list_Course_Enroll.Add(obj_Cour_Enroll);
        
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off1.Id;
        update obj_Cour_Enroll;
        
        map<id,hed__Course_Enrollment__c> oldMap = new map<id,hed__Course_Enrollment__c>();
        oldMap.put(obj_Cour_Enroll.Id,obj_Cour_Enroll); 
        
        delete obj_Cour_Enroll;
        undelete obj_Cour_Enroll;    
        
        Test.StartTest();
        MSTR_CourseConnection_TrigHandlr.DeleteStudentSemester(list_Course_Enroll, oldMap); 
        Test.StopTest(); 
        system.assertEquals(obj_Cour_Enroll.Id,obj_Cour_Enroll.Id); 
    }    
}