@isTest
private class ProgressBarControllerTest {

    @testSetup
    static void setup() {
        // Create a test Application record
        hed__Application__c app = new hed__Application__c(
            hed__Application_Status__c = 'Started'
        );
        insert app;
    }

    @isTest
    static void testGetLoggedInProfile() {
        // Get current user's profile name
        String expectedProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        
        Test.startTest();
        String actualProfile = ProgressBarController.getLoggedInProfile();
        Test.stopTest();
        
        System.assertEquals(expectedProfile, actualProfile, 'The profile name should match the logged-in user');
    }

    @isTest
    static void testGetApplicationStatus() {
        // Fetch the record created in setup
        hed__Application__c app = [SELECT Id FROM hed__Application__c LIMIT 1];
        
        Test.startTest();
        String status = ProgressBarController.getApplicationStatus(app.Id);
        Test.stopTest();
        
        System.assertEquals('Started', status, 'Should return the initial status correctly');
    }

    @isTest
    static void testUpdateApplicationStatus() {
        // Fetch the record created in setup
        hed__Application__c app = [SELECT Id FROM hed__Application__c LIMIT 1];
        String newStatus = 'In Review';
        
        Test.startTest();
        ProgressBarController.updateApplicationStatus(app.Id, newStatus);
        Test.stopTest();
        
        // Verify the update in database
        hed__Application__c updatedApp = [SELECT hed__Application_Status__c FROM hed__Application__c WHERE Id = :app.Id];
        System.assertEquals(newStatus, updatedApp.hed__Application_Status__c, 'The status should have been updated in the database');
    }

    @isTest
    static void testUpdateApplicationStatusFailure() {
        // Test with an invalid ID to ensure it handles errors (or throws them as expected)
        try {
            Test.startTest();
            ProgressBarController.updateApplicationStatus(null, 'Interested');
            Test.stopTest();
            System.assert(false, 'Should have thrown an exception for null ID');
        } catch (Exception e) {
            System.assert(true, 'Exception caught as expected');
        }
    }
}