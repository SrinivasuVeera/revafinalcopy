@isTest
public class UserTriggerTest {
    @isTest
    static void testUserTrigger() {
        // Create test data
         Account testAccount = new Account();
        testAccount.Name = 'testing';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId= testAccount.Id;
         testContact.FirstName = 'vasu';
        testContact.LastName = 'reddy';
        insert testContact;
         
              
        //Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1];   
        User testUser = new User();
               testUser.FirstName = 'Active';
               testUser.LastName = 'User ';
              testUser.Username = 'activeuser1@gmail.com';
              testUser.Email = 'activeuser1@gmail.com';
              testUser.Alias = 'AU';
              testUser.TimeZoneSidKey = 'Asia/Kolkata';
              testUser.LocaleSidKey = 'en_US';
              testUser.EmailEncodingKey = 'ISO-8859-1';
             testUser.LanguageLocaleKey = 'en_US';
            testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1].Id;
        testUser.ContactId = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id LIMIT 1].Id;
        testUser.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
        insert testUser;
        }
        // Modify the User record to trigger the trigger logic
        testUser.IsActive = true;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update testUser;
        }
        
        // Verify the results
        Contact updatedContact = [SELECT Id, Active__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, updatedContact.Active__c);
    }
}