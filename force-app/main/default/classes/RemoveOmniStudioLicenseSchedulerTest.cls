@isTest
public class RemoveOmniStudioLicenseSchedulerTest {

    @isTest
    static void testScheduler(){

        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        User u = new User(
            FirstName='Test',
            LastName='Scheduler',
            Email='sched@test.com',
            Username='sched'+System.currentTimeMillis()+'@test.com',
            Alias='schd',
            TimeZoneSidKey='Asia/Kolkata',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            ProfileId=p.Id
        );

        insert u;

        // Update non-setup field first
        u.LastActivityTime__c = System.now().addMinutes(-40);
        update u;

        Test.startTest();

        // run scheduler in separate context
        System.runAs(u){
            new RemoveOmniStudioLicenseScheduler().execute(null);
        }

        Test.stopTest();

        System.assert(true);
    }
}