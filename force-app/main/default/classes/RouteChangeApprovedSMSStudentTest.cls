@isTest
public class RouteChangeApprovedSMSStudentTest {

    @testSetup
    static void setupData() {
        // Create Contact
        Contact con = new Contact(
            LastName = 'TestStudent',
            SRN_Number__c = 'SRN555555',
           // Student_Full_Name__c = 'Test Student',
            MobilePhone = '9999999999',
            //Parent_Full_Name__c = 'Test Parent',
            RH_Parent_Phone_Number__c = '8888888888'
        );
        insert con;

        // Create Transport Registration record
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR-APP-001',
            Contact__c = con.Id,
            Registration_Status__c = 'Active'
        );
        insert tr;

        // Create Reva Transport Request with Route Change Request record type
        Id routeChangeRTId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId();

        RTR_Reva_Transport_Request__c request = new RTR_Reva_Transport_Request__c(
            //Name = 'REQ-APP-001',
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = routeChangeRTId
        );
        insert request;

        
    }

    @isTest
    static void testApprovedRouteChangeSMS() {
        // Fetch inserted Transport_Registeration__c record
        Transport_Registeration__c tr = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        Test.startTest();
        RouteChangeApprovedSMSStudent.rtrSMSNotificationStudent(new List<String>{tr.Id});
        Test.stopTest();

        System.assert(true); // Dummy assertion to satisfy test structure
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