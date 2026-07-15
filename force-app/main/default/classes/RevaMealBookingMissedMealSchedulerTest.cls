@IsTest
public class RevaMealBookingMissedMealSchedulerTest {

    @IsTest
    static void testRevaMealBookingMissedMealScheduler() {
        // Step 1: Create test data - Contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;

        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];

        User user = new User(
            Username = 'testusermeal2789@example.com',
            FirstName = 'Test2', LastName = 'User',
            Email = 'testusermeal001@example.com',
            ContactId = contact.Id,
            ProfileId = studentProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null
        );
        insert user;

        // Step 2: Create test data - Reva_Mess_Menu__c with breakfast time (7 AM to 8 AM)
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Type__c = 'Breakfast',
            Date__c = Date.today(),
            Start_Time__c = Time.newInstance(7, 0, 0, 0),  // 7:00 AM
            End_Time__c = Time.newInstance(8, 0, 0, 0)    // 8:00 AM
        );
        insert testMenu;

        // Step 3: Create test data - Reva_Meal_Booking__c with status 'Booked'
        List<Reva_Meal_Booking__c> mealBookings = new List<Reva_Meal_Booking__c>();
        for (Integer i = 0; i < 5; i++) {
            mealBookings.add(new Reva_Meal_Booking__c(
                Booking_For__c = contact.Id,
                Booking_For_User__c = user.Id,
                Reva_Meal_Booking_Status__c = 'Booked',
                Reva_Meal_Booking_Date__c = Date.today(),
                Reva_Mess_Menu__c = testMenu.Id
            ));
        }
        insert mealBookings;

        // Step 4: Schedule the RevaMealBookingMissedMealScheduler job
        Test.startTest();
        String cronExpression = '0 0 0 * * ?';  // Every day at midnight
        System.schedule('Test Reva Meal Booking Missed Meal Scheduler', cronExpression, new RevaMealBookingMissedMealScheduler());
        Test.stopTest();

        // Step 5: Verify that the Queueable job was enqueued
        // Check the job status
        List<CronTrigger> jobs = [SELECT Id, State FROM CronTrigger WHERE CronJobDetail.Name = 'Test Reva Meal Booking Missed Meal Scheduler'];
        System.assertEquals(1, jobs.size(), 'Job was not scheduled correctly.');
        
        // Correct the assertion to use 'WAITING' instead of 'Waiting'
        System.assertEquals('WAITING', jobs[0].State, 'Job did not reach the expected state.');
    }
}