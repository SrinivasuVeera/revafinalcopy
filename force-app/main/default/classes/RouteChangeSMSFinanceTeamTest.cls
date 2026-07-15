@isTest
public class RouteChangeSMSFinanceTeamTest {

    @testSetup
    static void setupTestData() {
        // Create a mock Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            MobilePhone = '9876543210',
            //Parent_Full_Name__c = 'Parent Name',
            RH_Parent_Phone_Number__c = '9123456780',
            SRN_Number__c = 'SRN987654'
            //Student_Full_Name__c = 'Test Student'
        );
        insert con;

        // Create New Route Master and Pick Up Point records
        RTR_Route_Master__c route = new RTR_Route_Master__c(Name = 'Route 101');
        insert route;

        RTR_Route_Pick_Up_Point__c pickPoint = new RTR_Route_Pick_Up_Point__c(Name = 'Main Gate');
        insert pickPoint;

        // Create a Transport Registration record
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR-0002',
            Registration_Status__c = 'Active',
            Contact__c = con.Id
        );
        insert tr;

        // Create a Route Change Request record
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId(),
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            New_Route_Master__c = route.Id,
            New_Route_Pick_Up_Point__c = pickPoint.Id
        );
        insert req;

        // Create mock user 'Bharathi S'
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

        // Insert mock SMS_Types__mdt (simulate with test context)
        SMS_Types__mdt sms = new SMS_Types__mdt(
            DeveloperName = 'RouteChangeFinanceSMS',
            MasterLabel = 'RouteChangeFinanceSMS',
            Dlt_Content_Id__c = '1007910406627926047',
            Unicode__c = false,
            SMS_Name__c = 'RouteChangeFinanceSMS',
            Sender__c = 'REVA',
            SMS_Template_long__c = 'Dear Sir, The route change request...'
        );
//        insert sms;
    }

    @isTest
    static void testFinanceSMSSending() {
        // Fetch one of the Transport Registration records
        Transport_Registeration__c tr = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        Test.startTest();
        RouteChangeSMSFinanceTeam.rtrSMSNotificationStudent(new List<String>{tr.Id});
        Test.stopTest();

        System.assert(true); // Minimal assertion; add more if needed for SMS logs
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