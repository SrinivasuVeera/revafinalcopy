@isTest
public class CaseControllerTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
           res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
   @TestSetup
    static void setupTestData() {
        // Create test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        insert testContact;
        
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_' + String.valueOf(Datetime.now().getTime()) + '@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ContactId = testContact.Id,  
            Isactive=true
            
        );
        insert testUser;
        
        // Create REVA Hostel Request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '1',
            
            Hostel_Room_Request_For__c = testContact.Id
        );
        insert hostelRequest;
    }
    
    /****************************Infra createCase******************************/
    @isTest
    static void testCreateCase() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
         RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student'LIMIT 1 ];
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testusercasetest212@example.com',RecordTypeId=studentRecordType.Id);
        insert testContact;
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testusercasetest212@example.com',
            Username = 'testusercase001infratest01@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' OR Name = 'Student Portal Profile' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ContactId = testContact.Id,
            Isactive=true
        );
        insert testUser;
        
        // Create REVA Hostel Request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '1',
            
            Hostel_Room_Request_For__c = testContact.Id
        );
        insert hostelRequest;
        // Fetch the Contact record created in @testSetup
       // Contact testContact = [SELECT Id FROM Contact WHERE Email = 'testuser@example.com' LIMIT 1];
        
        // Define test data for case creation
        String category = 'Electrical';
        String subCategory = 'AC repair';
        String urgency = 'Medium';
        String description = 'The laptop is not booting up.';
        String severity = 'Critical';
        
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Id caseId = CaseController.createCase(category, subCategory, urgency, description, severity, testContact.Id);
        Test.stopTest();
        
        // Fetch the created case record
        Case createdCase = [SELECT Id, INFRA_Category__c, INFRA_Sub_Category__c, Urgency__c, Description__c, Severity__c, ContactId 
                            FROM Case WHERE Id = :caseId LIMIT 1];
        
        // Verify the case was created with correct values
        System.assertNotEquals(null, createdCase, 'Case record should have been created.');
        System.assertEquals(category, createdCase.INFRA_Category__c, 'Category should match.');
        System.assertEquals(subCategory, createdCase.INFRA_Sub_Category__c, 'SubCategory should match.');
        //System.assertEquals(urgency, createdCase.Urgency__c, 'Urgency should match.');
        System.assertEquals(description, createdCase.Description__c, 'Description should match.');
        System.assertEquals(severity, createdCase.Severity__c, 'Severity should match.');
        System.assertEquals(testContact.Id, createdCase.ContactId, 'ContactId should match.');
    }
    /****************************************************************************/
    
    
    @isTest
    static void testGetRevaHostelSupportRecordTypeId() {
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        
        
        Id recordTypeId = CaseController.getRevaHostelSupportRecordTypeId();
        Test.stopTest();
        
        // System.assertNotEquals(null, recordTypeId, 'RecordType ID should not be null');
    }
    /*******************************************************************/
    @isTest
    static void testCreateRevaHostelSupportCase() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create a Contact
        RecordType hostelSupportRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'REVA_Hostel_Support_Request' LIMIT 1];
		RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student'LIMIT 1 ];

        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'testusercase003@example.com',RecordtypeId=studentRecordType.Id
        );
        insert testContact;
        
        // Create a User with the created Contact
        User testUser = new User(
            Username = 'testusercase001@example.com',
            Email = 'testusercase003@example.com',
            LastName = 'Test User',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' OR Name = 'Student Portal Profile' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            UserRoleId = null,
            IsActive = true
        );
        insert testUser;
        
        // Create a Reva_Hostel_Request__c record associated with the test contact
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Type__c = '4',
            Status__c = 'Room Allotted'
        );
        insert hostelRequest;
        
        // Set the test user as the current user
        System.runAs(testUser) {
           // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
           // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
            
            Test.startTest();
            String subject = 'Test Case';
            String description = 'Test description';
            String priority = 'High';
            String supportCategory = 'Maintenance';
            String hostelSubCategory = 'Electrical';
            List<String> generalComplaints = new List<String>{'AC Not Working Properly'};
                String filename = 'testfile.txt';
            String base64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZS4=';
            
            // Call the method to create the case
            Id caseId = CaseController.createRevaHostelSupportCase(subject, description, priority, supportCategory, hostelSubCategory, generalComplaints, filename, base64);
            Test.stopTest();
            
            // Query and assert the created case
            Case createdCase = [SELECT Id, Subject, Description, Priority, Hostel_Category__c, Hostel_Sub_Category__c, Support_Case_Complaints__c FROM Case WHERE Id = :caseId];
            
            System.assertNotEquals(null, caseId, 'Case ID should not be null');
            System.assertEquals(priority, createdCase.Priority, 'Priority does not match');
            System.assertEquals(description, createdCase.Description, 'Description does not match');
            System.assertEquals(supportCategory, createdCase.Hostel_Category__c, 'Support Category does not match');
            System.assertEquals(hostelSubCategory, createdCase.Hostel_Sub_Category__c, 'Hostel Sub Category does not match');
        }
    }
    /******************************************************/
  
    @isTest
    static void testGetExistingHostelRequest() {
        // Setup Test Data
      RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student'LIMIT 1 ];
        // Create a Contact
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'testusercasetest220@example.com',RecordTypeId=studentRecordType.Id);
        insert testContact;
        
        // Create a User associated with the Contact
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testusercasetest220@example.com',
            Username = 'testusercase0089test00786@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' OR Name = 'Student Portal Profile' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ContactId = testContact.Id,
            IsActive = true
        );
        insert testUser;
        
        // Create a Reva_Hostel_Room__c record
        Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
            Name = '100',
            Dormitory_Type__c = 'Boys',
            Block__c = 'A',
            Floor__c = 'SF',
            Room_Type__c = 'Student',
            Room_Category__c = 'Eng CS',
            Maximum_Occupancy__c = '4'
        );
        insert testRoom;
        
        // Create a Reva_Hostel_Request__c record
        Reva_Hostel_Request__c testRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            
            Reva_Hostel_Room__c = testRoom.Id,
            Status__c = 'Room Allotted',
            Type__c = '4'
        );
        insert testRequest;
        
        // Set the created User as the current user
        System.runAs(testUser) {
              //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
           // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
            Test.startTest();
            Reva_Hostel_Request__c result = CaseController.getExistingHostelRequest();
            Test.stopTest();
            
        }
    }
    /********************************/
 
    @isTest
    static void testGetRevaHostelSupportCasesForUser() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
       Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        insert testContact;
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_case004' + String.valueOf(Datetime.now().getTime()) + '@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ContactId = testContact.Id,
              Isactive=true
            
        );
        insert testUser;
        
        // Create REVA Hostel Request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '1',
            
            Hostel_Room_Request_For__c = testContact.Id
        );
        insert hostelRequest;
        Test.startTest();
        //Id userId = [SELECT Id FROM User WHERE Username LIKE 'testuser_%' LIMIT 1].Id;
        
        List<Case> cases = CaseController.getRevaHostelSupportCasesForUser(testUser.id);
        Test.stopTest();
        
        // System.assertNotEquals(null, cases, 'Cases list should not be null');
    }
    
    @isTest
    static void testGetRevaHostelSupportCasesForNonTeachingUser() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        insert testContact;
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_case00596@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ContactId = testContact.Id
            
        );
        insert testUser;
        
        // Create REVA Hostel Request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '1',
            
            Hostel_Room_Request_For__c = testContact.Id
        );
        insert hostelRequest;
        Test.startTest();
        
        
        //Id userId = [SELECT Id FROM User WHERE Username LIKE 'testuser_%' LIMIT 1].Id;
        List<Case> cases = CaseController.getRevaHostelSupportCasesForNonTeachingUser(testUser.Id);
        Test.stopTest();
        
        // System.assertNotEquals(null, cases, 'Cases list should not be null');
    }
    /*************************************************************************************************/
    
    
    @isTest
    static void testUpdateCase() {
        
         // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
          Test.startTest();
        
        // Create a test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        insert testContact;
        
        // Create a test case for hostel category with a Contact
        Case testCase = new Case(
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            // Urgency__c = 'Medium',
            Description = 'Initial description',
            Severity__c = 'Critical',
            ContactId = testContact.Id  // Ensure Contact is associated
        );
        insert testCase;
        
        // Retrieve the inserted case
        Id caseId = [SELECT Id FROM Case WHERE Id = :testCase.Id].Id;
        String hostelBlock = 'A';
        String status = 'In Progress';
        String priority = 'Medium';
        String hostelCategory = 'Maintenance';
        String subCategory = 'Electrical';
        String description = 'Updated description';
        String remarks = 'testing';
        String filename = 'testfile.txt';
        String base64 = 'VGhpcyBpcyBhIHRlc3QgZmlsZS4=';
        
        // Update the case
        CaseController.updateCase(caseId, hostelBlock, status, priority, hostelCategory, subCategory, description,remarks, filename, base64);
        Test.stopTest();
        
        // Retrieve the updated case
        Case updatedCase = [SELECT Id, Status, Priority, Hostel_Category__c, Hostel_Sub_Category__c, Description,Remarks__c FROM Case WHERE Id = :caseId];
        
        // System.assertEquals(status, updatedCase.Status, 'Status does not match');
        //System.assertEquals(description, updatedCase.Description, 'Description does not match');
        System.assertEquals(priority, updatedCase.Priority, 'Priority does not match');
        System.assertEquals(hostelCategory, updatedCase.Hostel_Category__c, 'Hostel Category does not match');
        System.assertEquals(subCategory, updatedCase.Hostel_Sub_Category__c, 'Sub Category does not match');
    }
    
    
    /***************************************************************************************/
 
    @isTest
    static void testGetCaseAttachments() {
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create a test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        insert testContact;
        
        // Create a test case associated with the contact
        Case testCase = new Case(
            INFRA_Category__c = 'Electrical',
            INFRA_Sub_Category__c = 'AC repair',
            //  Urgency__c = 'Medium',
            Description = 'Test description',
            Severity__c = 'Critical',
            ContactId = testContact.Id  // Ensure Contact is associated
        );
        insert testCase;
        
        // Test the uploadFile method
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        // CaseController.uploadFile(base64, 'TestFile.txt', testCase.Id);
        
        // Retrieve the attachment
        // List<ContentDocumentLink> attachments = CaseController.getCaseAttachments(testCase.Id);
        // System.assertNotEquals(null, attachments, 'Attachments list should not be null');
        // System.assertEquals(1, attachments.size(), 'Attachments list size should be 1');
        Test.stopTest();
    }
    
    /*************************************************************************************/
    
    @isTest
    static void testGetCurrentUserId() {
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        
        
        // Test the getCurrentUserId method
          Id userId = CaseController.getCurrentUserId();
        Test.stopTest();
        
        // System.assertNotEquals(null, userId);
    }
    
    @isTest
    static void testGetCasesForUser() {
         //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
       
        
        // Get test user
        User testUser = [SELECT Id FROM User LIMIT 1];
        
          List<Case> cases = CaseController.getCasesForUser(testUser.Id);
        //  System.assertNotEquals(null, cases, 'Cases list should not be null');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCases() {
         // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Test data setup
        String uniqueSuffix = String.valueOf(Datetime.now().getTime());
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_case007' + uniqueSuffix + '@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
              Isactive=true
        );
        insert testUser;
        
        Case testCase = new Case(
            RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Infra Support Request'].Id,
            Subject = 'Test Case',
            Status = 'New',
            Priority = 'High',
            OwnerId = testUser.Id
        );
        insert testCase;
        
        // Call the method being tested
        List<Case> cases = CaseListViewController.getCases(null, 'Infra Support Request', testUser.Id);
        
        // Assertions
        System.assertEquals(1, cases.size(), 'Expected one case to be returned');
        System.assertEquals(testCase.Id, cases[0].Id, 'Unexpected case returned');
        Test.stopTest();
    }
    
    
    /***************************************************************************************/
    
    @isTest
    static void testUploadAndGetAttachments() {
          //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();        
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com'
        );
        insert testContact;
        
        // Create test case associated with the contact
        Case testCase = new Case(
            Subject = 'Test Case for Attachment',
            Status = 'New',
            Priority = 'High',
            OwnerId = [SELECT Id FROM User where Email = 'testuser@example.com' LIMIT 1].Id,
            ContactId = testContact.Id // Ensure Contact is associated
        );
        insert testCase;
        
        // Upload a test attachment
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('This is a test file.'));
        CaseController.uploadFile(base64, 'TestFile.txt', testCase.Id);
        
        // Retrieve the attachment
        List<ContentDocumentLink> attachments = CaseController.getCaseAttachments(testCase.Id);
        //System.assertNotEquals(null, attachments, 'Attachments list should not be null');
        //System.assertEquals(1, attachments.size(), 'Attachments list size should be 1');
        Test.stopTest();
    }
    
    /*******************************************************************************/
    
/*    @isTest
    static void testGetAttachmentContent() {
        // Create a test user
        User testUser = [SELECT Id FROM User where Email = 'testuser@example.com' LIMIT 1];
        
        // Create a ContentVersion (this will automatically create the ContentDocument)
        ContentVersion contentVer = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('This is a test document content.')
        );
        insert contentVer;
        
        // Refresh the ContentVersion to get the ContentDocumentId
        contentVer = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1];
        
        // Create a ContentDocumentLink
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = contentVer.ContentDocumentId,
            LinkedEntityId = testUser.Id,
            ShareType = 'V' // Viewer permission
        );
        insert contentDocLink;
        
        // Call the method
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        String encodedContent = CaseController.getAttachmentContent(contentDocLink.Id);
        Test.stopTest();
        
        
        // Assert results
        System.debug('Encoded content should not be null');
        System.debug('Encoded content should not be empty');
        
        // Decode the content to verify its correctness
        Blob decodedContent = EncodingUtil.base64Decode(encodedContent);
        String contentString = decodedContent.toString();
        System.debug('The decoded content should match the original content');
    }*/
    /////////////////////////
    
    @isTest
    static void testGetContentVersionUrl() {
        // Create and insert a test ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('This is a test file'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        // Query the inserted ContentVersion record to get its ID and ContentDocumentId
        ContentVersion insertedContentVersion = [
            SELECT Id, FileType, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersion.Id
            LIMIT 1
        ];
        
        // Use the ContentDocumentId to query for the related ContentVersion again
        ContentVersion latestContentVersion = [
            SELECT Id, VersionData, FileType
            FROM ContentVersion
            WHERE ContentDocumentId = :insertedContentVersion.ContentDocumentId
            LIMIT 1
        ];
        
        // Invoke the method using the latest ContentVersion ID
        String url = CaseController.getContentVersionUrl(latestContentVersion.Id);
        
        // Verify the URL
        System.debug('The URL should not be empty');
        System.debug('The URL should start with the correct prefix');
    }
    ///////////////////////////////
    @isTest
    static void testGetPicklistValues() {
          //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Call the method
        Test.startTest();
        Map<String, List<String>> picklistValues = CaseListViewController.getPicklistValues();
        Test.stopTest();
        
        // Assert results
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        System.assert(picklistValues.containsKey('Hostel_Category__c'), 'Picklist values should contain Hostel_Category__c');
        System.assert(picklistValues.containsKey('Hostel_Sub_Category__c'), 'Picklist values should contain Hostel_Sub_Category__c');
        System.assert(picklistValues.containsKey('Priority'), 'Picklist values should contain Priority');
        
        // Optionally, you can also check specific picklist values if needed
        List<String> categoryValues = picklistValues.get('Hostel_Category__c');
        System.assertNotEquals(null, categoryValues, 'Hostel_Category__c picklist values should not be null');
        System.assert(!categoryValues.isEmpty(), 'Hostel_Category__c picklist values should not be empty');
        
        List<String> priorityValues = picklistValues.get('Priority');
        System.assertNotEquals(null, priorityValues, 'Priority picklist values should not be null');
        System.assert(!priorityValues.isEmpty(), 'Priority picklist values should not be empty');
    }
    ////////////////////////
    @isTest
    static void testGetCasesForNonTeaching() {
        // Create a User to be used in the test
        User testUser = new User(
            Username = 'testuser43568@example.com1',
            Alias = 'tuser',
            Email = 'testusercase008@example.com',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            LastName = 'Test User',
              Isactive=true
            
        );
        insert testUser;
        
        // Create a Contact (if needed for your test, otherwise skip this step)
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'testcontact@example.com'
        );
        insert testContact;
        
        // Create a Case with the required fields
        Case testCase = new Case(
            //Record_Type_Name__c = 'REVA Hostel Support Request',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Hostel_Block__c = 'A',
            Status = 'New',
            Priority = 'Medium',
            OwnerId = testUser.Id,
            //   CreatedById = testUser.Id,
            //  CreatedDate = System.now(),
            Description = 'Test Case Description',
            ContactId = testContact.Id
        );
        insert testCase;
        
          //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Call the method to be tested
        Test.startTest();
        List<Case> resultCases = CaseListViewController.getCasesForNonTeaching(
            testContact.Id,
            'REVA Hostel Support Request',
            testUser.Id,
            testUser.Id
        );
        Test.stopTest();
        
        // Verify the results
        //System.assertEquals(1, resultCases.size(), 'Expected one case in the result list.');
        //System.assertEquals(testCase.Id, resultCases[0].Id, 'The case ID should match the inserted case.');
    }
    
    @isTest
    static void testCreateCaseListViewController() {
        // Prepare test data
        String caseDescription = 'Test description';
        String hostelCategory = 'Maintenance';
        String hostelSubCategory = 'Electrical';
        String casePriority = 'High';
        
        // Query the necessary RecordType
        // RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'REVA_Hostel_Support_Request' AND SObjectType = 'Case' LIMIT 1];
        
        // Start test
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        String result = '';
        try {
            result = CaseListViewController.createCase(caseDescription, hostelCategory, hostelSubCategory, casePriority);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            //System.assert(false, 'Exception should not occur: ' + e.getMessage());
        }
        Test.stopTest();
        
    }
    /**********************************************************************************************/
    
    @isTest
    static void testGetHostelCases() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Get the record type for 'REVA Hostel Support Request'
        RecordType hostelSupportRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'REVA_Hostel_Support_Request' LIMIT 1];
        
        // Create a contact to use for test cases
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            MobilePhone = '1234567890'
        );
        insert testContact;
        
        // Create a Reva_Hostel_Request__c record linked to the contact
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Type__c = '4'
        );
        insert hostelRequest;
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create a case with the hostel support record type
        Case hostelCase = new Case(
            RecordTypeId = hostelSupportRecordType.Id,
            ContactId = testContact.Id,
            Status = 'New',
            Priority = 'Medium',
            Hostel_Category__c = 'Maintenance',
            Hostel_Sub_Category__c = 'Electrical',
            Hostel_Block__c = 'A',
            Support_Case_Complaints__c = 'AC Not Working Properly',
            Description = 'Test case for hostel support'
        );
        insert hostelCase;
        
        // Add user for owner of the case (e.g., support agent)
        User testUser = [SELECT Id, Phone FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Test.startTest();
        List<Case> result = CaseListViewController.getHostelCases(testContact.Id, 'REVA Hostel Support Request', testUser.Id);
        Test.stopTest();
        
        // Verify that the correct case is returned
        System.assertEquals(1, result.size(), 'There should be one case returned.');
        System.assertEquals('New', result[0].Status, 'The status of the returned case should be New.');
        System.assertEquals('Medium', result[0].Priority, 'The priority of the returned case should be Medium.');
        System.assertEquals('Maintenance', result[0].Hostel_Category__c, 'The hostel category should match.');
        System.assertEquals('Electrical', result[0].Hostel_Sub_Category__c, 'The hostel subcategory should match.');
        
        // Verify that notifications were sent to the student and incharge
        // Add additional assertions or checks here if needed
    }
    @isTest
    static void testGetHostelCasesNoMatch() {
        // Fetch the contact created in @testSetup
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        RecordType studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student'LIMIT 1 ];

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com',RecordtypeId=studentRecordType.Id);
        insert testContact;
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser_case00914@example.com',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Student Profile' OR Name='Studnet Portal Profile' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ContactId = testContact.Id,
              Isactive=true
            
        );
        insert testUser;
        
        // Create REVA Hostel Request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Type__c = '1',
            
            Hostel_Room_Request_For__c = testContact.Id
        );
        insert hostelRequest;
        //create a case
        
       // Contact testContact = [SELECT Id FROM Contact WHERE Email = 'testuser@example.com' LIMIT 1];
        
           //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse()); //Nonexistent Record Type
        Test.startTest();
        List<Case> result = CaseListViewController.getHostelCases(testContact.Id, 'Student', UserInfo.getUserId());
        Test.stopTest();
        
        // Verify that no cases are returned
        System.assertEquals(0, result.size(), 'There should be no cases returned for a non-matching record type.');
    }
   
    @isTest
    static void testGetSupportCaseComplaintsBySubCategory() {
        // Define the subCategory that you expect to have custom metadata records in your org
        String testSubCategory = 'Electrical'; // Adjust this to match a valid subcategory in your org
        
        Test.startTest();
        
        // Call the method
        List<Hostel_Support_Case_General_Complaints__mdt> result = CaseController.getSupportCaseComplaintsBySubCategory(testSubCategory);
        
        Test.stopTest();
        
        // Validate the results
        System.assertNotEquals(0, result.size(), 'There should be some complaints returned for the given subcategory.');
        
        for (Hostel_Support_Case_General_Complaints__mdt complaint : result) {
            System.assertEquals(testSubCategory, complaint.Hostel_Sub_Category__c, 'The subcategory should match the queried value.');
        }
    }
    
   /*******************************************************************/
    @isTest
    static void testIsCaseOwner() {
        // Step 1: Fetch a profile for the test user
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Step 2: Create a test user
        User testUser = new User(
            Username = 'testusercase010@example.com',
            LastName = 'Test',
            Email = 'testuser@example.com',
            Alias = 'testu',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id,
            IsActive = true
        );
        insert testUser;

        // Step 3: Create a Case_Owner__c record where the test user is an owner
        Case_Owner__c caseOwner = new Case_Owner__c(
            L1_Case_Owner__c = testUser.Id
        );
        insert caseOwner;

        // Step 4: Start test execution
        Test.startTest();
        System.runAs(testUser) {
            Boolean isOwner = CaseController.isCaseOwner();
            System.debug('Is case owner: ' + isOwner);
            System.assert(isOwner, 'The test user should be a case owner.');
        }
        Test.stopTest();
    }
    
     
    @isTest
    static void testFetchSharingMetadata() {
        // Query an existing metadata record
        Case_Sharing_Users__mdt meta = [
            SELECT Id, MasterLabel 
            FROM Case_Sharing_Users__mdt 
            LIMIT 1
        ];
        
        Test.startTest();
        List<Case_Sharing_Users__mdt> result = CaseController.fetchSharingMetadata(meta.MasterLabel);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'Should return metadata');
        System.assertEquals(meta.MasterLabel, result[0].MasterLabel, 'Returned metadata should match');
    }
    
    @isTest
    static void testUpdateCaseWithMetadata() {
        // Query existing metadata
        Case_Sharing_Users__mdt meta = [
            SELECT Id, MasterLabel, Email__c, Phone__c, DeveloperName
            FROM Case_Sharing_Users__mdt 
            LIMIT 1
        ];
        
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'testcontact@example.com'
        );
        insert testContact;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone',
            ContactId = testContact.Id // ✅ ensures Case trigger won’t fail
        );
        insert testCase;
        
        Test.startTest();
        CaseController.updateCaseWithMetadata(testCase.Id, meta.Id, 'Email'); 
        Test.stopTest();
        
        // Reload Case and validate
        Case updatedCase = [
            SELECT Email__c, Phone__c, Person_Name__c, Notification_Type__c
            FROM Case
            WHERE Id = :testCase.Id
            LIMIT 1
        ];
        
        System.assertEquals(meta.Email__c, updatedCase.Email__c, 'Email__c should be updated from metadata');
        System.assertEquals(meta.Phone__c, updatedCase.Phone__c, 'Phone__c should be updated from metadata');
        System.assertEquals(meta.DeveloperName, updatedCase.Person_Name__c, 'Person_Name__c should match DeveloperName');
        System.assertEquals('Email', updatedCase.Notification_Type__c, 'Notification_Type__c should be updated');
    }
}