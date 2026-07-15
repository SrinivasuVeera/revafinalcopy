@isTest
public class RevaRoomRequestTriggerHandlerTest {
    
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }

   /* @testSetup
    static void setup() {
        
        // Create a profile for community user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        
        // Create record type for Contact
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
        
            Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243',
            Email = 'testyop@gmail.com'
        
        );
        
        insert father;
        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286',
             Email = 'testyop@gmail.com'
        
        );
        
        insert Mother;
        
        // Create a contact with Professor record type
        Contact professorContact = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Email = 'john.doe@example.com',
            MobilePhone = '1234567890',
            RecordTypeId = professorRecordType.Id,
            Father__C =father.Id,
            Mother__C = Mother.Id
        );
        insert professorContact;
        
        // Generate a unique username
        String uniqueUsername = 'john.doe+' + DateTime.now().getTime() + '@example.com';
        
        // Create a community user linked to the contact
        User testUser = new User(
            ProfileId = p.Id,
            Username = uniqueUsername,
            Email = 'john.doe@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'jdoe',
            LastName = 'Doe',
            ContactId = professorContact.Id,
            CommunityNickname = 'jdoe',
            UserRoleId = null // Set this to an appropriate role ID if necessary
        );
        insert testUser;
        
         Reva_Hostel_Room__c room1 = new Reva_Hostel_Room__c(
            Name = '101',
            Block__c = 'A',
              Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS'
        );
        insert room1;
        
        Reva_Hostel_Room__c Room = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert Room;
         Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = professorContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Type__c = '1'
        );
        insert initialRequest;
        
          // Create a contact
        Contact studentContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice.doe@example.com',
            MobilePhone = '0987654321'
        );
        insert studentContact;

        // Create a Student_Fee__c record
        Student_Fee__c studentFee = new Student_Fee__c(
            Contact__c = studentContact.Id,
            Fee_Type__c = 'Hostel Fee',
            Payment_Type__c = 'Partial Payment',
            Date_of_Joining_Hostel__c = Date.today().addDays(-10),
            Due_Date__c = Date.today().addDays(20)  // Example due date
        );
        insert studentFee;
    }*/
    
    @isTest
    static void testTeachingStaffRoomAllocation() {
        // Retrieve the test user and contact
        //List<User> testUserList = [SELECT Id, ContactId FROM User WHERE Username LIKE 'john.doe%' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        
        // Create record type for Contact
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
          RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
            Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243',
            Email = 'testyop@gmail.com'
        
        );
        
        insert father;
        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286',
             Email = 'testyop@gmail.com'
        
        );
        
        insert Mother;
        
        // Create a contact with Professor record type
        Contact professorContact = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Email = 'john.doe@example.com',
            MobilePhone = '1234567890',
            RecordTypeId = professorRecordType.Id,
            Father__C =father.Id,
            Mother__C = Mother.Id
        );
        insert professorContact;
          Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = professorContact.Id,
            RecordTypeId = professorRecordType.Id
        );
        insert fatherContact;
        // Generate a unique username
        String uniqueUsername = 'john.doe+' + DateTime.now().getTime() + '@example.com';
        
        // Create a community user linked to the contact
        User testUser = new User(
            ProfileId = p.Id,
            Username = 'john.doehstl001room12@example.com',
            Email = 'john.doe@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'jdoe',
            LastName = 'Doe',
            ContactId = professorContact.Id,
            CommunityNickname = 'jdoe',
            UserRoleId = null // Set this to an appropriate role ID if necessary
        );
        insert testUser;
        List<User> testUserList = [SELECT Id, ContactId FROM User WHERE Username LIKE 'john.doe%' LIMIT 1];
        if (testUserList.isEmpty()) {
            System.assert(false, 'Test User not found');
        }
        User testUser1 = testUserList[0];
        
        List<Contact> professorContactList = [SELECT Id FROM Contact WHERE Id = :testUser1.ContactId LIMIT 1];
        if (professorContactList.isEmpty()) {
            System.assert(false, 'Professor Contact not found');
        }
        Contact professorContact1 = professorContactList[0];

        // Create a hostel request for the contact
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = professorContact1.Id,
            Status__c = 'Room Allotted',
            Type__c = '1',
            Reva_Hostel_Premium_Room__c = false
        );
        insert hostelRequest;
        
        List<Reva_Hostel_Request__c> hostelRequests = [SELECT Id, Hostel_Room_Request_For__c, Status__c, Type__c, Reva_Hostel_Premium_Room__c, Reva_Hostel_Room__c FROM Reva_Hostel_Request__c WHERE Hostel_Room_Request_For__c = :professorContact.Id];
        System.assert(!hostelRequests.isEmpty(), 'Hostel request not created');
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
       
        try {
            RevaRoomRequestTriggerHandler.TeachingStaffRoomAllocation(hostelRequests);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        Test.stopTest();
        
        // Refresh the hostel request record
        hostelRequest = [SELECT Id, Reva_Hostel_Room__c FROM Reva_Hostel_Request__c WHERE Id = :hostelRequest.Id];
        
    }

    @isTest
    static void testFirstYearStudentRoomAllocation() {
         Account acc = new Account(Name='TestAcc');
        insert acc;
          RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
       system.debug('test semester>>' +ProgramBatch.hed__Account__c);
        
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '1';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        semester.hed__Start_Date__c = Date.today().addDays(-30);
        semester.hed__End_Date__c = Date.today().addDays(30);        
        insert semester;
        
        Contact firstYearStudent = new Contact(
            LastName = 'Smith',
            FirstName = 'Alice',
            Email = 'alice.smith@example.com',
            MobilePhone = '0987654321',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1].Id,
            Active_Semester__c =semester.Id
        );
        insert firstYearStudent;
        
         Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = firstYearStudent.Id,
            RecordTypeId = parentRecordType.Id 
        );
        insert fatherContact;
        
        // Create a hostel request for the student
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = firstYearStudent.Id,
            Status__c = 'Booked',
            Type__c = '1',
            Reva_Hostel_Premium_Room__c = false,
            Reva_Hostel_JoiningDate__c = Date.today()
        );
        insert hostelRequest;
        
        // Create old map for the trigger method
        Map<Id, Reva_Hostel_Request__c> oldHostelRequests = new Map<Id, Reva_Hostel_Request__c>([SELECT Id, Reva_Hostel_JoiningDate__c FROM Reva_Hostel_Request__c WHERE Id = :hostelRequest.Id]);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
       
        RevaRoomRequestTriggerHandler.FirstYearStudentRoomAllocation(
            new Map<Id, Reva_Hostel_Request__c>{ hostelRequest.Id => hostelRequest },
            oldHostelRequests
        );
        
        Test.stopTest();
        
   }
    
    
     @isTest
    static void testCreateStudentHostelAttachment() {
        // Create multiple hostel requests with different Vacating_Request__c and Status__c values
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse()); 
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
          RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
                RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        
         Contact studentContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice.doe@example.com',
            MobilePhone = '987654321',
            RecordTypeId = studentRecordType.Id
        );
        insert studentContact;
        
          Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = studentContact.Id,
            RecordTypeId = parentRecordType.Id
        );
        insert fatherContact;
        
        User testUser = new User(
            ProfileId = p.Id,
            Username = 'testuser45628room001@gmail.com',
            Email = 'john.doe@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'jdoe',
            LastName = 'Doe',
            ContactId = studentContact.Id,
            CommunityNickname = 'jdoe',
            UserRoleId = null // Set this to an appropriate role ID if necessary
        );
        insert testUser;
        
       
        List<Reva_Hostel_Request__c> requests = new List<Reva_Hostel_Request__c>();

        Reva_Hostel_Request__c request1 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Status__c = 'Vacating Initiated',
            Vacating_Request__c = 'Request to warden',
            Type__c ='1'
        );
        requests.add(request1);
        
        Reva_Hostel_Request__c request2 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Status__c = 'Pending',
            Vacating_Request__c = 'Request to Admin',
            Type__c ='1'
        );
        requests.add(request2);

        Reva_Hostel_Request__c request3 = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Status__c = 'Vacating Initiated',
            Vacating_Request__c = 'Approved',
            Type__c ='1'
        );
        requests.add(request3);

        insert requests;

        Test.startTest();
        
        try {
    
            RevaRoomRequestTriggerHandler.createStudentHostelAttachment(requests);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        Test.stopTest();
        
       }
 @isTest
    static void testSendNOCToWardenUser() {
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
          RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
            Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243',
            Email = 'testyop@gmail.com'
        
        );
        
        insert father;
        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286',
             Email = 'testyop@gmail.com'
        
        );
        
        insert Mother;
        // Retrieve the initial request to use as a reference
        Contact professorContact = new Contact(
            LastName = 'Doe',
            FirstName = 'John',
            Email = 'john.doe@example.com',
            MobilePhone = '1234567890',
            RecordTypeId = professorRecordType.Id,
            Father__C =father.Id,
            Mother__C = Mother.Id
        );
        insert professorContact;
        
          Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = professorContact.Id ,
            RecordTypeId = professorRecordType.Id
        );
        insert fatherContact;
        
        Reva_Hostel_Room__c room = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert room;
         Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = professorContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Type__c = '1'
        );
        insert initialRequest;
       // Reva_Hostel_Request__c initialRequest = [SELECT Id, Status__c,Hostel_Room_Request_For__c, Reva_Hostel_Room__c FROM Reva_Hostel_Request__c WHERE Status__c = 'Room Allotted' LIMIT 1];

        // Simulate the insertion of a new request with status "Vacated"
        Reva_Hostel_Request__c newRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = initialRequest.Hostel_Room_Request_For__c,
            Reva_Hostel_Room__c = initialRequest.Reva_Hostel_Room__c,
            Status__c = 'Vacated',
            Type__c = '1'
        );

        Map<Id, Reva_Hostel_Request__c> oldMap = new Map<Id, Reva_Hostel_Request__c>();
Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        insert newRequest;
        try {
            List<Reva_Hostel_Request__c> updatedRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Id = :newRequest.Id];
            RevaRoomRequestTriggerHandler.sendNOCToWardenUser(updatedRequests, oldMap);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();

        // Additional assertions or checks can be added here
    }

    @isTest
    static void testSendRoomAllotmentNotificationOnChange() {
        
         RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
        Contact studentContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice.doe@example.com',
            MobilePhone = '0987654321',
            RecordTypeId = studentRecordType.Id
        );
        insert studentContact;
      
          Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = studentContact.Id,
            RecordTypeId = parentRecordType.Id  
        );
        insert fatherContact;
        //Contact studentContact = [SELECT Id, MobilePhone FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        Reva_Hostel_Room__c room = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert room;
        //Reva_Hostel_Room__c room = [SELECT Id, Name, Block__c FROM Reva_Hostel_Room__c WHERE Name = '102' LIMIT 1];
      
        // Insert a Reva_Hostel_Request__c record with a status different from "Room Allotted"
        Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Alloted',  // Status other than "Room Allotted"
            Type__c = '1'
        );
        insert initialRequest;

        // Insert a new Reva_Hostel_Request__c record with status "Room Allotted"
        Reva_Hostel_Request__c allotmentRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Type__c = '1'
        );

        // Create old map to simulate old state
        Map<Id, Reva_Hostel_Request__c> oldMap = new Map<Id, Reva_Hostel_Request__c>();
        oldMap.put(initialRequest.Id, initialRequest);
Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        insert allotmentRequest;
        try {
            List<Reva_Hostel_Request__c> updatedRequests = [SELECT Id, Status__c FROM Reva_Hostel_Request__c WHERE Id IN :new Id[]{allotmentRequest.Id}];
            RevaRoomRequestTriggerHandler.SendRoomAllotmentNotificationOnChange(updatedRequests, oldMap);
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();

        // Additional assertions or checks can be added here
    }
   @isTest
    static void testUpdateJoiningDateInStudentFee() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
         RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
       
        Contact studentContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice.doe@example.com',
            MobilePhone = '0987654321',
            RecordTypeId = studentRecordType.Id
        );
        insert studentContact;

         Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = studentContact.Id,
            RecordTypeId = parentRecordType.Id
        );
        insert fatherContact;
        // Retrieve the created test data
       // Contact studentContact = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];
       Reva_Hostel_Room__c room = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert room;
       // Reva_Hostel_Room__c room = [SELECT Id FROM Reva_Hostel_Room__c WHERE Name = '102' LIMIT 1];

        // Insert initial Reva_Hostel_Request__c record with an old joining date
        Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Reva_Hostel_JoiningDate__c = Date.today().addDays(-10),
            Type__c = '1'
        );
        insert initialRequest;

        // Insert new Reva_Hostel_Request__c record with a new joining date
        Reva_Hostel_Request__c newRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = studentContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Reva_Hostel_JoiningDate__c = Date.today().addDays(-5),
            Type__c = '1'
        );
        insert newRequest;

        // Create a map to simulate the old state
        Map<Id, Reva_Hostel_Request__c> oldMap = new Map<Id, Reva_Hostel_Request__c>();
        oldMap.put(initialRequest.Id, initialRequest);
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Call the method to update student fee records
        Test.startTest();
         try {
        RevaRoomRequestTriggerHandler.updateJoiningDateInStudentFee(new List<Reva_Hostel_Request__c>{newRequest}, oldMap);
                     } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        Test.stopTest();

       }
 @isTest
static void testHostelRoomRequestUpdate() {
    // Insert test data
    RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
    RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
    Account acc = new Account(Name = 'TestAcc');
    insert acc;

    hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c(
        Name = 'TestProgramBatch',
        hed__Account__c = acc.Id
    );
    insert ProgramBatch;

    hed__Term__c semester = new hed__Term__c(
        Name = '3',
        Program_Batch__c = ProgramBatch.Id,
        hed__Account__c = acc.Id,
        hed__Start_Date__c = Date.today().addDays(-30),
        hed__End_Date__c = Date.today().addDays(30)
    );
    insert semester;

    Contact studentContact = new Contact(
        LastName = 'Doe',
        FirstName = 'Jane',
        Email = 'jane.doe@example.com',
        MobilePhone = '9876543210',
        RecordTypeId = studentRecordType.Id,
        Active_Semester__c = semester.Id
    );
    insert studentContact;

      Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = studentContact.Id,
            RecordTypeId = parentRecordType.Id 
        );
        insert fatherContact;
    
    Reva_Hostel_Room__c room1 = new Reva_Hostel_Room__c(
        Name = '101',
        Block__c = 'A',
        Floor__c = 'SF',
        Maximum_Occupancy__c = '4',
        Room_Type__c = 'Student',
        Dormitory_Type__c = 'Boys',
        Room_Category__c = 'Eng CS'
    );
    insert room1;

    // Create a hostel request with status 'Booked' and necessary fields
    Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
        Hostel_Room_Request_For__c = studentContact.Id,
        Status__c = 'Booked',
        Reva_Hostel_Room__c = room1.Id,
        Reva_Hostel_JoiningDate__c = Date.today(),
        Reva_Hostel_Premium_Room__c = false,
        Type__c = '1'
    );
    insert hostelRequest;

    // Ensure the formula fields and other necessary fields are accessible by querying after insert
    hostelRequest = [SELECT Status__c, Room_Request_Type__c, Reva_Hostel_Room__c, Reva_Hostel_JoiningDate__c, Type__c, Reva_Hostel_Premium_Room__c, 
                     Hostel_Room_Request_For__r.RH_Current_Pursuing_Year_of_Student__c 
                     FROM Reva_Hostel_Request__c 
                     WHERE Id = :hostelRequest.Id];
    Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
    Test.startTest();
    try{
    RevaRoomRequestTriggerHandler.HostelRoomRequestUpdate(new List<Reva_Hostel_Request__c>{ hostelRequest });
    }catch(exception e){
        
    }
    Test.stopTest();

    // Add assertions to verify the expected outcomes
}

@isTest
static void testSendEmailWhenRoomAllocated() {
    Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        
      RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];
    
    Contact father = new Contact(
        LastName = 'Father',
        MobilePhone = '7731030243',
            Email = 'testyop@gmail.com'
        
        );
        
        insert father;
        
         Contact Mother = new Contact(
        LastName = 'Mother',
        MobilePhone = '7731030286',
             Email = 'testyop@gmail.com'
        
        );
        
        insert Mother;
    
    Contact studentContact = new Contact(
        LastName = 'Doe',
        FirstName = 'John',
        Email = 'john.doe@example.com',
        MobilePhone = '1234567890',
        Father__c =father.Id,
        Mother__c =Mother.id,
            RecordTypeId = studentRecordType.Id
    );
    insert studentContact;

      Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = studentContact.Id,
            RecordTypeId = parentRecordType.Id 
        );
        insert fatherContact;
    // Create initial hostel room record
    Reva_Hostel_Room__c initialRoom = new Reva_Hostel_Room__c(
        Name = '101',
        Block__c = 'A',
        Floor__c = 'FF',
        Maximum_Occupancy__c = '4',
        Room_Type__c = 'Student',
        Dormitory_Type__c = 'Boys',
        Room_Category__c = 'Eng CS'
    );
    insert initialRoom;

    // Create new hostel room record
    Reva_Hostel_Room__c newRoom = new Reva_Hostel_Room__c(
        Name = '102',
        Block__c = 'A',
        Floor__c = 'SF',
        Maximum_Occupancy__c = '4',
        Room_Type__c = 'Student',
        Dormitory_Type__c = 'Boys',
        Room_Category__c = 'Eng CS'
    );
    insert newRoom;

    // Create an initial hostel request
    Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
        Hostel_Room_Request_For__c = studentContact.Id,
       // Reva_Hostel_Room__c = initialRoom.Id,
        Status__c = 'Booked',
        Type__c = '1'
    );
    insert initialRequest;

    // Simulate the change in room assignment by creating a copy with a new room
    Reva_Hostel_Request__c newRequest = new Reva_Hostel_Request__c(
        Id = initialRequest.Id, // Keep the same Id to simulate an update
        Hostel_Room_Request_For__c = studentContact.Id,
        Reva_Hostel_Room__c = newRoom.Id, // Change to a different room
        Status__c = 'Room Allotted',
        Type__c = '1'
    );
	
    // Create a map to simulate the old state
    Map<Id, Reva_Hostel_Request__c> oldMap = new Map<Id, Reva_Hostel_Request__c>();
    oldMap.put(initialRequest.Id, initialRequest);

    // Create a list of updated requests
    List<Reva_Hostel_Request__c> updatedRequests = new List<Reva_Hostel_Request__c>{newRequest};

    Test.startTest();
    try {
        // Call the method with the updated records and the old state map
        RevaRoomRequestTriggerHandler.sendEmailWhenRoomAllocated(updatedRequests, oldMap);
        update updatedRequests;
    } catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
    }
    Test.stopTest();

}

 @isTest
    static void testSendStaffVacationRequestEmail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Setup test data
        // Create a Contact
        RecordType parentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Parent' LIMIT 1];
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1];

        
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'testuser25@example.com',
            RecordTypeId = studentRecordType.Id
        );
        insert testContact;

          Contact fatherContact = new Contact(
            LastName = 'Doe',
            FirstName = 'Alice',
            Email = 'alice1.doe@example.com',
            MobilePhone = '987654321',
            ReportsToId = testContact.Id,
            RecordTypeId = parentRecordType.Id
        );
        insert fatherContact;
        // Create a User with the name 'Warden1'
        User wardenUser = new User(
            FirstName = 'Warden',
            LastName = 'One',
            Email = 'warden1@example.com',
            Username = 'warden1_' + String.valueOf(Datetime.now().getTime()) + '@example.com',
            Alias = 'warden1',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            //Name = 'Warden1',
            IsActive = true
        );
        insert wardenUser;

        // Create a Reva_Hostel_Room__c record
        Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert testRoom;

        // Create a Reva_Hostel_Request__c record
        Reva_Hostel_Request__c testRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_Premium_Room__c = true,
            Reva_Hostel_Room__c = testRoom.Id,
            Status__c = 'Room Allotted',
            Type__c = '4'
        );
        insert testRequest;

        // Add the request Id to a set
        Set<Id> requestIds = new Set<Id>{testRequest.Id};

        // Test context
        Test.startTest();
        RevaRoomRequestTriggerHandler.sendStaffVacationRequestEmail(requestIds);
        Test.stopTest();

        // Verify that the email was sent
        Integer emailCount = Limits.getEmailInvocations();
        //System.assertEquals(1, emailCount, 'One email should have been sent');
    }
/**********************************************************************/
@isTest
    static void testGenerateStudentRoomAllotedMessage() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Define input parameters
        String studentName = 'John Doe';
        Decimal amountPaid = 1500.00;
        String roomNumber = '102';
        String block = 'A';

        // Expected message
        String expectedMessage = 'Dear John Doe,\n\n' +
            'We are delighted to inform you that your room booking has been confirmed for your upcoming stay. You have been assigned room number 102 in A.\n\n' +
            'Regards,\nHostel Office\nREVA University';

        // Call the method
        String resultMessage = RevaRoomRequestTriggerHandler.generateStudentRoomAllotedMessage(
            studentName,
            amountPaid,
            roomNumber,
            block
        );

        // Assert the result
        System.assertEquals(expectedMessage, resultMessage, 'The generated message does not match the expected message');
    }
/******************************************************************/
    
    

}