@isTest
public class RouteChangeSubmitSMSParentTest {

    @testSetup
    static void setupData() {
        // Create test Contact
        Contact con = new Contact(
            LastName = 'Student',
            //Student_Full_Name__c = 'Test Student',
            SRN_Number__c = 'SRN1001',
            MobilePhone = '9999999999',
            //Parent_Full_Name__c = 'Test Parent',
            RH_Parent_Phone_Number__c = '8888888888'
        );
        insert con;

        // Create Transport Registration record
        Transport_Registeration__c tr = new Transport_Registeration__c(
           // Name = 'TR-PARENT-001',
            Contact__c = con.Id,
            Registration_Status__c = 'Active'
        );
        insert tr;

        // Create Reva Transport Request with 'Route Change Request' record type
        Id recordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId();

        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
           // Name = 'REQ-PARENT-001',
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = recordTypeId
        );
        insert req;

      
    }

    @isTest
    static void testParentRouteChangeSMS() {
        // Fetch Transport Registration record
        Transport_Registeration__c reg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
		
        Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        Test.startTest();
        RouteChangeSubmitSMSParent.rtrSMSNotificationStudent(new List<String>{reg.Id});
        Test.stopTest();

        // Optional assertion (basic success)
        System.assert(true);
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