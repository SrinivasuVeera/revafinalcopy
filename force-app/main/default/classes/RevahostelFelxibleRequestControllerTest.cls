@istest
public class RevahostelFelxibleRequestControllerTest {
  
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
   
    @testSetup
    static void setup() {
        // Create a contact
        RecordType studentRecordType1 = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testuserhstl001hstl@example.com',RecordTypeId=studentRecordType1.ID);
        insert testContact;
        
         // Create a user with a profile
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Student Portal Profile' OR Name ='Student Profile'  LIMIT 1];
        User testUser = new User(
            ProfileId = p.Id,
            Username = 'testuserhstl001@example.com',
            Email = 'testuserhstl001hstl@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'tuser',
            LastName = 'Testing',
            ContactId = testContact.Id
        );
        //System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        //}
        
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];

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
        User testUser1 = new User(
            ProfileId = p.Id,
            Username = 'professor@example.com',
            Email = 'professor@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'prof',
            LastName = 'Professor',
            ContactId = testContact1.Id
        );
        insert testUser1;
    
  // Create a profile
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];

        // Create a record type for Contact
        RecordType nonTeachingRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        if (nonTeachingRecordType == null) {
            throw new AuraHandledException('RecordType for Non Teaching not found.');
        }

        // Create a contact with Non Teaching record type
        Contact testContact2 = new Contact(
            LastName = 'Test',
            FirstName = 'NonTeaching',
            Email = 'nonteaching@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            RecordTypeId = nonTeachingRecordType.Id
        );
        insert testContact2;

        // Create a user linked to the contact with a valid Alias value
        User testUser2 = new User(
            ProfileId = p2.Id,
            Username = 'nonteaching@example.com',
            Email = 'nonteaching@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'nontch', // Valid Alias (max 8 characters)
            LastName = 'NonTeaching',
            ContactId = testContact2.Id
        );
        insert testUser2;
        

                // Create a profile
        Profile p3 = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        
        // Create a record type for Contact
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        if (studentRecordType == null) {
            throw new AuraHandledException('RecordType for Student not found.');
        }

         Contact testContactFather = new Contact(
            LastName = 'Test',
            FirstName = 'Student',
            Email = 'student@example.com',
            MobilePhone = '1234567890'
            
        );
        insert testContactFather;
        
         Contact testContactMother = new Contact(
            LastName = 'Test',
            FirstName = 'Student',
            Email = 'student@example.com',
            MobilePhone = '1234567890'
           
        );
        insert testContactMother;
        
        // Create a contact with Student record type
        Contact testContact3 = new Contact(
            LastName = 'Test',
            FirstName = 'Student',
            Email = 'student@example.com',
            MobilePhone = '1234567890',
            hed__Gender__c = 'Male',
            RecordTypeId = studentRecordType.Id,
            Father__c =testContactFather.Id ,
            
            SRN_Number__c = 'SRN123456'
        );
        insert testContact3;
        
        // Create a user linked to the contact
        User testUser3 = new User(
            ProfileId = p3.Id,
            Username = 'student@example.com',
            Email = 'student@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'studen', // Valid Alias (max 8 characters)
            LastName = 'Student',
            ContactId = testContact3.Id
        );
        insert testUser3;
         // Create test records
        Account acc = new Account(Name = 'Test School');
        insert acc;
        
       hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestIAProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        // Add Program Batch to the contact
        testContact3.Program_Batch__c = programBatch.Id;
        update testContact;
        
       

        
        // Create an application record
        hed__Application__c application = new hed__Application__c(
            hed__Applicant__c = testContact.Id,
            Provisional_Admission_Fee_Paid__c = false
        );
        insert application;
    
       Reva_Hostel_Room__c HostelRoom = new Reva_Hostel_Room__c(
            Name = '100',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Floor__c = 'SF', 
            Room_Type__c = 'Student',
            Room_Category__c = 'Eng CS',
            Maximum_Occupancy__c = '4'
            
        );
        Insert HostelRoom;
        
         // Create a Hostel Request linked to the contact
        Reva_Hostel_Request__c hostelRequest3 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact3.Id,
            Status__c = 'Approved',
            Reva_Hostel_Room__c = HostelRoom.Id,
            Type__c = '1'
        );
        insert hostelRequest3;
        
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Status__c = 'Room Alloted',
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_Premium_Room__c = false,
            Reva_Hostel_Room__c=HostelRoom.id,
            Type__c = '1'
        );
        insert hostelRequest;
        
         Reva_Hostel_Request__c vacatedRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Status__c = 'Vacated',
             Type__c = '1'
        );
        insert vacatedRequest;
        
      //  Test.setMock(HttpCalloutMock.class, new RestMock());
    }
    
     @isTest
    static void testGetCurrentStudentContact() {
        User testUser = [SELECT Id FROM User WHERE Username = 'student@example.com' LIMIT 1];
         contact con = [SELECT id,SRN_Number__c FROM contact WHERE SRN_Number__c !=null];
        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> contactDetails = RevahostelFelxibleRequestController.getStudentBySRN(con.SRN_Number__c);
            List<String> years = RevahostelFelxibleRequestController.getAcademicYears();
            Id ids= RevahostelFelxibleRequestController.getLoggedInUserId();
            Test.stopTest();
        }
    }
    
    @isTest
static void testRevaHostelRoomAllotment_Method() {

    // Get an existing student user created in @testSetup
    User testUser = [SELECT Id, ContactId FROM User WHERE Username = 'student@example.com' LIMIT 1];
    Contact testContact = [SELECT Id, Advanced_Hostel_Registration__c FROM Contact WHERE Id = :testUser.ContactId];

    // Make sure Advanced Registration is FALSE to cover room availability logic
    testContact.Advanced_Hostel_Registration__c = false;
    update testContact;

    // Create a Hostel Room (required for availability)
    Reva_Hostel_Room__c room = new Reva_Hostel_Room__c(
        Name = '101',
        Block__c = 'A',
        Floor__c = 'FF',
        Maximum_Occupancy__c = '4',
        Room_Type__c = 'Student',
        Dormitory_Type__c = 'Boys',
        Room_Category__c = 'Eng CS',
        Is_Premium__c = false
    );
    insert room;

    Test.startTest();

    System.runAs(testUser) {

        Map<String, String> result = RevahostelFelxibleRequestController.RevaHostelRoomAllotment(
            testContact.Id,
            '4',
            false,
            Date.today(),
            'One Semester',
            5000,
            500,
            'hello'
        );

       }

    Test.stopTest();

    // Verify record inserted
    List<Reva_Hostel_Request__c> requests = [
        SELECT Id, Hostel_Room_Request_For__c
        FROM Reva_Hostel_Request__c
        WHERE Hostel_Room_Request_For__c = :testContact.Id
    ];

   // System.assert(requests.size() > 0, 'Hostel request should be created');
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
    static void testCreateStudentFeeRecord() {
        // Setup test data
        Contact testContact = new Contact(
            LastName = 'Test',
            Personal_Email__c = 'test@example.com',
            MobilePhone = '1234567890',
            Split_Booking_Fee__c = true
        );
        insert testContact;

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
        Boolean result = RevahostelFelxibleRequestController.createStudentFeeRecord(
            testContact.Id,
            'Full Payment',
            false,
            14000,
            hostelRequest.Id,
            'One Semester',
                5000
        );
        Boolean result1 = RevahostelFelxibleRequestController.createStudentFeeRecord(
            testContact.Id,
            'Partial Payment',
            false,
            14000,
            hostelRequest.Id,
            'One Semester',
                5000
        );
        Test.stopTest();
        
     }
    
        @isTest
    static void testCalculateHostelFee() {
        Test.startTest();
        
        // Create active academic year record
        REVA_Hostel_Academic_Year__c activeAcademicYear = new REVA_Hostel_Academic_Year__c(
            Name = '2024-2025', 
            Is_Active_Academic__c = false
        );
        insert activeAcademicYear;
        
        // Create test hostel fee structure records
        List<Hostel_Fee_Structure__c> hostelSettings = new List<Hostel_Fee_Structure__c>{
            new Hostel_Fee_Structure__c(
                Name = 'Single Premium Final Year Boys',
                REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                Hostel_Room_Fees__c = 194000,
                Occupancy__c = 'Single',
                Is_Final_Year__c = true,
                Premium__c = true,
                Gender__c = 'Boys',
                plan_Type__c = 'One Semester'
            ),
                new Hostel_Fee_Structure__c(
                    Name = 'Single Premium Non-Final Year Boys',
                    REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                    Hostel_Room_Fees__c = 271000,
                    Occupancy__c = 'Single',
                    Is_Final_Year__c = false,
                    Premium__c = true,
                    Gender__c = 'Boys',
                    plan_Type__c = 'One Semester'
                )
                };
                    insert hostelSettings;
        activeAcademicYear.Is_Active_Academic__c = true;
         update activeAcademicYear;
        
        // Fetch an existing User with a Role (System Admin)
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND UserRoleId != NULL LIMIT 1];
        
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        
        // Create test Contact linked to Account
        Contact testContact = new Contact(
            FirstName = 'Test', 
            LastName = 'User', 
            hed__Gender__c = 'Male',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Fetch Student Profile for Community Users
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        
        // Create test Community User without UserRoleId
        User testUser = new User(
            FirstName = 'Test', 
            LastName = 'User',
            ContactId = testContact.Id,
            Username = 'testuser@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = studentProfile.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser) {
            // Test case 1: Final year student with matching setting
            RevahostelFelxibleRequestController.HostelFeeResponse result1 = RevahostelFelxibleRequestController.calculateHostelFee('Single', true, true,'Male', 'One Semester',activeAcademicYear.Name);
          //  System.assertEquals(194000, result1.hostelFee, 'Expected hostelFee to be 194000');
            
            // Test case 2: Non-final year student with matching setting
            RevahostelFelxibleRequestController.HostelFeeResponse result2 = RevahostelFelxibleRequestController.calculateHostelFee('Single', true, false,'Male', 'One Semester',activeAcademicYear.Name);
            RevahostelFelxibleRequestController.HostelFeeResponse result3 = RevahostelFelxibleRequestController.calculateHostelFee('Single', true, false,'FeMale', 'One Semester',activeAcademicYear.Name);

        }
        
        Test.stopTest();
    }
    
    @isTest
static void testCalculateHostelFee1() {

    // ✅ Create Academic Year (ACTIVE from start)
    REVA_Hostel_Academic_Year__c academicYear = new REVA_Hostel_Academic_Year__c(
        Name = '2024-2025',
        Is_Active_Academic__c = false
    );
    insert academicYear;

    // ✅ Create Fee Records
    List<Hostel_Fee_Structure__c> listSettings = new List<Hostel_Fee_Structure__c>{

        new Hostel_Fee_Structure__c(
            Name = 'Final Boys',
            REVA_Hostel_Academic_Year__c = academicYear.Id,
            Hostel_Room_Fees__c = 100000,
            Occupancy__c = 'Single',
            Is_Final_Year__c = true,
            Premium__c = true,
            Gender__c = 'Boys',
            Plan_Type__c = 'One Semester'
        ),

        new Hostel_Fee_Structure__c(
            Name = 'Generic Boys',
            REVA_Hostel_Academic_Year__c = academicYear.Id,
            Hostel_Room_Fees__c = 80000,
            Occupancy__c = 'Double',
            Premium__c = true,
            Gender__c = 'Boys',
            Plan_Type__c = 'One Semester'
        )
    };

    insert listSettings;
    
    academicYear.Is_Active_Academic__c = true;
    update academicYear;

    Test.startTest();

    // ✅ 1. academicYear NOT NULL (first query)
    RevahostelFelxibleRequestController.HostelFeeResponse r1 =
        RevahostelFelxibleRequestController.calculateHostelFee(
            'Single', true, true, 'Male', 'One Semester', '2024-2025'
        );
    System.assertEquals(100000, r1.hostelFee);

    // ✅ 2. academicYear = NULL (else query)
    RevahostelFelxibleRequestController.HostelFeeResponse r2 =
        RevahostelFelxibleRequestController.calculateHostelFee(
            'Single', true, true, 'Male', 'One Semester', null
        );
    System.assertNotEquals(null, r2.hostelFee);

    // ✅ 3. academicYear = '' (VERY IMPORTANT - covers condition)
    RevahostelFelxibleRequestController.HostelFeeResponse r3 =
        RevahostelFelxibleRequestController.calculateHostelFee(
            'Double', true, true, 'Male', 'One Semester', ''
        );
    System.assertEquals(80000, r3.hostelFee);

    Test.stopTest();
}
    @isTest
    static void testGetAllRoomPrices() {
        Test.startTest();
        
        // Create active academic year record
        REVA_Hostel_Academic_Year__c activeAcademicYear = new REVA_Hostel_Academic_Year__c(
            Name = '2024-2025',
            Is_Active_Academic__c = false
        );
        insert activeAcademicYear;
        
       
        // Insert hostel fee structure records
        List<Hostel_Fee_Structure__c> hostelSettings = new List<Hostel_Fee_Structure__c>{
            new Hostel_Fee_Structure__c(
                Name = 'TestRoom1',
                REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                Hostel_Room_Fees__c = 50000,
                Occupancy__c = '4',
                Gender__c = 'Boys',
                 Plan_Type__c ='One Semester'
            ),
                new Hostel_Fee_Structure__c(
                    Name = 'TestRoom2',
                    REVA_Hostel_Academic_Year__c = activeAcademicYear.Id,
                    Hostel_Room_Fees__c = 75000,
                    Occupancy__c = '3',
                    Gender__c = 'Boys',
                     Plan_Type__c ='One Semester'
                )
                };
                    insert hostelSettings;
        
         activeAcademicYear.Is_Active_Academic__c = true;
         update activeAcademicYear;
        
         List<RevahostelFelxibleRequestController.RoomPriceResponse> result = RevahostelFelxibleRequestController.getAllRoomPrices();

        Test.stopTest();
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
        List<Reva_Hostel_Room__c> result = RevahostelFelxibleRequestController.hostelRoomsAvailability(
            '4',
            'Student',
            testContact,
            false
        );
        List<Reva_Hostel_Room__c> result1 = RevahostelFelxibleRequestController.hostelRoomsAvailability(
            '4',
            'Non-Staff',
            testContact,
            false
        );
        List<Reva_Hostel_Room__c> result2 = RevahostelFelxibleRequestController.hostelRoomsAvailability(
            '4',
            'Student',
            testContact2,
            false
        );
        
        List<Reva_Hostel_Room__c> result3 = RevahostelFelxibleRequestController.hostelRoomsAvailability(
            '2',
            'Student',
            testContact2,
            true
        );
        
        
        // Debugging
        System.debug('Result size: ' + result.size());
        if (!result.isEmpty()) {
            System.debug('First room ID: ' + result[0].Id);
        }
        
        // Validate results
//  System.assertNotEquals(null, result, 'Result should not be null');
        
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
        List<Reva_Hostel_Room__c> rooms = RevahostelFelxibleRequestController.hostelRoomsAvailability('1', 'Student', testContact, false);
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
        List<Reva_Hostel_Room__c> rooms = RevahostelFelxibleRequestController.hostelRoomsAvailability('1', 'Non-Staff', testContact, false);
        Test.stopTest();
        
        System.debug('Room should be found for Non-Staff');
    }
    
    @isTest
    static void testRoomTypeStudentFemaleWithCourseDetails() {
        
        Account testAccount = new Account(
            Name = 'B. Tech in Computer Science and Engineering',
            Program_Code__c='EF'
        );
        insert testAccount;
        // Setup test data
        hed__Term__c activeSemester = new hed__Term__c(Name = 'Sem-1' , hed__Account__c= testAccount.id);
        insert activeSemester;
        
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'teststudent@example.com',
            hed__Gender__c = 'Female',
            Primary_Academic_Program__c = testAccount.Id , // Link to the Account
            Active_Semester__c = activeSemester.id
        );
        insert testContact;
        
        REVA_Course_Type__c courseType = new REVA_Course_Type__c(Name='Test1', Engineering__c = true, CS__c = true);
        insert courseType;
        String mobile = '9999999999';
        Test.startTest();
        List<Reva_Hostel_Room__c> rooms = RevahostelFelxibleRequestController.hostelRoomsAvailability('1', 'Student', testContact, false);
          Boolean result9 = RevahostelFelxibleRequestController.isPUCtestigdStudent(mobile);
          Boolean result10 = RevahostelFelxibleRequestController.isPUCtestidStudent(mobile);
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
        List<Reva_Hostel_Room__c> rooms = RevahostelFelxibleRequestController.hostelRoomsAvailability('1', 'Student', testContact, false);
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
        List<Reva_Hostel_Room__c> rooms = RevahostelFelxibleRequestController.hostelRoomsAvailability('1', 'InvalidType', testContact, false);
        RevahostelFelxibleRequestController.getSharingOptions();
        Test.stopTest();
        
        System.debug('No room should be found for invalid room type');
    }
}