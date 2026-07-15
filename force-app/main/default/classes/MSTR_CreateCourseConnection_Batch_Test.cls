@isTest
public class MSTR_CreateCourseConnection_Batch_Test 
{
    Public static testmethod Void CreateCourseConnec()
    {
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Integrated Course';
        insert objMan;
        
        Practical_Course_Category__c objPractical = new Practical_Course_Category__c();
        objPractical.Name ='Practical/Term work';
        insert  objPractical;
        
        Elective_Course_Category__c obj_Ele_Cour = new Elective_Course_Category__c();
        obj_Ele_Cour.Name= 'Open Elective';
        insert obj_Ele_Cour;
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Id AccountuniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        Account objAcc1 = MSTR_TestDataFactory.CreateAccount('str_accName1', AccountuniversityRecTypeId);
        //objAcc1.RecordTypeId = AccountRecTypeId;
        insert objAcc1;
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
         ObjCon.Active__c = true;
        Insert ObjCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.Credits__c=4;
        obj_Cour.Offered_By_School__c=objAcc1.Id;
        obj_Cour.Credit_Hours__c=11;
        obj_Cour.Maximum_External_Marks__c = 50;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 30;
        Insert obj_Cour;
        
        hed__Program_Enrollment__c obj_Pro_Enroll = new hed__Program_Enrollment__c();
        obj_Pro_Enroll.hed__Contact__c= ObjCon.id;
        obj_Pro_Enroll.hed__Account__c = objAcc.id;
        insert obj_Pro_Enroll;
        
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
        
        hed__Course_Offering__c obj_Cour_Off1 =MSTR_TestDataFactory.createCourseOffering('Test Course1', objTerm.Id, obj_Cour.id);
        obj_Cour_Off1.Category__c ='Open Elective'; 
        insert obj_Cour_Off1;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', objTermParent.Id, obj_Cour.id);
        obj_Cour_Off.Category__c='Hardcore Integrated Course';
        obj_Cour_Off.Active__c=true;
        obj_Cour_Off.Parent_Course_Offering__c = obj_Cour_Off1.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = obj_Pro_Enroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c=objTerm.id;
        Insert obj_Cour_Enroll;  
        
        Id Stud_SemRecTypeId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Section).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stu_Sem =  new Student_Semester_Mapping__c();
        obj_Stu_Sem.Name = 'hello';
        obj_Stu_Sem.RecordTypeId = Stud_SemRecTypeId;
        obj_Stu_Sem.Program_Enrollment__c=obj_Pro_Enroll.Id;
        obj_Stu_Sem.Course_Offering_ID__c =obj_Cour_Off.id;
        obj_Stu_Sem.Active__c=true;
        obj_Stu_Sem.Course_Connections_Created__c=false;
        obj_Stu_Sem.Section__c = objTermParent.id;
        insert obj_Stu_Sem;
        Set<Id> set_STMIds = new Set<Id>();
        set_STMIds.add(obj_Stu_Sem.Id);
        Test.startTest();
        database.executeBatch(new MSTR_CreateCourseConnection_Batch(set_STMIds),1);
        Test.stopTest();
    }
    Public static testmethod Void CreateCourseConnec2()
    {
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Integrated Course';
        insert objMan;
        
        Practical_Course_Category__c objPractical = new Practical_Course_Category__c();
        objPractical.Name ='Practical/Term work';
        insert  objPractical;
        
        Elective_Course_Category__c obj_Ele_Cour = new Elective_Course_Category__c();
        obj_Ele_Cour.Name= 'Open Elective';
        insert obj_Ele_Cour;
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Id AccountuniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        Account objAcc1 = MSTR_TestDataFactory.CreateAccount('str_accName1', AccountuniversityRecTypeId);
        //objAcc1.RecordTypeId = AccountRecTypeId;
        insert objAcc1;
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = MSTR_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        ObjCon.Active__c = true;
        Insert ObjCon;
        
        hed__Course__c obj_Cour = MSTR_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.Credits__c=4;
        obj_Cour.Offered_By_School__c=objAcc1.Id;
        obj_Cour.Credit_Hours__c=11;
        obj_Cour.Maximum_External_Marks__c = 50;
        obj_Cour.Total_Maximum_Marks_IA_External__c = 30;
        Insert obj_Cour;
        
        hed__Program_Enrollment__c obj_Pro_Enroll = new hed__Program_Enrollment__c();
        obj_Pro_Enroll.hed__Contact__c= ObjCon.id;
        obj_Pro_Enroll.hed__Account__c = objAcc.id;
        insert obj_Pro_Enroll;
        
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
        
        hed__Course_Offering__c obj_Cour_Off1 =MSTR_TestDataFactory.createCourseOffering('Test Course1', objTerm.Id, obj_Cour.id);
        obj_Cour_Off1.Category__c ='Open Elective'; 
        insert obj_Cour_Off1;
        
        hed__Course_Offering__c obj_Cour_Off =MSTR_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, obj_Cour.id);
        obj_Cour_Off.Category__c='Hardcore Integrated Course';
        obj_Cour_Off.Active__c=true;
        obj_Cour_Off.Parent_Course_Offering__c = obj_Cour_Off1.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = obj_Pro_Enroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c=objTerm.id;
        obj_Cour_Enroll.Semester_ID__c = objTerm.id;
        Insert obj_Cour_Enroll;  
        
        Id Stud_SemRecTypeId1 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stu_Sem1 =  new Student_Semester_Mapping__c();
        obj_Stu_Sem1.Name = 'hello';
        obj_Stu_Sem1.RecordTypeId = Stud_SemRecTypeId1;
        obj_Stu_Sem1.Program_Enrollment__c=obj_Pro_Enroll.Id;
        obj_Stu_Sem1.Course_Offering_ID__c =obj_Cour_Off.id;
        obj_Stu_Sem1.Active__c=true;
        obj_Stu_Sem1.Course_Connections_Created__c=false;  
        obj_Stu_Sem1.Student_Group__c = objTermParent.id;
        insert obj_Stu_Sem1;
        Set<Id> set_STMIds = new Set<Id>();
        set_STMIds.add(obj_Stu_Sem1.Id);
        Test.startTest();
        database.executeBatch(new MSTR_CreateCourseConnection_Batch(set_STMIds),1);
        Test.stopTest();
    }
}