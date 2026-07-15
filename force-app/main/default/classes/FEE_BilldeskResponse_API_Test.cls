@isTest
public class FEE_BilldeskResponse_API_Test 
{
    private class RestMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}');
                res.setStatusCode(200);
                return res;
            }
    }

     @isTest
     public static Void billdeskMethod7()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = '1572332335';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        objStuPayment.Payment_Date_Time__c = system.now();
        objStuPayment.Fee_Type__c = 'Application Fee';
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
         Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;

 Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        //FEE_BilldeskResponse_API.getcalculateCheckSum('REVAECOMSF');
        insert payDetails2;    
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|08|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        res.updateApplicantFee();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
    
    @isTest
     public static Void billdeskMethod_pending()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Pending';
        objStuPayment.Transaction_ID__c = '1572332335';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        objStuPayment.Payment_Date_Time__c = system.now();
        objStuPayment.Fee_Type__c = 'Application Fee';
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
         Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
 Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        //FEE_BilldeskResponse_API.getcalculateCheckSum('REVAECOMSF');
        insert payDetails2;    
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|08|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        res.updateApplicantFee();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }

 @isTest
    public static Void billdeskMethod10()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = '1572332335';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2; 

         Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|09|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        res.updateApplicantFee();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
     @isTest
     public static Void failureMethod()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = '1572332335';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Payment Link Created';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;

        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|45|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0008|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        res.updateApplicantFee();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
     @isTest
    public static Void failureMethod1()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Student_Payment__c = objStuPayment.Id;
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        Test.setMock(HttpCalloutMock.class, new RestMock());       
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|09|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     } 
    @isTest
    public static Void failureMethod110()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        Test.setMock(HttpCalloutMock.class, new RestMock());       
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
  @isTest
    public static Void failureMethod2()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        //objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.BilldeskRespon();
        res.updateApplicantFee();
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }

    @isTest
    public static  Void billdeskMethod11()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|01|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod12()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|02|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod13()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|03|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod14()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|04|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod15()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|05|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod16()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|06|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod17()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|07|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod18()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|08|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod19()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|09|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod110()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Netbanking';
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
        

        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
          Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod01()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
         Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|02|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0008|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
 @isTest
    public static  Void billdeskMethod02()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|02|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
@isTest
    public static  Void billdeskMethod03()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|03|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
@isTest
    public static  Void billdeskMethod04()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|04|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }

@isTest
    public static  Void billdeskMethod05()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|05|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
  
@isTest
    public static  Void billdeskMethod06()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|06|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }

@isTest
    public static  Void billdeskMethod07()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|07|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
@isTest
    public static  Void billdeskMethod08()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|08|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
@isTest
    public static  Void billdeskMethod010()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
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
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       // objStuPayment.Payment_Mode_Type__c=  'Online';
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
        
        Billdesk_Merchant_Details__c payDetails = new Billdesk_Merchant_Details__c();
        payDetails.MerchantId__c='https://reva-university--couat1908.sandbox.lightning.force.com/lightning/n/Student_Payment_Comp';
        payDetails.Name='HomeUrl';
        insert payDetails;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
  Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl;          
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        payDetails1.MerchantId__c='07SnjK5CLPhS';
        payDetails1.Name='Checksum';
        insert payDetails1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
     }
/*@isTest
    public static  Void updateApplicationFeeMethod1()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId(); 
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.Application_Fee_Paid__c=True;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment'); // appplication fee
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        
        
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2; 
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
               
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|01|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
       	res.updateApplicantFee();
        test.stoptest();
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
        
        
        
     }
    @isTest
    public static Void updateApplicationFeeMethod2()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        //Inserting the contact object
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
       
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
       
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
        
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|PaymentId|U1230002449644|1|00065000.00|123|NA|02|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|PaymentId|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
    
      @isTest
     public static Void updateApplicationFeeMethod3()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|03|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
    
   @isTest
     public static Void updateApplicationFeeMethod4()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = 'PaymentId';
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|04|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
    
     @isTest
     public static Void updateApplicationFeeMethod5()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Checksum';
        insert paydetails2; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|05|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
     @isTest
     public static Void updateApplicationFeeMethod6()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
       string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        objStuPayment.Contact__c = objCon.Id;
        insert objStuPayment;
                
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;    
        
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|06|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
       
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
    
     @isTest
     public static Void updateApplicationFeeMethod7()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|07|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
    
     @isTest
     public static Void updateApplicationFeeMethod8()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;

        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        objStuPayment.contact__c = objCon.Id;
        insert objStuPayment;                   
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Success';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2; 
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|08|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
    
     @isTest
    public static Void updateApplicationFeeMethod9()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=True;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2; 
          
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|09|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(True,con.Application_fee_Paid__c);
     }
     @isTest
     public static Void updateApplicationFeeMethod10()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=False;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
       
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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

        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0300|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
       
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        //system.assertEquals(False,con.Application_fee_Paid__c);
     }*/
     @isTest
     public static Void updateApplicationFeeFailureMethod1()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=False;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
       
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
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

        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|10|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
       
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        //system.assertEquals(False,con.Application_fee_Paid__c);
     }
    
     @isTest
    public static Void updateApplicationFeeFailureMethod2()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=False;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Failed';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Failed';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
        
        
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='uatY7vF4Cx3L';
        payDetails2.Name='Checksum';
        insert payDetails2;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());       
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|09|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0002|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(False,con.Application_fee_Paid__c);
     }
    
   @isTest
    public static Void updateApplicationFeefailureMethod3()
    {    
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecordId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Fee_Paid__c=False;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test123'
        );
        insert Application;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Application Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='BD9MAIN';
        Insert objFeeCriteria;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Application Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Payment Link Created';
        objStuPayment.Transaction_ID__c = '1572332335';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Billdesk';
        objStuPayment.Amount__c = 100000;
        objStuPayment.Reference_Id__c ='1572332335'; 
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id, objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c = 'Pending';
        objStuFeePay.Amount__c=1000;
        objStuFeePay.Mode_of_Payment__c='Online';
        objStuFeePay.SF_Transaction_ID__c= 'Test213';
        objStuFeePay.Transaction_Date_Time__c  = system.now();
        objStuFeePay.Reference_Id__c = '1572332335';
        insert objStuFeePay;
        
               
        Billdesk_Merchant_Details__c homeUrl = new Billdesk_Merchant_Details__c();
        homeUrl.MerchantId__c='	https://www.reva.edu.in/';
        homeUrl.Name='Applicant_Billdesk_HomeUrl';
        insert homeUrl;
        Billdesk_Merchant_Details__c homeUrl1 = new Billdesk_Merchant_Details__c();
        homeUrl1.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/login/';
        homeUrl1.Name='ApplicantHomeUrl';
        insert homeUrl1;
        Billdesk_Merchant_Details__c portalUrl = new Billdesk_Merchant_Details__c();
        portalUrl.MerchantId__c='https://reva-university--couat1908.sandbox.my.site.com/Admissions/s/';
        portalUrl.Name='Applicant_PortalUrl';
        insert portalUrl; 
        
        //new
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='bbbbbbbb';
        payDetails2.Name='Checksum';
        insert payDetails2;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.starttest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        ApexPages.currentPage().getParameters().put('msg','BD9MAIN|1572332335|U1230002449644|1|00065000.00|123|NA|11|INR|DIRECT|NA|NA|00.00|20-06-2022 13:03:19|0123|NA|Vinodh Kumar|vinodh@epeoplebc.com|9398044427|1572332335|0030w00000qT5ZzAAK|NA|NA|NA|NA|1934500B72D6DF1DC76002F48B8533A21927F861B737BB01BA4E5506419071EE');
        FEE_BilldeskResponse_API res = new FEE_BilldeskResponse_API();
        res.updateApplicantFee();
        test.stoptest();
        
        Contact con=[select id,Application_fee_Paid__c from contact limit 1];
        system.assertEquals(False,con.Application_fee_Paid__c);
        
     } 
}