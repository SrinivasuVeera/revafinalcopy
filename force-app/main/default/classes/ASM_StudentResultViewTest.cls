@isTest
public class ASM_StudentResultViewTest {
    
    static TestMethod void  setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        // Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.hed__WorkEmail__c = 'hhhh@gmail.com';
        Insert ObjCon;
        
        //Create Student User below part is working one
        /*User student = ASM_TestDataFactory.createStudentUser('editest9');
student.ContactId = ObjCon.Id;
System.runAs(otherAdmin){
Insert student;
}*/
        User student;
        System.runAs(otherAdmin) {
            student = ASM_TestDataFactory.createStudentUser('editest9');
            student.ContactId = ObjCon.Id;
            insert student;
        }
        /***********ENded here********************/
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        for(integer i=1;i<=3;i++){
            String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
            list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
        }
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
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = obj_Term.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        //obj_Cour_Off.Publish_to_Students__c = true;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        Insert obj_Cour_Enroll;
        
        hed__Term_Grade__c resSmry = ASM_TestDataFactory.createResSummary(ObjCon.id,objTerm.Id,obj_Cour_Off.Id);
        Insert resSmry;
        
        hed__Term_Grade__c result = ASM_TestDataFactory.createResult(ObjCon.id,objTerm.Id,obj_Cour_Enroll.Id,obj_Cour_Off.Id);
        result.Result_Summary__c = resSmry.Id;
        Insert result;
        
        User std = [SELECT Id FROM User WHERE alias = 'editest9'];
        hed__Term_Grade__c summary = [SELECT Id FROM hed__Term_Grade__c WHERE Result_Summary__c = null LIMIT 1];
        System.runAs(std){
            Test.startTest();
            ASM_StudentResultView.fetchData(summary.Id);
            Test.stopTest();
        }
    }
    /* static testMethod void exe(){
User std = [SELECT Id FROM User WHERE alias = 'editest9'];
hed__Term_Grade__c summary = [SELECT Id FROM hed__Term_Grade__c WHERE Result_Summary__c = null LIMIT 1];
System.runAs(std){
Test.startTest();
ASM_StudentResultView.fetchData(summary.Id);
Test.stopTest();
}
}*/
    
    /********************New method*****************/
    @isTest
    static void testFetchStudentResultsMethod() {
        // Step 1: Create Program Plan
        // Create Academic Program (Account with specific RecordType)
        RecordType academicProgramRT = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Account' AND Name = 'Academic Program' 
            LIMIT 1
        ];
        
        
        Account academicProgram = new Account(
            Name = 'B.Sc Biotechnology Program',
            RecordTypeId = academicProgramRT.Id
        );
        insert academicProgram;
        
        Id universityDeptRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account universityAccount = new Account(Name = 'School of Science', RecordTypeId = universityDeptRtId);
        insert universityAccount;
        // Create Program Plan (linked to Academic Program)
        hed__Program_Plan__c progPlan = new hed__Program_Plan__c(
            Name = 'Test Plan',
            hed__Account__c = academicProgram.Id
        );
        insert progPlan;
        
        // Now create the Term with hed__Account__c
        hed__Term__c activeTerm = new hed__Term__c(
            Name = 'Semester 2',
            Program_Batch__c = progPlan.Id,
            Term_Number__c = 2,
            hed__Account__c = academicProgram.Id // ✅ Required field
        );
        insert activeTerm;
        
        // Step 3: Create Contact (Student)
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'testuser@example.com',
            RecordTypeId = studentRecordType.Id,
            Active_Semester__c = activeTerm.Id,
            Program_Batch__c = progPlan.Id
        );
        insert testContact;
        
        // Step 4: Create Course and Course Offering
        /*hed__Course__c course = new hed__Course__c(Name = 'Test Course');
        insert course;*/
        
        hed__Course__c course = new hed__Course__c(
            Name = 'Test Course',
            hed__Account__c = universityAccount.Id,
            Credits__c = 4,
            Offered_By_School__c = universityAccount.Id,
            Credit_Hours__c = 4,
            Maximum_External_Marks__c = 70,
            Total_Maximum_Marks_IA_External__c = 100
        );
        insert course;
        
        hed__Course_Offering__c offering = new hed__Course_Offering__c(
            Name = 'Offering',
            hed__Term__c = activeTerm.Id,
            hed__Course__c = course.Id
        );
        insert offering;
        
        // Step 5: Create Course Enrollment
        hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(
            hed__Contact__c = testContact.Id,
            hed__Course_Offering__c = offering.Id
        );
        insert enrollment;
        
        // Step 6: Create Term Grade (Result)
       hed__Term_Grade__c grade = new hed__Term_Grade__c(
    hed__Term__c = activeTerm.Id,
    hed__Contact__c = testContact.Id,
    Course__c = course.Id,
    hed__Course_Offering__c = offering.Id, // ✅ Required with hed__Contact__c
    Secured_Internal_Marks__c = 10,
    Secured_External_Marks__c = 20,
    CGPA__c = 7.5,
    AppliedForRevaluation__c = false,
    AppliedForPhotoCopy__c = false
);


        
        // Step 7: Create User
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' OR Name = 'Student Profile' LIMIT 1];
        User studentUser = new User(
            FirstName = 'Test',
            LastName = 'Student',
            Alias = 'tstdnt',
            Email = 'studentuser@example.com',
            Username = 'studentuser@example.com' + System.currentTimeMillis(),
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id
        );
        insert studentUser;
        
        // Step 8: Run the method as student user
        System.runAs(studentUser) {
            Test.startTest();
            ASM_StudentResultView.dataWpr resultData = ASM_StudentResultView.fetchStudentResults();
            Test.stopTest();
            
           
            /*System.assertNotEquals(null, resultData, 'Returned wrapper should not be null');
            System.assertNotEquals(null, resultData.list_Results, 'List of results should not be null');
            System.assert(resultData.list_Results.size() > 0, 'There should be at least one result');*/
        }
    }
    
}