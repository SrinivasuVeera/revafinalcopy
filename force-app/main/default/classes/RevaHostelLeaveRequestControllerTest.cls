@IsTest
public class RevaHostelLeaveRequestControllerTest {
    
public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"user" : "revaerp.trans","password" : "s1Sz2"},"from" : "REVAUn","shortMessages" : [ {"dltContentId" : "1007035180056853824","message" : "Dear Test User1, We’d like to inform you that the University bus will arrive at the pickup point 10 mins earlier than the regular schedule on 26.05.2024 on account of Test Description. REVA University", "recipient" : "1234567890"} ],"unicode" : true}');
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testGetHostelLeaveRequests() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        // Call the method
        List<REVA_Hostel_Leave_Request__c> leaveRequests = RevaHostelLeaveRequestController.getHostelLeaverequests();
        
        Test.stopTest();
        
        // Validate the results
        System.assertNotEquals(null, leaveRequests, 'The leave requests should not be null.');
        //System.assertNotEquals(0, leaveRequests.size(), 'There should be at least one leave request.');
    }

    @IsTest
    static void testSaveLeaveRequest() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        // Prepare the input data
        Map<String, Object> requestDetails = new Map<String, Object>();
        requestDetails.put('ReasonLeave', 'Going Home');
        requestDetails.put('NoteApprover', 'Please approve');
        requestDetails.put('VisitingAddress', 'Test Address');
        requestDetails.put('StartDate', '2024-08-11T10:00:00Z');
        requestDetails.put('EndDate', '2024-08-12T10:00:00Z');
        requestDetails.put('FileName', 'TestFile.txt');
        requestDetails.put('FileContent', EncodingUtil.base64Encode(Blob.valueOf('Test file content')));

      
        // Call the method
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId,UserType From User Where id =:userId  Limit 1];
        
        // Create Contact
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        if (studentRecordType == null) {
            System.debug('RecordType "Student" for Contact not found.');
            return;
        }
         contact con = new contact (
            LastName = 'Test Contact',
            Email = 'test367@gmail.com',
            phone ='9999999999'
        );
            insert con;
        Contact contact = new Contact(
            LastName = 'Test Contact',
            Email = 'test367@gmail.com',
            RecordTypeId = studentRecordType.Id,
            father__c =con.Id
        );
        insert contact;
        requestDetails.put('contactid', contact.Id);
        
        // Create Reva_Hostel_Request__c
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '4',
            Status__c ='Room Allotted',
            Hostel_Room_Request_For__c = contact.Id,
            Warden__c = adminUser.Id
        );
        insert hostelRequest;
        
        system.runAs(adminUser){
            RevaHostelLeaveRequestController.saveLeaveRequest(requestDetails);}
        Test.stopTest();

        // Validate the results
        List<REVA_Hostel_Leave_Request__c> leaveRequests = [SELECT Id, Reason_For_Leave__c FROM REVA_Hostel_Leave_Request__c WHERE Reason_For_Leave__c = 'Going Home' AND Contact__c =: contact.Id];
        System.assertEquals(1, leaveRequests.size(), 'Leave request should be created.');
        System.assertEquals('Going Home', leaveRequests[0].Reason_For_Leave__c, 'Leave request reason should match.');

        // Validate ContentVersion creation
        List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title = 'TestFile.txt'];
         }

    @IsTest
    static void testCancelLeave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        // Create a leave request
        Profile profile = [SELECT Id FROM Profile WHERE Name='Warden' LIMIT 1];
        
        if (profile == null) {
            System.debug('Profile "Warden" not found.');
            return;
        }
        
        // Create a User
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser855@example.com'
        );
        insert testUser;

        // Create Contact
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        if (studentRecordType == null) {
            System.debug('RecordType "Student" for Contact not found.');
            return;
        }

        contact con = new contact (
            LastName = 'Test Contact',
            Email = 'test367@gmail.com',
            phone ='9999999999'
        );
            insert con;
        
        Contact contact = new Contact(
            LastName = 'Test Contact',
            Email = 'test367@gmail.com',
            mobilePhone = '9999999999',
            RecordTypeId = studentRecordType.Id,
            father__c =con.Id
        );
        insert contact;

        // Create Reva_Hostel_Request__c
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '4',
            Hostel_Room_Request_For__c = contact.Id,
            Warden__c = testUser.Id
        );
        insert hostelRequest;
        
        // Create a leave request
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Contact__c = contact.Id,
            Reason_For_Leave__c = 'Going Home',
            Status__c = 'Leave Requested',
            Warden__c = testUser.Id,
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1)
        );
        insert leaveRequest;
        RevaHosteLeaveRequestController.getApprovalHistory(leaveRequest.Id);
         REVA_Hostel_Leave_Request__c leaverq =[select id, Name,Status__c From REVA_Hostel_Leave_Request__c where Status__c = 'Leave Requested'];
        if(leaverq != null) {
            leaverq.Status__c = 'Approved'; // Simulate approval process completion
            update leaverq;
           RevaHostelLeaveRequestController.cancelLeave(leaverq.Id);
              REVA_Hostel_Leave_Request__c updatedRequest = [SELECT Status__c FROM REVA_Hostel_Leave_Request__c WHERE Id = :leaveRequest.Id];
            System.assertEquals('Cancelled', updatedRequest.Status__c, 'Leave request status should be "Cancelled".');
        }
        
        Test.stopTest();
    }

    @IsTest
    static void testGetLeaveRequestWithContact() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Profile profile = [SELECT Id FROM Profile WHERE Name='Warden' LIMIT 1];
        
        if (profile == null) {
            System.debug('Profile "Warden" not found.');
            return;
        }
        
        // Create a User
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser5554@example.com'
        );
        insert testUser;

        // Create Contact
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        if (studentRecordType == null) {
            System.debug('RecordType "Student" for Contact not found.');
            return;
        }

         Contact mentorCon = new Contact(
            LastName = 'Test mentorCon 2',
            MobilePhone = '1234656791',
            Parent_Name__c = 'Test mentorCon 2',
            RH_Parent_Phone_Number__c = '09876254322',
            Email = 'test5432@gmail.com'
        );
        insert mentorCon;
        
        Contact fatherCon = new Contact(
            LastName = 'Test fatherCon 2',
            MobilePhone = '1223467891',
            Parent_Name__c = 'Test fatherCon 2',
            RH_Parent_Phone_Number__c = '09876543322',
            Email = 'test5443@gmail.com'
        );
        insert fatherCon;
           
        Contact contact = new Contact(
            LastName = 'Test Contact',
            Email = 'test367@gmail.com',
            RecordTypeId = studentRecordType.Id,
            Phone = '9883248709',
            File_Passport_Size_Photo__c = 'WWW.REVAUNIVERSITY.COM',
            SRN_Number__c = 'testunique4568',
            Mentor__c = mentorCon.Id,
            Father__c = fatherCon.Id
        );
        insert contact;
        // Create Reva_Hostel_Request__c
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '4',
            Hostel_Room_Request_For__c = contact.Id,
            Warden__c = testUser.Id
        );
        insert hostelRequest;
        
        // Create a leave request
        REVA_Hostel_Leave_Request__c leaveRequest = new REVA_Hostel_Leave_Request__c(
            Contact__c = contact.Id,
            Reason_For_Leave__c = 'Going Home',
            Status__c = 'Leave Requested',
            Warden__c = testUser.Id,
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Check_In__c = true,
            Check_Out__c = false,
            Scan__c = true
        );
        insert leaveRequest;
        
        REVA_Hostel_Leave_Request__c leaveRequest1 = new REVA_Hostel_Leave_Request__c(
            Contact__c = contact.Id,
            Reason_For_Leave__c = 'Going Home',
            Status__c = 'Leave Requested',
            Warden__c = testUser.Id,
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Check_In__c = false,
            Check_Out__c = true,
            Scan__c = true
        );
        insert leaveRequest1;
        
         REVA_Hostel_Leave_Request__c leaveRequest2 = new REVA_Hostel_Leave_Request__c(
            Contact__c = contact.Id,
            Reason_For_Leave__c = 'Going Home',
            Status__c = 'Leave Requested',
            Warden__c = testUser.Id,
            Start_Date_and_Time__c = System.now().addDays(-1),
            End_Date_and_Time__c = System.now().addDays(1),
            Check_In__c = false,
            Check_Out__c = false,
            Scan__c = true
        );
        insert leaveRequest2;
        
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Map<String, Object> result = RevaHostelLeaveRequestController.getLeaveRequestWithContact(leaveRequest.Id);
        RevaHostelLeaveRequestController.updateCheckStatus(leaveRequest.Id, true);
        RevaHostelLeaveRequestController.updateCheckStatus(leaveRequest1.Id, true);
        Boolean results = RevaHostelLeaveRequestController.hasStatusUpdated(leaveRequest.Id);
        Boolean results1 = RevaHostelLeaveRequestController.hasStatusUpdated(leaveRequest2.Id);
        REVA_Hostel_Leave_Request__c result1 = RevaHostelLeaveRequestController.getRecord(leaveRequest.Id);
        Test.stopTest();

        // Validate the results
        System.assertNotEquals(null, result, 'The result map should not be null.');
        System.assertEquals(leaveRequest.Id, result.get('Id'), 'Leave request Id should match.');
        System.assertEquals(leaveRequest.Contact__r.Parent_Name__c, result.get('ParentName'), 'Parent name should match.');
        System.assertEquals(leaveRequest.Contact__r.RH_Parent_Phone_Number__c, result.get('ParentPhoneNumber'), 'Parent phone number should match.');
    }
    
    

    
}