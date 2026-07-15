@isTest
public class FEE_RazorpayGetPaymentApiTest 
{
    public static testMethod Void RazorpayMethod()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Link_Id__c= 'plink_JeYmmPJlVpozjh';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Razorpay';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Razorpay_Signature__c= 'razorPay_Sign';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        insert objStuFeePay;

        Razorpay_Details__c paydetails = new Razorpay_Details__c();
        paydetails.Value__c='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
        paydetails.Name='CallbackUrl';
        insert paydetails;
        
        Razorpay_Details__c paydetails1 = new Razorpay_Details__c();
        paydetails1.Value__c='vdcSuL82zafd9GnXnfyzUIuK';
        paydetails1.Name='Password';
        insert paydetails1;
        
        Razorpay_Details__c paydetails2 = new Razorpay_Details__c();
        paydetails2.Value__c='https://api.razorpay.com/v1/payment_links';
        paydetails2.Name='Razorpay Endpoint';
        insert paydetails2;
        
        Razorpay_Details__c paydetails3 = new Razorpay_Details__c();
        paydetails3.Value__c='rzp_test_JA1KlDGzmvG6Hh';
        paydetails3.Name='UserName';
        insert paydetails3;
        
        Razorpay_Details__c paydetails4 = new Razorpay_Details__c();
        paydetails4.Value__c='https://api.razorpay.com/v1/payment_links';
        paydetails4.Name='FetchPaymentEndpoint';
        insert paydetails4;        
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new FEE_RazorpayGetPaymentApiMock());
        FEE_RazorpayGetPaymentApi.ReceivedData('plink_JeYmmPJlVpozjh','123456');   
        test.stoptest();   
    }
}