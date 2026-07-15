@isTest
public class ASM_IAMarksFomSfAPITest {
    @TestSetup
    static void setup() {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.hed__WorkEmail__c = 'hhhh@gmail.com';
        Insert ObjCon;        
        
        
        Mandatory_Courses_Category_Values__c objMan = new Mandatory_Courses_Category_Values__c();
        objMan.Name = 'Hardcore Course';
        insert objMan;
        
        List<hed__Course__c> list_Crs = new List<hed__Course__c>();
        
        hed__Course__c hardcore = ASM_TestDataFactory.CreateCourse(1, objAcc.Id, 'Hardcore Integrated Course');
        hardcore.hed__Course_ID__c = 'SUB01';
        hardcore.SEE_Conducted_Marks__c = 10;  
        hardcore.Total_Maximum_Marks_IA_External__c = 100; 
        hardcore.L_T_P__c = '2:2:0';
        list_Crs.add(hardcore);
         
        hed__Course__c practical = ASM_TestDataFactory.CreateCourse(2, objAcc.Id, 'Practical/Term Work');
        practical.SEE_Conducted_Marks__c = 25;  
        practical.Total_Maximum_Marks_IA_External__c = 50;
        practical.L_T_P__c = '2:2:0';
        list_Crs.add(practical);
        
        hed__Course__c proj = ASM_TestDataFactory.CreateCourse(3, objAcc.Id, 'Hardcore Course');
        proj.HardCore_Sub_Type__c = 'Project';
        proj.SEE_Conducted_Marks__c = 10;
        proj.Total_Maximum_Marks_IA_External__c = 75;
        proj.L_T_P__c = '2:2:0';
        list_Crs.add(proj);
        
        insert list_Crs;
        
        hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c = 20;
        objProgPlan.Intake_Per_Section__c = 5;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        ObjCon.Active_Semester__c = objTerm.Id;
        
        hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTermParent.hed__Parent_Term__c = objTerm.id;
        insert objTermParent;
        
        hed__Program_Enrollment__c objProgEnroll = ASM_TestDataFactory.createProgEnrollment(ObjCon.Id,objAcc.Id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c = objProgPlan.id; 
        objProgEnroll.Application_Number__c = '123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll; 
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.Program_Batch__c = objProgPlan.id;
        Insert obj_Term;
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem = ASM_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId = recordTypeName;
        obj_Stud_Sem.Active__c = true; 
        obj_Stud_Sem.Program_Enrollment__c = objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.End_Date__c = system.today();
        obj_Stud_Sem.Section__c = objTermParent.id;
        obj_Stud_Sem.Student_Batch__c = obj_Term.id;
        insert obj_Stud_Sem;
        
        string recordTypeName1 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud_Sem1 = ASM_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName1);
        obj_Stud_Sem1.RecordTypeId = recordTypeName1;
        obj_Stud_Sem1.Active__c = true;
        obj_Stud_Sem1.Program_Enrollment__c = objProgEnroll.id;
        obj_Stud_Sem1.Start_Date__c = system.today();
        obj_Stud_Sem1.End_Date__c = system.today();
        obj_Stud_Sem1.Section__c = objTermParent.id;
        obj_Stud_Sem1.Student_Batch__c = obj_Term.id;
        insert obj_Stud_Sem1;   
        
        string recordTypeName22 = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();
        
        Student_Semester_Mapping__c obj_Stud = ASM_TestDataFactory.createStudenttermMapping('StuTerm', recordTypeName22);
        obj_Stud.RecordTypeId = recordTypeName22;
        obj_Stud.Active__c = true; 
        obj_Stud.Program_Enrollment__c = objProgEnroll.id;
        obj_Stud.Start_Date__c = system.today();
        obj_Stud.End_Date__c = system.today();
        obj_Stud.Section__c = objTermParent.id;
        obj_Stud.Student_Batch__c = obj_Term.id;
        insert obj_Stud;
        
        Account schAcc = ASM_TestDataFactory.createSchoolAcc(1);
        Insert schAcc;
        
        List<hed__Course_Offering__c> list_crsff = new List<hed__Course_Offering__c>();
        for(hed__Course__c crs : list_Crs){
            hed__Course_Offering__c obj_Cour_Off = ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, crs.Id);
            obj_Cour_Off.Category__c = 'Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = obj_Term.Id;
            obj_Cour_Off.hed__Term__c = objTermParent.Id;
            obj_Cour_Off.Offered_By_School__c = schAcc.Id;
            list_crsff.add(obj_Cour_Off);
        }
        
        insert list_crsff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        List<hed__Course_Enrollment__c> list_crsCon = new List<hed__Course_Enrollment__c>();
        for(hed__Course_Offering__c cOf : list_crsff){
            hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.Id, cOf.Id);
            obj_Cour_Enroll.RecordTypeId = enrollRecTypeId;
            obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.Id;
            obj_Cour_Enroll.hed__Course_Offering__c = cOf.Id;
            obj_Cour_Enroll.hed__Contact__c = ObjCon.Id;
            obj_Cour_Enroll.Section__c = objTermParent.Id;
            list_crsCon.add(obj_Cour_Enroll);
        }
        
        Insert list_crsCon;
        
        List<IA_Marks__c> list_Iams = new List<IA_Marks__c>();
        for(integer i = 0; i < 3; i++){
            IA_Marks__c iam = new IA_Marks__c();
            iam.Course_Connection__c = list_crsCon[i].Id;
            iam.Course_Offering__c = list_crsff[i].Id;
            iam.IA_Type__c = 'IA1';
            iam.Semester__c = objTerm.Id;
            iam.Theory_Secured_Marks__c = 1;
            iam.Seminar_Secured_Marks__c = 1;
            iam.Quiz_Secured_marks__c = 1;
            iam.Analysis_and_Synthesis_Secured_Marks__c = 1;
            iam.Continuous_Learning_Secured_Marks__c = 1;
            iam.Ethical_Attitude_Secured_Marks__c = 1;
            iam.Independent_Learning_Secured_Marks__c = 1;
            iam.Literature_Survey_Secured_Marks__c = 1;
            iam.Selection_of_Topic_Secured_Marks__c = 1;
            iam.Oral_Presentation_Secured_Marks__c = 1;
            iam.Report_Writing_Secured_Marks__c = 1;
            iam.Knowledge_of_Exercise_Secured_Marks__c = 1;
            iam.Execution_of_Exercise_Secured_Marks__c = 1;
            iam.Description_of_Experiment_Secured_Mark__c = 1;
            iam.Viva_Voce_Practical_Secured_Marks__c = 1;
            iam.Punctuality_Secured_Marks__c = 1;
            iam.Results_Secured_Marks__c = 1;
            iam.Total_Secured_Marks_New__c=1.5;
          //  iam.Maximum_Internal_Marks_Logisys__c=0;
            
            list_Iams.add(iam);
        }
        insert list_Iams;
    }
    
    @isTest
    static void testSendIAMarksSuccess() {
        List<IA_Marks__c> scope = [SELECT Id FROM IA_Marks__c];
        Set<Id> set_Ids = new Set<Id>();
        for(IA_Marks__c iam : scope){
            set_Ids.add(iam.Id);
        }

        ASM_MockCallout TestMock = new ASM_MockCallout(200, '{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"S"}]}}', 'Success');
        Test.setMock(HttpCalloutMock.class, TestMock);

        Test.startTest();
        ASM_IAMarksFomSfAPI.sendIAMarks_future(set_Ids, 'I');
        Test.stopTest();
    }

    @isTest
    static void testSendIAMarksPartial() {
        List<IA_Marks__c> scope = [SELECT Id FROM IA_Marks__c];
        Set<Id> set_Ids = new Set<Id>();
        for(IA_Marks__c iam : scope){
            set_Ids.add(iam.Id);
        }

        ASM_MockCallout TestMock = new ASM_MockCallout(200, '{"status":"partial","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"P"}]}}', 'Partial');
        Test.setMock(HttpCalloutMock.class, TestMock);

        Test.startTest();
        ASM_IAMarksFomSfAPI.sendIAMarks_future(set_Ids, 'I');
        Test.stopTest();
    }

    @isTest
    static void testSendIAMarksFailure() {
        List<IA_Marks__c> scope = [SELECT Id FROM IA_Marks__c];
        Set<Id> set_Ids = new Set<Id>();
        for(IA_Marks__c iam : scope){
            set_Ids.add(iam.Id);
        }

        ASM_MockCallout TestMock = new ASM_MockCallout(200, '{"status":"failure","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}', 'Failed');
        Test.setMock(HttpCalloutMock.class, TestMock);

        Test.startTest();
        ASM_IAMarksFomSfAPI.sendIAMarks_future(set_Ids, 'I');
        Test.stopTest();
    }

    @isTest
    static void testSendIAMarksException() {
        List<IA_Marks__c> scope = [SELECT Id FROM IA_Marks__c];
        Set<Id> set_Ids = new Set<Id>();
        for(IA_Marks__c iam : scope){
            set_Ids.add(iam.Id);
        }

        ASM_MockCallout TestMock = new ASM_MockCallout(500, '', 'Exception');
        Test.setMock(HttpCalloutMock.class, TestMock);

        Test.startTest();
        try {
            ASM_IAMarksFomSfAPI.sendIAMarks_future(set_Ids, 'I');
        } catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testmapBaseParams(){
        IA_Marks__c IaMarks = [Select Id,SRN_Number__c,Program_Code__c,Program__c,Course_Connection__r.Semester__c,Course_Code__c,Course_Name__c from IA_Marks__c where IA_Type__c='IA1' limit 1];
        ASM_IAMarksFomSfAPI.mapBaseParams(IaMarks,'I','U',20,25);
    }
}