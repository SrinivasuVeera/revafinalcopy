/*@isTest
public class revaHostelLeaveRequestTest {

    @testSetup
    static void setup() {
        // Create test data for REVA_Hostel_Leave_Request__c
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Status__c = 'Leave Requested',
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Contact__c ='0035j00000WRIaiAAH',
            Note_to_the_approver__c='test'
        );
        insert leaveRequest;

        // Create test data for ProcessInstance and ProcessInstanceWorkitem
        // This part assumes you have an approval process set up for the object
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(leaveRequest.Id);
        Approval.ProcessResult result = Approval.process(req);
        
        // Approve the request to create a ProcessInstanceWorkitem
        if (result.isSuccess()) {
            List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :result.getInstanceId()];
            if (!workItems.isEmpty()) {
                Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                approveRequest.setComments('Approving request');
                approveRequest.setAction('Approve');
                approveRequest.setWorkitemId(workItems[0].Id);

                Test.startTest();
                Approval.process(approveRequest);
                Test.stopTest();
            }
        }
    }
    
    @isTest
    static void testUpdateRecordStatus() {
        // Retrieve the test data
        REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id, Status__c FROM REVA_Hostel_Leave_Request__c LIMIT 1];
        
        Test.startTest();
        revaHostelLeaveRequest.updateRecordStatus(leaveRequest.Id);
        Test.stopTest();
        
        // Verify the record status is updated to 'Canceled'
        leaveRequest = [SELECT Id, Status__c FROM REVA_Hostel_Leave_Request__c WHERE Id = :leaveRequest.Id];
        System.assertEquals('Canceled', leaveRequest.Status__c);
    }
    
    @isTest
    static void testGetLeaveRecordDetails() {
        // Retrieve the test data
        REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id, Status__c, Start_Date_and_Time__c, End_Date_and_Time__c FROM REVA_Hostel_Leave_Request__c LIMIT 1];
        
        Test.startTest();
        REVA_Hostel_Leave_Request__c result = revaHostelLeaveRequest.getLeaveRecordDetails(leaveRequest.Id);
        Test.stopTest();
        
        // Verify the method returns the correct record
        System.assertEquals(leaveRequest.Id, result.Id);
        System.assertEquals(leaveRequest.Status__c, result.Status__c);
        System.assertEquals(leaveRequest.Start_Date_and_Time__c, result.Start_Date_and_Time__c);
        System.assertEquals(leaveRequest.End_Date_and_Time__c, result.End_Date_and_Time__c);
    }
}*/

@isTest
public class revaHostelLeaveRequestTest {
     public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }

  /*  @testSetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create a test User record to act as the Warden
        Profile p = [SELECT Id FROM Profile WHERE Name='Warden' LIMIT 1]; // Use an appropriate profile
        User warden = new User(
            FirstName = 'Warden',
            LastName = 'Smith',
            Email = 'warden.smith@example.com',
            Username = 'warden.smith@example.com.test', // Username must be unique across all orgs
            Alias = 'wsmith',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert warden;

        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        // Create test data for REVA_Hostel_Leave_Request__c
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Status__c = 'Leave Requested',
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Contact__c = testContact.Id, // Use the dynamically created Contact
            Warden__c = warden.Id, // Populating the Warden field with the test user
            Note_to_the_approver__c = 'Test note'
        );
        insert leaveRequest;

        // Check if the record is already in an approval process
        List<ProcessInstance> instances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :leaveRequest.Id];
        if (instances.isEmpty()) {
            // Create test data for ProcessInstance and ProcessInstanceWorkitem
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(leaveRequest.Id);
            Approval.ProcessResult result = Approval.process(req);
            
            // Approve the request to create a ProcessInstanceWorkitem
            if (result.isSuccess()) {
                List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :result.getInstanceId()];
                if (!workItems.isEmpty()) {
                    Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                    approveRequest.setComments('Approving request');
                    approveRequest.setAction('Approve');
                    approveRequest.setWorkitemId(workItems[0].Id);

                    Test.startTest();
                    Approval.process(approveRequest);
                    Test.stopTest();
                }
            }
        }
    }
    */
    @isTest
    static void testUpdateRecordStatus() {
        // Retrieve the test data
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Profile p = [SELECT Id FROM Profile WHERE Name='Warden' LIMIT 1]; // Use an appropriate profile
        User warden = new User(
            FirstName = 'Warden',
            LastName = 'Smith',
            Email = 'warden.smith@example.com',
            Username = 'warden.smith02@example.com.test', // Username must be unique across all orgs
            Alias = 'wsmith',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert warden;

        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        // Create test data for REVA_Hostel_Leave_Request__c
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Status__c = 'Leave Requested',
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Contact__c = testContact.Id, // Use the dynamically created Contact
            Warden__c = warden.Id, // Populating the Warden field with the test user
            Note_to_the_approver__c = 'Test note'
        );
        insert leaveRequest;
        //REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id, Status__c FROM REVA_Hostel_Leave_Request__c LIMIT 1];
        /*List<ProcessInstance> instances = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :leaveRequest.Id];
        if (instances.isEmpty()) {
            // Create test data for ProcessInstance and ProcessInstanceWorkitem
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(leaveRequest.Id);
            Approval.ProcessResult result = Approval.process(req);
            
            // Approve the request to create a ProcessInstanceWorkitem
            if (result.isSuccess()) {
                List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :result.getInstanceId()];
                if (!workItems.isEmpty()) {
                    Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
                    approveRequest.setComments('Approving request');
                    approveRequest.setAction('Approve');
                    approveRequest.setWorkitemId(workItems[0].Id);

                    //Test.startTest();
                    Approval.process(approveRequest);
                    //Test.stopTest();
                }
            }
        }*/
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        revaHostelLeaveRequest.updateRecordStatus(leaveRequest.Id);
        Test.stopTest();
        
        // Verify the record status is updated to a valid picklist value (e.g., 'Completed')
        leaveRequest = [SELECT Id, Status__c FROM REVA_Hostel_Leave_Request__c WHERE Id = :leaveRequest.Id];
        System.assertEquals('Cancelled', leaveRequest.Status__c);
    }
    
    @isTest
    static void testGetLeaveRecordDetails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; // Use an appropriate profile
        User warden = new User(
            FirstName = 'Warden',
            LastName = 'Smith',
            Email = 'warden.smith@example.com',
            Username = 'warden.smith10@example.com.test', // Username must be unique across all orgs
            Alias = 'wsmith',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert warden;

        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        // Create test data for REVA_Hostel_Leave_Request__c
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Status__c = 'Leave Requested',
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Contact__c = testContact.Id, // Use the dynamically created Contact
            Warden__c = warden.Id, // Populating the Warden field with the test user
            Note_to_the_approver__c = 'Test note'
        );
        insert leaveRequest;
        // Retrieve the test data
       // REVA_Hostel_Leave_Request__c leaveRequest = [SELECT Id, Status__c, Start_Date_and_Time__c, End_Date_and_Time__c FROM REVA_Hostel_Leave_Request__c LIMIT 1];
        
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        REVA_Hostel_Leave_Request__c result = revaHostelLeaveRequest.getLeaveRecordDetails(leaveRequest.Id);
        Test.stopTest();
        
        // Verify the method returns the correct record
        System.assertEquals(leaveRequest.Id, result.Id);
        System.assertEquals(leaveRequest.Status__c, result.Status__c);
        System.assertEquals(leaveRequest.Start_Date_and_Time__c, result.Start_Date_and_Time__c);
        System.assertEquals(leaveRequest.End_Date_and_Time__c, result.End_Date_and_Time__c);
    }
}