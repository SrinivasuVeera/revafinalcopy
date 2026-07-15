@IsTest
public class FEE_BilldeskPendingPaymentUpdate_Test {

    public static testmethod void BillDesk()
    {
        Batch_Failure_Emails__c bfe = new Batch_Failure_Emails__c(name='Fee Module',Email_Ids__c='test@test.com');
        insert bfe;
    
         Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='BD9CHILD1';
        paydetails.Name='University Fee';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails1 = new Billdesk_Merchant_Details__c();
        paydetails1.MerchantId__c='https://revadev-chatbot.cs75.force.com/BillDeskResponse';
        paydetails1.Name='CallbackUrl';
        insert paydetails1;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Checksum';
        insert paydetails2;
        
        Billdesk_Merchant_Details__c paydetails3 = new Billdesk_Merchant_Details__c();
        paydetails3.MerchantId__c='BD9CHILD2';
        paydetails3.Name='Hostel Fee';
        insert paydetails3;
        
        Billdesk_Merchant_Details__c paydetails4 = new Billdesk_Merchant_Details__c();
        paydetails4.MerchantId__c='BD9MAIN';
        paydetails4.Name='MainMerchant';
        insert paydetails4;
        
        Billdesk_Merchant_Details__c paydetails5 = new Billdesk_Merchant_Details__c();
        paydetails5.MerchantId__c='BD9CHILD3';
        paydetails5.Name='Miscellaneous Fee';
        insert paydetails5;
        
        Billdesk_Merchant_Details__c paydetails6 = new Billdesk_Merchant_Details__c();
        paydetails6.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIQueryController';
        paydetails6.Name='QueryApiEndpoint';
        insert paydetails6;
        
        Billdesk_Merchant_Details__c paydetails7 = new Billdesk_Merchant_Details__c();
        paydetails7.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
        paydetails7.Name='PaymentLink';
        insert paydetails7;
        
        Billdesk_Merchant_Details__c paydetails8 = new Billdesk_Merchant_Details__c();
        paydetails8.MerchantId__c='BD9CHILD4';
        paydetails8.Name='Transportation Fee';
        insert paydetails8;
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.Application_fee_Paid__c =false;
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test12';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test12@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test12'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;        
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.fee_type__c= 'Application Fee';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Reference_Id__c = '1234';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id,objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c ='Payment Link Created';
        objStuFeePay.Amount__c = 100000;
        objStuFeePay.Reference_Id__c = '1234';
        insert objStuFeePay;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new billdeskPendingMock());
        FEE_BilldeskPendingPaymentUpdateBatch objBatch = new FEE_BilldeskPendingPaymentUpdateBatch();
        DataBase.executeBatch(objBatch,1);
        Test.stopTest();
    }
      public static testmethod void BillDesk1()
    {
        Batch_Failure_Emails__c bfe = new Batch_Failure_Emails__c(name='Fee Module',Email_Ids__c='test@test.com');
        insert bfe;
    
         Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='BD9CHILD1';
        paydetails.Name='University Fee';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails1 = new Billdesk_Merchant_Details__c();
        paydetails1.MerchantId__c='https://revadev-chatbot.cs75.force.com/BillDeskResponse';
        paydetails1.Name='CallbackUrl';
        insert paydetails1;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Checksum';
        insert paydetails2;
        
        Billdesk_Merchant_Details__c paydetails3 = new Billdesk_Merchant_Details__c();
        paydetails3.MerchantId__c='BD9CHILD2';
        paydetails3.Name='Hostel Fee';
        insert paydetails3;
        
        Billdesk_Merchant_Details__c paydetails4 = new Billdesk_Merchant_Details__c();
        paydetails4.MerchantId__c='BD9MAIN';
        paydetails4.Name='MainMerchant';
        insert paydetails4;
        
        Billdesk_Merchant_Details__c paydetails5 = new Billdesk_Merchant_Details__c();
        paydetails5.MerchantId__c='BD9CHILD3';
        paydetails5.Name='Miscellaneous Fee';
        insert paydetails5;
        
        Billdesk_Merchant_Details__c paydetails6 = new Billdesk_Merchant_Details__c();
        paydetails6.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIQueryController';
        paydetails6.Name='QueryApiEndpoint';
        insert paydetails6;
        
        Billdesk_Merchant_Details__c paydetails7 = new Billdesk_Merchant_Details__c();
        paydetails7.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
        paydetails7.Name='PaymentLink';
        insert paydetails7;
        
        Billdesk_Merchant_Details__c paydetails8 = new Billdesk_Merchant_Details__c();
        paydetails8.MerchantId__c='BD9CHILD4';
        paydetails8.Name='Transportation Fee';
        insert paydetails8;
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        string ApplicantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.Application_fee_Paid__c =true;
        objCon.RecordTypeId = ApplicantRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test12';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test12@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test12'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee'); //Academic Fee'
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;        
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.fee_type__c= 'University Fee';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Reference_Id__c = '1234';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id,objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c ='Payment Link Created';
        objStuFeePay.Amount__c = 100000;
        objStuFeePay.Reference_Id__c = '1234';
        insert objStuFeePay;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new billdeskPendingMock());
        FEE_BilldeskPendingPaymentUpdateBatch objBatch = new FEE_BilldeskPendingPaymentUpdateBatch();
        DataBase.executeBatch(objBatch,1);
        Test.stopTest();
    }
}