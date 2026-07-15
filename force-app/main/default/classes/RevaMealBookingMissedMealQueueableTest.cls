/*@IsTest
public class RevaMealBookingMissedMealQueueableTest {
    
    @IsTest
    static void testRevaMealBookingMissedMealQueueable() {
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
        
        // Step 3: Create test data - Reva_Mess_Menu__c
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Type__c ='Lunch',
            Date__c = Date.today(),
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // 12:00 PM
            End_Time__c = Time.newInstance(13, 30, 0, 0)   // 1:30 PM
        );
        insert testMenu;
        
        // Step 4: Create test data - Reva_Meal_Booking__c
        List<Reva_Meal_Booking__c> mealBookings = new List<Reva_Meal_Booking__c>();
        for (Integer i = 0; i < 5; i++) {
            mealBookings.add(new Reva_Meal_Booking__c(
                Booking_For__c = contact.Id,
                Booking_For_User__c = user.Id,
                Reva_Meal_Booking_Status__c = 'Booked',
                //Meal_Date__c = Date.today(), // Set the meal date to today
                Reva_Meal_Booking_Date__c = Date.today(),
                //Meal_End_Time__c = Datetime.now().addHours(-1), // Already past - ensures missed meal logic triggers
                Reva_Mess_Menu__c = testMenu.Id
                //Type_of_meal__c = testMenu.Type__c // Add type of meal
            ));
        }
        insert mealBookings;
        
        Test.startTest();
        // Step 5: Enqueue the Queueable job
        System.enqueueJob(new RevaMealBookingMissedMealQueueable());
        Test.stopTest();
        
        // Step 6: Verify updates
        List<Reva_Meal_Booking__c> updatedBookings = [
            SELECT Id, Reva_Meal_Booking_Status__c
            FROM Reva_Meal_Booking__c
            WHERE Id IN :mealBookings
        ];
        
        // Verify if the status is updated to "Missed Meal"
        for (Reva_Meal_Booking__c booking : updatedBookings) {
            System.debug('Booking Status: ' + booking.Reva_Meal_Booking_Status__c); // Debug to confirm
            System.assertEquals('Missed Meal', booking.Reva_Meal_Booking_Status__c,
                                'The booking status should be updated to Missed Meal.');
        }
    }
}*/
@IsTest
public class RevaMealBookingMissedMealQueueableTest {

    @IsTest
    static void testRevaMealBookingMissedMealQueueable() {
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

        // Step 3: Create test data - Reva_Mess_Menu__c with breakfast time (7 AM to 8 AM)
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Type__c = 'Breakfast',
            Date__c = Date.today(),
            Start_Time__c = Time.newInstance(7, 0, 0, 0),  // 7:00 AM
            End_Time__c = Time.newInstance(8, 0, 0, 0)    // 8:00 AM
        );
        insert testMenu;

        // Step 4: Create test data - Reva_Meal_Booking__c with status 'Booked'
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

        // Ensure meals have passed the end time to trigger missed meal logic
        // Updating the bookings so that the meal time has passed
        for (Reva_Meal_Booking__c booking : mealBookings) {
            booking.Reva_Meal_Booking_Date__c = Date.today().addDays(-1);  // Set the meal date to yesterday (before the current time)
        }
        update mealBookings;

        Test.startTest();
        // Step 5: Enqueue the Queueable job
        System.enqueueJob(new RevaMealBookingMissedMealQueueable());
        Test.stopTest();

        // Step 6: Verify updates
        List<Reva_Meal_Booking__c> updatedBookings = [
            SELECT Id, Reva_Meal_Booking_Status__c
            FROM Reva_Meal_Booking__c
            WHERE Id IN :mealBookings
        ];

        // Verify if the status is updated to "Missed Meal"
        for (Reva_Meal_Booking__c booking : updatedBookings) {
            System.debug('Booking Status: ' + booking.Reva_Meal_Booking_Status__c); // Debug to confirm
            System.assertEquals('Missed Meal', booking.Reva_Meal_Booking_Status__c,
                'The booking status should be updated to Missed Meal.');
        }
    }
}