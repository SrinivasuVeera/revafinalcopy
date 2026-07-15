@isTest
public class ASM_IamProfListViewTest {
	@TestSetup
    static void setup() {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        /*Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.OwnerId = Userinfo.getUserId();
        ObjCon.Active__c = true;
        Insert ObjCon; */
        
        string recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Professor).getRecordTypeId();
        Contact objcon = MSTR_TestDataFactory.createContact('test2 Contact2');
        objcon.AccountId = objAcc.id;
        objcon.FirstName  = 'Test2 Contact2';
        objcon.LastName  ='C';
        objcon.Employee_Number__c ='EP1237';
        objcon.RecordTypeId = recordTypeId;
        objcon.Active__c = true;
        objcon.hed__WorkEmail__c  = 'test16767233@ex.com';
        insert objcon;
        
        Contact prfCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        prfCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        prfCon.SRN_Number__c = '';
        //Insert prfCon;
        
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
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, list_Crs[0].id);
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
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c = objTermParent.Id;
        Insert obj_Cour_Enroll;
        
        Id enrollRecTypeId1 = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll1 = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll1.RecordTypeId=enrollRecTypeId1;
        obj_Cour_Enroll1.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll1.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll1.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll1.Section__c = objTermParent.Id;
        Insert obj_Cour_Enroll1;
        
        IA_Marks__c iam = ASM_TestDataFactory.createIAMarks(obj_Cour_Enroll.Id,obj_Cour_Off.Id,'IA1');
        if(ASM_IAMarksTrgHandler.rollupCountUpdate == false)
            Insert iam;
    }
    @IsTest
    static void exe(){
        Test.startTest();
        ASM_IamProfListView.fetchData('IA1');
        Test.stopTest();
    } 
    
    @IsTest
    static void exe2(){
        Test.startTest();
        ASM_IamProfListView.fetchDataSchoolDirector('IA1');
        Test.stopTest();
    }
    
    @isTest
    static void testcheckFreezingStatus(){
        ASM_IamProfListView.checkFreezingStatus('IA1');
    }
    
    @isTest
    static void testupdateFreezingStatus(){
        hed__Course_Enrollment__c courseoffering = [Select id from hed__Course_Enrollment__c where hed__Contact__r.FirstName = 'Test2 Contact2' limit 1];
        ASM_IamProfListView.updateFreezingStatus(courseoffering.id);
    }
    @isTest
    static void testgetstudents(){
        Contact con = [Select Id from Contact where LastName = 'C' limit 1];
        hed__Course_Enrollment__c courseEnrollment = [Select id,hed__Course_Offering__c,Section__c from hed__Course_Enrollment__c where hed__Contact__r.LastName = 'c' limit 1];
        hed__Course_Enrollment__c objCourOff = [Select id,hed__Course_Offering__c,Section__c from hed__Course_Enrollment__c where hed__Course_Offering__c = :courseEnrollment.hed__Course_Offering__c and RecordType.Name = 'Student' limit 1];
        
         IA_Marks__c iaMark = new IA_Marks__c();        
        iaMark.Course_Connection__c = objCourOff.id;
        iaMark.Course_Offering__c = objCourOff.hed__Course_Offering__c;
        iaMark.IA_Type__c = 'IA1';
        insert iaMark;
        

        // Create another IA Mark for IA2
        IA_Marks__c iaMark2 = new IA_Marks__c();        
        iaMark2.Course_Connection__c = objCourOff.id;
        iaMark2.Course_Offering__c = objCourOff.hed__Course_Offering__c;
        iaMark2.IA_Type__c = 'IA2';
        insert iaMark2;
        
       
        ASM_IamProfListView.getCourseWiseIAMarks(courseEnrollment.id);       
        
    }
    @isTest
static void testPDFGenerationLogic() {
    // Retrieve a faculty course enrollment record created in the setup
    hed__Course_Enrollment__c facultyCrsCon = [SELECT Id, hed__Course_Offering__r.hed__Course__r.Name, Section__r.Name 
                                               FROM hed__Course_Enrollment__c 
                                               WHERE RecordType.Name = 'Faculty' 
                                               AND hed__Contact__r.FirstName = 'Test2 Contact2' 
                                               LIMIT 1];

    // Retrieve a student course enrollment for the same course offering
    hed__Course_Enrollment__c studentCrsCon = [SELECT Id, hed__Course_Offering__c, Section__c 
                                               FROM hed__Course_Enrollment__c 
                                               WHERE RecordType.Name = 'Student' 
                                               AND hed__Course_Offering__c = :facultyCrsCon.hed__Course_Offering__c 
                                               LIMIT 1];

    // Create IA marks for the student
    IA_Marks__c iaMark1 = new IA_Marks__c();
    iaMark1.Course_Connection__c = studentCrsCon.Id;
    iaMark1.Course_Offering__c = studentCrsCon.hed__Course_Offering__c;
    iaMark1.IA_Type__c = 'IA1';
    iaMark1.Total_Secured_Marks_New__c = 40;    
    insert iaMark1;

    IA_Marks__c iaMark2 = new IA_Marks__c();
    iaMark2.Course_Connection__c = studentCrsCon.Id;
    iaMark2.Course_Offering__c = studentCrsCon.hed__Course_Offering__c;
    iaMark2.IA_Type__c = 'IA2';
    iaMark2.Total_Secured_Marks_New__c = 45;    
    insert iaMark2;

    Test.startTest();
    // Simulate the Visualforce page context by setting the courseId parameter
    ApexPages.currentPage().getParameters().put('courseId', facultyCrsCon.Id);

    // Instantiate the controller (this will invoke the constructor)
    ASM_IamProfListView controller = new ASM_IamProfListView();

    Test.stopTest();

    // Verify the results
    System.assertNotEquals(null, controller.studentMarks, 'studentMarks list should be populated');
    System.assertEquals(1, controller.studentMarks.size(), 'There should be exactly one student record in studentMarks');
    
    ASM_IamProfListView.PDFMarksWrapper pdfWrapper = controller.studentMarks[0];
    System.assertEquals('1', pdfWrapper.serialNumber, 'Serial number should be 1');
    System.assertEquals('Test2 Contact2 C', pdfWrapper.studentName, 'Student name should match the contact name');
    System.assertEquals(null, pdfWrapper.srnNumber, 'SRN number should match the IA marks record');
    System.assertEquals('40', pdfWrapper.ia1Marks, 'IA1 marks should be 40');
    System.assertEquals('45', pdfWrapper.ia2Marks, 'IA2 marks should be 45');
    System.assertEquals('85', pdfWrapper.totalMarks, 'Total marks should be 85 (40 + 45)');

    //System.assertEquals(facultyCrsCon.hed__Course_Offering__r.hed__Course__r.Name, controller.courseName, 'Course name should match');
    System.assertEquals(facultyCrsCon.Section__r.Name, controller.sectionName, 'Section name should match');
}
}