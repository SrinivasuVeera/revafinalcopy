@isTest
public class RevaHostelRequestAndAllotmentTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
        
    }
    private class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"success"}'); // Adjust as needed based on your expected response
            response.setStatusCode(200);
            return response;
        }
    }
    
    @isTest
    static void testRevaHostelRoomAllotment() {
        // Setup test data
        REVA_Course_Type__c testCourse = new REVA_Course_Type__c(
            Name = 'Computer Science and Engineeging 6',
            Course_Code__c = 'EF',
            Engineering__c = true,
            CS__c = true
        );
        insert testCourse;
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND UserRoleId != NULL LIMIT 1];
        
        // Create an Account record
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF',
            OwnerId = adminUser.Id 
        );
        insert testAccount;
        RecordType StudentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudentreva2025@example.com',
            hed__Gender__c = 'Male',
            Primary_Academic_Program__c = testAccount.Id,
            Advanced_Hostel_Registration__c = true,
            RecordTypeId = StudentRecordType.Id,
            AccountId = testAccount.Id// Link to the Account
        );
        insert testContact;
        
        Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
            Name = '206',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert testRoom;
        
        // Create a test User with a Contact association
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = :Constants.StudentProfile LIMIT 1];
        User testUser = new User(
            LastName='test',
            FirstName='user',
            Alias = 'testuser',
            Email = 'testusertestreva2025@example.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'corevahosteltestuserreva2025validate@example.com',
            ContactId = testContact.Id // Ensure the User has an associated Contact
        );
        insert testUser;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Rejoiner__c = false ,
            Type__c = '1',
            Status__c = 'Booked'
           
        );
        insert hostelRequest;
        
        
        // Run the test as the created User
        System.runAs(testUser) {
            // Call the method to test
            Map<String, String> result = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(
                testContact.Id,
                '4',
                false,
                Date.today()
            );
        }
        
        
        //Non Teaching Staff
        User adminUser1 = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' And IsActive=true AND UserRoleId != NULL LIMIT 1];
        Account testAccount1 = new Account(
            Name = 'Test Staff Account',
            OwnerId = adminUser1.Id // Ensuring the account owner has a role
        );
        insert testAccount1;
        
        Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();
        Contact testContact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudenttttete@example.com',
            hed__WorkEmail__c =  'teststudenttttete@example.com',
            hed__Gender__c = 'Male',
            RecordTypeId = Non_teachiningRecordTypeId,
            Employee_Number__c ='REVA01452',
            AccountId = testAccount1.Id 
            
        );
        insert testContact1;
        
          Reva_Hostel_Request__c hostelRequest1 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact1.Id,
            Rejoiner__c = false ,
            Type__c = '1',
            Status__c = 'Booked'
           
        );
        insert hostelRequest1;
        
        Reva_Hostel_Room__c testRoom1 = new Reva_Hostel_Room__c(
            Name = '206',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Staff',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'None - Demo/Staff',
            Is_Premium__c = false
        );
        insert testRoom1;
        
        // Create a test User with a Contact association
        Profile nonteachProfile = [SELECT Id FROM Profile WHERE Name = :Constants.NonTeachingStaffProfile LIMIT 1];
        User nontestUser1 = new User(
            LastName='test',
            FirstName='user',
            Alias = 'testuser',
            Email = 'teststudenttttete@example.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = nonteachProfile.Id,
            EmployeeNumber ='REVA01452',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'corevahosteltestuservalidate123@example.commmmm',
            ContactId = testContact1.Id // Ensure the User has an associated Contact
        );
        insert nontestUser1;
        
        System.runAs(nontestUser1) {
            Map<String, String> result1 = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(
                testContact1.Id,
                '4',
                false,
                Date.today()
            );
            
        }
        
        // Teaching Staff
        Id teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
        
        RecordType profRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
        
        Contact testContact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__WorkEmail__c  = 'teststudentyy553663t@example.com',
            hed__Gender__c = 'Male',
            Employee_Number__c ='REVA01452',
            RecordTypeId = teachiningRecordTypeId
        );
       // insert testContact2;
        
        Reva_Hostel_Room__c testRoom2 = new Reva_Hostel_Room__c(
            Name = '206',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Non-Staff',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Demo/Staff',
            Is_Premium__c = false
        );
        insert testRoom2;
        
        // Create a test User with a Contact association
        Profile teachProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser2 = new User(
            LastName='test',
            FirstName='user',
            Alias = 'testuser',
            Email = 'teststudent@example.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = teachProfile.Id,
            EmployeeNumber ='REVA01452',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'corevahosteltestuservalidate1234@example.commm'
        );
        //insert testUser2;
        
        //System.runAs(testUser2) {
            /* Map<String, String> result2 = RevaHostelRequestAndAllotment.RevaHostelRoomAllotment(
testContact2.Id,
//testProfContact.Id,
'4',
false,
Date.today()
); */
        //}
        
    }
    
    @isTest
    static void testGetCourses() {
        // Setup test data
        REVA_Course_Type__c testCourse = new REVA_Course_Type__c(
            Name = 'Computer Science and Engineering 6',  // Required field
            Course_Code__c = 'EF'
        );
        insert testCourse;
        
        // Call the method to test
        REVA_Course_Type__c result = RevaHostelRequestAndAllotment.getCourses('EF');
        
        // Validate results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('EF', result.Course_Code__c, 'Course code should match');
    }
    
    @isTest
    static void testHostelRoomsAvailability() {
        // Create an Account record
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering'
        );
        insert testAccount;
        
        // Setup test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Male',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact;
        
        Contact testContact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Female',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact2;
        
        REVA_Course_Type__c testCourse = new REVA_Course_Type__c(
            Name = 'Computer Science and Engineering 6',  // Corrected typo
            Course_Code__c = 'EF',
            Engineering__c = true,
            CS__c = true
        );
        insert testCourse;
        
        Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
            Name = 'Test Room',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            //Vacant_Occupancy__c = 1,  // Ensure this is set to a positive value
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert testRoom;
        
        // Call the method to test
        List<Reva_Hostel_Room__c> result = RevaHostelRequestAndAllotment.hostelRoomsAvailability(
            '4',
            'Student',
            testContact,
            false
        );
        List<Reva_Hostel_Room__c> result1 = RevaHostelRequestAndAllotment.hostelRoomsAvailability(
            '4',
            'Non-Staff',
            testContact,
            false
        );
        List<Reva_Hostel_Room__c> result2 = RevaHostelRequestAndAllotment.hostelRoomsAvailability(
            '4',
            'Student',
            testContact2,
            false
        );
        
        
        
        
        // Debugging
        System.debug('Result size: ' + result.size());
        if (!result.isEmpty()) {
            System.debug('First room ID: ' + result[0].Id);
        }
        
        // Validate results
        System.assertNotEquals(null, result, 'Result should not be null');
        
    }
    
    
    @isTest
    static void testCreateStudentFeeRecord() {
        // Setup test data
        Contact testContact = new Contact(
            LastName = 'Test',
            Personal_Email__c = 'test@example.com',
            MobilePhone = '1234567890',
            Split_Booking_Fee__c = true
        );
        insert testContact;
        /* REVA_Hostel_Academic_Year__c academicYear = new REVA_Hostel_Academic_Year__c(
Name='Academic 2024-2025',
Is_Active_Academic__c=true
);
insert academicYear;

Hostel_Fee_Structure__c hostelFeeStructure = new Hostel_Fee_Structure__c(
Name = '4 Sharing (Boys)',
REVA_Hostel_Academic_Year__c =academicYear.Id);

insert hostelFeeStructure;*/
        REVA_Hostel_Academic_Year__c academicYear = new REVA_Hostel_Academic_Year__c(
            Name = 'Academic 2024-2025',
            Is_Active_Academic__c = false // Initially set to false
        );
        insert academicYear;
        
        // Step 2: Insert Hostel Fee Structure linked to the Academic Year
        Hostel_Fee_Structure__c hostelFeeStructure = new Hostel_Fee_Structure__c(
            Name = '4 Sharing (Boys)',
            REVA_Hostel_Academic_Year__c = academicYear.Id,
            Gender__c = 'Boys',
            Hostel_Room_Fees__c=14000,
            Occupancy__c='4'
        );
        insert hostelFeeStructure;
        
        // Step 3: Now update the Academic Year to activate it
        academicYear.Is_Active_Academic__c = true;
        update academicYear;
        
        // Setup Fee Payment Criteria records
        Fee_Payment_Criteria__c fullPaymentCriteria = new Fee_Payment_Criteria__c(Name = 'Hostel Fee - Full Payment');
        Fee_Payment_Criteria__c partialPaymentCriteria = new Fee_Payment_Criteria__c(Name = 'Hostel Fee - Partial Payment');
        insert new List<Fee_Payment_Criteria__c>{ fullPaymentCriteria, partialPaymentCriteria };
            
            // Setup Hostel Request record
            Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
                Hostel_Room_Request_For__c = testContact.Id,
                Type__c = '4'
            );
        insert hostelRequest;
        
        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
        // Call the method
        Test.startTest();
        Boolean result = RevaHostelRequestAndAllotment.createStudentFeeRecord(
            testContact.Id,
            'Full Payment',
            false,
            14000,
            hostelRequest.Id
        );
        Boolean result1 = RevaHostelRequestAndAllotment.createStudentFeeRecord(
            testContact.Id,
            'Partial Payment',
            false,
            14000,
            hostelRequest.Id
        );
        Test.stopTest();
        
        // Assertions
        //System.assert(result, 'The student fee record should be created successfully');
        System.assert(result,TRUE);
        System.assertNotEquals(null, [SELECT Id FROM Student_Fee__c WHERE Contact__c = :testContact.Id LIMIT 1], 'Student Fee record should be created');
        System.assertNotEquals(null, [SELECT Id FROM Student_Payment__c WHERE Contact__c = :testContact.Id LIMIT 1], 'Student Payment record should be created');
    }
    
    @isTest
    static void testCreatePaymentRecord() {
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND  UserRoleId != NULL LIMIT 1];
        
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        // Setup test data
        Contact testContact = new Contact(
            LastName = 'Test',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        
        
        // Creating initial student fee record with 'Partial Payment' to meet method criteria
        Student_Fee__c studentFee = new Student_Fee__c(
            Name = 'Test Hostel Fee',
            Contact__c = testContact.Id,
            Fee_Type__c = 'Hostel Fee',
            Payment_Type__c = 'Partial Payment',
            Amount__c = 140000,
            Amount_Pending__c = 140000
        );
        insert studentFee;
        
        // Using a test user with the appropriate profile
        Profile teachProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User testUser = new User(
            Alias = 'tstuser',
            Email = 'tstuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = teachProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'corevahosteltstuserstupay004validate12345@example.com',
            ContactId = testContact.Id
        );
        insert testUser;
        
        // Setting the context to the test user
        System.runAs(testUser) {
            // Call the method
            Decimal amount = 500.0;
            Decimal pendingAmount = 1000.0;
            
            Test.startTest();
            RevaHostelRequestAndAllotment.createPaymentRecord(amount, pendingAmount);  // Adjust the class name as necessary
            Test.stopTest();
            
            // Assertions
            List<Student_Payment__c> studentPayments = [SELECT Id, Amount__c, Payment_Status__c, Fee_Type__c, Mode_of_Payment__c, Payment_Gateway__c, Contact__c FROM Student_Payment__c WHERE Contact__c = :testContact.Id];
            List<Student_Fee_Payment__c> studentFeePayments = [SELECT Id, Student_Fee__c, Student_Payment__c, Line_Item_Payment_Status__c, Mode_of_Payment__c, Line_Item_Payment_Gateway__c, Amount__c, Transaction_Date_Time__c FROM Student_Fee_Payment__c WHERE Student_Fee__c = :studentFee.Id];
            
            // Your assertion logic here
        }
    }
    
    
    @isTest
    static void testGetStudentFee() {
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND UserRoleId != NULL LIMIT 1];
        
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        
        // Setup test data
        Contact testContact = new Contact(
            LastName = 'Test',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Student_Fee__c studentFee = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Hostel Fee',
            Payment_Type__c = 'Partial Payment',
            Amount__c = 140000,
            Amount_Pending__c = 140000
        );
        insert studentFee;
        
        // Create a test User with the Contact association
        User testUser = new User(
            LastName='test',
            FirstName='user2',
            Alias = 'testuser',
            Email = 'testuser2@example.com',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1].Id, // Adjust profile as needed
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'corevahosteltestuser25stupay005@example.com',
            ContactId = testContact.Id
        );
        insert testUser;
        
        // Run the test as the created User
        System.runAs(testUser) {
            // Call the method to test
            Student_Fee__c result = RevaHostelRequestAndAllotment.getStudentFee();
            
            // Validate results
            System.assertNotEquals(null, result, 'Student Fee record should be retrieved');
            System.assertEquals('Hostel Fee', result.Fee_Type__c, 'The Fee Type should be Hostel Fee');
        }
    }
    
    
    
    @isTest
    static void testGetStudentFeeAndPaymentDetails() {
        // Setup test data
        Contact testContact = new Contact(
            LastName = 'Test'
        );
        insert testContact;
        
        Student_Fee__c studentFee = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Hostel Fee',
            Payment_Type__c = 'Partial Payment',
            Amount__c = 140000,
            Amount_Pending__c = 140000
        );
        insert studentFee;
        
        Student_Payment__c studentPayment = new Student_Payment__c(
            Contact__c = testContact.Id,
            Amount__c = 140000,
            Payment_Status__c = 'Pending',
            Fee_Type__c = 'Hostel Fee'
        );
        insert studentPayment;
        
        // Call the method
        Test.startTest();
        Map<String, Object> result = RevaHostelRequestAndAllotment.getStudentFeeAndPaymentDetails();
        Test.stopTest();
        
        
    }
    
    
    @isTest
    static void testCreateStudentFeeRecord1() {
        
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND UserRoleId != NULL LIMIT 1];
        
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        
        // Set up test data
        Contact testContact = new Contact(
            LastName = 'Test', // Adjust as needed
            Personal_Email__c = 'test@example.com',
            MobilePhone = '1234567890',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Set up Fee Payment Criteria data
        Fee_Payment_Criteria__c fullPaymentCriteria = new Fee_Payment_Criteria__c(
            Name = 'Hostel Fee - Full Payment'
        );
        insert fullPaymentCriteria;
        
        Fee_Payment_Criteria__c partialPaymentCriteria = new Fee_Payment_Criteria__c(
            Name = 'Hostel Fee - Partial Payment'
        );
        insert partialPaymentCriteria;
        
        // Set up a Hostel Request record
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Rejoiner__c = false ,
            Type__c = '1'
        );
        insert hostelRequest;
        
        // Set up necessary user context
       // Profile applicantProfile = [SELECT Id FROM Profile WHERE Name = 'Applicant Profile' LIMIT 1];
        User testUser = new User(
            Alias = 'tstuser',
            Email = 'tstuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId =  [SELECT Id FROM Profile WHERE Name = 'Applicant Profile' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'corevahosteltstuserstupay001@example.com',
            ContactId = testContact.Id
        );
        insert testUser;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        System.runAs(testUser) {
            Test.startTest();
            // Call the method with test data
            Boolean result = RevaHostelRequestAndAllotment.createStudentFeeRecord(
                testContact.Id,
                'Partial Payment',
                true,
                3000,
                hostelRequest.Id
            );
            Test.stopTest();
            
        }
    }
    
    /****************************/
    @isTest
    static void testRoomTypeStudentMale() {
        // Setup test data
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF'
        );
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Male',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact;
        REVA_Course_Type__c courseType = new REVA_Course_Type__c(Name='test', Engineering__c = true, CS__c = true);
        insert courseType;
        
        Test.startTest();
        List<Reva_Hostel_Room__c> rooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability('1', 'Student', testContact, false);
        Test.stopTest();
        
        System.debug('Room should be found for Male Student');
    }
    
    @isTest
    static void testRoomTypeNonStaff() {
        // Setup test data
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF'
        );
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Female',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact;
        
        Test.startTest();
        List<Reva_Hostel_Room__c> rooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability('1', 'Non-Staff', testContact, false);
        Test.stopTest();
        
        System.debug('Room should be found for Non-Staff');
    }
    
    @isTest
    static void testRoomTypeStudentFemaleWithCourseDetails() {
        // Setup test data
        
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF'
        );
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Female',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact;
        
        REVA_Course_Type__c courseType = new REVA_Course_Type__c(Name='Test1', Engineering__c = true, CS__c = true);
        insert courseType;
        
        Test.startTest();
        List<Reva_Hostel_Room__c> rooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability('1', 'Student', testContact, false);
        Test.stopTest();
        
        System.debug('Room should be found for Female Student with course details');
    }
    
    @isTest
    static void testRoomTypeStudentFemaleWithoutCourseDetails() {
        // Setup test data
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF'
        );
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Male',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact;
        
        Test.startTest();
        List<Reva_Hostel_Room__c> rooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability('1', 'Student', testContact, false);
        Test.stopTest();
        
        System.debug('No room should be found for Female Student without course details');
    }
    
    @isTest
    static void testInvalidRoomType() {
        // Setup test data
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF'
        );
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Male',
            Primary_Academic_Program__c = testAccount.Id  // Link to the Account
        );
        insert testContact;
        
        Test.startTest();
        List<Reva_Hostel_Room__c> rooms = RevaHostelRequestAndAllotment.hostelRoomsAvailability('1', 'InvalidType', testContact, false);
        Test.stopTest();
        
        System.debug('No room should be found for invalid room type');
    }
    
}