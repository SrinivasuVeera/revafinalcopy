@isTest
global class ASM_UpdateCourseConnectionBatch_Test
{
    global static testmethod void TestCourseMethod()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = ASM_TestDataFactory.createAcc(1); 
        objAcc.RecordTypeId = AccountRecTypeId; 
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = ASM_TestDataFactory.createContact(1,objAcc.Id);
        ObjCon.RecordTypeId = ContactRecTypeId;
        Insert ObjCon;
        
        //Create Student User
        User student = ASM_TestDataFactory.createStudentUser('editest9');
        student.ContactId = ObjCon.Id;
        System.runAs(otherAdmin){
            //Insert student;
        }
        
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
        objProgEnroll.Section_Change_Date__c = system.today();
        objProgEnroll.Section__c = objTermParent.id;
        insert objProgEnroll; 
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', obj_Term.Id, list_Crs[0].id);
        obj_Cour_Off.Category__c ='Hardcore Course'; 
        obj_Cour_Off.hed__Term__c = obj_Term.Id;
        obj_Cour_Off.hed__Term__c = objTermParent.Id;
        insert obj_Cour_Off;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
        
        hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_Cour_Off.Id);
        obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
        obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
        obj_Cour_Enroll.hed__Contact__c= ObjCon.id;
        Insert obj_Cour_Enroll;
        
        Batch_Failure_Emails__c bfm = new Batch_Failure_Emails__c();
        bfm.Name= 'Assessment Module';
        bfm.Email_Ids__c ='chetan@epeoplebc.com';
        insert bfm;
        Test.startTest();
        
        Database.executeBatch(new ASM_UpdateCourseConnectionBatch());
        ASM_UpdateCourseConnectionBatch ASM =  new ASM_UpdateCourseConnectionBatch();
        String Sch = '0 0 * * * ?';
        string jobId = system.schedule('ASM_UpdateCourseConnectionBatch', Sch, ASM);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        //BatchClass_Utility.sendBatchClassFailureMail('Assessment Module', ct.Id, 'Update Course Connection', 'Course Connection');
        Test.stopTest();
        system.assertEquals(objProgEnroll.Section_Change_Date__c,system.today());
    }
}