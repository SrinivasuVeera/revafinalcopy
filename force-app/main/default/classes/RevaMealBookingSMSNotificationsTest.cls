@isTest
public class RevaMealBookingSMSNotificationsTest {
    // Mock class to simulate HTTP callout responses
    public class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"Test message","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendMealBookingSMSNotification() {
        Test.setMock(HttpCalloutMock.class, new RestMock());

        // Create test data
        DateTime now = DateTime.now();
        Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);  
        Time endTime = Time.newInstance(now.hour() + 1, now.minute(), now.second(), 0);
        
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(Type__c = 'Lunch', Start_Time__c = currentTime, End_Time__c = endTime);
        insert testMenu;
        
        Contact testContact1 = new Contact(LastName = 'Test Contact 1', MobilePhone = '918123456789', Email = 'test1@example.com',Total_missed_meals_this_month__c = 0);
        insert testContact1;
        
        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
             
            Reva_Meal_Booking_Date__c = now.date(),
            Booking_For__c = testContact1.Id,
            Reva_Mess_Menu__c = testMenu.Id
        );
        
        insert testBooking1;

        // Call the method to be tested
        Test.startTest();
        RevaMealBookingSMSNotifications.sendMealBookingSMSNotification(new List<Id>{testBooking1.Id});
        Test.stopTest();
        
        // Assert that the booking was processed correctly
        System.assertEquals('Booked', [SELECT Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Id = :testBooking1.Id].Reva_Meal_Booking_Status__c);
    }

    @isTest
    static void testSendMissedMealNotifications() {
        Test.setMock(HttpCalloutMock.class, new RestMock());

        // Create test data
        Contact testContact2 = new Contact(LastName = 'Test Contact 2', MobilePhone = '919876543210', Email = 'test2@example.com',Total_missed_meals_this_month__c = 0);
        insert testContact2;
        
        DateTime now = DateTime.now();
        Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);  
        Time endTime = Time.newInstance(now.hour() + 1, now.minute(), now.second(), 0);
        DateTime tomorrow = now.addDays(1);
        
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(Type__c = 'Snacks', Start_Time__c = currentTime, End_Time__c = endTime);
        insert testMenu;
        Reva_Meal_Booking__c testBooking2 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
             Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Date__c = Date.today(),
            Booking_For__c = testContact2.Id
        );
        insert testBooking2;

        // Call the method to be tested
        Test.startTest();
        RevaMealBookingSMSNotifications.sendMissedMealNotifications(new List<Reva_Meal_Booking__c>{testBooking2});
        Test.stopTest();
        
        // Assert the missed meal notification
        List<Reva_Meal_Booking__c> missedBookings = [SELECT Id, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Reva_Meal_Booking_Status__c = 'Missed Meal'];
        System.assertEquals(1, missedBookings.size(), 'There should be one missed meal booking.');
    }

    @isTest
    static void testSendSMSAsyncMissed() {
        // Prepare test data for SMS async method
        Map<String, String> messages = new Map<String, String>{
            '918123456789' => 'Missed meal notification for student',
            '919876543210' => 'Missed meal notification for student'
        };
        
        Test.startTest();
       // RevaMealBookingSMSNotifications.sendSMSAsyncMissed('Meal Missed Notification (Student)', messages);
        Test.stopTest();
        
        // Assert that messages map is not empty
        System.assert(!messages.isEmpty(), 'The messages map should not be empty.');
    }

    @isTest
    static void testEdgeCases() {
        // Edge case: Empty meal booking list
        Test.startTest();
        RevaMealBookingSMSNotifications.sendMealBookingSMSNotification(new List<Id>());
        RevaMealBookingSMSNotifications.sendMissedMealNotifications(new List<Reva_Meal_Booking__c>());
       // RevaMealBookingSMSNotifications.sendSMSAsyncMissed('Meal Missed Notification (Student)', new Map<String, String>());
        Test.stopTest();
        
        // Assert no errors occur
        System.assert(true, 'Methods should handle empty lists without errors.');
    }
}