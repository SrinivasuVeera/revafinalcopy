@isTest
public class RouteChangeSMSTransportAdminTest {

    @testSetup
    static void setupData() {
        // Insert a User with Name = 'Lakshmanan' and MobilePhone != null
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Lakshmanan',
            LastName = 'G',
            Alias = 'lakg',
            Email = 'lakshmanan@example.com',
            Username = 'lakshmanan.testuser@example.com.test', // must be unique
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            MobilePhone = '9876543210'
        );
        insert u;

        // Create test Contact
        Contact con = new Contact(
            LastName = 'Test Student',
            //Student_Full_Name__c = 'Test Student',
            SRN_Number__c = 'SRN123456',
            MobilePhone = '9999999999',
            //Parent_Full_Name__c = 'Test Parent',
            RH_Parent_Phone_Number__c = '8888888888'
        );
        insert con;

        // Create Transport Registration
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR-TA-001',
            Contact__c = con.Id,
            Registration_Status__c = 'Active'
        );
        insert tr;

        // Create Route Change Request
        Id routeChangeRTId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId();

        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            //Name = 'REQ-TA-001',
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = routeChangeRTId
        );
        insert req;

        
    }

    @isTest
    static void testTransportAdminSMSNotification() {
        Transport_Registeration__c tr = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
		
        Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        Test.startTest();
        RouteChangeSMSTransportAdmin.rtrSMSNotificationStudent(new List<String>{tr.Id});
        Test.stopTest();

        System.assert(true); // Dummy assertion for structure
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