@isTest
public class FEE_BilldeskServerResponseAPI_Test 
{
    public static testMethod Void BilldeskMethod()
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
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Hostel Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee');        //'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        insert objStuPayment;
                
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        paydetails.Name='HomeUrl';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Checksum';
        insert paydetails2;
    
       Test.startTest();
       String jsonBody = 'BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE';
      //  ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|01|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE'); 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/BillDeskServerResponse/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        req.params.put('msg',jsonBody);
        RestContext.request = req;
        RestContext.response= res;
                
        FEE_BilldeskServerResponseAPI.ReceivedData();
        Test.stopTest();        
     }
     public static testMethod Void BilldeskMethod1()
    {
       String jsonBody = '';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/BillDeskServerResponse/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_BilldeskServerResponseAPI.ReceivedData();
        Test.stopTest();        
     }
}