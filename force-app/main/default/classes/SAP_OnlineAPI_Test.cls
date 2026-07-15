@IsTest
public class SAP_OnlineAPI_Test 
{
    public static testmethod void Online_API_Response()
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
          objcon.SAP_ID__c = '1024514';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Reference_Id__c = '1234';
        objStuPayment.Payment_Mode_Type__c= 'Online';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Payment_Link_Id__c= 'plink_JeYmmPJlVpozjh';
        insert objStuPayment;
        
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;        
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Push_to_SAP__c = false;
        objStuFeePay.Integrated_with_SAP__c = false;
        objStuFeePay.Transaction_Status__c = 'Completed';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Student_Fee__c = objStudentFee.id;
        objStuFeePay.Reference_Id__c = 'Test213';
        insert objStuFeePay;
        objStuFeePay.Push_to_SAP__c = true;
        Update objStuFeePay;
        
        List<id> lst_StudentFee = New List<id>();
        lst_StudentFee.add(objStuFeePay.id);
        
        objStuPayment.Payment_Gateway__c = 'Eazypay';
        update objStuPayment;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://revauniversity9--revadev.my.salesforce.com/services/apexrest/EasyPayResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='https://revauat-revauat.cs75.force.com/StudentPortal/s/student-fee';
        easypaydetails.name ='AES key';
        insert easypaydetails;
        
        EasyPay_Details__c easypaydetails1 = new EasyPay_Details__c();
        easypaydetails1.Value__c ='https://revauat-revauat.cs75.force.com/StudentPortal/s/student-fee';
        easypaydetails1.name ='HomeUrl';
        insert easypaydetails1;
        EasyPay_Details__c easypaydetails2 = new EasyPay_Details__c();
        easypaydetails2.Value__c ='  https://www.reva.edu.in/';
        easypaydetails2.name ='Applicant_HomeUrl';
        insert easypaydetails2;
        
        EasyPay_Details__c easypaydetails3 = new EasyPay_Details__c();
        easypaydetails3.Value__c ='https://rev--stratosuat.sandbox.my.site.com/Admissions/s/';
        easypaydetails3.name ='Applicant_PortalUrl';
        insert easypaydetails3;
        
        Payment_Gateway_Error_Msg__c objpayGateway = new Payment_Gateway_Error_Msg__c();
        objpayGateway.Error_Msg__c ='Success';
        objpayGateway.Name='Eazypay-E000';
        objpayGateway.Status__c ='Success';
        insert objpayGateway;
        
        SAP_OnlineAPI.RequestBodyWrapper reqWrpBody = new SAP_OnlineAPI.RequestBodyWrapper();
        reqWrpBody.Contact = objStuFeePay.id;
        reqWrpBody.Offline_Receipt_Number = '2';
            
        // Set up mock callout response
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SAP_OnlineAPI.OnlineAPIMethod(lst_StudentFee);
        test.stoptest(); 
        // Mock HTTP callout response class
  
    }
      public static testmethod void Online_API_Response2()
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
          objcon.SAP_ID__c = '1024514';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Reference_Id__c = '1234';
        objStuPayment.Payment_Mode_Type__c= 'Online';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Payment_Link_Id__c= 'plink_JeYmmPJlVpozjh';
        insert objStuPayment;
        
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;        
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Push_to_SAP__c = false;
        objStuFeePay.Integrated_with_SAP__c = false;
        objStuFeePay.Transaction_Status__c = 'Completed';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Student_Fee__c = objStudentFee.id;
        objStuFeePay.Reference_Id__c = 'Test213';
        insert objStuFeePay;
        objStuFeePay.Push_to_SAP__c = true;
        Update objStuFeePay;
        Delete objStuFeePay;
        
        List<id> lst_StudentFee = New List<id>();
        lst_StudentFee.add(objStuFeePay.id);
        
        objStuPayment.Payment_Gateway__c = 'Eazypay';
        update objStuPayment;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://revauniversity9--revadev.my.salesforce.com/services/apexrest/EasyPayResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='https://revauat-revauat.cs75.force.com/StudentPortal/s/student-fee';
        easypaydetails.name ='AES key';
        insert easypaydetails;
        
        EasyPay_Details__c easypaydetails1 = new EasyPay_Details__c();
        easypaydetails1.Value__c ='https://revauat-revauat.cs75.force.com/StudentPortal/s/student-fee';
        easypaydetails1.name ='HomeUrl';
        insert easypaydetails1;
        EasyPay_Details__c easypaydetails2 = new EasyPay_Details__c();
        easypaydetails2.Value__c ='  https://www.reva.edu.in/';
        easypaydetails2.name ='Applicant_HomeUrl';
        insert easypaydetails2;
        
        EasyPay_Details__c easypaydetails3 = new EasyPay_Details__c();
        easypaydetails3.Value__c ='https://rev--stratosuat.sandbox.my.site.com/Admissions/s/';
        easypaydetails3.name ='Applicant_PortalUrl';
        insert easypaydetails3;
        
        Payment_Gateway_Error_Msg__c objpayGateway = new Payment_Gateway_Error_Msg__c();
        objpayGateway.Error_Msg__c ='Success';
        objpayGateway.Name='Eazypay-E000';
        objpayGateway.Status__c ='Success';
        insert objpayGateway;
        
        SAP_OnlineAPI.RequestBodyWrapper reqWrpBody = new SAP_OnlineAPI.RequestBodyWrapper();
        reqWrpBody.Contact = objStuFeePay.id;
        reqWrpBody.Offline_Receipt_Number = '2';
            
        // Set up mock callout response
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SAP_OnlineAPI.OnlineAPIMethod(lst_StudentFee);
        test.stoptest(); 
        // Mock HTTP callout response class
  
    }
      public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"Response": [{"SFDCRecordId": "a1O1s000001qhGREAY", "statusCode": 0, "SAPID": "SAP123", "responseObject": "Success"}]}');
            return res;
        }
    }
}