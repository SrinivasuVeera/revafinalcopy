@isTest
public class RevaMealBookingTriggerHandle_Test {

    @testSetup
    static void setupData() {
        // Create a contact
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'tetstt@yopmail.com');
        insert contact;
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User user = new User(
            FirstName = 'Test1', 
            LastName = 'User',
            Username = 'testusermeal55@example.com',
            Email = 'testuser@example.com',
            ContactId = contact.Id,
            ProfileId = studentProfile.Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            UserRoleId = null
        );
       // insert user;
        
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Booking_For__c = contact.Id,
            Reva_Meal_Booking_Date__c = Date.today(), 
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert mealBooking;
    }

    @isTest
    static void testValidInsert() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Reva_Mess_Menu__c menu = [SELECT Id ,Type__c FROM Reva_Mess_Menu__c WHERE Type__c = 'Lunch' LIMIT 1];

        Reva_Meal_Booking__c newBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Date__c = Date.today(), 
            Reva_Meal_Booking_Status__c = 'Booked',
            Booking_For__c = con.Id
        );

        Test.startTest();
       try {
        insert newBooking;
        System.assert(false, 'Expected DmlException due to duplicate booking, but insert succeeded.');
    } catch (DmlException e) {
        System.assert(
            e.getMessage().contains('Duplicate meal booking found with the same Menu, Date, Type, and Contact'),
            'Expected validation error was not found in the exception message.'
        );
    }
        Test.stopTest();

    }

    @isTest
    static void testInsertDuplicateShouldFail() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Reva_Mess_Menu__c menu = [SELECT Id FROM Reva_Mess_Menu__c WHERE Type__c = 'Lunch' LIMIT 1];

        // Duplicate of test setup booking
        Reva_Meal_Booking__c dupBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Date__c = Date.today(), 
            Reva_Meal_Booking_Status__c = 'Booked',
            Booking_For__c = con.Id
        );

        Test.startTest();
        try {
            insert dupBooking;
            System.assert(false, 'Insert should have failed due to duplicate.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Duplicate meal booking'), 'Expected duplicate error.');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidUpdate() {
        Reva_Meal_Booking__c booking = [SELECT Id, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c LIMIT 1];
        booking.Reva_Meal_Booking_Status__c = 'Missed meal'; // unique combination

        Test.startTest();
        update booking;
        Test.stopTest();

        System.assertEquals('Missed meal', booking.Reva_Meal_Booking_Status__c, 'Booking status should update.');
    }
}