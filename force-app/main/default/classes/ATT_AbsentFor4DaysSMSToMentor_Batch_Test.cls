@isTest
public class ATT_AbsentFor4DaysSMSToMentor_Batch_Test 
{
    public static testMethod void AbsentFor4DaysSMS()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = ATT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = ATT_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAcc.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        objCon.Student_Status__c = 'Pursuing';
         objCon.Active__c = True;
        insert objcon;
               
        hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        obj_Cour.hed__Course_ID__c ='123';
        obj_Cour.Category__c ='Hardcore Course';
        obj_Cour.HardCore_Sub_Type__c = 'Theory';
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        insert obj_CourOff;
        
        hed__Program_Plan__c  objProgPlan =  ATT_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;
        
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = ATT_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;
        
        
        hed__Program_Enrollment__c objProgEnroll = ATT_TestDataFactory.createProgEnrollment(objCon.id,objAcc.id);
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id; 
        objProgEnroll.hed__Start_Date__c = system.today();
        objProgEnroll.hed__End_Date__c = system.today()+2;
        objProgEnroll.Classes_Attended_Last_4Days__c = 4;
        objProgEnroll.Classes_Attended_Last_4Days__c = 0.2;
        objProgEnroll.Classes_Conducted_Last_4Days__c = 1;
        objProgEnroll.SRN_Number__c = 'Test0001';
        insert objProgEnroll; 
        
        List<hed__Program_Enrollment__c> hedProgEnrol = New List<hed__Program_Enrollment__c>();
        hedProgEnrol.add(objProgEnroll);
        
        set<id> set_ContIds = New set<id>();
        set_ContIds.add(objProgEnroll.hed__Contact__c);
        
        string MentorRcdType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mentee').getRecordTypeId();
        Case objCase = New Case();
        //objCase.Id = 'Test5000w0';
        objCase.ContactId = objCon.id;
        objCase.Mentor__c = objCon.id;
        objCase.RecordTypeId =  MentorRcdType;
        Insert objCase;
        
        Map<id, Case> mapCase = New Map<id, Case>();
        mapCase.put(objCase.ContactId, objCase);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        ATT_AbsentFor4DaysSMSToMentor_Batch AbsFor4Days = new ATT_AbsentFor4DaysSMSToMentor_Batch();
        database.executeBatch(AbsFor4Days);
        Test.stopTest();
    }
}