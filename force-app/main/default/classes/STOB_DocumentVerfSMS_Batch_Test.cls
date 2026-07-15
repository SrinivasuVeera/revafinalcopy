@isTest
public class STOB_DocumentVerfSMS_Batch_Test 
{
    public static testMethod void STOB_DocVerifySMS()
    {
        string houseHoldRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Recordtypeid = houseHoldRecType;
        Insert objAcc;
        
        string studRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;
        objcon.Nationality__c ='Indian';
        objCon.RecordTypeId = studRecordType;
        objCon.Student_Status__c = 'Pursuing';
        Insert objCon;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.Term_Number__c = 1;
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon.id;
        objProgEnrlmt.hed__Eligible_to_Enroll__c=true;
        objProgEnrlmt.hed__Start_Date__c = system.today();
        objProgEnrlmt.hed__End_Date__c = system.today();
        objProgEnrlmt.hed__Admission_Date__c = system.today();
        objProgEnrlmt.Program_Enrollment_Status__c = 'Pending';
        objProgEnrlmt.hed__Admission_Date__c = system.today()-5;
        objProgEnrlmt.Semester__c = obj_Term.id;
        insert objProgEnrlmt;
        
        List<hed__Program_Enrollment__c> lst_ProgrmEnrol = New List<hed__Program_Enrollment__c>();
        lst_ProgrmEnrol.add(objProgEnrlmt);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        STOB_DocumentVerfSMS_Batch STOBBstch = new STOB_DocumentVerfSMS_Batch();
        database.executeBatch(STOBBstch);
        Test.stopTest();
        system.assertequals(objProgEnrlmt.Program_Enrollment_Status__c,'Pending');
    }
}