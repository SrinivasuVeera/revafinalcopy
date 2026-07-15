@isTest
public class ASM_IAandSEEExamSMS_Batch_Test 
{
    public static testMethod void IAandSemExamSMS()
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
                
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9090999090';
        objCon1.Aadhar_Card_Number__c ='098765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8363210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';       
        objCon1.Father__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()-15;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.IA_1_Start_date__c = system.today()+3;
        obj_Term.IA_1_End_date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
        //system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Pursuing');
        
    }
     public static testMethod void IAandSemExamSMS1()
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
                
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9090999090';
        objCon1.Aadhar_Card_Number__c ='098765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8363210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';       
        objCon1.Mother__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()-15;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.IA_1_Start_date__c = system.today()+3;
        obj_Term.IA_2_Start_date__c = system.today()+3;
        obj_Term.IA_1_End_date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
        //system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Year Back');
    }
     public static testMethod void IAandSemExamSMS2()
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
        
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9790909090';
        objCon1.Aadhar_Card_Number__c ='097765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8923210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';
        objCon1.Guardian__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()+7;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.IA_1_Start_date__c = system.today()+3;
        obj_Term.IA_1_End_date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
       // system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Pursuing');
        
    }
    public static testMethod void IAandSemExamSMS3()
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
        
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9790909090';
        objCon1.Aadhar_Card_Number__c ='097765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8923210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';
        objCon1.Father__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()-15;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.IA_2_Start_date__c = system.today()+3;
        obj_Term.IA_1_Start_date__c = system.today();
        obj_Term.IA_2_End_date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
        //system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Pursuing');
        
    }
    public static testMethod void IAandSemExamSMS4()
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
        
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9790909090';
        objCon1.Aadhar_Card_Number__c ='097765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8923210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';
        objCon1.Mother__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()-15;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.IA_2_Start_date__c = system.today()+3;
        obj_Term.IA_1_Start_date__c = system.today();
        obj_Term.IA_2_End_date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
        //system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Pursuing');
    }
    public static testMethod void IAandSemExamSMS5()
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
        
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9790909090';
        objCon1.Aadhar_Card_Number__c ='097765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8923210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';
        objCon1.Guardian__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()-15;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.IA_2_Start_date__c = system.today()+3;
        obj_Term.IA_1_Start_date__c = system.today();
        obj_Term.IA_2_End_date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
        //system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Pursuing');
        
    }
     public static testMethod void IAandSemExamSMS6()
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
        
        Contact objCon1 = STOB_TestDataFactory.createContact('Test');
        objCon1.MobilePhone ='9790909090';
        objCon1.Aadhar_Card_Number__c ='097765435612';
        objCon1.Application_Number__c = '1231';
        objCon1.hed__WorkEmail__c='1231@reva.edu.in';
        objCon1.Email = 'test1@reva.edu.in';
        objCon1.MobilePhone ='8923210547';
        objCon1.AccountId = objAcc.id;
        objCon1.Nationality__c ='Indian';
        objCon1.RecordTypeId = studRecordType;
        objCon1.Student_Status__c = 'Pursuing';
        objCon1.Guardian__c = objCon.id;
        Insert objCon1;
        
        hed__Program_Plan__c objProgplan = STOB_TestDataFactory.createProgramPlan('Prog Plan');
        Insert objProgplan;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();        
        hed__Term__c obj_Term = STOB_TestDataFactory.createTerm('Test Term',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        obj_Term.hed__Start_Date__c = system.today()-15;
        obj_Term.hed__End_Date__c = system.today()+15;
        obj_Term.Exam_Start_Date__c = system.today()+7;
        obj_Term.Exam_End_Date__c = system.today();
        Insert obj_Term;
        
        hed__Program_Enrollment__c objProgEnrlmt = STOB_TestDataFactory.createprogramEnrollment(objProgplan.Id);
        objProgEnrlmt.hed__Account__c=objAcc.id;
        objProgEnrlmt.hed__Contact__c=objCon1.id;
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
        ASM_IAandSEEExamSMS_Batch IAandSemSMS = new ASM_IAandSEEExamSMS_Batch();
        database.executeBatch(IAandSemSMS);
        Test.stopTest();
        //system.assertequals(objProgEnrlmt.hed__Contact__r.Student_Status__c,'Pursuing');
    }
}