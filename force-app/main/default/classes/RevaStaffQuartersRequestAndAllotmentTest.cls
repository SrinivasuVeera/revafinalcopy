@isTest
public class RevaStaffQuartersRequestAndAllotmentTest {
    
    @isTest
    static void testQuarterRequestProcess() {
        // Create test data
        Staff_Quarters_Room__c testRoom = new Staff_Quarters_Room__c(Type__c = '1 BHK');
        insert testRoom;
        SLCM_Employee_Rent_Detail__c rent = new SLCM_Employee_Rent_Detail__c(Monthly_Deduction_Amount__c =500.00,Room_Type__c ='1 BHK',Request_Type__c = 'Quarter');
        insert rent;
        // Mock User Profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserteaching@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company',
            EmployeeNumber = 'Reva0041'
        );
        insert testUser;
         RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];

        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = testUser.Email,
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id,
            Employee_Number__c = 'Reva0041',
            hed__WorkEmail__c = testUser.Email
        );
        insert testContact1;
        TriggerControl.isHCMTrggerDisable = true;
       // List<User> user = [SELECT Id ,Name,Email FROM User WHERE Email =: testContact1.hed__WorkEmail__c];
        System.runAs(testUser) {
            // Test quarter request process
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.quarterRequestProcess('1 BHK', Date.today());
            Map<String, String> result1 = RevaStaffQuartersRequestAndAllotment.quarterRequestProcess('10 BHK', Date.today());
            Test.stopTest();
            TriggerControl.isHCMTrggerDisable = false;
            // Assertions
           // System.assertEquals('true', result.get('isSuccess'));
            //System.assertNotEquals(null, result.get('quartersReq'));
            //System.assertEquals('Request for Quarters successfully submitted.', result.get('successMessage'));
        }
    }
    
    @isTest
    static void testFetchExistingQuartersReq() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
    
  
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Request Submitted',
            Quarter_Request_For__c = testContact1.Id
        );
        insert testRequest;


        System.runAs(testUser) {
            // Test fetch existing quarters request
            Test.startTest();
            Staff_Quarters_Request__c result = RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersReq(testUser.Id);
            Staff_Quarters_Request__c result1 = RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersDetails(testUser.Id);
            Test.stopTest();
            
            // Assertions
            System.assertNotEquals(null, result);
            System.assertEquals('Request Submitted', result.Status__c);
        }
    }
    
    
  @isTest
    static void testFetchExistingvac() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor826@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Request Submitted',
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest;

       Staff_Quarter_Vacation_Request__c  testvacreq = new Staff_Quarter_Vacation_Request__c(
        Staff_Quarters_Request__c = testRequest.Id,
           Status__c = 'Vacating Initiated'
        );
        insert testvacreq;
        
        System.runAs(testUser) {
            // Test fetch existing quarters request
            Test.startTest();
            Staff_Quarter_Vacation_Request__c result = RevaStaffQuartersRequestAndAllotment.fetchExistVacationReq(testvacreq.Id);
            Test.stopTest();
            
     }
    }
    
    @isTest
    static void testInitiateVacation() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor85@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
    
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Room Allotted',
            Quarter_Request_For__c =testContact1.Id
        );
        insert testRequest;
        
        System.runAs(testUser) {
            // Test initiate vacation
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.initiateVacation(testUser.Id);
            Test.stopTest();
            
            // Assertions
           // System.assertEquals('true', result.get('isSuccess'));
            //System.assertEquals('Staff Vacation Initiated', result.get('successMessage'));
            
            // Fetch updated request
            Staff_Quarters_Request__c updatedRequest = [SELECT Status__c FROM Staff_Quarters_Request__c WHERE Id = :testRequest.Id];
            //System.assertEquals('Vacation Initiated', updatedRequest.Status__c);
        }
    }
    
    @isTest
    static void testFetchInitialInfo() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor186@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Request Submitted',
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest;
/*

     
         Staff_Quarters_Request__c testRequest5 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Initiated'
        );
       // insert testRequest5;
        
         Staff_Quarters_Request__c testRequest6 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Completed'
        );
        //insert testRequest6;
        
*/
        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }
    

   @isTest
    static void testFetchallotedInfo() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor86@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
             
         Staff_Quarters_Request__c testRequest1 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Room Allotted',
             Quarter_Request_For__c =testContact1.Id
        );
        insert testRequest1;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchApprovedInfo() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor86@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
            Staff_Quarters_Request__c testRequest2 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Approved',
            Quarter_Request_For__c = testContact1.Id
        );
     insert testRequest2;
        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchRejectedInfo() {
        // Create test data
        //User testUser = createTestUser();
		RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor8685@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
         Staff_Quarters_Request__c testRequest3 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Rejected',
             Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest3;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchVacationInfo() {
        // Create test data
        //User testUser = createTestUser();
       RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor4586@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
         Staff_Quarters_Request__c testRequest4 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Initiated',
             Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest4;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }

  @isTest
    static void testFetchCompletedInfo() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor86@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
              Staff_Quarters_Request__c testRequest7 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Completed',
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest7;

        
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }
    
 @isTest
    static void testFetchVacInitiatedInfo() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor861@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
              Staff_Quarters_Request__c testRequest7 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Initiated',
                  Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest7;

        Staff_Quarter_Vacation_Request__c testvacrequest = new Staff_Quarter_Vacation_Request__c(
        Staff_Quarters_Request__c = testRequest7 .Id,
          Status__c =   'Vacating Initiated',
            Initiated_Date__c =system.Today()
        );
        insert testvacrequest;
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }


 @isTest
    static void testFetchVacCompletedInfo() {
        // Create test data
        //User testUser = createTestUser();
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor806@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
              Staff_Quarters_Request__c testRequest7 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Initiated',
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest7;

        Staff_Quarter_Vacation_Request__c testvacrequest = new Staff_Quarter_Vacation_Request__c(
        Staff_Quarters_Request__c = testRequest7 .Id,
          Status__c =   'Completed',
            Initiated_Date__c =system.Today()
        );
        insert testvacrequest;
        System.runAs(testUser) {
            // Test fetch initial info
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.fetchInitialInfo(testUser.Id);
            Test.stopTest();
            
         }
    }



    @isTest
    static void testFetchExistingQuartersUserDetails() {
        // Create test data
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
		// Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = 'professor@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id
        );
        insert testContact1;

        // Create a user linked to the contact
        User testUser = new User(
            ProfileId = p2.Id,
            Username = 'professor858@example.com',
            Email = testContact1.email,
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor'
            //ContactId = testContact1.Id
        );
        insert testUser;
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Type__c = '1 BHK',
            Status__c = 'Request Submitted',
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest;
        
        // Test fetch existing quarters user details
        Test.startTest();
        List<Staff_Quarters_Request__c> result = RevaStaffQuartersRequestAndAllotment.fetchExistingQuartersUserDetails('1 BHK');
        Test.stopTest();
        
        // Assertions
        System.assert(!result.isEmpty());
        System.assertEquals('1 BHK', result[0].Type__c);
    }
    
    // Helper method to create test user
    static User createTestUser() {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuserrrr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserProfessror@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company'
        );
        insert testUser;
        return testUser;
    }
    
     @isTest
    static void updateRejectedQuaterReqTest() {
        // Create test data
        Staff_Quarters_Room__c testRoom = new Staff_Quarters_Room__c(Type__c = '1 BHK');
        insert testRoom;
        SLCM_Employee_Rent_Detail__c rent = new SLCM_Employee_Rent_Detail__c(Monthly_Deduction_Amount__c =500.00,Room_Type__c ='1 BHK',Request_Type__c = 'Quarter');
        insert rent;
        // Mock User Profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser12@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserteaching12@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company',
            EmployeeNumber = 'Reva0043'
        );
        insert testUser;
         RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];

        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = testUser.Email,
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id,
            Employee_Number__c = 'Reva0043',
            hed__WorkEmail__c = testUser.Email
        );
        insert testContact1;
        
         Staff_Quarters_Request__c testRequest8 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Rejected',
            Staff_Quarters_Joining_Date__c = System.Today(),
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest8;
        
        TriggerControl.isHCMTrggerDisable = true;
        System.runAs(testUser) {
            // Test quarter request process
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.updateRejectedQuaterReq('1 BHK', Date.today(),testRequest8.Id);
            Test.stopTest();
            
           List<Staff_Quarters_Request__c> st = [SELECT Id ,Status__c,Is_Re_Joined__c,Quarter_Request_For__c from Staff_Quarters_Request__c WHERE Quarter_Request_For__c =: testContact1.Id];
            System.assertEquals(1 ,st.size());
            System.assertEquals('Request Submitted' ,st[0].Status__c);         
        }
    }
    
      @isTest
    static void updateRejectedQuaterReqReJoinTest() {
        // Create test data
        Staff_Quarters_Room__c testRoom = new Staff_Quarters_Room__c(Type__c = '1 BHK');
        insert testRoom;
        SLCM_Employee_Rent_Detail__c rent = new SLCM_Employee_Rent_Detail__c(Monthly_Deduction_Amount__c =500.00,Room_Type__c ='1 BHK',Request_Type__c = 'Quarter');
        insert rent;
        // Mock User Profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser123@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserteaching123@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company',
            EmployeeNumber = 'Reva00431'
        );
        insert testUser;
         RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];

        // Create a contact with Professor record type
        Contact testContact1 = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            Email = testUser.Email,
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            Birthdate = Date.newInstance(1980, 1, 1),
            RecordTypeId = professorRecordType.Id,
            Employee_Number__c = 'Reva00431',
            hed__WorkEmail__c = testUser.Email
        );
        insert testContact1;
        
         Staff_Quarters_Request__c testRequest8 = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Vacation Completed',
            Staff_Quarters_Joining_Date__c = System.Today(),
            Quarter_Request_For__c = testContact1.Id 
        );
        insert testRequest8;
        
        TriggerControl.isHCMTrggerDisable = true;
        System.runAs(testUser) {
            // Test quarter request process
            Test.startTest();
            Map<String, String> result = RevaStaffQuartersRequestAndAllotment.quarterRequestProcess('1 BHK', Date.today());

            Test.stopTest();
            List<Staff_Quarters_Request__c> st = [SELECT Id ,Status__c,Is_Re_Joined__c,Quarter_Request_For__c from Staff_Quarters_Request__c WHERE Quarter_Request_For__c =: testContact1.Id AND Status__c ='Re-Joined'];
            System.assertEquals(1 ,st.size());
            System.assertEquals(true ,st[0].Is_Re_Joined__c);
         
        }
    }
}