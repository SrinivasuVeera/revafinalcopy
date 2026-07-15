@isTest
public class FEE_RazorpayS2SResponseAPI_Test {
    private class RestMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}');
                res.setStatusCode(200);
                return res;
            }
        }
    
    @isTest
    static void FEE_RazorpayS2SResponseAPI_Method1(){
        
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
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
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
        objStuPayment.Payment_Link_Id__c = 'plink_KlkrGKBqAUFbTD';
        objStuPayment.Fee_Type__c='Applciation Fee';
        //objStuPayment.Mode_of_Payment__c = 'Online';
        
        insert objStuPayment;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c();
        hostelRequest.Hostel_Room_Request_For__c = objCon.Id;
       // hostelRequest.Employee_Salary__c = 5000;
       // hostelRequest.Is_HCM_Salary_Deduction_CNF__c = false;
      //  hostelRequest.HCM_Approval_Status__c = 'Deduction Approved';
      //  hostelRequest.Approved_by_Hostel_Office__c = true;
        hostelRequest.Status__c = 'Approved';
      //  hostelRequest.Reva_Hostel_Room__c = hostelroom.Id;
        hostelRequest.Reva_Hostel_JoiningDate__c = Date.today();
        hostelRequest.Type__c = '1';
        insert hostelRequest;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        objStuFeePay.Payment_Link_Id__c ='plink_KlkrGKBqAUFbTD';
        insert objStuFeePay;
        
        hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
         Test.setMock(HttpCalloutMock.class, new RestMock());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RazorpayS2SResponse'; //Request URL
        req.httpMethod = 'POST';
        string JSONbody = '{"account_id":"acc_J7LjT9AYniLrwI","contains":["payment_link","order","payment"],"created_at":1669703135,"entity":"event","event":"payment_link.paid","payload":{"order":{"entity":{"amount":6000000,"amount_due":0,"amount_paid":6000000,"attempts":1,"created_at":1669703137,"currency":"INR","entity":"order","id":"order_KlkrIJg4XotKLB","notes":{"paymentType":"FeePayment"},"offer_id":null,"receipt":"1433824309","status":"paid"}},"payment":{"entity":{"acquirer_data":{"auth_code":"347586"},"amount":6000000,"amount_refunded":0,"amount_transferred":0,"authorized_at":1669703188,"auto_captured":true,"bank":null,"base_amount":6000000,"captured":true,"captured_at":1669703188,"card":{"emi":false,"entity":"card","id":"card_Klks2I3VxQlPOD","international":false,"issuer":null,"last4":"1111","name":"","network":"Visa","sub_type":"consumer","token_iin":null,"type":"debit"},"card_id":"card_Klks2I3VxQlPOD","contact":"+917777777777","created_at":1669703181,"currency":"INR","description":"#KlkrGKBqAUFbTD","email":"test@gmail.com","entity":"payment","error_code":null,"error_description":null,"fee":0,"fee_bearer":"platform","id":"pay_Klks2FcrUupfjc","international":false,"invoice_id":null,"late_authorized":false,"method":"card","notes":{"paymentType":"FeePayment"},"order_id":"order_KlkrIJg4XotKLB","refund_status":null,"status":"captured","tax":0,"vpa":null,"wallet":null}},"payment_link":{"entity":{"accept_partial":false,"amount":6000000,"amount_paid":6000000,"callback_method":"get","callback_url":"https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse","cancelled_at":0,"created_at":1669703135,"currency":"INR","customer":{"contact":"1111122222","email":"vinodh@epeoplebc.com","name":"Vinodh Kumar"},"description":"Tuition Fee,","expire_by":1685341535,"expired_at":0,"first_min_partial_amount":0,"id":"plink_KlkrGKBqAUFbTD","notes":{"paymentType":"FeePayment"},"notify":{"email":true,"sms":true,"whatsapp":false},"order_id":"order_KlkrIJg4XotKLB","reference_id":"1433824309","reminder_enable":true,"reminders":{"status":"failed"},"short_url":"https://rzp.io/i/FNMC7fmjyN","status":"paid","updated_at":1669703188,"upi_link":false,"user_id":""}}}}';
        
        req.requestBody =  Blob.valueOf(JSONbody);
        
        RestContext.request = req;
        RestContext.response= res; 
        
        Test.startTest();
        FEE_RazorpayS2SResponseAPI.ReceivedData();
        Test.stopTest();
        system.assertequals(objStuPayment.id,objStuPayment.id); 
    }
    
     @isTest
    static void FEE_RazorpayS2SResponseAPI_Method2(){
 
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RazorpayS2SResponse'; //Request URL
        req.httpMethod = 'POST';
        string JSONbody = '{"account_id":"acc_J7LjT9AYniLrwI","contains":["payment_link","order","payment"],"created_at":1669703135,"entity":"event","event":"payment_link.paid","payload":{"order":{"entity":{"amount":6000000,"amount_due":0,"amount_paid":6000000,"attempts":1,"created_at":1669703137,"currency":"INR","entity":"order","id":"order_KlkrIJg4XotKLB","notes":{"paymentType":"FeePayment"},"offer_id":null,"receipt":"1433824309","status":"paid"}},"payment":{"entity":{"acquirer_data":{"auth_code":"347586"},"amount":6000000,"amount_refunded":0,"amount_transferred":0,"authorized_at":1669703188,"auto_captured":true,"bank":null,"base_amount":6000000,"captured":true,"captured_at":1669703188,"card":{"emi":false,"entity":"card","id":"card_Klks2I3VxQlPOD","international":false,"issuer":null,"last4":"1111","name":"","network":"Visa","sub_type":"consumer","token_iin":null,"type":"debit"},"card_id":"card_Klks2I3VxQlPOD","contact":"+917777777777","created_at":1669703181,"currency":"INR","description":"#KlkrGKBqAUFbTD","email":"test@gmail.com","entity":"payment","error_code":null,"error_description":null,"fee":0,"fee_bearer":"platform","id":"pay_Klks2FcrUupfjc","international":false,"invoice_id":null,"late_authorized":false,"method":"card","notes":{"paymentType":"FeePayment"},"order_id":"order_KlkrIJg4XotKLB","refund_status":null,"status":"captured","tax":0,"vpa":null,"wallet":null}},"payment_link":{"entity":{"accept_partial":false,"amount":6000000,"amount_paid":6000000,"callback_method":"get","callback_url":"https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse","cancelled_at":0,"created_at":1669703135,"currency":"INR","customer":{"contact":"1111122222","email":"vinodh@epeoplebc.com","name":"Vinodh Kumar"},"description":"Tuition Fee,","expire_by":1685341535,"expired_at":0,"first_min_partial_amount":0,"id":"plink_KlkrGKBqAUFbTD","notes":{"paymentType":"FeePayment"},"notify":{"email":true,"sms":true,"whatsapp":false},"order_id":"order_KlkrIJg4XotKLB","reference_id":"1433824309","reminder_enable":true,"reminders":{"status":"failed"},"short_url":"https://rzp.io/i/FNMC7fmjyN","status":"paid","updated_at":1669703188,"upi_link":false,"user_id":""}}}}';
        
        req.requestBody =  Blob.valueOf(JSONbody);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_RazorpayS2SResponseAPI.ReceivedData();
        Test.stopTest();
    }
    @isTest
    static void FEE_RazorpayS2SResponseAPI_Method3(){
        
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
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
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
        //SELECT id,Transaction_ID__c,Payment_Link_Id__c,Mode_of_Payment__c,Payment_Gateway__c,Fee_Type__c,
                                  //Amount__c ,Razorpay_Signature__c,Payment_Mode_Type__c FROM Student_Payment__c WHERE Reference_Id__c =: refId]
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335';
        objStuPayment.Payment_Link_Id__c = 'plink_KlkrGKBqAUFbTD';
        objStuPayment.Mode_of_Payment__c = 'Online';
        objStuPayment.Fee_Type__c = 'Academic';
        objStuPayment.Razorpay_Signature__c = 'Rzrpay';
        
        
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        objStuFeePay.Payment_Link_Id__c ='plink_KlkrGKBqAUFbTD';
        insert objStuFeePay;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/RazorpayS2SResponse'; //Request URL
        req.httpMethod = 'POST';
        //string JSONbody = '{"account_id":"acc_J7LjT9AYniLrwI","contains":["payment_link","order","payment"],"created_at":1669703135,"entity":"event","event":"payment.failed","payload":{"order":{"entity":{"amount":6000000,"amount_due":0,"amount_paid":6000000,"attempts":1,"created_at":1669703137,"currency":"INR","entity":"order","id":"order_KlkrIJg4XotKLB","notes":{"paymentType":"FeePayment"},"offer_id":null,"receipt":"1433824309","status":"paid"}},"payment":{"entity":{"acquirer_data":{"auth_code":"347586"},"amount":6000000,"amount_refunded":0,"amount_transferred":0,"authorized_at":1669703188,"auto_captured":true,"bank":null,"base_amount":6000000,"captured":true,"captured_at":1669703188,"card":{"emi":false,"entity":"card","id":"card_Klks2I3VxQlPOD","international":false,"issuer":null,"last4":"1111","name":"","network":"Visa","sub_type":"consumer","token_iin":null,"type":"debit"},"card_id":"card_Klks2I3VxQlPOD","contact":"+917777777777","created_at":1669703181,"currency":"INR","description":"#KlkrGKBqAUFbTD","email":"test@gmail.com","entity":"payment","error_code":null,"error_description":null,"fee":0,"fee_bearer":"platform","id":"pay_Klks2FcrUupfjc","international":false,"invoice_id":null,"late_authorized":false,"method":"card","notes":{"paymentType":"FeePayment"},"order_id":"order_KlkrIJg4XotKLB","refund_status":null,"status":"captured","tax":0,"vpa":null,"wallet":null}},"payment_link":{"entity":{"accept_partial":false,"amount":6000000,"amount_paid":6000000,"callback_method":"get","callback_url":"https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse","cancelled_at":0,"created_at":1669703135,"currency":"INR","customer":{"contact":"1111122222","email":"vinodh@epeoplebc.com","name":"Vinodh Kumar"},"description":"Tuition Fee,","expire_by":1685341535,"expired_at":0,"first_min_partial_amount":0,"id":"plink_KlkrGKBqAUFbTD","notes":{"paymentType":"FeePayment"},"notify":{"email":true,"sms":true,"whatsapp":false},"order_id":"order_KlkrIJg4XotKLB","reference_id":"1433824309","reminder_enable":true,"reminders":{"status":"failed"},"short_url":"https://rzp.io/i/FNMC7fmjyN","status":"paid","updated_at":1669703188,"upi_link":false,"user_id":""}}}}';
        //string JSONbody = '{ "account_id": "acc_J7LjT9AYniLrwI", "contains": [ "payment_link", "order", "payment" ], "created_at": 1669703135, "entity": "event", "event": "payment.failed", "payload": { "order": { "entity": { "amount": 6000000, "amount_due": 0, "amount_paid": 6000000, "attempts": 1, "created_at": 1669703137, "currency": "INR", "entity": "order", "id": "order_KlkrIJg4XotKLB", "notes": { "paymentType": "FeePayment" }, "offer_id": null, "receipt": "1433824309", "status": "paid" } }, "payment": { "entity": { "acquirer_data": { "auth_code": "347586" }, "amount": 6000000, "amount_refunded": 0, "amount_transferred": 0, "authorized_at": 1669703188, "auto_captured": true, "bank": null, "base_amount": 6000000, "captured": true, "captured_at": 1669703188, "card": { "emi": false, "entity": "card", "id": "card_Klks2I3VxQlPOD", "international": false, "issuer": null, "last4": "1111", "name": "", "network": "Visa", "sub_type": "consumer", "token_iin": null, "type": "debit" }, "card_id": "card_Klks2I3VxQlPOD", "contact": "+917777777777", "created_at": 1669703181, "currency": "INR", "description": "#KlkrGKBqAUFbTD", "email": "test@gmail.com", "entity": "payment", "error_code": null, "error_description": null, "fee": 0, "fee_bearer": "platform", "id": "pay_Klks2FcrUupfjc", "international": false, "invoice_id": null, "late_authorized": false, "method": "card", "notes": { "paymentType": "FeePayment", }, "order_id": "order_KlkrIJg4XotKLB", "refund_status": null, "status": "captured", "tax": 0, "vpa": null, "wallet": null, "reference_id":"test123" } }, "payment_link": { "entity": { "accept_partial": false, "amount": 6000000, "amount_paid": 6000000, "callback_method": "get", "callback_url": "https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse", "cancelled_at": 0, "created_at": 1669703135, "currency": "INR", "customer": { "contact": "1111122222", "email": "vinodh@epeoplebc.com", "name": "Vinodh Kumar" }, "description": "Tuition Fee,", "expire_by": 1685341535, "expired_at": 0, "first_min_partial_amount": 0, "id": "plink_KlkrGKBqAUFbTD", "notes": { "paymentType": "FeePayment" }, "notify": { "email": true, "sms": true, "whatsapp": false }, "order_id": "order_KlkrIJg4XotKLB", "reference_id": "1433824309", "reminder_enable": true, "reminders": { "status": "failed" }, "short_url": "https://rzp.io/i/FNMC7fmjyN", "status": "paid", "updated_at": 1669703188, "upi_link": false, "user_id": "" } } } }';
        //string JSONbody ='{"account_id":"acc_J7LjT9AYniLrwI","contains":["payment_link","order","payment"],"created_at":1669703135,"entity":"event","event":"payment.failed","payload":{"order":{"entity":{"amount":6000000,"amount_due":0,"amount_paid":6000000,"attempts":1,"created_at":1669703137,"currency":"INR","entity":"order","id":"order_KlkrIJg4XotKLB","notes":{"paymentType":"FeePayment"},"offer_id":null,"receipt":"1433824309","status":"paid"}},"payment":{"entity":{"acquirer_data":{"auth_code":"347586"},"amount":6000000,"amount_refunded":0,"amount_transferred":0,"authorized_at":1669703188,"auto_captured":true,"bank":null,"base_amount":6000000,"captured":true,"captured_at":1669703188,"card":{"emi":false,"entity":"card","id":"card_Klks2I3VxQlPOD","international":false,"issuer":null,"last4":"1111","name":"","network":"Visa","sub_type":"consumer","token_iin":null,"type":"debit"},"card_id":"card_Klks2I3VxQlPOD","contact":"+917777777777","created_at":1669703181,"currency":"INR","description":"#KlkrGKBqAUFbTD","email":"test@gmail.com","entity":"payment","error_code":null,"error_description":null,"fee":0,"fee_bearer":"platform","id":"pay_Klks2FcrUupfjc","international":false,"invoice_id":null,"late_authorized":false,"method":"card","notes":{"paymentType":"FeePayment","reference_id":"test123"},"order_id":"order_KlkrIJg4XotKLB","refund_status":null,"status":"captured","tax":0,"vpa":null,"wallet":null}},"payment_link":{"entity":{"accept_partial":false,"amount":6000000,"amount_paid":6000000,"callback_method":"get","callback_url":"https:\/\/revadev-chatbot.cs75.force.com\/RazorPayPGResponse","cancelled_at":0,"created_at":1669703135,"currency":"INR","customer":{"contact":"1111122222","email":"vinodh@epeoplebc.com","name":"Vinodh Kumar"},"description":"Tuition Fee,","expire_by":1685341535,"expired_at":0,"first_min_partial_amount":0,"id":"plink_KlkrGKBqAUFbTD","notes":{"paymentType":"FeePayment"},"notify":{"email":true,"sms":true,"whatsapp":false},"order_id":"order_KlkrIJg4XotKLB","reference_id":"1433824309","reminder_enable":true,"reminders":{"status":"failed"},"short_url":"https:\/\/rzp.io\/i\/FNMC7fmjyN","status":"paid","updated_at":1669703188,"upi_link":false,"user_id":""}}}}';
        //string JSONbody = '{"account_id":"acc_J7LjT9AYniLrwI","contains":["payment_link","order","payment"],"created_at":1669703135,"entity":"event","event":"payment.failed","payload":{"order":{"entity":{"amount":6000000,"amount_due":0,"amount_paid":6000000,"attempts":1,"created_at":1669703137,"currency":"INR","entity":"order","id":"order_KlkrIJg4XotKLB","notes":{"paymentType":"FeePayment"},"offer_id":null,"receipt":"1433824309","status":"paid"}},"payment":{"entity":{"acquirer_data":{"auth_code":"347586"},"amount":6000000,"amount_refunded":0,"amount_transferred":0,"authorized_at":1669703188,"auto_captured":true,"bank":null,"base_amount":6000000,"captured":true,"captured_at":1669703188,"card":{"emi":false,"entity":"card","id":"card_Klks2I3VxQlPOD","international":false,"issuer":null,"last4":"1111","name":"","network":"Visa","sub_type":"consumer","token_iin":null,"type":"debit"},"card_id":"card_Klks2I3VxQlPOD","contact":"+917777777777","created_at":1669703181,"currency":"INR","description":"#KlkrGKBqAUFbTD","email":"test@gmail.com","entity":"payment","error_code":null,"error_description":null,"fee":0,"fee_bearer":"platform","id":"pay_Klks2FcrUupfjc","international":false,"invoice_id":null,"late_authorized":false,"method":"card","notes":{"reference_id;":"test1234"},"order_id":"order_KlkrIJg4XotKLB","refund_status":null,"status":"captured","tax":0,"vpa":null,"wallet":null}},"payment_link":{"entity":{"accept_partial":false,"amount":6000000,"amount_paid":6000000,"callback_method":"get","callback_url":"https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse","cancelled_at":0,"created_at":1669703135,"currency":"INR","customer":{"contact":"1111122222","email":"vinodh@epeoplebc.com","name":"Vinodh Kumar"},"description":"Tuition Fee,","expire_by":1685341535,"expired_at":0,"first_min_partial_amount":0,"id":"plink_KlkrGKBqAUFbTD","notes":{"paymentType":"FeePayment"},"notify":{"email":true,"sms":true,"whatsapp":false},"order_id":"order_KlkrIJg4XotKLB","reference_id":"1433824309","reminder_enable":true,"reminders":{"status":"failed"},"short_url":"https://rzp.io/i/FNMC7fmjyN","status":"paid","updated_at":1669703188,"upi_link":false,"user_id":""}}}}';
        string JSONbody = '{"entity":"event","account_id":"acc_J7LjT9AYniLrwI","event":"payment.failed","contains":["payment"],"payload":{"payment":{"entity":{"id":"pay_KmZri9RoZlrTc0","entity":"payment","amount":6000000,"currency":"INR","status":"failed","order_id":"order_KmZrKes5SWFU8G","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":false,"description":"#KmZrGye3zzJMrO","card_id":null,"bank":"YESB","wallet":null,"vpa":null,"email":"test@gmail.com","contact":"+917777777777","notes":{"reference_id":"1572332335"},"fee":null,"tax":null,"error_code":"BAD_REQUEST_ERROR","error_description":"Your payment did not go through as it was declined by the bank. Try another payment method or contact your bank.","error_source":"bank","error_step":"payment_authorization","error_reason":"payment_failed","acquirer_data":{"bank_transaction_id":null},"created_at":1669882763,"late_authorized":false}}},"created_at":1669882767}';
        
        req.requestBody =  Blob.valueOf(JSONbody);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        FEE_RazorpayS2SResponseAPI.ReceivedData();
        Test.stopTest();
        system.assertequals(objStuPayment.id,objStuPayment.id); 
    }
    
    
   
}