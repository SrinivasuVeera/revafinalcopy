@isTest
public class TestrveExaminationVerticalHeadClass {
    
    @Testsetup
    public static void createData(){
        Account acc = ASM_TestDataFactory.createAcc(1);
        acc.recordtypeid = [Select Id from RecordType where sobjectType='Account' and developername='University_Department' limit 1].id;
        insert acc;
        RecordType Rt = [Select Id from RecordType where sobjectType='Hed__Term__c' and developername='Semester' limit 1];
        Hed__Term__c ParentTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert parentTerm;
        Hed__Term__c childTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert childTerm;
        childTerm.hed__Parent_Term__c = ParentTerm.id;
        update childTerm;
        hed__Course__c course = ASM_TestDataFactory.CreateCourse(1,acc.id,'Hardcore Course','Theory');
        course.SEE_Conducted_Marks__c = 12;
        insert course;
        hed__Course_Offering__c courseoffering = ASM_TestDataFactory.createCourseOffering('BioInformatics',
                                                                                          childTerm.Id, course.id);
        insert courseoffering;
        Contact con = new Contact();
        con.Active__c = true;
        con.lastname = 'test';
        insert con;
        
        List<hed__Course_Enrollment__c>courseEnrollmentlist = new List<hed__Course_Enrollment__c>();
        for(integer i=0;i<3;i++){
            hed__Course_Enrollment__c courseEnrollment = ASM_testDataFactory.createCourseEnrollment(con.id,courseoffering.id);
            courseEnrollmentlist.add(courseEnrollment);
        }
        insert courseEnrollmentlist;
        
        List<IA_Marks__c>IAMarksList = new List<IA_Marks__c>();
        //  for(integer i=0;i<courseEnrollmentlist.size();i++){
        IA_Marks__c IaMark = ASM_testDataFactory.createIAMarks(courseEnrollmentlist[0].id, courseoffering.id, 'IA1');
        //      IAMarksList.add(IaMark);
        //   }
        insert IAMark;
        System.debug('IAMark=> '+IAMark);
    }
    
    @isTest
    public static void testFetchRelatableProgram(){
        rveExaminationVerticalHeadFreezeClass.getRelatedProgramBatch();
    }
    
    @isTest
    public static void testFetchSemester(){
        rveExaminationVerticalHeadFreezeClass.getRelatedSemester((ASM_TestDataFactory.createProgramPlan('ProgramR')).id);
    }
    
    @isTest
    public static void testFetchCourseEnrollment(){
        Account acc = ASM_TestDataFactory.createAcc(1);
        RecordType Rt = [Select Id from RecordType where sobjectType='Hed__Term__c' and developername='Semester' limit 1];
        rveExaminationVerticalHeadFreezeClass.getCourseEnrollments((ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id)).id);
    }
    
    @isTest
    public static void testFetchCourseWiseIAMarks(){
        Contact con = [Select Id from Contact where LastName = 'test' limit 1];
        hed__Course_Enrollment__c courseoffering = [Select Id from hed__Course_Enrollment__c where hed__Contact__r.lastname='test' limit 1];
        rveExaminationVerticalHeadFreezeClass.getCourseWiseIAMarks(courseoffering.id);
    }
    
   /* @isTest
    public static void testupdateSemFreezingStatus(){
        Account acc = ASM_TestDataFactory.createAcc(1);
        acc.recordtypeid = [Select Id from RecordType where sobjectType='Account' and developername='University_Department' limit 1].id;
        insert acc;
        RecordType Rt = [Select Id from RecordType where sobjectType='Hed__Term__c' and developername='Semester' limit 1];
        Hed__Term__c ParentTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert parentTerm;
        Hed__Term__c childTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert childTerm;
        childTerm.hed__Parent_Term__c = ParentTerm.id;
        update childTerm;
        hed__Course__c course = ASM_TestDataFactory.CreateCourse(1,acc.id,'Hardcore Course','Theory');
        course.SEE_Conducted_Marks__c = 12;
        insert course;
        hed__Course_Offering__c courseoffering = ASM_TestDataFactory.createCourseOffering('BioInformatics',
                                                                                          childTerm.Id, course.id);
        insert courseoffering;
        System.debug('courseoffering=> '+courseoffering);
        rveExaminationVerticalHeadFreezeClass.updateSemFreezingStatus(childTerm.id);
    } */
    
    @isTest
    public static void testupdateExamVerticalHeadStatusForSemester(){
        Account acc = ASM_TestDataFactory.createAcc(1);
         acc.recordtypeid = [Select Id from RecordType where sobjectType='Account' and developername='University_Department' limit 1].id;
        insert acc;
        RecordType Rt = [Select Id from RecordType where sobjectType='Hed__Term__c' and developername='Semester' limit 1];
        Hed__Term__c ParentTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert parentTerm;
        Hed__Term__c childTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert childTerm;
        childTerm.hed__Parent_Term__c = ParentTerm.id;
        update childTerm;
        
        hed__Course__c course = ASM_TestDataFactory.CreateCourse(1,acc.id,'Hardcore Course','Theory');
        course.SEE_Conducted_Marks__c = 12;
        insert course;
        hed__Course_Offering__c courseoffering = ASM_TestDataFactory.createCourseOffering('BioInformatics',
                                                                                          childTerm.Id, course.id);
        insert courseoffering;
        Contact con = new Contact();
        con.Active__c = true;
        con.lastname = 'test';
        insert con;
        
        
         List<hed__Course_Enrollment__c>courseEnrollmentlist = new List<hed__Course_Enrollment__c>();
        Recordtype Rt2 = [Select Id from RecordType where SobjectType='hed__Course_Enrollment__c' AND developername = 'Faculty'];
        for(integer i=0;i<3;i++){
            hed__Course_Enrollment__c courseEnrollment = ASM_testDataFactory.createCourseEnrollment(con.id,courseoffering.id);
            courseEnrollment.recordtypeid = Rt2.id;
            courseEnrollmentlist.add(courseEnrollment);
        }
        insert courseEnrollmentlist;
        
        for(hed__Course_Enrollment__c conr: courseEnrollmentlist){
            conr.Section__c = childTerm.id;
        }
        update courseEnrollmentlist;
        
        Profile ExamHeadProf = [Select Id from profile where Name = 'Examination Vertical Head'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = ExamHeadProf.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Examuser@testorg.com');
        System.runAs(u){
        rveExaminationVerticalHeadFreezeClass.updateExamVerticalHeadStatusForSemester(parentTerm.id, 'Freeze');
        }
    }
    
    @isTest
    public static void testupdateFacultyEligibility(){
        Contact con = [Select Id from Contact where LastName = 'test' limit 1];
        hed__Course_Enrollment__c courseoffering = [Select Id from hed__Course_Enrollment__c where hed__Contact__r.lastname='test' limit 1];
        rveExaminationVerticalHeadFreezeClass.updateFacultyEligibility(courseoffering.id,true,'FREEZE');
    }
    @isTest
    public static void testBULKupdateFacultyEligibility(){
        Contact con = [Select Id from Contact where LastName = 'test' limit 1];
        hed__Course_Enrollment__c courseoffering = [Select Id from hed__Course_Enrollment__c where hed__Contact__r.lastname='test' limit 1];
        rveExaminationVerticalHeadFreezeClass.updateFacultyEligibility(courseoffering.id,true,'VERIFY');
    }
    @isTest
    public static void testupdateFacultyEligibilityesle(){
        Contact con = [Select Id from Contact where LastName = 'test' limit 1];
        List<hed__Course_Enrollment__c> courseEnrollments = [
        SELECT Id 
        FROM hed__Course_Enrollment__c 
        WHERE hed__Contact__r.LastName = 'test' 
        LIMIT 50 
    ];
        List<Id> courseEnrollmentIds = new List<Id>();
    for (hed__Course_Enrollment__c ce : courseEnrollments) {
        courseEnrollmentIds.add(ce.Id);
    }
     Test.startTest();
        rveExaminationVerticalHeadFreezeClass.bulkUpdateVerification(courseEnrollmentIds, true);
    Test.stopTest();
    }
    @isTest
    public static void testFetchSemesterIAMarks(){
        Account acc = ASM_TestDataFactory.createAcc(1);
        acc.recordtypeid = [Select Id from RecordType where sobjectType='Account' and developername='University_Department' limit 1].id;
        insert acc;
        RecordType Rt = [Select Id from RecordType where sobjectType='Hed__Term__c' and developername='Semester' limit 1];
        Hed__Term__c ParentTerm = ASM_TestDataFactory.createTerm('Sem-1',acc.id,Rt.Id);
        insert parentTerm;   
        
        hed__Course__c course = ASM_TestDataFactory.CreateCourse(1,acc.id,'Hardcore Course','Theory');
        course.SEE_Conducted_Marks__c = 12;
        insert course;     
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,acc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.Active__c = true;
        ObjCon.Employee_Number__c ='EP1234';
        ObjCon.Email='test@gmail.com';
        Insert ObjCon;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',acc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Parent_Term__c = ParentTerm.Id;
        insert objTerm;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',acc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Parent_Term__c = objTerm.Id;
        Insert obj_Term;
        
        Account schAcc = ASM_TestDataFactory.createSchoolAcc(1);
        Insert schAcc;
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', parentTerm.Id, course.id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = parentTerm.Id;
        obj_Cour_Off.hed__Term__c = objTerm.Id;
        obj_Cour_Off.Offered_By_School__c = schAcc.Id;
        //obj_Cour_Off.Publish_to_Students__c = true;
        insert obj_Cour_Off;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(objCon.id,acc.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Semester__c = parentTerm.id;
        insert objProgEnroll; 
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        obj_Cour_Enroll.Section__c = objTerm.Id;
        Insert obj_Cour_Enroll;
        
        IA_Marks__c iam1 = ASM_TestDataFactory.createIAMarks(obj_Cour_Enroll.Id,obj_Cour_Off.Id,'IA1');
        ASM_IAMarksTrgHandler.rollupCountUpdate = false;
        iam1.Course_Connection__c = obj_Cour_Enroll.Id;
        //iam.Faculty_Course_Connection__c = prfCrsCon.Id;
        Insert iam1;
        
        IA_Marks__c iam2 = ASM_TestDataFactory.createIAMarks(obj_Cour_Enroll.Id,obj_Cour_Off.Id,'IA2');
        ASM_IAMarksTrgHandler.rollupCountUpdate = false;
        iam2.Course_Connection__c = obj_Cour_Enroll.Id;
        //iam.Faculty_Course_Connection__c = prfCrsCon.Id;
        Insert iam2;
        
        //hed__Course_Enrollment__c courseenrollment = [Select Id from hed__Course_Enrollment__c where hed__Contact__r.lastname='test' limit 1];
        rveExaminationVerticalHeadFreezeClass.getSemesterIAMarks(ParentTerm.id);
    }
     @isTest
    public static void testUpdateStatus(){
        Contact con = [Select Id from Contact where LastName = 'test' limit 1];
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Faculty_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = new hed__Course_Enrollment__c();
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;        
        obj_Cour_Enroll.hed__Contact__c= con.id;
        obj_Cour_Enroll.IA_Marks_Entry_Status__c = 'Not Entered';
        Insert obj_Cour_Enroll;
        
        rveExaminationVerticalHeadFreezeClass.updateStatus(obj_Cour_Enroll.id,'Open');
    }
    
}