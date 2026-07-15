@istest
public class StudentSupportWAppNotificationTest {
Public class RestMock implements HttpCalloutMock {
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
    static void testSendChangedCaseWhatsAppNotification() {
        
         Contact testContact = new Contact(LastName = 'Test Contact', MobilePhone = '1234567890',Email = 'test@example.com');
        insert testContact;
        
        // Test data setup
        Case testCase = new Case(
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'Test complaint description',
            Status = 'New',
            contactId=testContact.Id
        );
        insert testCase;

        
         Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        // Call the method to test
        Update_Student_Support_WAppNotification.sendChangedCaseWhatsAppNotification(new List<String>{testCase.Id});
        New_Student_Support_WhatsAppNotification.sendNewCaseWhatsAppNotification(new List<String>{testCase.Id});
        Test.stopTest();

        // Assertions
        // Add your assertions here
    }
}