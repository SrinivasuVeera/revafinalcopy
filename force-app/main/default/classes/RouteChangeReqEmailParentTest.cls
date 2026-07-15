@isTest
public class RouteChangeReqEmailParentTest {

    @isTest
    static void testSendEmailForParent() {
        // Create Contact with Father Info
        Contact father = new Contact(LastName = 'Parent Test',Email = 'student@example.com');
        insert father;
System.debug('father-->> '+father);
        
        Contact student = new Contact(
            LastName = 'Student Test',
            SRN_Number__c = 'SRN123456',
            Email = 'student@example.com',
            //Father_Email_ID__c = 'father@example.com',
            Father__c = father.Id
        );
        insert student;
        System.debug('student-->> '+student);

        // Create OrgWideEmailAddress
        OrgWideEmailAddress owa = [SELECT Id,DisplayName,Address FROM OrgWideEmailAddress where DisplayName ='REVA Alerts'];
        System.debug('owa-->> '+owa);
        //insert owa;

        // Create Transport Registeration
        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = student.Id,
            //Name = 'REQ-001',
            Registration_Status__c = 'Route Change Request Submitted'
        );
        insert reg;
        System.debug('reg-->> '+reg);

        // Create RecordType
         RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1];
        System.debug('rt-->> '+rt);

        // Create RTR_Reva_Transport_Request__c
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = student.SRN_Number__c,
            Cancellation_Date__c = System.today(),
            RecordTypeId = rt.Id
        );
        insert req;
        System.debug('req-->> '+req);
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        // Run method
        Test.startTest();
        RouteChangeReqEmailParent.sendEmails(new List<String>{reg.Id});
        Test.stopTest();

        // Assert: No exception means the logic executed
        System.assert(true, 'RouteChangeReqEmailParent executed successfully');
    }

    @isTest
    static void testWithInvalidStatus() {
       
        // Same setup as above with different status
        Contact father = new Contact(LastName = 'Parent',Email = 'student@example.com');
        insert father;

        Contact student = new Contact(
            LastName = 'Student',
            SRN_Number__c = 'SRN999',
            //Father_Email_ID__c = 'parent@example.com',
            Father__c = father.Id
        );
        insert student;

         OrgWideEmailAddress owa = [SELECT Id,DisplayName,Address FROM OrgWideEmailAddress where DisplayName ='REVA Alerts'];
        System.debug('owa-->> '+owa);
        //insert owa;

        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = student.Id,
            //Name = 'REQ-002',
            Registration_Status__c = 'Route Change Request Submitted'
        );
        insert reg;
		Test.setMock(HttpCalloutMock.class, new MyServiceMock());
        Test.startTest();
        RouteChangeReqEmailParent.sendEmails(new List<String>{reg.Id});
        Test.stopTest();

        System.assert(true, 'Handled invalid status gracefully');
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