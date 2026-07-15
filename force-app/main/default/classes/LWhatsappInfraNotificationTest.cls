@isTest
public class LWhatsappInfraNotificationTest {

    @isTest
    static void testProcessContactsL1() {
        // Create test data
        Map<String, Id> testData = createTestData();
        Id caseId = testData.get('caseId');
        Id userId = testData.get('userId');

        // Set up InputParameters for L1
        LWhatsappInfraNotification.InputParameters inputParams = new LWhatsappInfraNotification.InputParameters();
        inputParams.recordIds = new List<String>{caseId};
        inputParams.userIds = new List<String>{userId};
        inputParams.UserCheck = new List<String>{'L1'};

        // Test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock()); // Mock response
        LWhatsappInfraNotification.processContacts(new List<LWhatsappInfraNotification.InputParameters>{inputParams});
        Test.stopTest();

        // Verify expected behavior
        // Add assertions here to validate expected behavior
    }

    @isTest
    static void testProcessContactsL2() {
        // Create test data
        Map<String, Id> testData = createTestData();
        Id caseId = testData.get('caseId');
        Id userId = testData.get('userId');

        // Set up InputParameters for L2
        LWhatsappInfraNotification.InputParameters inputParams = new LWhatsappInfraNotification.InputParameters();
        inputParams.recordIds = new List<String>{caseId};
        inputParams.userIds = new List<String>{userId};
        inputParams.UserCheck = new List<String>{'L2'};

        // Test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock()); // Mock response
        LWhatsappInfraNotification.processContacts(new List<LWhatsappInfraNotification.InputParameters>{inputParams});
        Test.stopTest();

        // Verify expected behavior
        // Add assertions here to validate expected behavior
    }

    @isTest
    static void testProcessContactsL3() {
        // Create test data
        Map<String, Id> testData = createTestData();
        Id caseId = testData.get('caseId');
        Id userId = testData.get('userId');

        // Set up InputParameters for L3
        LWhatsappInfraNotification.InputParameters inputParams = new LWhatsappInfraNotification.InputParameters();
        inputParams.recordIds = new List<String>{caseId};
        inputParams.userIds = new List<String>{userId};
        inputParams.UserCheck = new List<String>{'L3'};

        // Test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock()); // Mock response
        LWhatsappInfraNotification.processContacts(new List<LWhatsappInfraNotification.InputParameters>{inputParams});
        Test.stopTest();

        // Verify expected behavior
        // Add assertions here to validate expected behavior
    }

    @isTest
    static void testProcessContactsL4() {
        // Create test data
        Map<String, Id> testData = createTestData();
        Id caseId = testData.get('caseId');
        Id userId = testData.get('userId');

        // Set up InputParameters for L4
        LWhatsappInfraNotification.InputParameters inputParams = new LWhatsappInfraNotification.InputParameters();
        inputParams.recordIds = new List<String>{caseId};
        inputParams.userIds = new List<String>{userId};
        inputParams.UserCheck = new List<String>{'L4'};

        // Test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock()); // Mock response
        LWhatsappInfraNotification.processContacts(new List<LWhatsappInfraNotification.InputParameters>{inputParams});
        Test.stopTest();

        // Verify expected behavior
        // Add assertions here to validate expected behavior
    }

    @isTest
    static void testL1UserMethod() {
        // Create test data
        Map<String, Id> testData = createTestData();
        Id caseId = testData.get('caseId');
        Id userId = testData.get('userId');

        // Test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock()); // Mock response
        LWhatsappInfraNotification.L1UserMethod(
            new List<String>{caseId}, 
            'infrastructure_support_l1_copy', 
            new List<Id>{userId}
        );
        Test.stopTest();

        // Verify the HTTP callout or process further as needed.
        // Add assertions here to validate expected behavior
    }

    @isTest
    static void testL2UserMethod() {
        // Create test data
        Map<String, Id> testData = createTestData();
        Id caseId = testData.get('caseId');
        Id userId = testData.get('userId');

        // Test start
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock()); // Mock response
        LWhatsappInfraNotification.L1UserMethod(
            new List<String>{caseId}, 
            'infrastructure_support_l2_copy', 
            new List<Id>{userId}
        );
        Test.stopTest();

        // Verify the HTTP callout or process further as needed.
        // Add assertions here to validate expected behavior
    }

    private static Map<String, Id> createTestData() {
        // Create a Contact record
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testContact;

        // Create an Account record
        Account testAccount = new Account(
            Name = 'Test Facility'
        );
        insert testAccount;

        // Create a Facility record
        hed__Facility__c fac = new hed__Facility__c(
            Name = 'test facility'
        );
        insert fac;

        // Create a Case record with the correct Facility and Contact ID
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            INFRA_Category__c = 'Electrical',
            INFRA_Sub_Category__c = 'AC',
            Facility__c = fac.Id, // Use the ID from the inserted Facility record
            ContactId = testContact.Id, // Ensure ContactId is populated
            Description = 'Test Description'
        );
        insert testCase;

        // Create a User record with all required fields
        User testUser = new User(
            Username = 'testuserrrrrrr123@example.com',
            Alias = 'testuser',
            Email = 'testuser@example.com',
            ProfileId = UserInfo.getProfileId(),
            Phone = '+1234567890',
            LastName = 'User',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Return a map of IDs for use in test methods
        Map<String, Id> testData = new Map<String, Id>{
            'caseId' => testCase.Id,
            'userId' => testUser.Id
        };

        return testData;
    }}