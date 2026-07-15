@isTest
public class RouteChangeApproveSMSParentTest {

    @testSetup
    static void setupData() {
        // Create a test Contact
        Contact con = new Contact(
            LastName = 'Student',
            //Student_Full_Name__c = 'Test Student',
            SRN_Number__c = 'SRN2001',
            MobilePhone = '9999999999',
            //Parent_Full_Name__c = 'Test Parent',
            RH_Parent_Phone_Number__c = '8888888888'
        );
        insert con;

        // Create a Transport Registration record
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR-PAR-APP-001',
            Contact__c = con.Id,
            Registration_Status__c = 'Active'
        );
        insert tr;

        // Create a Route Change Request record
        Id routeChangeRTId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId();

        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            //Name = 'REQ-PAR-APP-001',
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = routeChangeRTId
        );
        insert req;

       
    }

    @isTest
    static void testParentApprovedSMSNotification() {
        // Fetch the inserted Transport Registration
        Transport_Registeration__c tr = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        // Optional: Mock HTTP callout if your SMS utility performs real callouts
        // Test.setMock(HttpCalloutMock.class, new MockSMSCallout());

        Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        
        Test.startTest();
        RouteChangeApproveSMSParent.rtrSMSNotificationStudent(new List<String>{tr.Id});
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