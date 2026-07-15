@isTest
public class RouteChangeRejectedSMSStudentTest {

    @testSetup
    static void setupTestData() {
        // Create a test Contact
        Contact con = new Contact(
            LastName = 'TestStudent',
           // Student_Full_Name__c = 'Test Student',
            SRN_Number__c = 'SRN999999',
            MobilePhone = '9999999999',
           // Parent_Full_Name__c = 'Test Parent',
            RH_Parent_Phone_Number__c = '8888888888'
        );
        insert con;

        // Create a Transport Registration
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR-REJ-001',
            Contact__c = con.Id,
            Registration_Status__c = 'Active'
        );
        insert tr;

        // Create Route Change Request Record (custom RecordType)
        Id routeChangeRecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId();

        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            //Name = 'REQ-REJ-001',
            SRN_EmployeeID__c = con.SRN_Number__c,
            RecordTypeId = routeChangeRecordTypeId
        );
        insert req;

        // Insert custom metadata if allowed — simulate SMS template
        SMS_Types__mdt smsType = new SMS_Types__mdt(
            DeveloperName = 'Route_Change_Rejected',
            Dlt_Content_Id__c = '1007195903383989162',
            Unicode__c = false,
            SMS_Name__c = 'Route Change Rejected',
            Sender__c = 'REVA',
            SMS_Template_long__c = 'Route change rejected template'
        );
        
    }

    @isTest
    static void testRouteChangeRejectedSMS() {
        // Fetch the inserted Transport Registration record
        Transport_Registeration__c reg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];
		
        Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        Test.startTest();
        RouteChangeRejectedSMSStudent.rtrSMSNotificationStudent(new List<String>{reg.Id});
        Test.stopTest();

        System.debug('Route Change Rejected SMS invoked successfully.');
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