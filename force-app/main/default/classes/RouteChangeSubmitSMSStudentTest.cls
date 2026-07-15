@isTest
public class RouteChangeSubmitSMSStudentTest {
    @testSetup
    static void setupData() {
        // Create test Contact
        Contact con = new Contact(
            LastName = 'Test Student',
            //Student_Full_Name__c = 'Test Student',
            SRN_Number__c = 'SRN123456',
            MobilePhone = '9876543210',
            //Parent_Full_Name__c = 'Test Parent',
            RH_Parent_Phone_Number__c = '9123456789'
        );
        insert con;

        // Create Transport Registration
        Transport_Registeration__c tr = new Transport_Registeration__c(
            //Name = 'TR001',
            Contact__c = con.Id,
            Registration_Status__c = 'Active'
        );
        insert tr;

        // Create metadata test record
        // Use @isTest(seeAllData=true) if needed or create a mock using Custom Metadata Loader
        SMS_Types__mdt smsType = new SMS_Types__mdt(
            DeveloperName = 'Route_Change_Notification',
            Dlt_Content_Id__c = '1007359194942877167',
            Unicode__c = false,
            SMS_Name__c = 'Route Change Notification',
            Sender__c = 'REVA',
            SMS_Template_long__c = 'Test Template'
        );
       

        // Create transport request record
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
           // Name = 'REQ001',
            SRN_EmployeeID__c = 'SRN123456',
            RecordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c.getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId()
        );
        insert req;
    }

    @isTest
    static void testSMSNotificationStudent() {
        // Get the inserted Transport Registration ID
        Transport_Registeration__c reg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        // Call the method
        Test.startTest();
        RouteChangeSubmitSMSStudent.rtrSMSNotificationStudent(new List<String>{reg.Id});
        Test.stopTest();

        // Assertions or debug logs can be added here as needed
        System.debug('Route change SMS logic executed successfully.');
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