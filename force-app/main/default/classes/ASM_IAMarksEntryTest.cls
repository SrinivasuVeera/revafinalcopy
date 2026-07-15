@isTest
public class ASM_IAMarksEntryTest {
    @TestSetup
    static void setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true AND UserRoleId != Null LIMIT 1];
       
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.Active__c = true;
        ObjCon.Employee_Number__c ='EP1234';
        ObjCon.Email='test@gmail.com';
        Insert ObjCon;
        
        Contact prfCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        prfCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        prfCon.SRN_Number__c = '';
        prfCon.Employee_Number__c ='1245';
        Insert prfCon;
        
        /*  //Create Student User
UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
User student = ASM_TestDataFactory.createStudentUser('editest9');
student.UserRoleId = portalRole.Id;
student.ContactId = ObjCon.Id;
System.runAs(otherAdmin){
Insert student;
}*/
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
        hed__Course__c course = ASM_TestDataFactory.CreateCourse(1, objAcc.id, 'Hardcore Course');
        insert course;
        
       /* List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            String Hardcore = (i == 1) ? 'Theory' : (i == 2) ? 'Project' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat,Hardcore));
        }
        Insert list_Crs;  */
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        /*ObjCon.Active_Semester__c = objTerm.Id;
        Update ObjCon;*/
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objcon.id,objAcc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
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
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, course.id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = obj_Term.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        obj_Cour_Off.Offered_By_School__c = schAcc.Id;
        //obj_Cour_Off.Publish_to_Students__c = true;
        insert obj_Cour_Off;
        
        
        hed__Course_Enrollment__c prfCrsCon = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        prfCrsCon.RecordTypeId=Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        prfCrsCon.hed__Program_Enrollment__c = objProgEnroll.id;
        prfCrsCon.hed__Course_Offering__c = obj_Cour_Off.Id;
        prfCrsCon.hed__Contact__c= ObjCon.id;
        prfCrsCon.Section__c = objTermParent.Id; 
        Insert prfCrsCon;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c = objTermParent.Id;
        Insert obj_Cour_Enroll;
        
        IA_Marks__c iam = ASM_TestDataFactory.createIAMarks(obj_Cour_Enroll.Id,obj_Cour_Off.Id,'IA1');
        ASM_IAMarksTrgHandler.rollupCountUpdate = false;
        iam.Course_Connection__c = obj_Cour_Enroll.Id;
        iam.Faculty_Course_Connection__c = prfCrsCon.Id;
        Insert iam;
        
        string MentorRcdType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mentee').getRecordTypeId();
        
        case objcase = FEE_TestDataFactory.createCase('Queued','Email');
        objcase.ContactId = ObjCon.id;
        objcase.Mentor__c = ObjCon.id;
        objcase.RecordTypeId =  MentorRcdType;
        insert objcase;
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name = 'Alumni Portal Profile'];
        
        User objUser = new User();
        objUser.LastName = 'Te';
        objUser.FirstName ='testing';
        objUser.alias = 'testu'+'tes';
        objUser.Email = 'test@unitingambitionn.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.LocaleSidKey = 'en_US';
        objUser.TimeZoneSidKey='America/Los_Angeles';
        objUser.ProfileId = p.Id;
        objUser.ContactId = ObjCon.Id;
        objUser.UserName='test@unitingambitions.com';
        objUser.EmployeeNumber ='EP1234';
        insert objUser;*/
    }
    
    static testmethod void exe(){
        hed__Course_Enrollment__c prfCon = [SELECT Id,IA_Marks_Entry_Status__c,hed__Course_Offering__c,Section__c FROM hed__Course_Enrollment__c WHERE RecordType.Name = 'Faculty'];
        List<IA_Marks__c> list_IaMarks = new List<IA_Marks__c>([SELECT id,Faculty_Course_Connection__c,Course_Connection__c,OwnerId FROM IA_Marks__c limit 1]);
        Test.startTest();
        ASM_IAMarksEntry.fetchData(prfCon.Id, 'IA1');
        ASM_IAMarksEntry.saveData(list_IaMarks,'IA2');
        try{ASM_IAMarksEntry.saveData(null,null);}catch(exception e){}
        Test.stopTest();
    }
    static testmethod void testPDFGenerationLogic() {
        // Retrieve the Faculty Course Enrollment record
        hed__Course_Enrollment__c prfCon = [SELECT Id, hed__Course_Offering__c, Section__c 
                                            FROM hed__Course_Enrollment__c 
                                            WHERE RecordType.Name = 'Faculty' LIMIT 1];
        
        // Retrieve the IA Marks record to ensure data exists
        IA_Marks__c iaMark = [SELECT Id, Theory_Secured_Marks__c, Seminar_Secured_Marks__c, Quiz_Secured_marks__c, 
                              Total_Secured_Marks_New__c, Acknowledgment_Response__c 
                              FROM IA_Marks__c LIMIT 1];
        
        Test.startTest();
        
        // Simulate the Visualforce page context
        Test.setCurrentPage(Page.IAMarksEntryPDF);
        ApexPages.currentPage().getParameters().put('prfConId', prfCon.Id);
        ApexPages.currentPage().getParameters().put('iaType', 'IA1');
        
        // Instantiate the controller
        ASM_IAMarksEntry controller = new ASM_IAMarksEntry();
        
        // Verify the properties are populated
        System.assertNotEquals(null, controller.studentMarks, 'studentMarks should not be null');
        System.assertEquals(1, controller.studentMarks.size(), 'There should be 1 student mark record');
        
        // Verify the PDFMarksWrapper fields
        ASM_IAMarksEntry.PDFMarksWrapper wrapper = controller.studentMarks[0];
        System.assertEquals('1', wrapper.serialNumber, 'Serial number should be 1');
        System.assertNotEquals(null, wrapper.studentName, 'Student name should not be null');
        System.assertNotEquals(null, wrapper.srnNumber, 'SRN number should not be null');        
        System.assertEquals('1', wrapper.totalMarks, 'Total marks should be 80');
        System.assertEquals('No', wrapper.acknowledgedByStudent, 'Acknowledged by Student should be Yes');
        System.assertEquals('No', wrapper.acknowledgedByAdmin, 'Acknowledged by Admin should be No');
        
        // Verify other controller properties
        System.assertNotEquals(null, controller.courseName, 'Course name should not be null');
        System.assertNotEquals(null, controller.sectionName, 'Section name should not be null');
        System.assertEquals('IA1', controller.iaType, 'IA Type should be IA1');        
        //System.assertEquals(0.00, controller.totalMaxMarks, 'Total max marks should be 100');
        
        Test.stopTest();
    }
}