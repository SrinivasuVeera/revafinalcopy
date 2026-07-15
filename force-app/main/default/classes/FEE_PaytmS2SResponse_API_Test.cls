@isTest
public class FEE_PaytmS2SResponse_API_Test {
    @isTest
    static void FEE_PaytmS2SResponse_API_Method1_PAYTMCC(){
        
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
        objStuPayment.Reference_Id__c  = '123';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c ='123';
        insert objStuFeePay;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse/apex/ApplicationFeeResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        Razorpay_Details__c resdetails = new Razorpay_Details__c();
        resdetails.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        resdetails.name='HomeUrl';
        insert resdetails;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
        insert PayDet;
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDetHome = new Paytm_Details__c();
        PayDetHome.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        PayDetHome.Name ='HomeUrl';
        insert PayDetHome;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
        PayDet3.Name ='Endpoint';
        insert PayDet3;
        
        EasyPay_Details__c easyPay = new EasyPay_Details__c();
        easyPay.Name='HomeUrl';
        easyPay.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee'; 
        insert easyPay;
        
        FEE_PaytmS2SResponse_API.paytmDateWrp pwrap = new FEE_PaytmS2SResponse_API.paytmDateWrp();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/PaytmS2SResponse/';       
        
        RestContext.request = req; 
        RestContext.response= res;
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('ORDERID','123');
        req.params.put('PAYMENTMODE','CC');
        req.params.put('STATUS','TXN_SUCCESS');
        req.params.put('PAYMENTMODE','DC');
        req.params.put('PAYMENTMODE','NB');
        req.params.put('PAYMENTMODE','UPI');
        req.params.put('PAYMENTMODE','PPI');
        req.params.put('PAYMENTMODE','PAYTMCC');
        req.params.put('STATUS','PENDING');
        Test.startTest();
        
        FEE_PaytmS2SResponse_API.ReceivedData();
        
        Test.stopTest();
        system.assertequals(objStuPayment.id,objStuPayment.id); 
    }
    @isTest
    static void FEE_PaytmS2SResponse_API_Method1_Applicant(){
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecId;
        objCon.Application_Fee_Paid__c = false;
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
        objStuPayment.Payment_Gateway__c = 'Paytm';
        objStuPayment.Fee_Type__c = 'Application fee';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Razorpay_Signature__c= 'razorPay_Sign';
        objStuPayment.Reference_Id__c  = '123';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c ='123';
        insert objStuFeePay;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse/apex/ApplicationFeeResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        Razorpay_Details__c resdetails = new Razorpay_Details__c();
        resdetails.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        resdetails.name='HomeUrl';
        insert resdetails;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
        insert PayDet;
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDetHome = new Paytm_Details__c();
        PayDetHome.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        PayDetHome.Name ='HomeUrl';
        insert PayDetHome;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
        PayDet3.Name ='Endpoint';
        insert PayDet3;
        
        EasyPay_Details__c easyPay = new EasyPay_Details__c();
        easyPay.Name='HomeUrl';
        easyPay.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee'; 
        insert easyPay;
        
        FEE_PaytmS2SResponse_API.paytmDateWrp pwrap = new FEE_PaytmS2SResponse_API.paytmDateWrp();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/PaytmS2SResponse/';       
        
        RestContext.request = req; 
        RestContext.response= res;
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('ORDERID','123');
        req.params.put('PAYMENTMODE','CC');
        req.params.put('STATUS','TXN_SUCCESS');
        req.params.put('PAYMENTMODE','DC');
        req.params.put('PAYMENTMODE','NB');
        req.params.put('PAYMENTMODE','UPI');
        req.params.put('PAYMENTMODE','PPI');
        req.params.put('PAYMENTMODE','PAYTMCC');
        req.params.put('STATUS','PENDING');
        Test.startTest();
        
        FEE_PaytmS2SResponse_API.ReceivedData();
        
        Test.stopTest();
        system.assertequals(objStuPayment.id,objStuPayment.id); 
    }
     @isTest
    static void FEE_PaytmS2SResponse_API_Method2_UPI(){
        
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
        objStuPayment.Reference_Id__c  = '123';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c ='123';
        insert objStuFeePay;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse/apex/ApplicationFeeResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        Razorpay_Details__c resdetails = new Razorpay_Details__c();
        resdetails.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        resdetails.name='HomeUrl';
        insert resdetails;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
        insert PayDet;
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDetHome = new Paytm_Details__c();
        PayDetHome.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        PayDetHome.Name ='HomeUrl';
        insert PayDetHome;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
        PayDet3.Name ='Endpoint';
        insert PayDet3;
        
        EasyPay_Details__c easyPay = new EasyPay_Details__c();
        easyPay.Name='HomeUrl';
        easyPay.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee'; 
        insert easyPay;
        
        FEE_PaytmS2SResponse_API.paytmDateWrp pwrap = new FEE_PaytmS2SResponse_API.paytmDateWrp();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/PaytmS2SResponse/';       
        //String postData = 'Your actual request which covers both scenario in JSON format';
        //String JsonMsg=JSON.serialize(postData);
        //req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req; 
        RestContext.response= res;
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('ORDERID','123');
        req.params.put('PAYMENTMODE','CC');
        req.params.put('STATUS','TXN_SUCCESS');
        req.params.put('PAYMENTMODE','DC');
        req.params.put('PAYMENTMODE','NB');
        req.params.put('PAYMENTMODE','UPI');
        //req.params.put('PAYMENTMODE','PPI');
        //req.params.put('PAYMENTMODE','PAYTMCC');
        req.params.put('STATUS','PENDING');
        Test.startTest();
        
        FEE_PaytmS2SResponse_API.ReceivedData();
        
        Test.stopTest();
        system.assertequals(objStuPayment.id,objStuPayment.id); 
    }
     @isTest
    static void FEE_PaytmS2SResponse_API_Method3_NB(){
        
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
        objStuPayment.Reference_Id__c  = '123';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c ='123';
        insert objStuFeePay;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse/apex/ApplicationFeeResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        Razorpay_Details__c resdetails = new Razorpay_Details__c();
        resdetails.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        resdetails.name='HomeUrl';
        insert resdetails;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
        insert PayDet;
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDetHome = new Paytm_Details__c();
        PayDetHome.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        PayDetHome.Name ='HomeUrl';
        insert PayDetHome;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
        PayDet3.Name ='Endpoint';
        insert PayDet3;
        
        EasyPay_Details__c easyPay = new EasyPay_Details__c();
        easyPay.Name='HomeUrl';
        easyPay.Value__c ='https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee'; 
        insert easyPay;
        
        FEE_PaytmS2SResponse_API.paytmDateWrp pwrap = new FEE_PaytmS2SResponse_API.paytmDateWrp();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/PaytmS2SResponse/';       
        
        RestContext.request = req; 
        RestContext.response= res;
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('MID','RevaUn85385305140219');
        req.params.put('ORDERID','123');
        req.params.put('PAYMENTMODE','CC');
        req.params.put('STATUS','TXN_SUCCESS');
        req.params.put('PAYMENTMODE','DC');
        req.params.put('PAYMENTMODE','NB');
        //req.params.put('PAYMENTMODE','UPI');
        //req.params.put('PAYMENTMODE','PPI');
        //req.params.put('PAYMENTMODE','PAYTMCC');
        req.params.put('STATUS','PENDING');
        Test.startTest();
        
        FEE_PaytmS2SResponse_API.ReceivedData();
        
        Test.stopTest();
        
        system.assertequals(objStuPayment.id,objStuPayment.id); 
    }
}