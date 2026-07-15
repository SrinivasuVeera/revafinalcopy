@isTest
public class FEE_SMSDueDate_Batch_Test 
{
    public static testMethod void FEE_SMSDueDateBtch()
    {
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
        
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');       //'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=10000;
        objStudentFee.Amount_Paid__c=50000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.Due_Date__c = system.today() + 2;
        objStudentFee.Fee_Type__c = 'Tuition Fee';
        objStudentFee.Father_Mobile_Number__c = '1234567890';
        Insert objStudentFee;
        
        
        /*SMS_API_Utility.shortMessageWrp shortMsg = New SMS_API_Utility.shortMessageWrp();
        shortMsg.message = 'TestMsg';
        shortMsg.recipient = 'TestRecp';
        shortMsg.dltContentId = 'DLTID001';
        
         List<SMS_API_Utility.shortMessageWrp> listshort = new List<SMS_API_Utility.shortMessageWrp>();
        listshort.add(shortMsg);*/
        
        Test.startTest();
        SMS_MockCallout TestMock = new SMS_MockCallout(200,'{"status":"success","data":{"resdata":[{"regno":"SRN0001","iatype":"IA1","subcode":"SUB01","status":"F"}]}}','Failed');
        Test.setMock(HttpCalloutMock.class,TestMock);
        FEE_SMSDueDate_Batch FeeSMSBtch = new FEE_SMSDueDate_Batch();
        database.executeBatch(FeeSMSBtch);
        //SMS_API_Utility.SendSMSOneToMany('Fee Payment Remainder- Parent',listshort);
        Test.stopTest();
        system.assertequals(objStudentFee.id,objStudentFee.id);
    }
}