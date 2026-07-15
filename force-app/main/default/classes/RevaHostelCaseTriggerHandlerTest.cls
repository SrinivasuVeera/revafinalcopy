@isTest
public class RevaHostelCaseTriggerHandlerTest {
       private class MockHttpResponseGeneratorForRevaHostel implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private static User createUser(Contact con, String alias, String email, String username, String profileName) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        if (profile == null) {
            System.assert(false, 'Profile not found: ' + profileName);
        }
        User testUser = new User(
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            ContactId = con.Id,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = username
        );
        insert testUser;
        return testUser;
    }
    
    private static Contact createContact(String lastName, String email, String mobilePhone) {
        Contact con = new Contact(
            LastName = lastName,
            Email = email,
            MobilePhone = mobilePhone
        );
        insert con;
        return con;
    }
    
    private static Id getRecordTypeId(String sObjectType, String recordTypeName) {
        Map<String, Schema.SObjectType> sObjectTypes = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectTypeRef = sObjectTypes.get(sObjectType);
        if (sObjectTypeRef == null) {
            System.assert(false, 'SObject type not found: ' + sObjectType);
        }
        Map<String, Schema.RecordTypeInfo> recordTypes = sObjectTypeRef.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo recordTypeInfo = recordTypes.get(recordTypeName);
        if (recordTypeInfo == null) {
            System.assert(false, 'Record type not found: ' + recordTypeName);
        }
        return recordTypeInfo.getRecordTypeId();
    }
    
    
     @isTest
    static void testUpdateStudentContact() {
        // Create test data
        Contact con = createContact('Vamshi Gupta', 'testclass@yopmail.com', '1234567890');
        User testUser = createUser(con, 'testU', 'testclass@yopmail.com', 'testuser@example.com', 'Student Profile');

        Case newCase = new Case(
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'description',
            ContactId = con.Id,
            OwnerId = testUser.Id,
            RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
            Student_Contact_For_Updates__c = con.Id
        );
        insert newCase;

        // Start of test execution
        Test.startTest();

        // Set mock for HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());

        // Call the method that performs the callout
        RevaHostelCaseTriggerHandler.updateStudentContact(new List<Case>{newCase});

        // End of test execution
        Test.stopTest();

        // Assert the expected results if needed
        Case updatedCase = [SELECT Id, Student_Contact_For_Updates__c, Student_UserId__c, Contact_Mobile_Number__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(newCase.ContactId, updatedCase.Student_Contact_For_Updates__c);
        System.assertEquals(newCase.OwnerId, updatedCase.Student_UserId__c);
        System.assertEquals(con.MobilePhone, updatedCase.Contact_Mobile_Number__c);
    }
    
    @isTest
    static void testNotifyStudentOnCaseCreation() {
        Contact con = createContact('Vamshi Gupta', 'testclass2@yopmail.com', '1234567890');
        User testUser = createUser(con, 'testU2', 'testclass2@yopmail.com', 'testuser2@example.com', 'Student Profile');
        
        Case newCase = new Case(
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'description',
            ContactId = con.Id,
            OwnerId = testUser.Id,
            RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
            Student_Contact_For_Updates__c = con.Id
        );
        insert newCase;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());
        RevaHostelCaseTriggerHandler.notifyStudentOnCaseCreation(new List<Case>{newCase});
        Test.stopTest();
        
        // No direct assertions as the method sends an SMS, but we can check debug logs if needed
    }
    
    @isTest
    static void testHandleOwnerChangeContact() {
        Contact con = createContact('Vamshi Gupta', 'testclass3@yopmail.com', '1234567890');
        User testUser = createUser(con, 'testU3', 'testclass3@yopmail.com', 'testuser3@example.com', 'Student Profile');
        
        Case newCase = new Case(
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'description',
            ContactId = con.Id,
            OwnerId = testUser.Id,
            RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
            Student_Contact_For_Updates__c = con.Id
        );
        insert newCase;
        
        Contact nonTeachingContact = createContact('John Doe', 'nonteaching@yopmail.com', '0987654321');
        User newOwner = createUser(nonTeachingContact, 'newOwn', 'newowner@yopmail.com', 'newowner@example.com', 'Non Teaching Profile');
        
        // Clone the case and set the ID
        Case updatedCase = new Case(
            Id = newCase.Id,
            OwnerId = newOwner.Id
        );
        
        Test.startTest();
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());
        update updatedCase;
        RevaHostelCaseTriggerHandler.handleOwnerChangeContact(new List<Case>{updatedCase}, new Map<Id, Case>{newCase.Id => newCase});
        Test.stopTest();
        
        // No direct assertions as the method sends an SMS, but we can check debug logs if needed
    }

  @isTest
static void testNotifyStudentOnStatusChange() {
    // Create test data
    // Contact with mobile number
    Contact conWithMobile = createContact('Vamshi Gupta', 'testclass4@yopmail.com', '1234567890');
    // Contact without mobile number
    Contact conWithoutMobile = createContact('Ravi Kumar', 'testclass5@yopmail.com', null);
    User testUser = createUser(conWithMobile, 'testU4', 'testclass4@yopmail.com', 'testuser4@example.com', 'Student Profile');

    // Create a case with Contact Mobile Number set
    Case newCaseWithMobile = new Case(
        Priority = 'Medium',
        Hostel_Category__c = 'Maintenance',
        Hostel_Sub_Category__c = 'Electrical',
        Description = 'description',
        ContactId = conWithMobile.Id,
        OwnerId = testUser.Id,
        RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
        Status = 'New',
        Student_Contact_For_Updates__c = conWithMobile.Id
    );
    insert newCaseWithMobile;

    // Create a case without Contact Mobile Number
    Case newCaseWithoutMobile = new Case(
        Priority = 'Medium',
        Hostel_Category__c = 'Maintenance',
        Hostel_Sub_Category__c = 'Plumbing',
        Description = 'Another description',
        ContactId = conWithoutMobile.Id,
        OwnerId = testUser.Id,
        RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
        Status = 'New',
        Student_Contact_For_Updates__c = conWithoutMobile.Id
    );
    insert newCaseWithoutMobile;

    // Set mock HTTP response
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());

    // Update the cases to trigger the status change notification
    newCaseWithMobile.Status = 'In Progress';
    newCaseWithoutMobile.Status = 'In Progress';

    Test.startTest();
    update newCaseWithMobile;
    update newCaseWithoutMobile;
    RevaHostelCaseTriggerHandler.notifyStudentOnStatusChange(new List<Case>{newCaseWithMobile, newCaseWithoutMobile}, 
        new Map<Id, Case>{newCaseWithMobile.Id => newCaseWithMobile, newCaseWithoutMobile.Id => newCaseWithoutMobile});
    Test.stopTest();

  }
   
    
    @isTest
    static void testNotifyInchargeOnCaseCreation() {
        // Setup contacts and users
        Contact studentContact = createContact('Student One', 'student1@example.com', '1234567890');
        User studentUser = createUser(studentContact, 'stud1', 'student1@example.com', 'student1@example.com', 'Student Profile');
        
        Contact inchargeContact = createContact('Incharge One', 'incharge1@example.com', '0987654321');
        User inchargeUser = createUser(inchargeContact, 'inch1', 'incharge1@example.com', 'incharge1@example.com', 'Non Teaching Profile');
        
        // Create a case
        Case newCase = new Case(
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'description',
            ContactId = studentContact.Id,
            OwnerId = inchargeUser.Id,
            RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
            Student_Contact_For_Updates__c = studentContact.Id,
            Student_UserId__c = studentUser.Id
        );
        insert newCase;
        
        // Create a related Reva_Hostel_Request__c record
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '4',
            Hostel_Room_Request_For__c = studentContact.Id
        );
        insert hostelRequest;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());
        RevaHostelCaseTriggerHandler.notifyInchargeOnCaseCreation(new List<Case>{newCase});
        Test.stopTest();
        
        // No direct assertions as the method sends an SMS, but we can check debug logs if needed
    }
    
    @isTest
    static void testHandleOwnerChangeContactWithNotify() {
        Contact con = createContact('Vamshi Gupta', 'testclass5@yopmail.com', '1234567890');
        User testUser = createUser(con, 'testU5', 'testclass5@yopmail.com', 'testuser5@example.com', 'Student Profile');
        
        Case newCase = new Case(
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'description',
            ContactId = con.Id,
            OwnerId = testUser.Id,
            RecordTypeId = getRecordTypeId('Case', 'REVA Hostel Support Request'),
            Student_Contact_For_Updates__c = con.Id
        );
        insert newCase;
        
        Contact nonTeachingContact = createContact('John Doe', 'nonteaching2@yopmail.com', '0987654321');
        User newOwner = createUser(nonTeachingContact, 'newOwn2', 'newowner2@yopmail.com', 'newowner2@example.com', 'Non Teaching Profile');
        
        // Clone the case and set the ID
        Case updatedCase = new Case(
            Id = newCase.Id,
            OwnerId = newOwner.Id
        );
        
        Test.startTest();
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());
        update updatedCase;
        RevaHostelCaseTriggerHandler.handleOwnerChangeContact(new List<Case>{updatedCase}, new Map<Id, Case>{newCase.Id => newCase});
        Test.stopTest();
    }
    
    // Additional test for case without RecordTypeId set
    @isTest
    static void testCaseWithoutRecordType() {
        Contact con = createContact('Vamshi Gupta', 'testclass6@yopmail.com', '1234567890');
        User testUser = createUser(con, 'testU6', 'testclass6@yopmail.com', 'testuser6@example.com', 'Student Profile');
        
        Case newCase = new Case(
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Description = 'description',
            ContactId = con.Id,
            OwnerId = testUser.Id,
            Student_Contact_For_Updates__c = con.Id
        );
        insert newCase;
        
        Test.startTest();
        RevaHostelCaseTriggerHandler.updateStudentContact(new List<Case>{newCase});
        Test.stopTest();
        
        // Assert the expected results
        Case updatedCase = [SELECT Id, Student_Contact_For_Updates__c, Student_UserId__c, Contact_Mobile_Number__c FROM Case WHERE Id = :newCase.Id];
        System.assertEquals(newCase.ContactId, updatedCase.Student_Contact_For_Updates__c);
        System.assertEquals(newCase.OwnerId, updatedCase.Student_UserId__c);
        System.assertEquals(con.MobilePhone, updatedCase.Contact_Mobile_Number__c);
    }
    
@isTest
static void testShareCasesAfterOwnershipChange() {
    // Setup test data
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForRevaHostel());
    Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
    Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];

    Contact studentContact = new Contact(FirstName = 'Student', LastName = 'Contact', Email = 'studentuser@example.com');
    Contact nonTeachingContact = new Contact(FirstName = 'NonTeaching', LastName = 'Contact', Email = 'nonteachinguser@example.com');
    insert new List<Contact>{studentContact, nonTeachingContact};

    User studentUser = new User(
        ProfileId = studentProfile.Id,
        Username = 'studentuser@example.com',
        Email = 'studentuser@example.com',
        EmailEncodingKey = 'UTF-8',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles',
        Alias = 'stduser',
        LastName = 'Student',
        ContactId = studentContact.Id
    );
    insert studentUser;

    User nonTeachingUser = new User(
        ProfileId = nonTeachingProfile.Id,
        Username = 'nonteachinguser@example.com',
        Email = 'nonteachinguser@example.com',
        EmailEncodingKey = 'UTF-8',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles',
        Alias = 'nuser',
        LastName = 'NonTeaching',
        ContactId = nonTeachingContact.Id
    );
    insert nonTeachingUser;

    RecordType hostelSupportRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'REVA Hostel Support Request' LIMIT 1];
    
    Case case1 = new Case(
        RecordTypeId = hostelSupportRecordType.Id,
       // CreatedById = studentUser.Id,
        OwnerId = nonTeachingUser.Id,
        Subject = 'Test Case 1'
    );
    System.runAs(studentUser){
    insert case1;
    }
    Case case2 = new Case(
        RecordTypeId = hostelSupportRecordType.Id,
        //CreatedById = studentUser.Id,
        OwnerId = nonTeachingUser.Id,
        Subject = 'Test Case 2'
    );
    System.runAs(studentUser){
    insert case2;
    }
    

    case1.OwnerId = studentUser.Id;
    case2.OwnerId = studentUser.Id;
    
    // Ensure running user has access to update cases
    System.runAs(new User(Id = UserInfo.getUserId())) {
        // Updating Cases
        try {
            update new List<Case>{case1, case2};
        } catch (Exception e) {
            System.debug('Error while updating cases: ' + e.getMessage());
        }

        // Call the handler directly (if applicable)
        try {
            RevaHostelCaseTriggerHandler.shareCasesAfterOwnershipChange(new List<Case>{case1, case2}, new Map<Id, Case>{case1.Id => case1, case2.Id => case2});
        } catch (Exception e) {
            System.debug('Error in shareCasesAfterOwnershipChange: ' + e.getMessage());
        }
    
    }

    // Assert statements and validation
}


}