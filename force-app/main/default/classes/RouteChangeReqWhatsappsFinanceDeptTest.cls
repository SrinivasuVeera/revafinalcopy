@isTest
public class RouteChangeReqWhatsappsFinanceDeptTest {

    // Mock class to simulate WhatsApp callout
    public class WhatsAppMockCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendWhatsAppToFinance() {
        Test.setMock(HttpCalloutMock.class, new WhatsAppMockCallout());

        // Insert Finance User
        User financeUser = new User(
            Alias = 'fin',
            Email = 'finance@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Vishali Perni',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'Asia/Kolkata',
            Username = 'vishali.perni.' + DateTime.now().getTime() + '@example.com',
            MobilePhone = '9999988888'
        );
        insert financeUser;

        // Create Contact (Student)
        Contact student = new Contact(
            LastName = 'Student A',
            SRN_Number__c = 'SRN123'
        );
        insert student;

        // Insert Transport Registration (status = Transport admin Approved)
        Transport_Registeration__c reg = new Transport_Registeration__c(
            //Name = 'REG-001',
            Contact__c = student.Id,
            Registration_Status__c = 'Route change Transport admin Approved'
        );
        insert reg;
	Id routeChangeRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1].Id;
        // Insert Transport Request
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = 'SRN123',
            Cancellation_Date__c = Date.today(),
            RTRStudent_Faculty_NonFaculty__c = student.Id,
            RecordTypeId = routeChangeRtId
        );
        insert req;

        // Insert dummy ProcessInstance and ProcessInstanceWorkitem to simulate approval link
        // (Not required for logic, but included for coverage of approval link generation)
        // You can skip these if approval link logic has try/catch, which it does

        // Prepare recordIds list
        List<String> recordIds = new List<String>{ reg.Id };

        // Execute method
        Test.startTest();
        RouteChangeReqWhatsappsFinanceDept.sendWhatsAppNotifications(recordIds);
        Test.stopTest();
    }
}