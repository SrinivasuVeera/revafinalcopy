@isTest
private class ApplicationListControllerTest {

    @isTest
    static void testGetAdmissionApplicationsWithApplications() {
       
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Applicant Profile' LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id,
            Email = 'testuser@gmail1.com'
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

        System.runAs(testUser) {
            hed__Application__c testApplication = new hed__Application__c(
                hed__Applicant__c = testContact.Id
            );
            insert testApplication;

            // Run test
            Test.startTest();
            ApplicationListController.AdmissionApplicationsWrapper result = ApplicationListController.getAdmissionApplications();
            Test.stopTest();

            // Verify results
            //System.assertNotEquals(null, result);
            //System.assertEquals(1, result.applicationList.size());
        }
    }

    @isTest
    static void testGetAdmissionApplicationsNoApplications() {
      

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Applicant Profile' LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;

      

        Contact testContact = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            AccountId = acc.Id,
            Email = 'testuser@gmail1.com'
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

       

        System.runAs(testUser) {
            // Run test
            Test.startTest();
            Boolean exceptionThrown = false;
            try {
                ApplicationListController.getAdmissionApplications();
            } catch (Reva_CustomException e) {
                exceptionThrown = true;
           //     System.assertEquals('No applications submitted for current user !', e.getMessage());
            }
          //  System.assert(exceptionThrown, 'Expected custom exception to be thrown.');
            Test.stopTest();
        }
    }
}