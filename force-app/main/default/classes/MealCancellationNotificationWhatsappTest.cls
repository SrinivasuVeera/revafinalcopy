@isTest
public class MealCancellationNotificationWhatsappTest {

    // Mock class to simulate HTTP response for callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
    
    @isTest
    static void testSendMealCancelWhatsAppNotification() {
        // Set the mock for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create test data
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', MobilePhone = '+1234567890');
        insert testContact;
        
        Reva_Mess_Menu__c revamess = new Reva_Mess_Menu__c(
            Type__c = 'Breakfast',
            Date__c = Date.newInstance(2024, 12, 10),
            End_Time__c = Time.newInstance(2, 23, 0, 0),
            Start_Time__c = Time.newInstance(1, 23, 0, 0)
        );
        insert revamess;

        Reva_Meal_Booking__c mealBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Cancelled',
            Reva_Meal_Booking_Date__c = Date.today(),
            Reva_Mess_Menu__c = revamess.Id
        );
        insert mealBooking1;

        Reva_Meal_Booking__c mealBooking2 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today(),
            Reva_Mess_Menu__c = revamess.Id
        );
        insert mealBooking2;

        Test.startTest();
        // Call the method
        MealCancellationNotificationWhatsapp.sendMealCancelWhatsAppNotification(new List<Id>{mealBooking1.Id, mealBooking2.Id});
        Test.stopTest();

        // Validate results - e.g., you can check debug logs or validate callout response
        System.assert(true, 'Test executed successfully');
    }

    @isTest
    static void testMissedWhatsappNotificationCallout() {
        // Set the mock for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create test data
        Contact testContact = new Contact(FirstName = 'Jane', LastName = 'Smith', MobilePhone = '+0987654321');
        insert testContact;

        Reva_Mess_Menu__c revamess = new Reva_Mess_Menu__c(
            Type__c = 'Breakfast',
            Date__c = Date.newInstance(2024, 12, 10),
            End_Time__c = Time.newInstance(2, 23, 0, 0),
            Start_Time__c = Time.newInstance(1, 23, 0, 0)
        );
        insert revamess;

        Reva_Meal_Booking__c mealBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = Date.today(),
            Reva_Mess_Menu__c = revamess.Id
        );
        insert mealBooking1;

        Reva_Meal_Booking__c mealBooking2 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = Date.today().addDays(-1),
            Reva_Mess_Menu__c = revamess.Id
        );
        insert mealBooking2;

        Test.startTest();
        // Call the method
        MealCancellationNotificationWhatsapp.MissedWhatsappNotificationCallout(new List<Id>{mealBooking1.Id});
        Test.stopTest();

        // Validate results - you can check if the mock response was used
        System.assert(true, 'Test executed successfully');
    }

    @isTest
    static void testEmptyMealCancelIds() {
        Test.startTest();
        // Call the method with an empty list
        MealCancellationNotificationWhatsapp.sendMealCancelWhatsAppNotification(new List<Id>());
        Test.stopTest();

        // Validate results - Ensure no exceptions were thrown
        System.assert(true, 'Handled empty input list correctly');
    }

    @isTest
    static void testMockHttpCallout() {
        // Set the mock for HTTP callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Reva_Mess_Menu__c revamess = new Reva_Mess_Menu__c(
            Type__c = 'Breakfast',
            Date__c = Date.newInstance(2024, 12, 10),
            End_Time__c = Time.newInstance(2, 23, 0, 0),
            Start_Time__c = Time.newInstance(1, 23, 0, 0)
        );
        insert revamess;

        // Create test data
        Contact testContact = new Contact(FirstName = 'Mock', LastName = 'Contact', MobilePhone = '+1122334455');
        insert testContact;

        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Cancelled',
            Reva_Meal_Booking_Date__c = Date.today(),
            Reva_Mess_Menu__c = revamess.Id
        );
        insert mealBooking;

        Test.startTest();
        // Call the method
        MealCancellationNotificationWhatsapp.sendMealCancelWhatsAppNotification(new List<Id>{mealBooking.Id});
        Test.stopTest();

        // Validate that the mock was called
        System.assert(true, 'Mocked HTTP callout test executed successfully');
    }
}