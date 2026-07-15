@isTest
public class ATT_AttdShortageSMS_Batch_Test
{
    @TestSetup
    static void setup()    
    {  
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
        Account objAcc = ATT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        insert objAcc;
        
        string studRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = ATT_TestDataFactory.createContact('Test');
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
        
        Contact objCon1 = ATT_TestDataFactory.createContact('Test');
         objCon1.MobilePhone ='8890909090';
        objCon1.Aadhar_Card_Number__c ='098765425612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test5@reva.edu.in';
        objCon1.MobilePhone ='8933210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';
        objCon1.Father__c = objCon.id;
        Insert objCon1;
        
        Contact objCon2 = ATT_TestDataFactory.createContact('Test');
        objCon2.MobilePhone ='90770909090';
        objCon2.Aadhar_Card_Number__c ='078765435612';
        objCon2.Application_Number__c = '1232';
        objCon2.hed__WorkEmail__c='1232@reva.edu.in';
        objCon2.Email = 'test2@reva.edu.in';
        objCon2.MobilePhone ='8961210547';
        objCon2.AccountId = objAcc.id;
        objCon2.Nationality__c ='Indian';
        objCon2.RecordTypeId = studRecordType;
        objCon2.Student_Status__c = 'Pursuing';
        objCon2.Mother__c = objCon.id;
        Insert objCon2;
        
        Contact objCon3 = ATT_TestDataFactory.createContact('Test');
         objCon3.MobilePhone ='9090909090';
        objCon3.Aadhar_Card_Number__c ='090765435612';
        objCon3.Application_Number__c = '1233';
        objCon3.hed__WorkEmail__c='1233@reva.edu.in';
        objCon3.Email = 'test3@reva.edu.in';
        objCon3.MobilePhone ='8903210547';
        objCon3.AccountId = objAcc.id;
        objCon3.Nationality__c ='Indian';
        objCon3.RecordTypeId = studRecordType;
        objCon3.Student_Status__c = 'Pursuing';
        objCon3.Guardian__c = objCon.id;
        Insert objCon3;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();        
        hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today();
        obj_Term.hed__End_Date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt =  ATT_TestDataFactory.createProgEnrollment(objCon1.id, objAcc.Id);
        objProgEnrlmt.hed__Start_Date__c = system.today();
        objProgEnrlmt.hed__End_Date__c = system.today();
        objProgEnrlmt.Total_Classes_Attended__c = 0.6;
        objProgEnrlmt.Total_Classes_Completed__c = 1;
        objProgEnrlmt.Semester__c = obj_Term.id;
        insert objProgEnrlmt;
        
        hed__Program_Enrollment__c objProgEnrlmt1 =  ATT_TestDataFactory.createProgEnrollment(objCon2.id, objAcc.Id);
        objProgEnrlmt1.hed__Start_Date__c = system.today();
        objProgEnrlmt1.hed__End_Date__c = system.today();
        objProgEnrlmt1.Total_Classes_Attended__c = 0.6;
        objProgEnrlmt1.Total_Classes_Completed__c = 1;
        objProgEnrlmt1.Semester__c = obj_Term.id;
        insert objProgEnrlmt1;
        
        hed__Program_Enrollment__c objProgEnrlmt2 =  ATT_TestDataFactory.createProgEnrollment(objCon3.id, objAcc.Id);
        objProgEnrlmt2.hed__Start_Date__c = system.today();
        objProgEnrlmt2.hed__End_Date__c = system.today();
        objProgEnrlmt2.Total_Classes_Attended__c = 0.6;
        objProgEnrlmt2.Total_Classes_Completed__c = 1;
        objProgEnrlmt2.Semester__c = obj_Term.id;
        insert objProgEnrlmt2;     
    }
    static testmethod void exe()
    {
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        ATT_AttdShortageSMS_Batch ATTShortage = new ATT_AttdShortageSMS_Batch();
        database.executeBatch(ATTShortage);
        Test.stopTest();
    } 
}