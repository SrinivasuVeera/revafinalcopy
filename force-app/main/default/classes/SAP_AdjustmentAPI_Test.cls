@isTest
public class SAP_AdjustmentAPI_Test 
{
    @TestSetup
    static void setupTestData() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
   
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id,
            MobilePhone = '1234567890'
        );
        insert testContact;
        

        Student_Fee__c testStudentFee = new Student_Fee__c(
            Demand_Number__c = 'D123',
            Amount__c = 10000,
            Fee_Type__c ='University Fee',
            Contact__c = testContact.Id
        );
        insert testStudentFee;
        

        Student_Payment__c testStudentPayment = new Student_Payment__c(
            Demand_Number__c = 'D123',
            Amount__c = 5000,
            Contact__c = testContact.Id
            
        );
        insert testStudentPayment;
        
        
    }
    
    @isTest
    static void testPaymentAdjustments_MissingModeOfPayment() {
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        req.Adjusted_DemandNo = 'D123';
        req.Mode_of_Payment = null; 
        
        SAP_AdjustmentAPI.Payment payment = new SAP_AdjustmentAPI.Payment();
        payment.Demand_Number = 'D123';
        payment.Amount = 5000;
        payment.Application_Number = '12345';
        
        req.Payment = new List<SAP_AdjustmentAPI.Payment>{payment};
            requestData.add(req);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testPaymentAdjustments_MissingAdjustedDemandNo() {
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        req.Adjusted_DemandNo = null; 
        req.Mode_of_Payment = 'Online';
        
        SAP_AdjustmentAPI.Payment payment = new SAP_AdjustmentAPI.Payment();
        payment.Demand_Number = 'D123';
        payment.Amount = 5000;
        payment.Application_Number = '12345';
        
        req.Payment = new List<SAP_AdjustmentAPI.Payment>{payment};
            requestData.add(req);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testPaymentAdjustments_OfflinePayment() {
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        req.Adjusted_DemandNo = 'D123';
        req.Mode_of_Payment = 'Offline';
        
        SAP_AdjustmentAPI.Payment payment = new SAP_AdjustmentAPI.Payment();
        payment.Demand_Number = 'D123';
        payment.Amount = 5000;
        payment.Application_Number = '12345';
        
        req.Payment = new List<SAP_AdjustmentAPI.Payment>{payment};
            requestData.add(req);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
    }
    
    //@isTest
    static void testPaymentAdjustments_NoPaymentData() {
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        req.Adjusted_DemandNo = 'D123';
        req.Mode_of_Payment = 'Online';
        
        req.Payment = null; 
        requestData.add(req);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
        
    }
    
    
    
    @isTest
    static void testProcessStudentPaymentsNegativeEntrySCN1() {
        Map<String, Decimal> demandNegativeEntryAmount = new Map<String, Decimal>();
        demandNegativeEntryAmount.put('D123', 5000);
        
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.processStudentPaymentsNegativeEntrySCN1(demandNegativeEntryAmount, responseList);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testInnerStudentPaymentsPositiveEntrySCN1() {
        Map<String, Decimal> demandAmountInnerMap = new Map<String, Decimal>();
        demandAmountInnerMap.put('D123', 5000);
        
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.innerStudentPaymentsPostiveEntrySCN1(demandAmountInnerMap, responseList);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testProcessStudentPaymentsNegativeEntrySCN2() {
        Map<String, Decimal> stdFeeNegativeEntryAmountSCN2 = new Map<String, Decimal>();
        stdFeeNegativeEntryAmountSCN2.put('D123', 5000);
        
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.processStudentPaymentsNegativeEntrySCN2(stdFeeNegativeEntryAmountSCN2, responseList);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testInnerStudentPaymentsPositiveEntrySCN3() {
        Map<String, Decimal> demandAmountInnerMapSCN3 = new Map<String, Decimal>();
        demandAmountInnerMapSCN3.put('D123', -5000);
        
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.innerStudentPaymentsPostiveEntrySCN3(demandAmountInnerMapSCN3, responseList);
        Test.stopTest();
        
        
    }
    @isTest
    static void testInnerStudentPaymentsPositiveEntrySCN2() {
        Map<String, Decimal> demandAmountInnerMapSCN2 = new Map<String, Decimal>();
        demandAmountInnerMapSCN2.put('D123', 5000);
        
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.innerStudentPaymentsPostiveEntrySCN2(demandAmountInnerMapSCN2, responseList);
        Test.stopTest();
        
        
    }
    @isTest
    static void testProcessStudentPaymentsNegativeEntrySCN3() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id,
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        Student_Fee__c testStudentFee = new Student_Fee__c(
            Demand_Number__c = 'D123',
            Amount__c = 10000,
            Contact__c = testContact.Id,
            Fee_Type__c = 'University Fee'
        );
        insert testStudentFee;
        
        Student_Payment__c testStudentPayment = new Student_Payment__c(
            Demand_Number__c = 'D123',
            Amount__c = 5000,
            Contact__c = testContact.Id
        );
        insert testStudentPayment;
        
        Student_Fee_Payment__c testStudentFeePayment = new Student_Fee_Payment__c(
            Student_Fee__c = testStudentFee.Id,
            Amount__c = 6000,
            Line_Item_Payment_Status__c = 'Pending',
            Student_Payment__c = testStudentPayment.Id
        );
        insert testStudentFeePayment;
        
        
        
        Map<String, Decimal> stPayNegativeEntryAmountSCN3 = new Map<String, Decimal>();
        //stPayNegativeEntryAmountSCN3.put('D123', 5000);
        stPayNegativeEntryAmountSCN3.put(testStudentPayment.Id, -5000);
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.processStudentPaymentsNegativeEntrySCN3(stPayNegativeEntryAmountSCN3, responseList);
        Test.stopTest();
        
        
    }
       @isTest
    static void testProcessStudentPaymentsNegativeEntrySCN22() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id,
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        Student_Fee__c testStudentFee = new Student_Fee__c(
            Demand_Number__c = 'D123',
            Amount__c = 10000,
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee'
        );
        insert testStudentFee;
        
        Student_Payment__c testStudentPayment = new Student_Payment__c(
            Demand_Number__c = 'D123',
            Amount__c = 5000,
            Contact__c = testContact.Id
        );
        insert testStudentPayment;
        
        Student_Fee_Payment__c testStudentFeePayment = new Student_Fee_Payment__c(
            Student_Fee__c = testStudentFee.Id,
            Amount__c = 6000,
            Line_Item_Payment_Status__c = 'Pending',
            Student_Payment__c = testStudentPayment.Id
        );
        insert testStudentFeePayment;
        
        
        
        Map<String, Decimal> stPayNegativeEntryAmountSCN2 = new Map<String, Decimal>();
        //stPayNegativeEntryAmountSCN3.put('D123', 5000);
        stPayNegativeEntryAmountSCN2.put(testStudentFeePayment.Id, -5000);
        List<SAP_AdjustmentAPI.ResponseData> responseList = new List<SAP_AdjustmentAPI.ResponseData>();
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = 
            SAP_AdjustmentAPI.processStudentPaymentsNegativeEntrySCN2(stPayNegativeEntryAmountSCN2, responseList);
        Test.stopTest();
        
        
    }
    @isTest
    static void testHttpCallout_MockResponse() {
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        req.Adjusted_DemandNo = 'D123';
        req.Mode_of_Payment = 'Online';
        
        SAP_AdjustmentAPI.Payment payment = new SAP_AdjustmentAPI.Payment();
        payment.Demand_Number = 'D123';
        payment.Amount = 5000;
        payment.Application_Number = '12345';
        
        req.Payment = new List<SAP_AdjustmentAPI.Payment>{payment};
            requestData.add(req);
        
   
        SAP_ReconAPICalloutMock mock = new SAP_ReconAPICalloutMock(200, 'OK', 
                                                                   '{"StatusMessage":"Success","StatusCode":0}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
    }
    @isTest
    static void testPaymentAdjustments_OfflinePayment2() {
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        //req.Adjusted_DemandNo = 'D123';
        // req.Mode_of_Payment = 'Offline';
        
        SAP_AdjustmentAPI.Payment payment = new SAP_AdjustmentAPI.Payment();
        payment.Demand_Number = 'D123';
        payment.Amount = 5000;
        payment.Application_Number = '12345';
        
        req.Payment = new List<SAP_AdjustmentAPI.Payment>{payment};
            requestData.add(req);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
    }
    @isTest
    static void testPaymentAdjustments_OnlinePayment3() {
        Student_Fee__c sf =[select id from Student_Fee__c Limit 1];
        List<SAP_AdjustmentAPI.RequestData> requestData = new List<SAP_AdjustmentAPI.RequestData>();
        SAP_AdjustmentAPI.RequestData req = new SAP_AdjustmentAPI.RequestData();
        req.Adjusted_DemandNo = 'D123';
        req.Mode_of_Payment ='Online';
        req.SFDCRecordId = sf.Id;
        
        SAP_AdjustmentAPI.Payment payment = new SAP_AdjustmentAPI.Payment();
        payment.Demand_Number = 'D123';
        payment.Amount = 5000;
        payment.Application_Number = '12345';
        
        req.Payment = new List<SAP_AdjustmentAPI.Payment>{payment};
            requestData.add(req);
        
        Test.startTest();
        List<SAP_AdjustmentAPI.ResponseData> responses = SAP_AdjustmentAPI.paymentAdjustments(requestData);
        Test.stopTest();
        
    }
    
      @isTest
    static void testGetContactFromPayments() {
        Id studentPaymentId = [SELECT Id FROM Student_Payment__c LIMIT 1].Id;
        Set<Id> stdPaymentIds = new Set<Id>{ studentPaymentId };

        Test.startTest();
        Map<String, String> result = SAP_AdjustmentAPI.getContactfromPayments(stdPaymentIds);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'getContactfromPayments should return at least one record');
    }

   
    @isTest
    static void testGetContactIdFromPaymentid() {
        Id studentPaymentId = [SELECT Id FROM Student_Payment__c LIMIT 1].Id;

        Test.startTest();
        Id contactId = SAP_AdjustmentAPI.getContactIdFromPaymentid(String.valueOf(studentPaymentId));
        Test.stopTest();

        System.assertNotEquals(null, contactId, 'getContactIdFromPaymentid should return a valid Contact Id');
    }

   
    //@isTest
    static void testGetStudentFeeIdBasedOnStudentPaymentId() {
        Id studentPaymentId = [SELECT Id FROM Student_Payment__c LIMIT 1].Id;

        Test.startTest();
        Id studentFeeId = SAP_AdjustmentAPI.getStudentFeeIdBasedonStudentpaymentId(String.valueOf(studentPaymentId));
        Test.stopTest();

        System.assertNotEquals(null, studentFeeId, 'getStudentFeeIdBasedonStudentpaymentId should return a valid Student Fee Id');
    }

    
    
    @isTest
    static void testGetContactIdForSFeeRecordId() {
        Id studentFeeId = [SELECT Id FROM Student_Fee__c LIMIT 1].Id;

        Test.startTest();
        Id contactId = SAP_AdjustmentAPI.getContactIdForSFeeRecordId(String.valueOf(studentFeeId));
        Test.stopTest();

        System.assertNotEquals(null, contactId, 'getContactIdForSFeeRecordId should return a valid Contact Id');
    }
}