@isTest
private class FEE_RazorpayPendingPaymentUpdateTest {
    
    private class RazorpayMock implements HttpCalloutMock {
        private Boolean isSuccess;
        public RazorpayMock(Boolean isSuccess) { this.isSuccess = isSuccess; }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (isSuccess) {                
                res.setBody('{"status": "paid", "payments": [{"payment_id": "pay_TEST12345", "method": "card"}]}');
            } else {
                res.setBody('{"status": "failed"}');
            }
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void setup() {      
        insert new Razorpay_Details__c(Name = 'UserName', Value__c = 'test');
        insert new Razorpay_Details__c(Name = 'Password', Value__c = 'test');
        insert new Razorpay_Details__c(Name = 'FetchPaymentEndpoint', Value__c = 'https://api.razorpay.com/v1/');
        
        Id applicantRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        Contact con = new Contact(
            LastName = 'Academic Student', 
            Application_Number__c = 'APP-999',
            RecordTypeId = applicantRecTypeId
        );
        insert con;
        
        hed__Application__c app = new hed__Application__c(
            Application_Number__c = 'APP-999',
            Provisional_Admission_Fee_Paid__c = false
        );
        insert app;
        
        Student_Fee__c sf = new Student_Fee__c(
            Contact__c = con.Id,
            Fee_Year__c = '1st Year'
        );
        insert sf;
       
        Student_Payment__c sp = new Student_Payment__c(
            Contact__c = con.Id,
            Payment_Status__c = 'Pending',
            Payment_Gateway__c = 'Razorpay',
            Reference_Id__c = 'REF-ACAD-001',
            Payment_Link_Id__c = 'plink_Academic123',
            Fee_Type__c = 'Tuition Fee' // Anything but 'Application Fee'
        );
        insert sp;
        
        insert new Student_Fee_Payment__c(
            Student_Payment__c = sp.Id, 
            Line_Item_Payment_Status__c = 'Pending'
        );
    }
    
    @isTest
    static void testAcademicFeeSuccess() {
        
        Test.setMock(HttpCalloutMock.class, new RazorpayMock(true));        
        Test.startTest();
        FEE_RazorpayPendingPaymentUpdateBatch batch = new FEE_RazorpayPendingPaymentUpdateBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        Student_Payment__c result = [SELECT Payment_Status__c, Payment_Mode_Type__c FROM Student_Payment__c WHERE Reference_Id__c = 'REF-ACAD-001' LIMIT 1];
        System.assertEquals('Success', result.Payment_Status__c);
        System.assertEquals('card', result.Payment_Mode_Type__c);
    }
    
    @isTest
    static void testBatchSuccess() {
       
        Test.setMock(HttpCalloutMock.class, new RazorpayMock(true));
        Test.startTest();
        Database.executeBatch(new FEE_RazorpayPendingPaymentUpdateBatch());
        Test.stopTest();
        
        List<Student_Payment__c> results = [SELECT Payment_Status__c FROM Student_Payment__c WHERE Payment_Status__c = 'Success'];
        System.assert(results.size() > 0, 'At least one record should have succeeded');
    }
    
    @isTest
    static void testBatchFailure() {
        Test.setMock(HttpCalloutMock.class, new RazorpayMock(false));
        Test.startTest();
        Database.executeBatch(new FEE_RazorpayPendingPaymentUpdateBatch());
        Test.stopTest();
        
        Student_Payment__c result = [SELECT Payment_Status__c FROM Student_Payment__c LIMIT 1];
        System.assertEquals('Failed', result.Payment_Status__c);
    }

    @isTest
    static void testSchedulerExecution() {
        Test.setMock(HttpCalloutMock.class, new RazorpayMock(true));
        Test.startTest();    
        FEE_RazorpayPendingPaymentUpdateBatch sch = new FEE_RazorpayPendingPaymentUpdateBatch();
        sch.execute(null);     
        Test.stopTest(); 
        
        Student_Payment__c result = [SELECT Payment_Status__c FROM Student_Payment__c LIMIT 1];
        System.assertNotEquals('Pending', result.Payment_Status__c);
    }
}