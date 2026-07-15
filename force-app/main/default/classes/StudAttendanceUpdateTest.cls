@isTest
public class StudAttendanceUpdateTest {    
     public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
        //   res.setBody('{"status":"success","message":"Mock response"}');
             res.setBody('{ "Response": [ { "SFDCRecordId": "001ABC123", "statusCode": 200, "statusMessage": "Success", "SAPID": "SAP12345", "responseObject": "Some response data" } ] }');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testSearchAttendanceRecords() {
        // Prepare test data with only writable fields
        List<hed__Attendance_Event__c> attendanceRecords = new List<hed__Attendance_Event__c>();
        for (Integer i = 0; i < 5; i++) {
            attendanceRecords.add(new hed__Attendance_Event__c(
                // Only include writable fields
                hed__Attendance_Type__c = 'Absent'               
            ));
        }
        insert attendanceRecords;

        // Test valid input
        List<String> srns = new List<String>{ 'SRN0', 'SRN1' };
        Date todayDate = Date.today();
		Date yesterdayDate = todayDate.addDays(-1);
        List<String> slots = new List<String>{ '1', '2' };
        String searchTypeSRN = 'SRN';
        String searchTypeAppno = 'Application';
        Test.startTest();
        List<hed__Attendance_Event__c> results = StudAttendanceUpdate.searchAttendanceRecords(srns, searchTypeAppno, yesterdayDate, todayDate, slots);
        System.assertEquals(0, results.size(), 'Should return 0 attendance records.');
        List<hed__Attendance_Event__c> results1 = StudAttendanceUpdate.searchAttendanceRecords(srns, searchTypeSRN, yesterdayDate, todayDate, slots);
        Test.stopTest(); 
        System.assertEquals(0, results1.size(), 'Should return 0 attendance records.');        
    }  
    
 	@isTest
    static void testSearchAttendanceRecordsNullCheck() {        
        List<String> srns = new List<String>{};        
        Date todayDate = Date.today();
		Date yesterdayDate = todayDate.addDays(-1);
        List<String> slots = new List<String>{};
        List<String> trimmedSrns = new List<String>{};
     	Test.startTest();
        String searchTypeSRN = 'SRN';
        try{
            List<hed__Attendance_Event__c> results = StudAttendanceUpdate.searchAttendanceRecords(srns, searchTypeSRN, yesterdayDate, todayDate, slots);
        }catch(Exception e){            
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();  
    }

    @isTest
    static void testUpdateAttendanceRecords() {
        // Prepare test data with only writable fields
        hed__Attendance_Event__c attendanceRecord = new hed__Attendance_Event__c(
            hed__Attendance_Type__c = 'Absent'        
        );
        insert attendanceRecord;

        // Update record
        attendanceRecord.hed__Attendance_Type__c = 'Present';
        List<hed__Attendance_Event__c> recordsToUpdate = new List<hed__Attendance_Event__c>{ attendanceRecord };
        
        Test.startTest();
        StudAttendanceUpdate.updateAttendanceRecords(recordsToUpdate);
        Test.stopTest();

        // Verify update
        attendanceRecord = [SELECT hed__Attendance_Type__c FROM hed__Attendance_Event__c WHERE Id = :attendanceRecord.Id];
        System.assertEquals('Present', attendanceRecord.hed__Attendance_Type__c, 'The attendance type should be updated to Present.');
    }
    
    @isTest
    static void testUpdateAttendanceWithNotify() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Prepare test data with only writable fields
        hed__Attendance_Event__c attendanceRecord = new hed__Attendance_Event__c(
            hed__Attendance_Type__c = 'Absent'       
        );
        insert attendanceRecord;

        // Update record
        attendanceRecord.hed__Attendance_Type__c = 'Present';
        List<hed__Attendance_Event__c> recordsToUpdate = new List<hed__Attendance_Event__c>{ attendanceRecord };
            
            
        // Send Notification Test code
     
        // Create a User record (simulating the logged-in user)
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1]; 
        User testUser = new User(
            Username = 'testuser0505@example.com',
            LastName = 'testuser0505 lastname',
            Email = 'testuser0505@example.com',
            Alias = 'tuser',
            ProfileId = profile1.Id,
            Department = 'School of Electrical and Electronics Engineering',  // This will be used to find the Account.
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            FederationIdentifier = 'testuser0505@example.com'
        );
        insert testUser;
        
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        // Step 2: Create Account record with a related School Head
        Account testAccount = new Account(
            Name = 'School of Electrical and Electronics Engineering',            
            School_Head__c = user.Id
        );
        insert testAccount;
        
		Profile profile2 = [SELECT Id FROM Profile WHERE Name = 'School Director' LIMIT 1]; 
        // Step 3: Create the Director User that is related to the Account's School Head
        User testDirector = new User(
            Username = 'director@example.com',
            LastName = 'lastNamedir',
            Email = 'director@example.com',
            Alias = 'tuser',
            ProfileId = profile2.Id,
            Department = 'School of Electrical and Electronics Engineering',  
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            FederationIdentifier = 'director@example.com'
        );
        insert testDirector;
        
		System.runAs(testUser) {
            Test.startTest();
            StudAttendanceUpdate.updateAttendanceWithNotify(recordsToUpdate);
            Test.stopTest();
        }
        
        // Verify update
        attendanceRecord = [SELECT hed__Attendance_Type__c FROM hed__Attendance_Event__c WHERE Id = :attendanceRecord.Id];
        System.assertEquals('Present', attendanceRecord.hed__Attendance_Type__c, 'The attendance type should be updated to Present.');
    } 
    
    @isTest
    static void testGetHedReasonPicklistValues() {
        Test.startTest();
        List<String> picklistValues = StudAttendanceUpdate.getHedReasonPicklistValues();
        Test.stopTest();

        System.assertNotEquals(null, picklistValues);
        System.assert(picklistValues.size() > 0, 'Picklist values should not be empty.');
    }
    
    @isTest
    static void testGetSchoolAttendanceData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Setup test data
        // Create a User record with FederationIdentifier
        User testUser = new User(
            Username = 'testuser250225@test.com',
            Email = 'testuser250225@test.com',
            Lastname = 'last name value2502202',
            FederationIdentifier = 'testuser250225@test.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id, // assuming a standard profile
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        Account testAccount = new Account(
            Name = 'Test School'
        );
        insert testAccount;

        // Create a Contact record linked to the User via email
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            hed__WorkEmail__c = 'testuser250225@test.com',
            AccountId  = testAccount.Id          
        );
        insert testContact;

        // Create Attendance Event records related to the School Name
        hed__Attendance_Event__c attendanceEvent = new hed__Attendance_Event__c(
            hed__Attendance_Type__c = 'Absent',
            activity_based_att_req_dt__c = Date.today(),
            hed__Contact__c = testContact.Id        
        );
        insert attendanceEvent;
        
        // Set the UserId for the test to simulate the logged-in user
        System.runAs(testUser) {
            // Call the method
            Test.startTest();
            List<hed__Attendance_Event__c> result = StudAttendanceUpdate.getSchoolAttendanceData(); // replace with your actual class name
            Test.stopTest();
        }
    }
    
      @isTest
    static void testGetLoggedInUserProfileValidUser() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a User with a valid Profile_Name__c
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; 
        
        User testUser = new User(
            Username = 'testuser25022025@test.com',
            Lastname = 'last name value25022025',
            Email = 'testuser25022025@test.com',
            FederationIdentifier = 'testuser25022025@test.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;    
      

        // Set the UserId for the test to simulate the logged-in user
        System.runAs(testUser) {
            Test.startTest();
            String profileName = StudAttendanceUpdate.getLoggedInUserProfile();
            Test.stopTest();           
        }
    }
    
    @isTest
    static void testGetAttendanceRecPendingForApprovalWithRecords() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Assuming a profile exists named 'Standard User'
         User testUser = new User(
            Username = 'testuser25022025@test.com',
            Lastname = 'last name value25022025',          
            Email = 'testuser25022025@test.com',
            FederationIdentifier = 'testuser25022025@test.com',
            ProfileId = testProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a test Contact record (with School_Name__c)
        Account testAccount = new Account(
            Name = 'School of Electrical and Electronics Engineering'
        );
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            hed__WorkEmail__c = 'testuser@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        // Create a test Attendance Event record matching the query criteria
        hed__Attendance_Event__c attendanceEvent = new hed__Attendance_Event__c(        
            hed__Contact__c = testContact.Id,       
            hed__Attendance_Type__c = 'Absent',
            hed__Reason__c = 'Sick',
            activity_based_att_req_dt__c = Date.today(),
            activity_based_att_app_dt__c = null          
        );
        insert attendanceEvent;
        
        // Set the UserId for the test to simulate the logged-in user
        System.runAs(testUser) {
            Test.startTest();
            List<hed__Attendance_Event__c> result = StudAttendanceUpdate.getAttendanceRecPendingForApproval(); 
            Test.stopTest();
            // Assertions to check if the result contains the expected attendance event
            System.assertEquals(1, result.size(), 'Expected one attendance record to be returned');
       
        }
    }
    
    @isTest
    static void testGetSchoolProgramDataWithValidData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Setup test data: Create an Account, Contact, and User
        Account schoolAccount = new Account(Name = 'Test School');
        insert schoolAccount;

        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            hed__WorkEmail__c = 'johndoe250225@test.com',          
            AccountId = schoolAccount.Id
        );
        insert testContact;

        User testUser = new User(
            Username = 'johndoe250225@test.com',
            Lastname = 'john doee',
            Email = 'johndoe250225@test.com',
            FederationIdentifier = 'john.doe250225@example.com',
            Alias = 'jdoe',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;      
        
        // Simulate running as the created User
        System.runAs(testUser) {
            // Setup Accounts related to the School
            Account programAccount = new Account(Name = 'Test Program', ParentId = schoolAccount.Id, Program_Code__c = 'AB12');
            insert programAccount;

            Test.startTest();
            List<String> result = StudAttendanceUpdate.getSchoolProgramData(); 
            Test.stopTest();

            // Assert that the program code is added to the result
            System.assertEquals(1, result.size(), 'Expected one program code to be returned');         
        }
    }
 
    @isTest
    static void testGetSchoolProgramDataNoProgramAccounts() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Setup test data: Create an Account and Contact
        Account schoolAccount = new Account(Name = 'Test School');
        insert schoolAccount;

        Contact testContact = new Contact(
            FirstName = 'Michael',
            LastName = 'Jordan',
            hed__WorkEmail__c = 'michael.jordan@example.com',
            AccountId = schoolAccount.Id
        );
        insert testContact;

        User testUser = new User(
            Username = 'michaeljordan@test.com',
            LastName = 'michael jordan',
            Email = 'michaeljordan@test.com',
            FederationIdentifier = 'michael.jordan@example.com',
            Alias = 'mjordan',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert testUser;
        
        // Simulate running as the created User
        System.runAs(testUser) {
            // Test with no related Program Accounts
            Test.startTest();
            List<String> result = StudAttendanceUpdate.getSchoolProgramData(); 
            Test.stopTest();

            // Assert that the result contains the error message for no program accounts found
            System.assertEquals(1, result.size(), 'Expected error message for no program accounts');
            System.assertEquals('Error in fetching programAccounts', result[0], 'Expected error message for no program accounts');
        }
    }  
}