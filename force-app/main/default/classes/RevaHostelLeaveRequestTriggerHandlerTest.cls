@IsTest
public class RevaHostelLeaveRequestTriggerHandlerTest {
    
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @IsTest
    static void testLeaveRequestNotification() {
        // Retrieve the leave requests created in the setup
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        
        
        Contact mentorCon = new Contact(
            LastName = 'Test mentorCon 2',
            MobilePhone = '1234656791',
            Parent_Name__c = 'Test mentorCon 2',
            RH_Parent_Phone_Number__c = '09876254322',
            Email = 'test5432@gmail.com',
            SRN_Number__c = 'tesmtuniw1que347'
        );
        insert mentorCon;
        
        Contact fatherCon = new Contact(
            LastName = 'Test fatherCon 2',
            MobilePhone = '1223467891',
            Parent_Name__c = 'Test fatherCon 2',
            RH_Parent_Phone_Number__c = '09876543322',
            Email = 'test5443@gmail.com',
            SRN_Number__c = 'testuniw1que347'
        );
        insert fatherCon;
        
        Contact testContact1 = new Contact(
            LastName = 'Test Student 1',
            MobilePhone = '1234567890',
            Parent_Name__c = 'Test Parent 1',
            RH_Parent_Phone_Number__c = '0987654321',
            Email = 'test345@gmail.com',
            Mentor__c = mentorCon.Id,
            Father__c = fatherCon.Id,
             SRN_Number__c = 'testuni1que347'
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            LastName = 'Test Student 2',
            MobilePhone = '1234567891',
            Parent_Name__c = 'Test Parent 2',
            RH_Parent_Phone_Number__c = '0987654322',
            Email = 'test543@gmail.com',
            Mentor__c = mentorCon.Id,
            Father__c = fatherCon.Id,
            SRN_Number__c = 'testunique347'
        );
        insert testContact2;
        
        // Query Profiles and handle empty results
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        if (studentProfile == null) {
            // Handle the case where the profile is not found
            System.debug('Student Profile not found');
            return;
        }
        
        User studentUser1 = new User(
            Username = 'studentuser45696@test.com',
            Email = 'studentuser1@test.com',
            Alias = 'stu1',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Student',
            LastName = 'User 1',
            ContactId = testContact1.Id,
            IsActive = true
        );
        insert studentUser1;
        
        User studentUser2 = new User(
            Username = 'studentuser265469@test.com',
            Email = 'studentuser2@test.com',
            Alias = 'stu2',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Student',
            LastName = 'User 2',
            ContactId = testContact2.Id,
            IsActive = true
        );
        insert studentUser2;
        
        // Query Profiles and handle empty results
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        if (wardenProfile == null) {
            // Handle the case where the profile is not found
            System.debug('Warden Profile not found');
            return;
        }
        
        User wardenUser = new User(
            FirstName = 'Warden',
            LastName = 'User',
            Email = 'wardenuser@test.com',
            Username = 'wardenuser@test.com',
            ProfileId = wardenProfile.Id,
            Alias = 'warden1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Phone = '1111111111',
            UserRoleId = null,
            IsActive = true
        );
        insert wardenUser;
        
         Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
        Room_Type__c = 'Student',
        Room_Category__c = '1 Eng',
        Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
        
        // Create test Reva Hostel Requests
        Reva_Hostel_Request__c hostelRequest1 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Reva_Hostel_Room__c = hostelroom.Id,
            Type__c = '4',
            Warden__c = wardenUser.Id // Assuming this field is required
        );
        insert hostelRequest1;
        
       
 
        
        Reva_Hostel_Request__c hostelRequest2 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact2.Id,
            Type__c = '4',
            Reva_Hostel_Room__c = hostelroom.Id,
            Warden__c = wardenUser.Id // Assuming this field is required
        );
        insert hostelRequest2;
        
        // Create test Leave Requests
        REVA_Hostel_Leave_Request__c leaveRequest1 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact1.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(1),
            End_Date_and_Time__c = DateTime.now().addDays(2),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id // Assuming this field is required
        );
        insert leaveRequest1;
        
        REVA_Hostel_Leave_Request__c leaveRequest2 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact2.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(3),
            End_Date_and_Time__c = DateTime.now().addDays(4),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id,
            Status__c = 'Leave Requested'
        );
        insert leaveRequest2;
        
        REVA_Hostel_Leave_Request__c leaveRequest3 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact2.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(3),
            End_Date_and_Time__c = DateTime.now().addDays(4),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id,
            Status__c = 'Approved'
        );
        insert leaveRequest3;
        
        REVA_Hostel_Leave_Request__c leaveRequest4 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact2.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(3),
            End_Date_and_Time__c = DateTime.now().addDays(4),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id,
            Status__c = 'Check Out'
        );
        insert leaveRequest4;
        
        REVA_Hostel_Leave_Request__c leaveRequest5 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact2.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(3),
            End_Date_and_Time__c = DateTime.now().addDays(4),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id,
            Status__c = 'Check In'
        );
        insert leaveRequest5;
        Test.startTest();
        RevaHostelLeaveRequestTriggerHandler.leaveRequestNotification(new List<REVA_Hostel_Leave_Request__c> {leaveRequest2}); 
        RevaHostelLeaveRequestTriggerHandler.leaveRequestNotification(new List<REVA_Hostel_Leave_Request__c> {leaveRequest3}); 
        RevaHostelLeaveRequestTriggerHandler.leaveRequestNotification(new List<REVA_Hostel_Leave_Request__c> {leaveRequest4}); 
        RevaHostelLeaveRequestTriggerHandler.leaveRequestNotification(new List<REVA_Hostel_Leave_Request__c> {leaveRequest5}); 
        RevaHostelLeaveRequestTriggerHandler.leaveApprovalNotification(new List<REVA_Hostel_Leave_Request__c>{leaveRequest5} );
        Test.stopTest();
        
    }
    
   /* @IsTest
    static void testLeaveApprovalNotification() {
        // Retrieve the leave requests created in the setup
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        
        
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
                
        Contact testContact1 = new Contact(
            LastName = 'Test Student 1',
            MobilePhone = '1234567890',
            Parent_Name__c = 'Test Parent 1',
            RH_Parent_Phone_Number__c = '0987654321',
            Email = 'test345@gmail.com',
            Mentor__c = mentorCon.Id,
            Father__c = fatherCon.Id
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            LastName = 'Test Student 2',
            MobilePhone = '1234567891',
            Parent_Name__c = 'Test Parent 2',
            RH_Parent_Phone_Number__c = '0987654322',
            Email = 'test543@gmail.com',
            Mentor__c = mentorCon.Id,
            Father__c = fatherCon.Id
        );
        insert testContact2;
        
        // Query Profiles and handle empty results
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        if (studentProfile == null) {
            // Handle the case where the profile is not found
            System.debug('Student Profile not found');
            return;
        }
        
        User studentUser1 = new User(
            Username = 'studentuser456@test.com',
            Email = 'studentuser1@test.com',
            Alias = 'stu1',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Student',
            LastName = 'User 1',
            ContactId = testContact1.Id,
            IsActive = true
        );
        insert studentUser1;
        
        User studentUser2 = new User(
            Username = 'studentuser2654@test.com',
            Email = 'studentuser2@test.com',
            Alias = 'stu2',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Student',
            LastName = 'User 2',
            ContactId = testContact2.Id,
            IsActive = true
        );
        insert studentUser2;
        
        // Query Profiles and handle empty results
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        if (wardenProfile == null) {
            // Handle the case where the profile is not found
            System.debug('Warden Profile not found');
            return;
        }
        
        User wardenUser = new User(
            FirstName = 'Warden',
            LastName = 'User',
            Email = 'wardenuser@test.com',
            Username = 'wardenuser@test.com',
            ProfileId = wardenProfile.Id,
            Alias = 'warden1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Phone = '1111111111',
            UserRoleId = null,
            IsActive = true
        );
        insert wardenUser;
        
        // Create test Reva Hostel Requests
        Reva_Hostel_Request__c hostelRequest1 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Type__c = '4',
            Warden__c = wardenUser.Id // Assuming this field is required
        );
        insert hostelRequest1;
        
        Reva_Hostel_Request__c hostelRequest2 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact2.Id,
            Type__c = '4',
            Warden__c = wardenUser.Id // Assuming this field is required
        );
        insert hostelRequest2;
        
        // Create test Leave Requests
        REVA_Hostel_Leave_Request__c leaveRequest1 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact1.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(1),
            End_Date_and_Time__c = DateTime.now().addDays(2),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id // Assuming this field is required
        );
        insert leaveRequest1;
        
        REVA_Hostel_Leave_Request__c leaveRequest2 = new REVA_Hostel_Leave_Request__c(
            Contact__c = testContact2.Id,
            Start_Date_and_Time__c = DateTime.now().addDays(3),
            End_Date_and_Time__c = DateTime.now().addDays(4),
            Reason_For_Leave__c = 'Going Home',
            Warden__c = wardenUser.Id // Assuming this field is required 
        );
        insert leaveRequest2;
        // new List<REVA_Hostel_Leave_Request__c>  {leaveRequest1,leaveRequest2} 
        
        Test.startTest();
        Test.stopTest();
        
        // Validate that the SMS messages were sent (Mocked)
        // Add assertions here to validate the expected behavior, such as checking the log or verifying the state changes
    }*/
}