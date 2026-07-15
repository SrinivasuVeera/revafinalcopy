@isTest
public class FEE_GrayQuest_Test {

    private class GrayQuestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true, "status_code": 201, "data": {"redirection_url": "https://grayquest.test/payment"}}');
            res.setStatusCode(201);
            return res;
        }
    }

    @testSetup
    static void setupData() {
        // Keep Contact and Payment setup here
        Contact con = new Contact(FirstName='Test', LastName='Student', Application_Number__c='26170400046', Email='test@test.com');
        insert con;

        Student_Payment__c testPay = new Student_Payment__c(
            Amount__c = 1000,
            Contact__c = con.Id,
            Payment_Status__c = 'Pending',
            Mode_of_Payment__c = 'Online',
            Reference_Id__c = '150124790'
        );
        insert testPay;

        Student_Fee__c testFee = new Student_Fee__c(
            Amount__c = 1000, 
            Fee_Type__c = 'Tuition Fee', 
            Contact__c = con.Id,
            Fee_Year__c = '1st Year'
        );
        insert testFee;

        insert new Student_Fee_Payment__c(
            Student_Payment__c = testPay.Id,
            Student_Fee__c = testFee.Id,
            Amount__c = 1000,
            Reference_Id__c = '150124790',
            Line_Item_Payment_Status__c = 'Pending'
        );
    }

   @isTest
    static void testGenerateLink() {
        Student_Payment__c sp = [SELECT Id, Amount__c, Contact__c, Program_Enrollment__c FROM Student_Payment__c LIMIT 1];
        Contact con = [SELECT Id, Application_Number__c FROM Contact LIMIT 1];
        
        List<Object> paymentList = new List<Object>();
        Map<String, Object> payMap = new Map<String, Object>();
        payMap.put('Id', (String)sp.Id);
        payMap.put('Amount__c', '1000'); // Use string
        payMap.put('Contact__c', (String)con.Id);
        payMap.put('Program_Enrollment__c', (String)sp.Program_Enrollment__c);
        
        Map<String, Object> conMap = new Map<String, Object>();
        conMap.put('Application_Number__c', '26170400046');
        payMap.put('Contact__r', conMap);
        
        paymentList.add(payMap);
    
        Test.setMock(HttpCalloutMock.class, new GrayQuestMock());
        
        Test.startTest();
        FEE_LoggedInApplicantPayment_Ctrl.GrayQuestResponse result = 
            FEE_LoggedInApplicantPayment_Ctrl.grayQuestGenerateLink(paymentList, 1000, 'Single');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    @isTest
    static void testWebhookSuccess() {
        String jsonReq = '{"event": "dt.payment.captured", "reference_id": "150124790", "payment_details": {"code": "GQ-TXN-SUCCESS", "method": "UPI"}}';
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/GrayQuestWebhook/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonReq);
        RestContext.request = request;

        Test.startTest();
        FEE_GrayQuestWebhookHandler.handleNotification();
        Test.stopTest(); 

        Student_Payment__c updatedPay = [SELECT Payment_Status__c FROM Student_Payment__c WHERE Reference_Id__c = '150124790' LIMIT 1];
        System.assertEquals('Success', updatedPay.Payment_Status__c);
    }

    @isTest
    static void testWebhookReject() {
        String jsonReq = '{"event": "emi.rejected", "reference_id": "150124790", "application_details": {"code": "GQ-TXN-REJECT"}}';
        
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/GrayQuestWebhook/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonReq);
        RestContext.request = request;

        Test.startTest();
        FEE_GrayQuestWebhookHandler.handleNotification();
        Test.stopTest();

        Student_Payment__c updatedPay = [SELECT Payment_Status__c FROM Student_Payment__c WHERE Reference_Id__c = '150124790' LIMIT 1];
        System.assertEquals('Failed', updatedPay.Payment_Status__c);
    }
}