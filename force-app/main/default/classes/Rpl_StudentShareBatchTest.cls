@isTest
public class Rpl_StudentShareBatchTest {

    @isTest
    static void testRpl_StudentShareBatch() {
          id userid = userinfo.getuserid();
        user u = [Select id,Name from user where id =:userid];
        System.runAs(u) {
            
            Profile testProfile1 = [SELECT Id FROM Profile WHERE Name='Vertical Head' LIMIT 1];
             User VHuser = new User(
                FirstName = 'VH',
                LastName = 'User',
                Email ='VH@gmail.com',
                Username ='VHtest@example.com',
                Alias ='VHtest',
                CommunityNickName ='somuser',
                ProfileId = testProfile1.Id,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'
            );
            insert VHuser;
            
            
            
        }
        // Create test Student Registration records
       Rpl_Student_Registration__c std1 = new Rpl_Student_Registration__c();
        std1.Name = 'Block Test Data1';
        std1.Rpl_Personal_Mail_ID__c = 'blocktest1@gmail.com';
        std1.Rpl_Interested_in_placement__c = 'Yes';
        std1.Rpl_University_Mail_ID__c = '123123123123@reva.edu.in';
       // std1.Contact__c = eCon2.Id;
        std1.Rpl_Is_Blocked__c = true;
        insert std1;

        Rpl_Student_Registration__c std2 = new Rpl_Student_Registration__c();
        std2.Name = 'Data2';
        std2.Rpl_Personal_Mail_ID__c = 'harshithaperuri36@gmail.com';
        std2.Rpl_Interested_in_placement__c = 'Yes';
        std2.Rpl_University_Mail_ID__c = '123123123123@reva.edu.in';
       // std1.Contact__c = eCon1.Id;
        std2.Rpl_Is_Blocked__c = true;
        insert std2;


        // Step 2: Instantiate and execute the batch
        Test.startTest();
        Rpl_StudentShareBatch batch = new Rpl_StudentShareBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Step 3: Verify results
        List<Rpl_Student_Registration__Share> newShares = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Rpl_Student_Registration__Share];
        
      //  System.assertEquals(2, newShares.size(), 'Expected 2 share records to be created.');
        for (Rpl_Student_Registration__Share share : newShares) {
           // System.assertEquals(testUser.Id, share.UserOrGroupId, 'Share record should be assigned to the test user.');
            //System.assertEquals('Read', share.AccessLevel, 'Share record should have Read access level.');
        }
    }
    @isTest
    static void testRpl_ScheduleStudentShareBatch() {
        // Schedule the batch job
        Test.startTest();
        String cronExpression = '0 0 2 * * ?'; // Cron expression for 2:00 AM every day
        Rpl_ScheduleStudentShareBatch schedulableInstance = new Rpl_ScheduleStudentShareBatch();
        System.schedule('Test Nightly Student Share Batch', cronExpression, schedulableInstance);
        Test.stopTest();

        // Verify the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Test Nightly Student Share Batch' LIMIT 1];
        System.assertEquals(cronExpression, ct.CronExpression, 'Cron expression should match the scheduled expression.');
        System.assert(ct.NextFireTime != null, 'Next fire time should be set.');
    }
}