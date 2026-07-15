/*@istest
public class RevaMealBookingWhatsAppNotificationsTest {
    Public class RestMock implements HttpCalloutMock {
       public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }  
     Public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = '{"unicode":"False","sender":"REVAUN","message":{"text":"Dear Applicant\r\n\r\nMake a payment of Rs. 8000.00 to confirm your Provisional Admission at https:/\r\neva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId=0030T00000VQx7FQAT&isPAF=true&stupayid=a1P0T000001WIxSUAW.\r\nIn case of confusion connect with your admission counsellor.\r\n\r\nRegards\r\nREVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
        HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
        return res;
    }
   }
@isTest
static void testSendMealBookingWhatsAppNotification() {
    Test.setMock(HttpCalloutMock.class, new RestMock());
    // Create test data
    DateTime now = DateTime.now();
    Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);  
    Time endTime = Time.newInstance(now.hour() + 1, now.minute(), now.second(), 0);  // Set end time to one hour later
    DateTime tomorrow = now.addDays(1);
    
    Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(Type__c = 'Snacks', Start_Time__c = currentTime, End_Time__c = endTime);
    insert testMenu;
    
    Contact testContact = new Contact(LastName = 'Test Contact', MobilePhone = '1234567890', Email = 'test@example.com');
    insert testContact;
    
    Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
        Reva_Meal_Booking_Status__c = 'Booked',
        Reva_Meal_Booking_Date__c = tomorrow.date(),  // Use tomorrow's date
        Booking_For__c = testContact.Id,
        Reva_Mess_Menu__c = testMenu.Id
    );
    insert testBooking1;
    
    Reva_Meal_Booking__c testBooking2 = new Reva_Meal_Booking__c(
        Reva_Meal_Booking_Status__c = 'Missed Meal',
        Reva_Meal_Booking_Date__c = tomorrow.date(),  // Use tomorrow's date
        Booking_For__c = testContact.Id,
        Reva_Mess_Menu__c = testMenu.Id
    );
    insert testBooking2;
    
    Case cs = new Case();
    cs.ContactId = testContact.Id;
    cs.Hostel_Category__c = 'Maintenance';
    cs.Hostel_Sub_Category__c = 'Electrical';    
    cs.Description__c = 'issue';
    cs.Status = 'New';
    insert cs;
    
    Reva_Hostel_Request__c revahostel = new Reva_Hostel_Request__c();
    revahostel.Hostel_Room_Request_For__c = testContact.Id;
    revahostel.Type__c = '1';
    insert revahostel;
    
   // Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    // Call the method to be tested
    List<Id> mealBookingIds = new List<Id>{testBooking1.Id, testBooking2.Id};
    List<String> recordIds = new List<String>();
    recordIds.add(revahostel.Id);
    RevaMealBookingWhatsAppNotifications.sendMealBookingWhatsAppNotification(mealBookingIds);
    // RoomAllocationWhatsAppNotifications.sendRoomAllotedWhatsAppNotification(recordIds);
    RevaMealBookingSMSNotifications.sendMealBookingSMSNotification(mealBookingIds);
    Test.stopTest();
}
  
}*/

/*********************************************************/
@isTest
public class RevaMealBookingWhatsAppNotificationsTest {
    Public class RestMock implements HttpCalloutMock {
       public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }  

    Public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"False","sender":"REVAUN","message":{"text":"Dear Applicant\r\n\r\nMake a payment of Rs. 8000.00 to confirm your Provisional Admission at https:/\r\neva-university--couat1908.sandbox.my.site.com/Admissions/s/payment-page?contactId=0030T00000VQx7FQAT&isPAF=true&stupayid=a1P0T000001WIxSUAW.\r\nIn case of confusion connect with your admission counsellor.\r\n\r\nRegards\r\nREVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testMissedWhatsappNotificationCallout() {
        Test.setMock(HttpCalloutMock.class, new RestMock());

        // Create test data
        DateTime now = DateTime.now();
        Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);  
        Time endTime = Time.newInstance(now.hour() + 1, now.minute(), now.second(), 0);
        DateTime tomorrow = now.addDays(1);
        
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(Type__c = 'Snacks', Start_Time__c = currentTime, End_Time__c = endTime);
        insert testMenu;
        
        Contact testContact1 = new Contact(LastName = 'Test Contact 1', MobilePhone = '1234567890', Email = 'test1@example.com',Total_missed_meals_this_month__c = 0);
        Contact testContact2 = new Contact(LastName = 'Test Contact 2', MobilePhone = null, Email = 'test2@example.com',Total_missed_meals_this_month__c = 0);  // No mobile number
        insert new List<Contact>{testContact1, testContact2};

        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = tomorrow.date(),
            Booking_For__c = testContact1.Id,
            Reva_Mess_Menu__c = testMenu.Id
        );
        Reva_Meal_Booking__c testBooking2 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = tomorrow.date(),
            Booking_For__c = testContact1.Id,
            Reva_Mess_Menu__c = testMenu.Id
        );
        Reva_Meal_Booking__c testBooking3 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = tomorrow.date(),
            Booking_For__c = testContact2.Id,
            Reva_Mess_Menu__c = testMenu.Id
        );
        insert new List<Reva_Meal_Booking__c>{testBooking1, testBooking2, testBooking3};

        // Mock WhatsApp Notification Template (no DML insert for custom metadata)
        //Test.loadData(WhatsApp_Notification_Template__mdt.sObjectType, 'WhatsApp_Notification_Template_TestData');

        Test.startTest();
        
        // Call the method to be tested
        List<Id> mealBookingIds = new List<Id>{testBooking1.Id, testBooking2.Id, testBooking3.Id};
        RevaMealBookingWhatsAppNotifications.MissedWhatsappNotificationCallout(mealBookingIds);
        RevaMealBookingWhatsAppNotifications.sendMealBookingWhatsAppNotification(mealBookingIds);
        // RoomAllocationWhatsAppNotifications.sendRoomAllotedWhatsAppNotification(recordIds);
        //RevaMealBookingSMSNotifications.sendMealBookingSMSNotification(mealBookingIds);
       // RevaMealBookingSMSNotifications.sendMissedMealNotifications(new List<Reva_Meal_Booking__c>{ mealBookingIds});

        Test.stopTest();

        // Assert that callouts were made successfully
        List<Reva_Meal_Booking__c> missedBookings = [SELECT Id, Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Reva_Meal_Booking_Status__c = 'Missed Meal'];
        System.assertEquals(2, missedBookings.size(), 'There should be two missed meal bookings');
        
        // Assert that no notification was sent for contact without a mobile number
        List<Reva_Meal_Booking__c> bookingsWithoutPhone = [SELECT Id FROM Reva_Meal_Booking__c WHERE Booking_For__r.MobilePhone = null];
        System.assertEquals(1, bookingsWithoutPhone.size(), 'One booking should have no mobile phone associated');
    }
}
/******************************************************************/
/*@isTest
public class RevaMealBookingWhatsAppNotificationsTest {

    // Mock class for WhatsApp callout
    public class WhatsAppMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"WhatsApp notification sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock class for SMS callout
    public class SMSMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"SMS notification sent successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendNotifications() {
        // Set mocks for WhatsApp and SMS notifications
        Test.setMock(HttpCalloutMock.class, new WhatsAppMock());
        Test.setMock(HttpCalloutMock.class, new SMSMock());

        // Create test data
        DateTime now = DateTime.now();
        Time currentTime = Time.newInstance(now.hour(), now.minute(), now.second(), 0);
        Time endTime = Time.newInstance(now.hour() + 1, now.minute(), now.second(), 0);
        DateTime tomorrow = now.addDays(1);

        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Type__c = 'Snacks',
            Start_Time__c = currentTime,
            End_Time__c = endTime
        );
        insert testMenu;

        Contact testContactWithPhone = new Contact(LastName = 'Test Contact 1', MobilePhone = '1234567890', Email = 'test1@example.com');
        Contact testContactWithoutPhone = new Contact(LastName = 'Test Contact 2', MobilePhone = null, Email = 'test2@example.com');
        insert new List<Contact>{testContactWithPhone, testContactWithoutPhone};

        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = tomorrow.date(),
            Booking_For__c = testContactWithPhone.Id,
            Reva_Mess_Menu__c = testMenu.Id
        );
        Reva_Meal_Booking__c testBooking2 = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = tomorrow.date(),
            Booking_For__c = testContactWithoutPhone.Id,
            Reva_Mess_Menu__c = testMenu.Id
        );
        insert new List<Reva_Meal_Booking__c>{testBooking1, testBooking2};

        Test.startTest();

        // Call the methods to send notifications
        List<Id> mealBookingIds = new List<Id>{testBooking1.Id, testBooking2.Id};
        RevaMealBookingWhatsAppNotifications.MissedWhatsappNotificationCallout(mealBookingIds);
        RevaMealBookingSMSNotifications.sendMealBookingSMSNotification(mealBookingIds);

        Test.stopTest();

        // Assert that callouts were made only for the contact with a mobile number
        List<Reva_Meal_Booking__c> missedBookings = [
            SELECT Id, Reva_Meal_Booking_Status__c 
            FROM Reva_Meal_Booking__c 
            WHERE Reva_Meal_Booking_Status__c = 'Missed Meal'
        ];
        System.assertEquals(2, missedBookings.size(), 'There should be two missed meal bookings');

        List<Reva_Meal_Booking__c> bookingsWithPhone = [
            SELECT Id 
            FROM Reva_Meal_Booking__c 
            WHERE Booking_For__r.MobilePhone != null
        ];
        System.assertEquals(1, bookingsWithPhone.size(), 'Only one booking should have a mobile phone associated');

        List<Reva_Meal_Booking__c> bookingsWithoutPhone = [
            SELECT Id 
            FROM Reva_Meal_Booking__c 
            WHERE Booking_For__r.MobilePhone = null
        ];
        System.assertEquals(1, bookingsWithoutPhone.size(), 'One booking should have no mobile phone associated');
    }
}*/