@isTest
public class MSTR_SemStartSMS_Batch_Test 
{
    public static testMethod void SemStartSMS()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = MSTR_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='1111111111';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test1123';
        objcon.SRN_Number__c ='1231';
        objcon.hed__WorkEmail__c  = 'test1123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objcon.Student_Status__c = 'Pursuing';
        Insert objCon; 
        
        Contact objCon1 = MSTR_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='2222222222';
        objCon1.Aadhar_Card_Number__c ='098765435612';
        objCon1.RecordTypeId = StudentRecId;
        objCon1.AccountId = objAcc.Id;
        objcon1.Application_Number__c = 'test123';
        objcon1.SRN_Number__c ='123';
        objcon1.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon1.Nationality__c ='Indian';
        objcon1.Active__c = true;
        objcon1.Student_Status__c = 'Pursuing';
        objcon1.Father__c = objcon.id;
        Insert objCon1; 
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.hed__Start_Date__c = system.today()+10;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Program_Enrollment__c objProgenroll = MSTR_TestDataFactory.createProgEnrollment(objCon1.Id,objAcc.id);
        objProgenroll.hed__Start_Date__c = system.today()-5;
        objProgenroll.hed__End_Date__c = system.today()+5;
        objProgenroll.Semester__c = objTerm.id;
        Insert objProgenroll;
        
        List<hed__Program_Enrollment__c> lst_PrgmEnrl = New List<hed__Program_Enrollment__c>();
        lst_PrgmEnrl.add(objProgenroll);
        
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        MSTR_SemStartSMS_Batch btch = new MSTR_SemStartSMS_Batch();
        database.executeBatch(btch);
        Test.stopTest();
        //system.assertEquals(objProgenroll.hed__Program_Enrollment__c,objCon1.Id); 
        
    }
    public static testMethod void SemStartSMS1()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = MSTR_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='1111111111';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test1123';
        objcon.SRN_Number__c ='1231';
        objcon.hed__WorkEmail__c  = 'test1123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objcon.Student_Status__c = 'Pursuing';
        Insert objCon; 
        
        Contact objCon1 = MSTR_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='2222222222';
        objCon1.Aadhar_Card_Number__c ='098765435612';
        objCon1.RecordTypeId = StudentRecId;
        objCon1.AccountId = objAcc.Id;
        objcon1.Application_Number__c = 'test123';
        objcon1.SRN_Number__c ='123';
        objcon1.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon1.Nationality__c ='Indian';
        objcon1.Active__c = true;
        objcon1.Student_Status__c = 'Pursuing';
        objcon1.Mother__c = objcon.id;
        Insert objCon1; 
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.hed__Start_Date__c = system.today()+10;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Program_Enrollment__c objProgenroll = MSTR_TestDataFactory.createProgEnrollment(objCon1.Id,objAcc.id);
        objProgenroll.hed__Start_Date__c = system.today()-5;
        objProgenroll.hed__End_Date__c = system.today()+5;
        objProgenroll.Semester__c = objTerm.id;
        Insert objProgenroll;
        
        List<hed__Program_Enrollment__c> lst_PrgmEnrl = New List<hed__Program_Enrollment__c>();
        lst_PrgmEnrl.add(objProgenroll);
        
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        MSTR_SemStartSMS_Batch btch = new MSTR_SemStartSMS_Batch();
        database.executeBatch(btch);
        Test.stopTest();
        //system.assertEquals(obj_AttEvent.Course_Offering_Schedule__c,objcourseSch.Id); 
        
    }
    public static testMethod void SemStartSMS2()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = MSTR_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = MSTR_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='1111111111';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test1123';
        objcon.SRN_Number__c ='1231';
        objcon.hed__WorkEmail__c  = 'test1123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objcon.Student_Status__c = 'Pursuing';
        Insert objCon; 
        
        Contact objCon1 = MSTR_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='2222222222';
        objCon1.Aadhar_Card_Number__c ='098765435612';
        objCon1.RecordTypeId = StudentRecId;
        objCon1.AccountId = objAcc.Id;
        objcon1.Application_Number__c = 'test123';
        objcon1.SRN_Number__c ='123';
        objcon1.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon1.Nationality__c ='Indian';
        objcon1.Active__c = true;
        objcon1.Student_Status__c = 'Pursuing';
        objcon1.Guardian__c = objcon.id;
        Insert objCon1; 
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.hed__Start_Date__c = system.today()+10;
        objTerm.hed__End_Date__c =  system.today()+15;
        insert objTerm;
        
        hed__Program_Enrollment__c objProgenroll = MSTR_TestDataFactory.createProgEnrollment(objCon1.Id,objAcc.id);
        objProgenroll.hed__Start_Date__c = system.today()-5;
        objProgenroll.hed__End_Date__c = system.today()+5;
        objProgenroll.Semester__c = objTerm.id;
        Insert objProgenroll;
        
        List<hed__Program_Enrollment__c> lst_PrgmEnrl = New List<hed__Program_Enrollment__c>();
        lst_PrgmEnrl.add(objProgenroll);
        
        SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
        List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        MSTR_SemStartSMS_Batch btch = new MSTR_SemStartSMS_Batch();
        database.executeBatch(btch);
        Test.stopTest();
        //system.assertEquals(obj_AttEvent.Course_Offering_Schedule__c,objcourseSch.Id); 
        
    }
}