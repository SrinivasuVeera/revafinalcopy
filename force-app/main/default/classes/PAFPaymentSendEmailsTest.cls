@istest
public class PAFPaymentSendEmailsTest {
 private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }   
   Public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = '{"unicode":"False","sender":"REVAUN","message":{"text":"Dear Applicant\r\n\r\nMake a payment of Rs. 8000.00 to confirm your Provisional Admission at https:/\r\neva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId=0030T00000VQx7FQAT&isPAF=true&stupayid=a1P0T000001WIxSUAW.\r\nIn case of confusion connect with your admission counsellor.\r\n\r\nRegards\r\nREVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
        HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
        return res;
    }
   }
    
      @isTest
    static void testSendDirectPaymentLinkEmail() {
    Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        
        hed__Application__c app = new hed__Application__c(
        		hed__Applicant__c = testContact.Id
        );
        insert app;

        Map<Id, Map<String, String>> testData = new Map<Id, Map<String, String>>();
        Map<String, String> emailData = new Map<String, String>();
        emailData.put('Amount', '1000');
        emailData.put('URL', 'http://example.com');
        emailData.put('CounsellorName', 'John Doe');
        emailData.put('CounsellorMobileNo', '1234567890');
        testData.put(testContact.Id, emailData);
        
        Test.startTest();
        if(!system.isbatch()){
        PAFPaymentSendEmails.sendDirectPaymentLinkEmail(testData);
        PAFPaymentSendEmails.sendConfirmEmail(testData);
        PAFPaymentSendEmails.sendRejectionEmail(testData);
        PAFPaymentSendEmails.sendRejectionEmailOwner(testData);
        }
        Test.stopTest();
}
    
       @isTest
    public static void WhatsAppTest() {
        
        List<Contact> conList = new List<Contact>(); // Create test contacts and necessary related data
        Set<Id> lstStuPay1 = new Set<Id>(); 
        
         Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'jun1@gmail.com',
          MobilePhone = '1234567890' // Assuming this is the format you use for WhatsApp numbers
        );
        conList.add(testContact1);

        // Create related student payment records
        Student_payment__c testPayment1 = new Student_payment__c(
            Mode_of_Payment__c = 'Online',
            Amount__c = 1000,
            Contact__c = testContact1.Id,
            Fee_type__c='University fee',
            Payment_Status__c = 'Failed'
        );
        insert testPayment1;
        lstStuPay1.add(testPayment1.Id);
        
        

         Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //Call the handler
        Test.startTest();
        PAFPaymentSendEmails.WhatstappNotificationCounselor(conList, lstStuPay1, 'payment_reject_counselor');
        Test.stopTest();
    }

    @isTest
    static void testRejectedSmsApplicant_WithValues() {
        // Test data setup
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567890' // Ensure MobilePhone is not null
        );
        insert testContact;

        Student_payment__c testPayment = new Student_payment__c(
            Mode_of_Payment__c = 'Online',
            Amount__c = 1000,
            Contact__c = testContact.Id,
            Fee_type__c='University fee',
            Payment_Status__c = 'Failed'
        );
        insert testPayment;

        // Create a test list to hold the SMS message wrapper
        List<SMS_API_Utility.shortMessageWrp> messageList = new List<SMS_API_Utility.shortMessageWrp>();

        // Call the method to be tested
        Test.startTest();
        PAFPaymentSendEmails.RejectedSmsApplicant(testPayment, messageList);
        PAFPaymentSendEmails.RejectedSmsOwner(testPayment, messageList);
        Test.stopTest();

       }

    @isTest
    static void testMakeCalloutAsync() {
        // Create test data
       
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567890' // Ensure MobilePhone is not null
        );
        insert testContact;

        Student_payment__c testPayment = new Student_payment__c(
            Mode_of_Payment__c = 'Online',
            Amount__c = 1000,
            Contact__c = testContact.Id,
            Fee_type__c='University fee',
            Payment_Status__c = 'Failed'
        );
        insert testPayment;
        
        Set<Id> testSet = new Set<Id>();
        testSet.add(testPayment.Id);
        
        
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        // Call the method under test
        PAFPaymentSendEmails.makeCalloutAsync(testSet);
        Test.stopTest();
        
    }
    @isTest
static void testPAFPaymentEmailQueueable() {

    // Create Contact
    Contact con = new Contact(
        FirstName = 'Test',
        LastName = 'Applicant',
        Admission_Mode__c='UQ',
        Email = 'testapplicant@test.com'
    );
    insert con;

    // Create Application
    hed__Application__c app = new hed__Application__c(
        hed__Applicant__c = con.Id,
        
        hed__Application_Status__c = 'Provisionally Offered'
    );
    insert app;

    // Create Student Fee
    Student_Fee__c fee = new Student_Fee__c(
        Contact__c = con.Id,
        Fee_Type__c = 'University Fee',
        Fee_Year__c = '1st Year',
        Actual_Program_Fee__c = 50000
    );
    insert fee;

    // Create Student Payment
    Student_Payment__c pay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 10000,
        Fee_Type__c = 'University Fee',
        Payment_Status__c = 'Success'
    );
    insert pay;

    // Email data map
    Map<Id, Map<String,String>> testMap = new Map<Id, Map<String,String>>();

    Map<String,String> innerMap = new Map<String,String>();
    innerMap.put('Amount','10000');
    innerMap.put('URL','https://test.com');
    innerMap.put('CounsellorName','Test Counselor');
    innerMap.put('CounsellorMobileNo','9999999999');

    testMap.put(con.Id, innerMap);

    Test.startTest();

    // Execute Queueable
    System.enqueueJob(new PAFPaymentEmailQueueable(testMap));

    Test.stopTest();
}
 
}