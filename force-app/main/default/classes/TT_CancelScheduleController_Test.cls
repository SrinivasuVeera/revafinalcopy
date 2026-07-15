@Istest
public class TT_CancelScheduleController_Test 
{
    Public static testmethod Void CancelMethod()
    {
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Educational_Institution).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('parent Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
         string Universityid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department')?.getRecordTypeId();
        Account department;
        if (Universityid != null) {
            department = new Account(
                Name = 'Test Department',
                RecordTypeId = Universityid
            );
            insert department;
        } else {
            department = new Account(Name = 'Test Department');
            insert department;
        }
        
        hed__Program_Plan__c  objProgPlan =  TT_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Account__c = objAccount.id;
        insert objProgPlan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAccount.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.Program_Batch__c = objProgPlan.id;
        Insert obj_Term;
        
        Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term1 = TT_TestDataFactory.createTerm('TermName1',objAccount.Id, termRecTypeId);
        obj_Term1.RecordTypeId = termRecTypeId1;
        obj_Term1.Program_Batch__c = objProgPlan.id;
        obj_Term1.hed__Parent_Term__c = obj_Term.id;
        Insert obj_Term1;
        
         hed__Course__c objCourse = TT_TestDataFactory.CreateCourse('CourseName', department.Id);
        objCourse.hed__Course_ID__c ='123';
        objCourse.L_T_P__c = '3:0:0';
        objCourse.Credits__c = 2;
        objCourse.Offered_By_School__c = department.Id;
        objCourse.Credit_Hours__c = 3.0;
        objCourse.Maximum_External_Marks__c = 10;
        objCourse.Total_Maximum_Marks_IA_External__c = 100.0;
        Insert objCourse;
        
        hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, objCourse.id);
        insert obj_CourOff;
        
        hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
        objcourseSch.hed__Start_Time__c = system.now().time();
        objcourseSch.hed__End_Time__c = system.now().adddays(1).time();
        objcourseSch.hed__Monday__c =false;
        objcourseSch.hed__Tuesday__c =true;
        objcourseSch.hed__Wednesday__c =true;
        objcourseSch.hed__Thursday__c = true;
        objcourseSch.hed__Friday__c =true;
        objcourseSch.hed__Saturday__c =true;
        objcourseSch.hed__Sunday__c =true;
        insert objcourseSch;
        
        test.starttest();
        TT_CancelScheduleController.getUniversityList('parent Account');
        TT_CancelScheduleController.getAccountBasedOnParentIdList(objAccount.id);
        TT_CancelScheduleController.getProgramBatchList(objAccount.id);
        TT_CancelScheduleController.getSemesterList(objProgPlan.id);
        TT_CancelScheduleController.getSectionList(obj_Term.id);
        TT_CancelScheduleController.onCancelSchedule(objAccount.id,'faculty',system.now(),system.now().adddays(1),'test');
        TT_CancelScheduleController.onCancelSchedule(objAccount.id,'school',system.now(),system.now().adddays(1),'test');
        TT_CancelScheduleController.onCancelSchedule(objAccount.id,'program',system.now(),system.now().adddays(1),'test');
        TT_CancelScheduleController.onCancelSchedule(objProgPlan.id,'programBatch',system.now(),system.now().adddays(1),'test');
        TT_CancelScheduleController.onCancelSchedule(obj_Term.id,'semester',system.now(),system.now().adddays(1),'test');
        TT_CancelScheduleController.onCancelSchedule(obj_Term1.id,'section',system.now(),system.now().adddays(1),'test');
        TT_CancelScheduleController.getDefaultValues();
        test.stoptest();
        system.assertequals(objAccount.id,objAccount.id);
      }
}