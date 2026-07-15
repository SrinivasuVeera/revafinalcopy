@isTest
private class RevaHostelRequestControllerTest {

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
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
    }
    
     @isTest
    static void testGetCurrentStudentContact() {
        User testUser = [SELECT Id FROM User WHERE Username = 'student@example.com' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> contactDetails = RevaHostelRequestController.getCurrentStudentContact();
            Test.stopTest();
        }
    }
    
       @isTest
    static void testGetCurrentNonTeachingContact() {
        User testUser = [SELECT Id FROM User WHERE Username = 'nonteaching@example.com' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
           // Map<String, Object> contactDetails = RevaHostelRequestController.getCurrentNonTeachingContact();
            Test.stopTest();
            
        }
    }
    
      @isTest
    static void testGetCurrentTeachingContact() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'professor@example.com' LIMIT 1];
        REVA_Hostel_Academic_Year__c requestrec=new REVA_Hostel_Academic_Year__c(
            Name = 'Test record',
            Is_Next_Year_Academic__c = true
        );
        insert requestrec;
        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to get the current teaching contact
            Test.startTest();
            Map<String, Object> contactDetails = RevaHostelRequestController.getCurrentTeachingContact();
            RevaHostelRequestController.getAdvancedRegistration();
             RevaHostelRequestController.UpdateChecked();
             RevaHostelRequestController.UpdateUnchecked();
             RevaHostelRequestController.getHostelRoomChangeRequest();
            Test.stopTest();

        }
    }
    
       @isTest
    static void testCheckHostelRequestExists() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to check if hostel request exists
            Test.startTest();
            Boolean doesHostelRequestExist = RevaHostelRequestController.checkHostelRequestExists();
            Test.stopTest();

            // Assert the result is true, as the hostel request exists for the test contact
            //System.assertEquals(true, doesHostelRequestExist);
        }
    }

    @isTest
    static void testHostelDetailsCurrentlyLoggedInUser() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to get hostel details
            Test.startTest();
            Map<String, String> hostelDetails = RevaHostelRequestController.hostelDetailsCurrentlyLoggedInUser();
            Test.stopTest();

          
        }
    }
    
    
   @isTest
    static void testFetchHostelRequestDetails() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Mock the fetchContactId method to return the contactId of the test user
            Test.startTest();
            RevaHostelRequestController.fetchHostelRequestDetails();
            List<Reva_Hostel_Request__c> hostelRequests = RevaHostelRequestController.fetchHostelRequestDetails();
            Test.stopTest();

        }
    }
    
    
     @isTest
    static void testGetExistingHostelRequest() {
        // https://reva-university--couat1908.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to get existing hostel requests
            List<Reva_Hostel_Request__c> requests = RevaHostelRequestController.getExistingHostelRequest();
            Reva_Hostel_Request__c request = requests[0];

        }
    }
    
    
     @isTest
    static void testRejoingRequest() {
        // Retrieve the test user and hostel request
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];
        Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c Where Status__c ='Vacated'  LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to update the request
            RevaHostelRequestController.RejoingRequest(hostelRequest.Id);
           

            // Retrieve the updated hostel request record
            Reva_Hostel_Request__c updatedHostelRequest = [SELECT Id, Status__c, Rejoiner__c 
                                                           FROM Reva_Hostel_Request__c 
                                                           WHERE Id = :hostelRequest.Id];

            // Assert the status and rejoiner fields are updated
            System.assertEquals('Rejoin', updatedHostelRequest.Status__c);
            System.assertEquals(true, updatedHostelRequest.Rejoiner__c);
        }
    }
    
  
    @isTest
    static void testGetExistingRoomAllotedHostelRequest() {
        // Retrieve the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to get existing room allotted hostel request
            Reva_Hostel_Request__c hostelRequest = RevaHostelRequestController.getExistingRoomAllotedHostelRequest();
        }
    }
    
    /********************************************************************************************/
    /* @isTest
    static void testUpdateVacationDate() {
        // Retrieve the test user and hostel request
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com' LIMIT 1];
        Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c  Where Status__c ='Vacated' LIMIT 1];

        // Define new vacation date
        Date newVacationDate = Date.today().addDays(10);
        String cancellationReason ='Not Interested';

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to update the vacation date
            RevaHostelRequestController.updateVacationDate(hostelRequest.Id, newVacationDate,cancellationReason);

            // Retrieve the updated hostel request record
            Reva_Hostel_Request__c updatedHostelRequest = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
                                                           FROM Reva_Hostel_Request__c 
                                                           WHERE Id = :hostelRequest.Id];

            // Assert the vacation date and status are updated
            System.assertEquals(newVacationDate, updatedHostelRequest.RevaHostelVacatingDate__c);
            System.assertEquals('Vacated', updatedHostelRequest.Status__c);
        }
    }*/
    @isTest
static void testUpdateVacationDate() {
    // Create and insert a test user
    Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
    // Create a contact and associate it with the user
    Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
    insert testContact;
    User testUser = new User(
        //Username = 'testuser52@example.com',
        ProfileId = studentProfile.Id,
        Email = 'testuser@example.com',
        LastName = 'Test',
        Alias = 'ttest',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        UserName = 'testuser5214@example.com',
        ContactId=testContact.id
    );
    insert testUser;
    
    
    
    // Create a new hostel request
    Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
        Hostel_Room_Request_For__c = testContact.Id,
        Type__c= '4',
        Status__c = 'Vacating Initiated'
    );
    insert hostelRequest;

    // Define new vacation date and reason
    Date newVacationDate = Date.today().addDays(10);
    String cancellationReason = 'Not Interested';

    // Run the method in the context of the test user
    Test.startTest();
    System.runAs(testUser) {
        RevaHostelRequestController.updateVacationDate(
            hostelRequest.Id, newVacationDate, cancellationReason
        );
    }
    Test.stopTest();

    // Verify the updates
    Reva_Hostel_Request__c updatedHostelRequest = [
        SELECT RevaHostelVacatingDate__c, Status__c 
        FROM Reva_Hostel_Request__c 
        WHERE Id = :hostelRequest.Id
    ];

    System.assertEquals(newVacationDate, updatedHostelRequest.RevaHostelVacatingDate__c);
    System.assertEquals('Vacating Initiated', updatedHostelRequest.Status__c);
}

/*******************************************************************************************************************/    
      @isTest
    static void testUpdateStudentVacationDate() {
        // Retrieve the test user and hostel request
        User testUser = [SELECT Id,ContactId FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];
        Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c Where Status__c ='Vacated'  LIMIT 1];

        // Define new vacation date
        Date newVacationDate = Date.today().addDays(10);

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to update the vacation date
            RevaHostelRequestController.updateStudentVacationDate(hostelRequest.Id, newVacationDate);

            // Retrieve the updated hostel request record
            Reva_Hostel_Request__c updatedHostelRequest = [SELECT Id, RevaHostelVacatingDate__c, Status__c 
                                                           FROM Reva_Hostel_Request__c 
                                                           WHERE Id = :hostelRequest.Id];

            // Assert the vacation date and status are updated
            System.assertEquals(newVacationDate, updatedHostelRequest.RevaHostelVacatingDate__c);
            System.assertEquals('Vacation Initiated', updatedHostelRequest.Status__c);
        }
    }
   @isTest
    static void testUpdateStudentHostelRequest() {
        // Retrieve the test user and hostel request
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];
        Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c WHERE Status__C = 'Vacated' LIMIT 1];

        // Set the current user to the test user
        System.runAs(testUser) {
            // Call the method to update the hostel request
            Date programEndDate = Date.today().addDays(10);
            RevaHostelRequestController.updateStudentHostelRequest(hostelRequest.Id, programEndDate);

            // Verify the updated hostel request
            Reva_Hostel_Request__c updatedRequest = [SELECT Id, Status__c, RevaHostelVacatingDate__c FROM Reva_Hostel_Request__c WHERE Id = :hostelRequest.Id];
            System.assertEquals('Vacation Initiated', updatedRequest.Status__c);
            System.assertEquals(programEndDate, updatedRequest.RevaHostelVacatingDate__c);
        }
    }

   
    
    @isTest
    static void testFetchProgramEndDate() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        System.runAs(testUser) {
            // Call the method and assert the end date
            Date programEndDate = RevaHostelRequestController.fetchProgramEndDate();
          //  System.assertEquals(Date.newInstance(2025, 12, 31), programEndDate);
        }
    }
    
    @isTest
    static void testGetLoggedInUserProfile() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        System.runAs(testUser) {
            // Call the method and assert the profile name
            String profileName = RevaHostelRequestController.getLoggedInUserProfile();
          //  System.assertEquals('Student Portal Profile', profileName);
        }
    }

    @isTest
    static void testProvisionalFeePaid() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuserhstl001@example.com' LIMIT 1];

        System.runAs(testUser) {
            // Call the method and assert the application record
            hed__Application__c application = RevaHostelRequestController.ProvisionalFeePaid();
            System.assertNotEquals(null, application);
            System.assertEquals(false, application.Provisional_Admission_Fee_Paid__c);
        }
    }
    
    /**************************************************/
    
    @isTest
    static void testHasExistingHostelRequest() {
        // Create a contact and associate it with the test user
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com'
        );
        insert testContact;
        // Create a test profile and user for Non-Teaching Profile
        Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
        User testUser = new User(
            Username = 'testuser951@example.com',
            ProfileId = nonTeachingProfile.Id,
            Email = 'testuser951@example.com',
            LastName = 'Test',
            Alias = 'ntest',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId=testContact.Id
        );
        insert testUser;
	

        // Create a hostel request for the contact
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Type__c ='4',
            Status__c = 'Booked'
        );
        insert hostelRequest;

        // Start the test context and run the method as the test user
        Test.startTest();
        System.runAs(testUser) {
            Boolean hasRequest = RevaHostelRequestController.hasExistingHostelRequest();
            System.assertEquals(true, hasRequest, 'User should have an existing hostel request');
        }
        Test.stopTest();

    }
    /*****************************************************/
    
    
    @isTest
static void testupdateHostelRequest() {
    // Create and insert a test user
    Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];
    // Create a contact and associate it with the user
    Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', hed__Gender__c='Male',Email = 'testuser@example.com');
    insert testContact;
    User testUser = new User(
        //Username = 'testuser52@example.com',
        ProfileId = studentProfile.Id,
        Email = 'testuser@example.com',
        LastName = 'Test',
        Alias = 'ttest',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        UserName = 'testuser5214@example.com',
        ContactId=testContact.id
    );
    insert testUser;
    
    Reva_Hostel_Room__c HostelRoom = new Reva_Hostel_Room__c(
            Name = '100',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Floor__c = 'SF', 
            Room_Type__c = 'Staff',
        Room_Category__c='None - Demo/Staff',
            Maximum_Occupancy__c = '4'
            
        );
        Insert HostelRoom;
    
    
    // Create a new hostel request
    Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
        Hostel_Room_Request_For__c = testContact.Id,
        Type__c= '4',
        Status__c = 'Rejected'
    );
    insert hostelRequest;
    Test.startTest();
        System.runAs(testUser) {
            RevaHostelRequestController.updateHostelRequest(hostelRequest.id,'4',System.Today(), false);
            //System.assertEquals(true, hasRequest, 'User should have an existing hostel request');
        }
        Test.stopTest();
    
}

    /**************************createStudentHostelAttachment********************************/
	/*  public class MockPageReference implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/pdf');
            res.setBodyAsBlob(Blob.valueOf('Test PDF Content'));
            res.setStatusCode(200);
            return res;
        }
    }

    
   

    @isTest
    static void testCreateStudentHostelAttachment() {
        // Step 1: Set up mock callout
        Test.setMock(HttpCalloutMock.class, new MockPageReference());

        // Step 2: Create a Student Contact
        Contact studentContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'student@example.com'
        );
        insert studentContact;

        // Step 3: Create a Student User linked with the contact
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User studentUser = new User(
            Username = 'studentuser@example.com',
            ProfileId = studentProfile.Id,
            Email = studentContact.Email,
            ContactId = studentContact.Id,
            LastName = 'Student',
            Alias = 'stud',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert studentUser;

        // Step 4: Create a Warden User (Recipient)
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        User wardenUser = new User(
            Username = 'wardenuser@example.com',
            ProfileId = wardenProfile.Id,
            Email = 'warden@example.com',
            LastName = 'Warden',
            Alias = 'warden',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert wardenUser;

        // Step 5: Create a Hostel Request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Type__c = '4'
        );
        insert hostelRequest;

        // Step 6: Start the test execution
        Test.startTest();
        System.runAs(studentUser) {
            RevaHostelRequestController.createStudentHostelAttachment(hostelRequest.Id);
        }
        Test.stopTest();

        // Step 7: Verify the attachment creation
        List<Attachment> attachments = [
            SELECT Id, Name, ParentId 
            FROM Attachment 
            WHERE ParentId = :hostelRequest.Id
        ];
         System.assertEquals(1, attachments.size(), 'One attachment should have been created.');
         System.assertEquals('HostelVacationNOC.pdf', attachments[0].Name, 'Attachment name should be HostelVacationNOC.pdf.');

        // Optional: Verify if an email was sent (if applicable for your org)
        // List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage WHERE ...];
        // System.assertEquals(1, sentEmails.size(), 'One email should have been sent.');
    }*/

    /*****************************************************************************************/
}