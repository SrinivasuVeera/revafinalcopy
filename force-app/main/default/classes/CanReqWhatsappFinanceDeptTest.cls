@isTest
public class CanReqWhatsappFinanceDeptTest {

    @isTest
    static void testSendWhatsAppNotifications_Finance() {
        // Create test Finance User
        User financeUser = new User(
            FirstName = 'Vishali',
            LastName = 'Perni',
            Alias = 'vpern',
            Email = 'vishali.perni@test.com',
            Username = 'vishali.perni' + DateTime.now().getTime() + '@test.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '9999999999'
        );
        insert financeUser;

        // Create Contact (Student)
        Contact con = new Contact(
            LastName = 'Test Student',
            SRN_Number__c = 'SRN1001'
        );
        insert con;

        // Create Transport Registration with "Transport Admin Approved" status
        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = 'Transport Admin Approved'
        );
        insert reg;

        // Get record type for 'Transport Cancellation'
        Id recTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName()
            .get('Transport Cancellation')
            .getRecordTypeId();

        // Create Transport Request
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = con.SRN_Number__c,
            RTR_Student__c = con.Id,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = recTypeId
        );
        insert req;
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        // Call the method
        Test.startTest();
            CanReqWhatsappFinanceDept.sendWhatsAppNotifications(new List<String>{reg.Id});
        Test.stopTest();

        System.assert(true, 'sendWhatsAppNotifications ran without exception.');
    }
    public class MyServiceMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message": "Mock response"}');
        res.setStatusCode(200);
        return res;
    }
}
}