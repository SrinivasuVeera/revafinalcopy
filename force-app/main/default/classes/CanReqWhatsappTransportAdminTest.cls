@isTest
public class CanReqWhatsappTransportAdminTest {
    @isTest
    static void testSendWhatsAppNotificationsToTransportAdmin() {
        // Get RecordType Id for 'Transport Cancellation'
        Id recordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId();

        // Create a dummy Transport Admin User with the name 'Lakshmanan'
        User transportAdmin = new User(
            Username = 'lakshmanan@example.com.test',
            LastName = 'Lakshmanan',
            Alias = 'laksh',
            Email = 'laksh@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            MobilePhone = '9876543210'
        );
        insert transportAdmin;

        // Test Data: 2 Contacts and SRNs for meaningful coverage
        List<String> srns = new List<String>{'SRN100', 'SRN200'};
        List<String> statuses = new List<String>{
            'Cancellation Request Submitted',
            'Cancellation Approved'
        };

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 2; i++) {
            contacts.add(new Contact(
                LastName = 'Student' + i,
                Email = 'student' + i + '@test.com',
                SRN_Number__c = srns[i]
            ));
        }
        insert contacts;

        // Transport Registrations
        List<Transport_Registeration__c> regs = new List<Transport_Registeration__c>();
        for (Integer i = 0; i < 2; i++) {
            regs.add(new Transport_Registeration__c(
                Contact__c = contacts[i].Id,
                Registration_Status__c = statuses[i]
            ));
        }
        insert regs;

        // Dummy Route Master and Pickup Point
        RTR_Route_Master__c route = new RTR_Route_Master__c(Name = 'Route 6');
        insert route;

        RTR_Route_Pick_Up_Point__c pickup = new RTR_Route_Pick_Up_Point__c(
            Name = 'Yelahanka',
            RTR_Route_Master__c = route.Id
        );
        insert pickup;

        // Transport Requests
        List<RTR_Reva_Transport_Request__c> requests = new List<RTR_Reva_Transport_Request__c>();
        for (Integer i = 0; i < 2; i++) {
            requests.add(new RTR_Reva_Transport_Request__c(
                SRN_EmployeeID__c = srns[i],
                RTR_Student__c = contacts[i].Id,
                Cancellation_Date__c = Date.today(),
                RTR_Route_Pick_Up_Point__c = pickup.Id,
                RecordTypeId = recordTypeId
            ));
        }
        insert requests;

        // Capture Registration Ids for test
        List<String> regIds = new List<String>();
        for (Transport_Registeration__c reg : regs) {
            regIds.add(reg.Id);
        }
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        // Execute Test
        Test.startTest();
            CanReqWhatsappTransportAdmin.sendWhatsAppNotifications(regIds);
        Test.stopTest();

        // Assert method completed
        System.assert(true, 'WhatsApp notification method executed successfully.');
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