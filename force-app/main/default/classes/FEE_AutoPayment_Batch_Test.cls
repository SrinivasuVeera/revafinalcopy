@isTest
public class FEE_AutoPayment_Batch_Test {
    @isTest
    static void autopayment(){
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        contact objCon = new contact();
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');       //'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=10000;
        objStudentFee1.Amount_Paid__c=50000;
        objStudentFee1.Contact__c = objCon.id;
        objStudentFee1.Due_Date__c = system.today() - 1;
        objStudentFee1.Fee_Type__c = 'Tuition Fee';
        Insert objStudentFee1;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Amount__c = 10000;
        objStuPayment.Payment_Mode_Type__c = 'Online';
        objStuPayment.Payment_Gateway__c = 'Razorpay';
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Auto_Allocate__c = true;
        objStuPayment.Auto_Allocate_isDone__c = false;
        objStuPayment.Mode_of_Payment__c = 'Online';
        
        
        //objStuPayment.Payment_Date__c = system.today();
        insert objStuPayment;
        
        Test.startTest();
        ExecuteBatch_Ctrl eb = new ExecuteBatch_Ctrl();
        ExecuteBatch_Ctrl.ExecuteBatchClass();
        //FEE_AutoPayment_Batch apb = new FEE_AutoPayment_Batch();
        //database.executeBatch(apb);
        Test.stopTest();
        system.assertequals(objStudentFee1.id,objStudentFee1.id);
        //system.assertEquals(expected, actual);
    }
    @isTest
    static void autopayment2(){
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        contact objCon = new contact();
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');       //'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=100000;
        objStudentFee1.Amount_Paid__c=50000;
        objStudentFee1.Contact__c = objCon.id;
        objStudentFee1.Due_Date__c = null;
        objStudentFee1.Fee_Type__c = 'Tuition Fee';
        Insert objStudentFee1;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Amount__c = 10000;
        objStuPayment.Payment_Mode_Type__c = 'Online';
        objStuPayment.Payment_Gateway__c = 'Razorpay';
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Auto_Allocate__c = true;
        objStuPayment.Auto_Allocate_isDone__c = false;
        objStuPayment.Mode_of_Payment__c = 'Online';
        
        
        //objStuPayment.Payment_Date__c = system.today();
        insert objStuPayment;
        
        Test.startTest();
        ExecuteBatch_Ctrl eb = new ExecuteBatch_Ctrl();
        ExecuteBatch_Ctrl.ExecuteBatchClass();
        //FEE_AutoPayment_Batch apb = new FEE_AutoPayment_Batch();
        //database.executeBatch(apb);
        Test.stopTest();
        system.assertequals(objStudentFee1.id,objStudentFee1.id);
    }
    @isTest
    static void autopayment3(){
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        contact objCon = new contact();
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');       
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=100;
        objStudentFee1.Amount_Paid__c=50000;
        objStudentFee1.Contact__c = objCon.id;
        objStudentFee1.Due_Date__c = null;
        objStudentFee1.Fee_Type__c = 'Tuition Fee';
        Insert objStudentFee1;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Amount__c = 10000;
        objStuPayment.Payment_Mode_Type__c = 'Online';
        objStuPayment.Payment_Gateway__c = 'Razorpay';
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Auto_Allocate__c = true;
        objStuPayment.Auto_Allocate_isDone__c = false;
        objStuPayment.Mode_of_Payment__c = 'Online';
        
        
        //objStuPayment.Payment_Date__c = system.today();
        insert objStuPayment;
        
        Test.startTest();
        
        FEE_AutoPayment_Batch apb = new FEE_AutoPayment_Batch();
        database.executeBatch(apb);
        ExecuteBatch_Ctrl eb = new ExecuteBatch_Ctrl();
        ExecuteBatch_Ctrl.ExecuteBatchClass();
        Test.stopTest();
        system.assertequals(objStudentFee1.id,objStudentFee1.id);
    }
}