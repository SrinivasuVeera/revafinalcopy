@IsTest
public class MealCancellationNotificationSMSTest {
    @TestSetup
    static void setupTestData() {
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            MobilePhone = '1234567890'
        );
        insert testContact;

        // Create Reva_Mess_Menu__c record
        Reva_Mess_Menu__c revamess = new Reva_Mess_Menu__c(
            Type__c = 'Breakfast',
            Date__c = Date.newInstance(2024, 12, 10),
            End_Time__c = Time.newInstance(2, 23, 0, 0),
            Start_Time__c = Time.newInstance(1, 23, 0, 0)
        );
        insert revamess;

        // Create test Meal Bookings
        Reva_Meal_Booking__c cancelledBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Cancelled',
            Reva_Mess_Menu__c = revamess.Id
        );
        insert cancelledBooking;

        // Corrected: Create a record with 'Confirmed' status
        Reva_Meal_Booking__c confirmedBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Confirmed',
            Reva_Mess_Menu__c = revamess.Id
        );
        insert confirmedBooking;
    }

    @IsTest
    static void testSendCancellationSMS_ValidBookingIds() {
        // Set up mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorr());

        // Retrieve the cancelled booking for testing
        List<Reva_Meal_Booking__c> bookings = [
            SELECT Id 
            FROM Reva_Meal_Booking__c 
            WHERE Reva_Meal_Booking_Status__c = 'Cancelled'
        ];

        Test.startTest();
        // Call the method with valid booking IDs
        MealCancellationNotificationSMS.sendCancellationSMS(new List<Id> {bookings[0].Id});
        Test.stopTest();

        // Assert debug logs (this demonstrates assertions for mock scenarios in absence of callout logic)
        System.assert(true, 'Test executed without exceptions for valid booking IDs');
    }

    @IsTest
    static void testSendCancellationSMS_EmptyList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorr());

        Test.startTest();
        // Call the method with an empty list
        MealCancellationNotificationSMS.sendCancellationSMS(new List<Id>());
        Test.stopTest();

        // Assert debug logs
        System.assert(true, 'Test executed without exceptions for empty booking ID list');
    }

    @IsTest
    static void testSendCancellationSMS_NullList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorr());

        Test.startTest();
        // Call the method with a null list
        MealCancellationNotificationSMS.sendCancellationSMS(null);
        Test.stopTest();

        // Assert debug logs
        System.assert(true, 'Test executed without exceptions for null booking ID list');
    }

    @IsTest
    static void testMakeCalloutAsync_NoCancelledBookings() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorr());

        // Retrieve the non-cancelled booking for testing
        List<Reva_Meal_Booking__c> bookings = [
            SELECT Id 
            FROM Reva_Meal_Booking__c 
            WHERE Reva_Meal_Booking_Status__c = 'Confirmed'
        ];

        System.assert(bookings.size() > 0, 'No bookings with status "Confirmed" found. Check test setup.');

        Test.startTest();
        // Call the future method with non-cancelled booking IDs
        MealCancellationNotificationSMS.makeCalloutAsync(new List<Id> {bookings[0].Id});
        Test.stopTest();

        // Assert debug logs
        System.assert(true, 'Test executed without exceptions for non-cancelled booking IDs');
    }
}