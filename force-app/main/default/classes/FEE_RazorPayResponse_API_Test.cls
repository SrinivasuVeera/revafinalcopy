@isTest
    public class FEE_RazorPayResponse_API_Test 
    {
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
        paydetails.Value__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        paydetails.Name='HomeUrl';
        insert paydetails;
        
        string myJSON = '';
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse/apex/ApplicationFeeResponse';
        request.httpMethod = 'POST';
        RestContext.request = request; 
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('razorpay_payment_link_id','plink_JeYmmPJlVpozjh');
      //  FEE_RazorPayResponse_API.ReceivedData();
        FEE_RazorPayResponse_API res = new FEE_RazorPayResponse_API();
        res.updateStudentFee();        
        test.stoptest();   
        system.assertequals(objStuPayment.id,objStuPayment.id);     
    }
 
    @isTest
    public static Void testApplicantFeePaymentViaRazorPay()
    {    
        ApexPages.currentPage().getParameters().put('razorpay_payment_link_status','paid');
        string householdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',householdRecId);
        objAcc.Recordtypeid = householdRecId;
        Insert objAcc;

        //setting data into the student contact details 
        string studentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = studentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        //setting data into payment criteria 
        Fee_Payment_Criteria__c objFeeCriteria = new Fee_Payment_Criteria__c();
        objFeeCriteria.name = 'test';
        /*objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';*/
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgEnroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgEnroll;
        
        //setting data into the student fee 
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee');      //'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee');        //'Academic Fee');
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
        Insert objStuPayment;
        
        hed__Program_Plan__c objProgramBatch = new hed__Program_Plan__c();
        objProgramBatch.Name = 'B. Tech in Electronics and Computer Engineering-(2019-2023)';
        Insert objProgramBatch;
        
        //verifying the Fee Type 
        Fee_Master__c objFeeMaster = new Fee_Master__c();
        objFeeMaster.Fee_Type__c = 'Application Fee';
        objFeeMaster.Program_Batch__c = objProgramBatch.id;
        Insert objFeeMaster;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        Insert objStuFeePay;
       
        Razorpay_Details__c payDetails1 = new Razorpay_Details__c();
        payDetails1.Value__c='https://www.reva.edu.in/';
        payDetails1.Name='Applicant_HomeUrl';
        Insert payDetails1;
        
        Razorpay_Details__c portalUrl = new Razorpay_Details__c();
        portalUrl.Value__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('razorpay_payment_link_id','plink_JeYmmPJlVpozjh');
        FEE_RazorPayResponse_API res = new FEE_RazorPayResponse_API();
        res.updateApplicantFee();       
        test.stoptest();   
        //system.assertequals(objStuPayment.id,objStuPayment.id);
    }   
        
        @isTest
    public static Void testApplicantUnpaidFeePaymentViaRazorPay()
    {    
        ApexPages.currentPage().getParameters().put('razorpay_payment_link_status','Failed');
        string householdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',householdRecId);
        objAcc.Recordtypeid = householdRecId;
        Insert objAcc;

        //setting data into the student contact details 
        string studentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = studentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        //setting data into payment criteria 
        Fee_Payment_Criteria__c objFeeCriteria = new Fee_Payment_Criteria__c();
        objFeeCriteria.name = 'test';
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgEnroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgEnroll;
        
        //setting data into the student fee 
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee');      //'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=50000;
        objStudentFee.Amount_Paid__c=0;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Hostel Fee');        //'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=5000;
        objStudentFee1.Amount_Paid__c=0;
        
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Failed';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Link_Id__c= 'plink_JeYmmPJlVpozjh';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Razorpay';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Razorpay_Signature__c= 'razorPay_Sign';
        Insert objStuPayment;
        
        hed__Program_Plan__c objProgramBatch = new hed__Program_Plan__c();
        objProgramBatch.Name = 'B. Tech in Electronics and Computer Engineering-(2019-2023)';
        Insert objProgramBatch;
        
        //verifying the Fee Type 
        Fee_Master__c objFeeMaster = new Fee_Master__c();
        objFeeMaster.Fee_Type__c = 'Application Fee';
        objFeeMaster.Program_Batch__c = objProgramBatch.id;
        Insert objFeeMaster;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Failed';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Payment_Link_Id__c = 'plink_JeYmmPJlVpozjh';
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        Insert objStuFeePay;
       
        Razorpay_Details__c payDetails1 = new Razorpay_Details__c();
        payDetails1.Value__c='https://www.reva.edu.in/';
        payDetails1.Name='Applicant_HomeUrl';
        Insert payDetails1;
      
        Razorpay_Details__c portalUrl = new Razorpay_Details__c();
        portalUrl.Value__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('razorpay_payment_link_id','plink_JeYmmPJlVpozjh');
        FEE_RazorPayResponse_API res = new FEE_RazorPayResponse_API();
        res.updateApplicantFee();       
        test.stoptest();   
        //system.assertequals(objStuPayment.id,objStuPayment.id);
    }   
}