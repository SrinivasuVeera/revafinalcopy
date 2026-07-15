@isTest
public class ActivityTrackerTest {

    @isTest
    static void testUpdateActivity() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User u = new User(
            FirstName='Activity',
            LastName='User',
            Email='activity@test.com',
            Username='activity'+System.currentTimeMillis()+'@test.com',
            Alias='auser',
            TimeZoneSidKey='Asia/Kolkata',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p.Id
        );

        insert u;

        Test.startTest();

        ActivityTracker.updateActivity(u.Id);

        Test.stopTest();

        User updatedUser = [
            SELECT LastActivityTime__c
            FROM User
            WHERE Id=:u.Id
        ];

        System.assert(updatedUser.LastActivityTime__c != null);
    }
}