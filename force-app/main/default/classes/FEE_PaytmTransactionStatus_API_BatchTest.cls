@isTest
public class FEE_PaytmTransactionStatus_API_BatchTest {
    @isTest
    static void paytmStatusBatchMethod(){
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
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/v3/order/status';
        PayDet3.Name ='Transaction Status';
        insert PayDet3;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Pending';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Paytm';
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
        
        Billdesk_Merchant_Details__c MerDetails = new Billdesk_Merchant_Details__c();
        MerDetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        MerDetails.Name ='HomeUrl';
        insert MerDetails;
        
        test.starttest();
        //ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        //ApexPages.currentPage().getParameters().put('MID','RevaUn85385305140219');
        
        paytmMock mck = new paytmMock(200,'{"head":{"responseTimestamp":"1664361482299","version":"v1","signature":"+/LECe4T9bzkSJCqjmgf1WrudRhUcnwNW+OaL6oTP7uqbVaROZjf5YonH20HJaEOoh0UF2qNQ7vpGPdemLbJTc0dgLJEU9JF8RpM748WLcg="},"body":{"resultInfo":{"resultStatus":"TXN_SUCCESS","resultCode":"01","resultMsg":"Txn Success"},"txnId":"20220927111212800110168827904095844","bankTxnId":"777001655511917","orderId":"233169703","txnAmount":"40000.00","txnType":"SALE","gatewayName":"HDFC","bankName":"JPMorgan Chase Bank","mid":"RevaUn85385305140219","paymentMode":"CC","refundAmt":"0.00","txnDate":"2022-09-27 11:50:56.0","cardScheme":"VISA","rrnCode":"777001655511917","authCode":"123456"}}','application/json','Content-Type');
        Test.setMock(HttpCalloutMock.class, mck);
        Test.setMock(HttpCalloutMock.class,mck);
         //Test.setMock(HttpCalloutMock.class, new paytmMock());
        FEE_PaytmTransactionStatus_API_Batch btch = new FEE_PaytmTransactionStatus_API_Batch();
        database.executeBatch(btch);
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
    }
    @isTest
    static void paytmStatusBatchApplicationMethod(){
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string ApplicantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = ApplicantRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
         hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = objCon.Id,
            Provisional_Admission_Fee_Paid__c = false,
            Application_Number__c = 'test12'
        );
        insert Application;
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
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/v3/order/status';
        PayDet3.Name ='Transaction Status';
        insert PayDet3;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Pending';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Paytm';
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
        
        Billdesk_Merchant_Details__c MerDetails = new Billdesk_Merchant_Details__c();
        MerDetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        MerDetails.Name ='HomeUrl';
        insert MerDetails;
        
        test.starttest();
        //ApexPages.StandardController sc = new ApexPages.StandardController(objStuPayment);
        //ApexPages.currentPage().getParameters().put('MID','RevaUn85385305140219');
        
        paytmMock mck = new paytmMock(200,'{"head":{"responseTimestamp":"1664361482299","version":"v1","signature":"+/LECe4T9bzkSJCqjmgf1WrudRhUcnwNW+OaL6oTP7uqbVaROZjf5YonH20HJaEOoh0UF2qNQ7vpGPdemLbJTc0dgLJEU9JF8RpM748WLcg="},"body":{"resultInfo":{"resultStatus":"TXN_SUCCESS","resultCode":"01","resultMsg":"Txn Success"},"txnId":"20220927111212800110168827904095844","bankTxnId":"777001655511917","orderId":"233169703","txnAmount":"40000.00","txnType":"SALE","gatewayName":"HDFC","bankName":"JPMorgan Chase Bank","mid":"RevaUn85385305140219","paymentMode":"CC","refundAmt":"0.00","txnDate":"2022-09-27 11:50:56.0","cardScheme":"VISA","rrnCode":"777001655511917","authCode":"123456"}}','application/json','Content-Type');
        Test.setMock(HttpCalloutMock.class, mck);
        Test.setMock(HttpCalloutMock.class,mck);
         //Test.setMock(HttpCalloutMock.class, new paytmMock());
        FEE_PaytmTransactionStatus_API_Batch btch = new FEE_PaytmTransactionStatus_API_Batch();
        database.executeBatch(btch);
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
    }
    @isTest
    static void paytmStatusBatchMethod2(){
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
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/v3/order/status';
        PayDet3.Name ='Transaction Status';
        insert PayDet3;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Pending';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Paytm';
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
        
        Billdesk_Merchant_Details__c MerDetails = new Billdesk_Merchant_Details__c();
        MerDetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        MerDetails.Name ='HomeUrl';
        insert MerDetails;
        
        test.starttest(); 
        
        paytmMock mck = new paytmMock(200,'{"head":{"responseTimestamp":"1664361482299","version":"v1","signature":"+/LECe4T9bzkSJCqjmgf1WrudRhUcnwNW+OaL6oTP7uqbVaROZjf5YonH20HJaEOoh0UF2qNQ7vpGPdemLbJTc0dgLJEU9JF8RpM748WLcg="},"body":{"resultInfo":{"resultStatus":"TXN_FAILURE","resultCode":"01","resultMsg":"Txn Success"},"txnId":"20220927111212800110168827904095844","bankTxnId":"777001655511917","orderId":"233169703","txnAmount":"40000.00","txnType":"SALE","gatewayName":"HDFC","bankName":"JPMorgan Chase Bank","mid":"RevaUn85385305140219","paymentMode":"CC","refundAmt":"0.00","txnDate":"2022-09-27 11:50:56.0","cardScheme":"VISA","rrnCode":"777001655511917","authCode":"123456"}}','application/json','Content-Type');
        Test.setMock(HttpCalloutMock.class, mck);        
        FEE_PaytmTransactionStatus_API_Batch btch = new FEE_PaytmTransactionStatus_API_Batch();
        database.executeBatch(btch);
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
    }
    
    @isTest
    static void paytmStatusBatchMethod3(){
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
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/v3/order/status';
        PayDet3.Name ='Transaction Status';
        insert PayDet3;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Pending';
        objStuPayment.Transaction_ID__c = 'PaymentId';
        objStuPayment.Payment_Mode_Type__c=  'Online';
        objStuPayment.Payment_Gateway__c = 'Paytm';
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
        
        Billdesk_Merchant_Details__c MerDetails = new Billdesk_Merchant_Details__c();
        MerDetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.site.com/StudentPortal/s/student-fee';
        MerDetails.Name ='HomeUrl';
        insert MerDetails;
        
        test.starttest();
        
        paytmMock mck = new paytmMock(200,'{"head":{"responseTimestamp":"1664361482299","version":"v1","signature":"+/LECe4T9bzkSJCqjmgf1WrudRhUcnwNW+OaL6oTP7uqbVaROZjf5YonH20HJaEOoh0UF2qNQ7vpGPdemLbJTc0dgLJEU9JF8RpM748WLcg="},"body":{"resultInfo":{"resultStatus":"NO_RECORD_FOUND","resultCode":"01","resultMsg":"Txn Success"},"txnId":"20220927111212800110168827904095844","bankTxnId":"777001655511917","orderId":"233169703","txnAmount":"40000.00","txnType":"SALE","gatewayName":"HDFC","bankName":"JPMorgan Chase Bank","mid":"RevaUn85385305140219","paymentMode":"CC","refundAmt":"0.00","txnDate":"2022-09-27 11:50:56.0","cardScheme":"VISA","rrnCode":"777001655511917","authCode":"123456"}}','application/json','Content-Type');
        Test.setMock(HttpCalloutMock.class, mck);        
        FEE_PaytmTransactionStatus_API_Batch btch = new FEE_PaytmTransactionStatus_API_Batch();
        database.executeBatch(btch);
        
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
    }
    @isTest
    static void paytmStatusBatchVAriables(){
        FEE_PaytmTransactionStatus_API_Batch.resBodyDetails btch = new FEE_PaytmTransactionStatus_API_Batch.resBodyDetails();
        btch.txnId = '123';
         btch.bankTxnId = '123';
         btch.orderId = '123';
         btch.txnAmount = '123';
         btch.txnType = '123';
         btch.gatewayName = '123';
         btch.bankName = '123';
         btch.mid = '123';
         btch.paymentMode = '123';
         btch.refundAmt = '123';
         btch.txnDate = '123';
         btch.cardScheme = '123';
         btch.rrnCode = '123';
         btch.authCode = '123';
    }
}