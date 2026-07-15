@isTest
public class FetchCampusRecDataTest {
    
     @isTest
    public static void getAllCases() {
        // Create a test user with a profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        Account acc = new Account();
         acc.name='testaccount';
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id
        );
        insert testContact;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = testContact.Id
        );
        insert testUser;

        // Set the current user context
        System.runAs(testUser) {
            Test.startTest();
            
            //Try{
                List<Case> result = FetchCampusRecData.getAllCases();

            Test.stopTest();
        }
    }
    
    @isTest
    public static void getAllCasesWithoutSubject() {
        // Create a test user with a profile
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        Account acc = new Account();
         acc.name='testaccount';
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id
        );
        insert testContact;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = testProfile.Id,
            ContactId = testContact.Id
        );
        insert testUser;

        // Set the current user context
        System.runAs(testUser) {
            Test.startTest();
            
            //Try{
              List<Case> result = FetchCampusRecData.getAllCasesWithoutSubject();
            Test.stopTest();
        }
    }
    
     @isTest
    static void getContacts() {
        // Test data setup
        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                MobilePhone = '123456789' + i
            ));
        }
        insert testContacts;

        Test.startTest();
        // Call the method to be tested
        List<Contact> resultContacts = FetchCampusRecData.getContacts();
        Test.stopTest();
}
}