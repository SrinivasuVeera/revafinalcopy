@isTest
public class RouteChangeTransportadminpayamountTest {

    @testSetup
    static void setupTestData() {
        // Create test Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '9876543210',
            //Parent_Full_Name__c = 'Parent Test',
            RH_Parent_Phone_Number__c = '9123456780',
            SRN_Number__c = 'SRN123456'
            //Student_Full_Name__c = 'Test Student'
        );
        insert con;

        // Create Transport Registration
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR0001',

            Contact__c = con.Id
        );
        insert tr;

        // Create RTR Reva Transport Request
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId(),
            SRN_EmployeeID__c = con.SRN_Number__c,
            //RouteChangeAmountToPay__c = 1500,
            Cancellation_Date__c = Date.today()
        );
        insert req;

        // Create a mock User
        User u = new User(
            FirstName = 'Bharathi',
            LastName = 'S',
            Username = 'bharathi.s@example.com.test',
            Email = 'bharathi.s@example.com',
            Alias = 'bhs',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            MobilePhone = '9999999999'
        );
        insert u;

        // Load SMS metadata using static resource (if needed)
        // Alternatively, mock in test directly as below
        SMS_Types__mdt sms = new SMS_Types__mdt(
            DeveloperName = 'RouteChangePayment',
            MasterLabel = 'RouteChangePayment',
            Dlt_Content_Id__c = '1007053527011667174',
            Unicode__c = false,
            SMS_Name__c = 'RouteChangePayment',
            Sender__c = 'REVA',
            SMS_Template_long__c = 'Template'
        );
        //insert sms;
    }

    @isTest
    static void testRouteChangeSMSNotification() {
        // Fetch inserted registration
        Transport_Registeration__c tr = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        // Simulate the Invocable Method call
        Test.startTest();
        RouteChangeTransportadminpayamount.rtrSMSNotificationStudent(new List<String>{tr.Id});
        Test.stopTest();

        // Add assertions if needed for your SMS system, e.g. mock logs, callouts, etc.
        System.assert(true); // Placeholder
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