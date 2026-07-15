@IsTest
private class RevaMealBookingControllerTest {
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testFetchMealMenus() {
        // Setup test data
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Test method
        Test.startTest();
        List<Reva_Mess_Menu__c> result = RevaMealBookingController.fetchMealMenus();
        Test.stopTest();
        
        // Validate results
        /*System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(1, result.size(), 'The result size should be 1.');
        System.assertEquals(menu.Id, result[0].Id, 'The returned menu ID should match the inserted menu.');*/
    }
    
    @isTest
    static void testGetStudentDetails() {
        // Setup test data
       User adminUser = [SELECT Id, UserRoleId, IsActive FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL AND IsActive = TRUE LIMIT 1];

        // User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com',AccountId = testAccount.Id);
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
        
        System.runAs(user) {
            Student_Fee__c fee = new Student_Fee__c(
                Contact__c = contact.Id,
                Amount_Pending__c = 100,
                Fee_Type__c = 'Hostel Fee',
                Name = 'Hostel Fee'
            );
            insert fee;
            
            // Debugging to check the ContactId
            System.debug('User ContactId: ' + user.ContactId);
            System.debug('Inserted Fee Record: ' + fee);
            
            // Test method with user context
            Test.startTest();
            List<Student_Fee__c> result = RevaMealBookingController.getStudentDetails();
           
            Test.stopTest();
            
            // Debugging to check the query result
            System.debug('Result from getStudentDetails: ' + result);
            
            // Validate results
            System.assertNotEquals(null, result, 'The result should not be null.');
            System.assertEquals(1, result.size(), 'The result size should be 1.');
            System.assertEquals(fee.Id, result[0].Id, 'The returned fee ID should match the inserted fee.');
        }
    }
    
    
    
    @isTest
    static void testInstantMealBooking() {
        // Setup test data
        User adminUser = [SELECT Id, UserRoleId, IsActive FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL AND IsActive = TRUE LIMIT 1];

       // User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com',AccountId = testAccount.Id);
        insert contact;
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User user = new User(
            Username = 'testuserMeal3@example.com',
            FirstName = 'Test3', LastName = 'User',
            Email = 'testusermeal002@example.com',
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
        
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Test method
        Test.startTest();
        Map<String, Object> result = RevaMealBookingController.instantMealBooking(contact.Id);
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assert(result.containsKey('isInstanceMealBookingAvailable'), 'The result should contain the key isInstanceMealBookingAvailable.');
        System.assertEquals(true, result.get('isInstanceMealBookingAvailable'), 'Instant meal booking availability should be true.');
    }
    
    @isTest
    static void testFetchContactsForBooking() {
        // Get Record Type IDs
        Id studentRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Student' LIMIT 1].Id;
        Id nonTeachingRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1].Id;
        Id professorRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1].Id;
        
        // Setup test data
        Contact studentContact = new Contact(
            FirstName = 'Student', 
            LastName = 'User', 
            Email = 'teststudent@example.com',
            RecordTypeId = studentRecordTypeId // Set the Record Type ID
        );
        insert studentContact;
        
        Contact nonTeachingContact = new Contact(
            FirstName = 'NonTeaching', 
            LastName = 'User',
            RecordTypeId = nonTeachingRecordTypeId // Set the Record Type ID
        );
        insert nonTeachingContact;
        
        Contact professorContact = new Contact(
            FirstName = 'Professor', 
            LastName = 'User',
            RecordTypeId = professorRecordTypeId // Set the Record Type ID
        );
        insert professorContact;
        
        // Test method
        Test.startTest();
        List<Contact> result = RevaMealBookingController.fetchContactsForBooking('Student');
        //  List<Contact> result = RevaMealBookingController.fetchContactsForBooking();
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
       // System.assert(!result.isEmpty(), 'The result list should not be empty.');
      //  System.assertEquals(studentContact.Id, result[0].Id, 'The returned contact ID should match the inserted student contact.');
    }
    
    
    
    @isTest
    static void testFetchMealsAvailable() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Set up test data
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1,
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Type__c = 'Breakfast'
        );
        insert testMenu;
        
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        Reva_Meal_Booking__c testBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert testBooking;
        
        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert testBooking1;
        
        List<Reva_Meal_Booking__c> rmbLst = new List<Reva_Meal_Booking__c>();
        rmbLst.add(testBooking);
         rmbLst.add(testBooking1);
        
        // Test method
        Test.startTest();
        InvalidStatusUpdater queueableJob = new InvalidStatusUpdater(testBooking.id, 'Invalid');
        System.enqueueJob(queueableJob);
        RevaMealBookingController.MealInfoWrapper result = RevaMealBookingController.fetchMealsAvailable();
        Test.stopTest();
        
        // Add assertions to validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assert(result.mealMenuDetails != null, 'MealMenuDetails should not be null.');
        System.assert(result.mealMenuDetails.size() > 0, 'There should be at least one meal menu detail.');
        System.assert(result.showError == false, 'showError should be false.');
        System.assert(result.showWarning == false, 'showWarning should be false.');
    }
    
        @isTest
    static void testFetchMealsAvailable2() {
        
      
  Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Set up test data
       Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = Date.today() - 1,
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(11, 0, 0, 0),
            Type__c = 'Breakfast'
        );
        insert testMenu;
        
        
        Reva_Mess_Menu_Items__c	testMenuItem = New Reva_Mess_Menu_Items__c(
        Name = 'Test',
        Reva_Mess_Menu__c = testMenu.Id
        );
        insert testMenuItem;
        
        Contact testContact = new Contact(LastName = 'Test', FirstName = 'User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        Reva_Meal_Booking__c testBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert testBooking;
        
        Reva_Meal_Booking__c testBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = testMenu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert testBooking1;
        
        List<Reva_Meal_Booking__c> rmbLst = new List<Reva_Meal_Booking__c>();
        rmbLst.add(testBooking);
         rmbLst.add(testBooking1);
        
        // Test method
        Test.startTest();
        RevaMealBookingController.MealInfoWrapper result = RevaMealBookingController.fetchMealsAvailable();
        Test.stopTest();
        
        // Add assertions to validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assert(result.mealMenuDetails != null, 'MealMenuDetails should not be null.');
      
    }
    
 
   @isTest
static void testBookMeal() {
    // Create Contact
    Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
    insert contact;

    // Create Test User (with Contact linked)
    Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];

    User testUser = new User(
        FirstName = 'Test',
        LastName = 'User',
        Username = 'testusermeal@example.com',
        Email = 'testuser@example.com',
        ContactId = contact.Id,
        ProfileId = studentProfile.Id,
        Alias = 'tuser',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US'
    );
    insert testUser;

    // Create a Reva_Mess_Menu__c record
    Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
        Date__c = Date.today(),
        Type__c = 'Lunch',
        Start_Time__c = Time.newInstance(1, 0, 0, 0),      // 1:00 AM
        End_Time__c = Time.newInstance(23, 45, 0, 0)       // 11:45 PM
    );
    insert menu;

    // Run the test logic as the testUser
    System.runAs(testUser) {
        Test.startTest();

        // Call method being tested
        Boolean result = RevaMealBookingController.bookMeal(new List<Id>{menu.Id});

        Test.stopTest();

        // You can assert true or false depending on your data/logic
        System.assertEquals(true, result, 'Meal should be booked successfully');
    }
}

    
     @isTest
    static void testBookMeal2() {
       
        
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
       /* Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Booking_For__c = contact.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert mealBooking; */
        
        // Test method
        Test.startTest();
        Boolean result = RevaMealBookingController.bookMeal(new List<Id>{menu.Id});
        Test.stopTest();
        
        // Validate results
        System.assertequals(result, false);
    }
    
    @isTest
    static void testUpdateMealStatus() {
        // Setup test data
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Insert a meal booking record for testing
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert mealBooking;
        
        // Test method
        Test.startTest();
        RevaMealBookingController.updateMealStatus(mealBooking.Id, 'Availed',null); 
         RevaMealBookingController.invalidStatus(mealBooking.Id, 'Invalid'); 
         RevaMealBookingController.SuccessStatus(mealBooking.Id, 'QrSuccess'); 
        RevaMealBookingController.FailedStatus(mealBooking.Id, 'QrFailed'); 
         RevaMealBookingController.hascheckUpdated(mealBooking.Id);
        Test.stopTest();
        
        // Verify the status was updated
        Reva_Meal_Booking__c updatedBooking = [SELECT Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Id = :mealBooking.Id];
        System.assertEquals('Availed', updatedBooking.Reva_Meal_Booking_Status__c, 'The meal booking status should be updated to Confirmed.');
    }
    
    static testMethod void testSuccessfulScan() {
         Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(1, 0, 0, 0),       // 1:00 AM
           End_Time__c   = Time.newInstance(23, 45, 0, 0)  
        );
        insert menu;
        // Setup: Create meal booking with future end time
        Reva_Meal_Booking__c meal = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Mess_Menu__c = menu.Id
        );
        insert meal;

        Test.startTest();
        String result = RevaMealBookingController.updateMealStatus(meal.Id, 'Availed',DateTime.now().getTime());
        Test.stopTest();

        System.assertEquals('Success: QR Code Scanned Successfully!', result);
        Reva_Meal_Booking__c updated = [SELECT Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Id = :meal.Id];
        System.assertEquals('Availed', updated.Reva_Meal_Booking_Status__c);
    }

    static testMethod void testAlreadyAvailedOrMissed() {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User user = new User(
            FirstName = 'Test1', 
            LastName = 'User',
            Username = 'testusermeal@example.com',
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
         Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() , 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
       // for (String status : new List<String>{'Availed', 'Missed meal', 'Cancelled'}) {
            Reva_Meal_Booking__c meal = new Reva_Meal_Booking__c(
                Reva_Meal_Booking_Status__c = 'Availed',
                 Reva_Mess_Menu__c = menu.Id ,
                Booking_For__c = contact.Id
            );
            insert meal;

            Test.startTest();
            String result = RevaMealBookingController.updateMealStatus(meal.Id, 'Availed',DateTime.now().getTime());
            Test.stopTest();

            System.assertEquals('Error: QR Code Already Scanned for this Meal or Cancelled.', result);
       // }
    }

    static testMethod void testExpiredQRScan() {
         Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(1, 0, 0, 0),
            End_Time__c =  Time.newInstance(1, 30, 0, 0)
        );
        insert menu;
        Reva_Meal_Booking__c expiredMeal = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Mess_Menu__c = menu.Id
        );
        insert expiredMeal;

        Test.startTest();
        String result = RevaMealBookingController.updateMealStatus(expiredMeal.Id, 'Availed',DateTime.now().getTime());
        Test.stopTest();

        System.assertEquals('Error: QR Code Expired for this meal / Meal time Ended.', result);
    }

    static testMethod void testCancelBooking() {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User user = new User(
            FirstName = 'Test1', 
            LastName = 'User',
            Username = 'testusermeal@example.com',
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
         Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(), 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        Reva_Meal_Booking__c meal = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Mess_Menu__c = menu.Id,
            Booking_For__c = contact.Id
        );
        insert meal;

        Test.startTest();
        String result = RevaMealBookingController.updateMealStatus(meal.Id, 'Cancelled',DateTime.now().getTime());
        Test.stopTest();

        System.assertEquals('Success: Your meal has been successfully cancelled.', result);
    }

    static testMethod void testMealAlreadyCancelled() {
         Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() , 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        Reva_Meal_Booking__c meal = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Cancelled',
            Reva_Mess_Menu__c = menu.Id       );
        insert meal;

        Test.startTest();
        String result = RevaMealBookingController.updateMealStatus(meal.Id, 'Cancelled',DateTime.now().getTime());
        Test.stopTest();

        System.assertEquals('Success: Meal already cancelled.', result);
    }

    static testMethod void testInvalidRecordId() {
        Test.startTest();
        String result = RevaMealBookingController.updateMealStatus('001000000000000AAA', 'Availed',DateTime.now().getTime()); // fake ID
        Test.stopTest();

        System.assert(result.startsWith('Error:'), 'Should return error for invalid ID.');
    }
    
    @isTest
    static void testUpdateFeedbackBookedmeal() {
        // Setup test data
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today() + 1, 
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Insert a meal booking record for testing
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert mealBooking;
        
        // Test method with all required parameters
        Test.startTest();
        List<Reva_Meal_Booking__c> result = RevaMealBookingController.updateFeedbackBookedmeal(
            mealBooking.Id, 
            '😊', 
            'Great Meal', 
            'The meal was excellent.', 
            '5'
        );
        Test.stopTest();
        
        // Validate results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(1, result.size(), 'The result size should be 1.');
        Reva_Meal_Booking__c updatedMealBooking = [SELECT Meal_Feedback__c, Rating__c FROM Reva_Meal_Booking__c WHERE Id = :mealBooking.Id];
        System.assertEquals('😊 Great Meal The meal was excellent.', updatedMealBooking.Meal_Feedback__c, 'The feedback field should be updated.');
        System.assertEquals('5', updatedMealBooking.Rating__c, 'The rating should be updated to 5.');
    }
    
    /***********************************************************/
  /*  @isTest
    static void testCancelMealSuccess() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Setup test data
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        
        // Create a Reva_Mess_Menu__c record
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today().addDays(1),  // Future date to ensure it's cancellable
            Type__c = 'Lunch', 
           Start_Time__c = Time.newInstance(1, 0, 0, 0),       // 1:00 AM
           End_Time__c   = Time.newInstance(23, 45, 0, 0)      // 11:45 PM

        );
        insert menu;
        
        // Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c booking = new Reva_Meal_Booking__c(
            Booking_For__c = contact.Id,
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today().addDays(1)
        );
        insert booking;
        
        // Test the cancelMeal method
        Test.startTest();
        List<Id> messMenuIds = new List<Id>{menu.Id};
            RevaMealBookingController.CancelMealWrapper result = RevaMealBookingController.cancelMeal(messMenuIds);
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.cancelSuccess, 'The meal should be successfully cancelled');
        System.assert(!result.showWarning, 'There should be no warning');
        System.assert(!result.showError, 'There should be no error');
       // System.assertEquals('Booked', [SELECT Reva_Meal_Booking_Status__c FROM Reva_Meal_Booking__c WHERE Id = :booking.Id].Reva_Meal_Booking_Status__c);
    }
    
    @isTest
    static void testCancelMealFailureDueToTimeExceeded() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Setup test data
        Contact contact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'srinivaschundru@yopmail.com');
        insert contact;
        
        // Create a Reva_Mess_Menu__c record
        Reva_Mess_Menu__c menu = new Reva_Mess_Menu__c(
            Date__c = Date.today(),  // Today's date
            Type__c = 'Lunch', 
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0)
        );
        insert menu;
        
        // Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c booking = new Reva_Meal_Booking__c(
            Booking_For__c = contact.Id,
            Reva_Mess_Menu__c = menu.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today()
        );
        insert booking;
        
        // Test the cancelMeal method (Time exceeded scenario)
        Test.startTest();
        List<Id> messMenuIds = new List<Id>{menu.Id};
            RevaMealBookingController.CancelMealWrapper result = RevaMealBookingController.cancelMeal(messMenuIds);
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        
    }
    
    @isTest
    static void testCancelMealExceptionHandling() {
        // Test data setup that will cause an exception
       // List<Id> invalidMessMenuIds = new List<Id>{'a3QIl00000001BKMAY'};
            Reva_Mess_Menu__c todayMenu = new Reva_Mess_Menu__c(
            Date__c = System.today(),
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 1',
            Mess_Items__c = 'Bread'
        );
        insert todayMenu;
            
            // Test the cancelMeal method (Exception handling)
            Test.startTest();
        RevaMealBookingController.CancelMealWrapper result = RevaMealBookingController.cancelMeal(new list<Id>{todayMenu.Id});
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.showError, 'An error should be shown due to exception');
        //System.assertEquals('Some Exception Occured.', result.message);
        //System.assert(!result.cancelSuccess, 'The meal should not be cancelled');
    } */
    
    
    /*******************************************************/
    @isTest
    static void testFeebackForBookedMeals() {
        // Test data setup
        Id contactId = createTestContact();
        Id messMenuId = createTestMessMenu();
        
        // Create a Reva_Meal_Booking__c record for today with status 'Availed'
        Reva_Meal_Booking__c mealBookingToday = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuId,
            Reva_Meal_Booking_Status__c = 'Availed',
            Reva_Meal_Booking_Date__c = Date.today()
        );
        insert mealBookingToday;
        
        // Create a Reva_Meal_Booking__c record for yesterday with status 'Availed'
        Reva_Meal_Booking__c mealBookingYesterday = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuId,
            Reva_Meal_Booking_Status__c = 'Availed',
            Reva_Meal_Booking_Date__c = Date.today().addDays(-1)
        );
       
        try {
        insert mealBookingYesterday;
    } catch (DmlException e) {
        System.assert(
            e.getMessage().contains('Duplicate meal booking found with the same Menu, Date, Type, and Contact'),
            'Expected validation error was not found in the exception message.'
        );
    }
        
        // Test the feebackForBookedMeals method
        Test.startTest();
        List<RevaMealBookingController.BookedMealInfoWrapper> result = RevaMealBookingController.feebackForBookedMeals();
        Test.stopTest();
        
        // Debugging information
        System.debug('Result size: ' + result.size());
        for (RevaMealBookingController.BookedMealInfoWrapper wrapper : result) {
            System.debug('Wrapper: ' + wrapper);
        }
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        ///System.assertEquals(2, result.size(), 'There should be 2 booked meals in the result');
        
        for (RevaMealBookingController.BookedMealInfoWrapper wrapper : result) {
            System.assertEquals(contactId, wrapper.booking.Booking_For__c, 'Booking should be associated with the correct contact');
            System.assertEquals('Availed', wrapper.booking.Reva_Meal_Booking_Status__c, 'Booking status should be Availed');
        }
    }
    
    // Helper method to create a test Contact
    private static Id createTestContact() {
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        return testContact.Id;
    }
    
    // Helper method to create a test Reva_Mess_Menu__c record
    private static Id createTestMessMenu() {
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = Date.today(),
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Set the start time to 12:00 PM
            End_Time__c = Time.newInstance(14, 0, 0, 0),   // Set the end time to 2:00 PM
            Type__c = 'Lunch'
        );
        insert testMenu;
        return testMenu.Id;
    }
    /***********************************************************/
    @isTest
    static void testFetchBookedMealsForTodayTomorrow() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Test data setup
        Id contactId = createTestContact1();
        Id messMenuIdToday = createTestMessMenu(Date.today());
        Id messMenuIdTomorrow = createTestMessMenu(Date.today().addDays(1));
        
        // Create a Reva_Meal_Booking__c record for today with status 'Booked'
        Reva_Meal_Booking__c mealBookingToday = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuIdToday,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today()
        );
        insert mealBookingToday;
        
        // Create a Reva_Meal_Booking__c record for tomorrow with status 'Booked'
        Reva_Meal_Booking__c mealBookingTomorrow = new Reva_Meal_Booking__c(
            Booking_For__c = contactId,
            Reva_Mess_Menu__c = messMenuIdTomorrow,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = Date.today().addDays(1)
        );
        insert mealBookingTomorrow;
        
        // Test the fetchBookedMealsForTodayTomorrow method
        Test.startTest();
        List<RevaMealBookingController.BookedMealInfoWrapper> result = RevaMealBookingController.fetchBookedMealsForTodayTomorrow();
        Test.stopTest();
        
        // Assert the results
        System.assert(result != null, 'Result should not be null');
        System.debug('Result size: ' + result.size());
        
        if (!result.isEmpty()) {
            RevaMealBookingController.BookedMealInfoWrapper wrapper = result[0];
            System.assertEquals('Booked', wrapper.booking.Reva_Meal_Booking_Status__c, 'Booking status should be Booked');
            System.assertEquals(messMenuIdToday, wrapper.booking.Reva_Mess_Menu__c, 'Booking should be associated with today\'s menu');
            
            // Check if cancel is disabled based on the booking time
            Datetime compare = Datetime.newInstance(wrapper.booking.Reva_Mess_Menu__r.Date__c, wrapper.booking.Reva_Mess_Menu__r.Start_Time__c);
            Boolean expectedDisableCancel = DateTime.now() >= compare.addHours(-6);
            //System.assertEquals(expectedDisableCancel, wrapper.disableCancel, 'disableCancel flag should be correctly set');
        } else {
            System.debug('Result is empty');
        }
    }
    
    // Helper method to create a test Contact
    private static Id createTestContact1() {
        Contact testContact = new Contact(
            LastName = 'TestContact',
            Email = 'srinivaschundru@yopmail.com'
        );
        insert testContact;
        return testContact.Id;
    }
    
    // Helper method to create a test Reva_Mess_Menu__c record
    private static Id createTestMessMenu(Date menuDate) {
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = menuDate,
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Set the start time to 12:00 PM
            End_Time__c = Time.newInstance(14, 0, 0, 0),   // Set the end time to 2:00 PM
            Type__c = 'Lunch'
        );
        insert testMenu;
        return testMenu.Id;
    }
    /***********************************************************/
    @isTest
    static void testMissedMealsByTheUser() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Test data setup
        Contact testContact = new Contact(
            LastName = 'Test',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        
        // Get the first day of the current month
        Date firstDayOfMonth = Date.today().toStartOfMonth();
        
        // Create a "Missed Meal" booking for the first day of the month
        Reva_Meal_Booking__c missedMealBooking1 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = createTestMessMenu(firstDayOfMonth), // Assuming you have a helper method for this
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = firstDayOfMonth
        );
        insert missedMealBooking1;
        
        // Create another "Missed Meal" booking for a date within the current month
        Reva_Meal_Booking__c missedMealBooking2 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = createTestMessMenu(firstDayOfMonth.addDays(5)), // Assuming you have a helper method for this
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Meal_Booking_Date__c = firstDayOfMonth.addDays(5)
        );
        insert missedMealBooking2;
        
         Reva_Meal_Booking__c missedMealBooking22 = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Mess_Menu__c = createTestMessMenu(firstDayOfMonth.addDays(5)), // Assuming you have a helper method for this
            Reva_Meal_Booking_Status__c = 'Availed'
        );
        insert missedMealBooking22;
        
        // Run the test
        Test.startTest();
        Integer missedMeals = RevaMealBookingController.missedMealsByTheUser();
        RevaMealBookingController.hasStatusUpdated(missedMealBooking22.Id);
        Test.stopTest();
        
        // Assert the result
        //System.assertEquals(2, missedMeals, 'There should be 2 missed meals for the current month');
    }
    
    // Assuming you have a helper method to create Reva_Mess_Menu__c records
    private static Id createTestMessMenu3(Date menuDate) {
        Reva_Mess_Menu__c testMenu = new Reva_Mess_Menu__c(
            Date__c = menuDate,
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Set the start time to 12:00 PM
            End_Time__c = Time.newInstance(14, 0, 0, 0),   // Set the end time to 2:00 PM
            Type__c = 'Lunch'
        );
        insert testMenu;
        return testMenu.Id;
    }

    @isTest
    static void testIfUserOnLeave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
           Reva_Hostel_Room__c Room = new Reva_Hostel_Room__c(
            Name = '102',  // Required field
            Block__c = 'A',
            Floor__c = 'SF',
            Maximum_Occupancy__c = '4',
            Room_Type__c = 'Student',
            Dormitory_Type__c = 'Boys',
            Room_Category__c = 'Eng CS',
            Is_Premium__c = false
        );
        insert Room;
         Reva_Hostel_Request__c initialRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_Room__c = room.Id,
            Status__c = 'Room Allotted',
            Type__c = '1'
        );
        insert initialRequest;
        // Create test REVA_Hostel_Leave_Request__c records
        Date today = Date.today();
        DateTime dtToday = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        DateTime dtTomorrow = dtToday.addDays(1);
        DateTime dtEndSoon = dtToday.addHours(1);
        DateTime dtStartSoon = dtToday.addDays(-2);
        
        REVA_Hostel_Leave_Request__c leaveRequestDuringMeal = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = dtStartSoon,
            End_Date_and_Time__c = dtTomorrow,
            Status__c = 'Approved',
            Contact__c = testContact.Id
        );
        insert leaveRequestDuringMeal;
        
        REVA_Hostel_Leave_Request__c leaveRequestEndingSoon = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = dtStartSoon,
            End_Date_and_Time__c = dtEndSoon,
            Status__c = 'Approved',
            Contact__c = testContact.Id
        );
        insert leaveRequestEndingSoon;
        
        REVA_Hostel_Leave_Request__c leaveRequestPast = new REVA_Hostel_Leave_Request__c(
            Start_Date_and_Time__c = dtStartSoon.addDays(-10),
            End_Date_and_Time__c = dtStartSoon.addDays(-5),
            Status__c = 'Approved',
            Contact__c = testContact.Id
        );
        insert leaveRequestPast;
        
        // Scenario 1: User is on leave during mealDateTime
        Test.startTest();
        Integer result = RevaMealBookingController.ifUserOnLeave(dtToday.date()); // Ensure to pass Date if method signature expects Date
        Test.stopTest();
        //System.assertEquals(1, result, 'User should not be allowed to book meals during leave.');
        
        // Scenario 2: User's leave ending within 24 hours, and mealDateTime is after leave end time
        //Test.startTest();
        result = RevaMealBookingController.ifUserOnLeave(dtTomorrow.date());
        //Test.stopTest();
        System.assertEquals(0, result, 'User should be allowed to book meals after leave end time.');
        
        // Scenario 3: User's leave ending within 24 hours, and mealDateTime is before leave end time
        //Test.startTest();
        result = RevaMealBookingController.ifUserOnLeave(dtToday.date());
        //Test.stopTest();
        //System.assertEquals(1, result, 'User should not be allowed to book meals before leave end time.');
        
        // Scenario 4: No leave records for the user
        //Test.startTest();
        // Remove all leave requests
        delete new List<REVA_Hostel_Leave_Request__c>{leaveRequestDuringMeal, leaveRequestEndingSoon, leaveRequestPast};
            
            result = RevaMealBookingController.ifUserOnLeave(dtToday.date());
        //Test.stopTest();
        System.assertEquals(0, result, 'User should be allowed to book meals when no leave records are found.');
        
        // Clean up test Contact
        delete testContact;
    }
    
    /***********************************************************/
    @isTest
    static void testGetMessMenuItems() {
        // Create a test Mess Menu record
        Reva_Mess_Menu__c testMessMenu = new Reva_Mess_Menu__c(
            Mess_Items__c ='Bread',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Type__c = 'Breakfast'
        );
        insert testMessMenu;
        
        // Call the getMessMenuItems method with the testMessMenu Id
        Test.startTest();
        List<Reva_Mess_Menu__c> result = RevaMealBookingController.getMessMenuItems(testMessMenu.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result should contain one item');
        System.assertEquals(testMessMenu.Id, result[0].Id, 'The returned item should have the same Id as the test record');
        System.assertEquals('Bread', result[0].Mess_Items__c, 'The Mess_Items__c should match the test data');
        System.assertEquals(testMessMenu.Start_Time__c, result[0].Start_Time__c, 'The Start_Time__c should match the test data');
        System.assertEquals(testMessMenu.End_Time__c, result[0].End_Time__c, 'The End_Time__c should match the test data');
        System.assertEquals('Breakfast', result[0].Type__c, 'The Type__c should match the test data');
        
        // Clean up the test data
        delete testMessMenu;
    }
    
    /************************************************************/
    @isTest
    static void testBookAndFetchMeals() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com'
        );
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records for today, yesterday, and tomorrow
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date nextDate = today.addDays(1);
        
        Reva_Mess_Menu__c todayMenu = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 1',
            Mess_Items__c = 'Bread'
        );
        insert todayMenu;
        
        Reva_Mess_Menu__c nextDayMenu = new Reva_Mess_Menu__c(
            Date__c = nextDate,
            Type__c = 'Breakfast',
            Start_Time__c = Time.newInstance(7, 0, 0, 0),
            End_Time__c = Time.newInstance(8, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 2',
            Mess_Items__c = 'Bread'
        );
        insert nextDayMenu;
        
        Reva_Mess_Menu__c yesterdayMenu = new Reva_Mess_Menu__c(
            Date__c = yesterday,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            // Reva_Mess__c = 'Reva Mess 3',
            Mess_Items__c = 'Bread'
        );
        insert yesterdayMenu;
        
        // Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Mess_Menu__c = todayMenu.Id,
            Booking_For__c = testContact.Id
        );
        try {
        insert mealBooking;
       // System.assert(false, 'Expected DmlException due to duplicate booking, but insert succeeded.');
    } catch (DmlException e) {
        System.assert(
            e.getMessage().contains('Duplicate meal booking found with the same Menu, Date, Type, and Contact'),
            'Expected validation error was not found in the exception message.'
        );
    }
        
        // Mock the getRevaMessMenuIds method to return the created menu Ids
        Test.startTest();
        List<Id> menuIds = new List<Id>{todayMenu.Id, nextDayMenu.Id, yesterdayMenu.Id};
            RevaMealBookingController mockController = new RevaMealBookingController();
        // Use @TestVisible annotation in the original class for this method or move this logic to helper class for mocking.
        
        // Call the method and verify the results
        Map<String, List<Object>> result = RevaMealBookingController.bookAndFetchMeals();
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assertEquals(2, result.size(), 'Result map should have two keys: MealsToBook and BookedMeals');
        
        List<Object> mealsToBook = result.get('MealsToBook');
        System.assertEquals(1, mealsToBook.size(), 'MealsToBook list should contain one menu item for the next day');
        
        List<Object> bookedMeals = result.get('BookedMeals');
        //System.assertEquals(1, bookedMeals.size(), 'BookedMeals list should contain one booked meal item');
        
        // Clean up test data
        delete mealBooking;
        delete todayMenu;
        delete nextDayMenu;
        delete yesterdayMenu;
        delete testContact;
    }
    
    /*************************************************************/
    @isTest
    static void testCheckExistingBooking() {
         Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        
        // Create a test Reva_Mess_Menu__c record for today's date
        Date today = Date.today();
        Reva_Mess_Menu__c todayMenu = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            //Reva_Mess__c = 'Reva Mess 1',
            Mess_Items__c = 'Bread'
        );
        insert todayMenu;
        
        // Test case 1: No existing booking for today
        Test.startTest();
        boolean result = RevaMealBookingController.checkExistingBooking(todayMenu.Id, testContact.Id);
        Test.stopTest();
        System.assertEquals(true, result, 'There should be no booking for today, so result should be true.');
        
        // Create a Reva_Meal_Booking__c record to simulate an existing booking for today
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = todayMenu.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked'
        );
        insert mealBooking;
        
        // Test case 2: Existing booking for today
        //Test.startTest();
        result = RevaMealBookingController.checkExistingBooking(todayMenu.Id, testContact.Id);
        //Test.stopTest();
        System.assertEquals(false, result, 'There should be an existing booking for today, so result should be false.');
        
        // Clean up test data
        delete mealBooking;
        delete todayMenu;
        delete testContact;
    }
    
    /*************************************************************/
    @isTest
    static void testFetchBookedMeals() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(
            LastName = 'Test User',
            Email = 'srinivaschundru@yopmail.com '
        );
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture;
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
        List<RevaMealBookingController.BookedMealInfoWrapper> result = RevaMealBookingController.fetchBookedMeals();
        Test.stopTest();
        System.assert(result != null, 'Result should not be null.');
        //System.assertEquals(1, result.size(), 'There should be one booked meal in the result.');
        
        // Check if the result list is not empty before accessing the first element
        if (!result.isEmpty()) {
            System.assertEquals(messMenuFuture.Id, result[0].booking.Reva_Mess_Menu__c, 'The booked meal should match the future menu.');
        } else {
            //System.assert(false, 'Expected booked meal, but none found.');
        }
        
        // Test case 2: No bookings for today or future dates
        delete mealBooking;
        
        //Test.startTest();
        result = RevaMealBookingController.fetchBookedMeals();
        //Test.stopTest();
        System.assert(result != null, 'Result should not be null.');
        System.assertEquals(0, result.size(), 'There should be no booked meals in the result.');
        
        // Clean up test data
        delete messMenuToday;
        delete messMenuFuture;
        delete testContact;
    }
    
    /***************************************************************/
    
    //AddedbyRajshekar checkIfMessAdmin
    /*************************************************************/
    @isTest
    static void testbookMealByMessAdmin() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(LastName = 'Test User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture;
        List<Id> messmenuids = new List<Id>();
        messmenuids.add(messMenuFuture.Id);
        
         Reva_Mess_Menu__c messMenuFuture1 = new Reva_Mess_Menu__c(
            Date__c = futureDate.addDays(1),
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture1;
        List<Id> messmenuids1 = new List<Id>();
        messmenuids1.add(messMenuFuture1.Id);
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
         RevaMealBookingController.bookMealByMessAdmin(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmin(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmin(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmin(messmenuids1,null);
         
        Test.stopTest();

    }
    
    /***************************************************************/
    //AddedbyRajshekar 
    /*************************************************************/
    @isTest
    static void testcheckIfMessAdmin() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(LastName = 'Test User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture;
        List<Id> messmenuids = new List<Id>();
        messmenuids.add(messMenuFuture.Id);
        
         Reva_Mess_Menu__c messMenuFuture1 = new Reva_Mess_Menu__c(
            Date__c = futureDate.addDays(1),
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture1;
        List<Id> messmenuids1 = new List<Id>();
        messmenuids1.add(messMenuFuture1.Id);
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
        insert mealBooking;
        
        // Test case 1: Valid contactId, future booking exists
        Test.startTest();
         RevaMealBookingController.checkIfMessAdmin();
        RevaMealBookingController rb = new RevaMealBookingController();
        rb.sampleDataForTest();
        rb.sampleDataForTest1();
        rb.sampleDataForTest2();
        Test.stopTest();
      
    }
    
     @isTest
    static void testbookMealByMessAdmintestdata() {
          Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Create test Contact record
        Contact testContact = new Contact(LastName = 'Test User',Email = 'srinivaschundru@yopmail.com');
        insert testContact;
        
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date futureDate = today.addDays(1);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuToday;
        
        Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
            Date__c = futureDate,
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture;
        List<Id> messmenuids = new List<Id>();
        messmenuids.add(messMenuFuture.Id);
        
         Reva_Mess_Menu__c messMenuFuture1 = new Reva_Mess_Menu__c(
            Date__c = futureDate.addDays(1),
            Type__c = 'Dinner',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(9, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuFuture1;
        List<Id> messmenuids1 = new List<Id>();
        messmenuids1.add(messMenuFuture1.Id);
        
        // Create test Reva_Meal_Booking__c records
        Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
            Reva_Mess_Menu__c = messMenuFuture.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = today
        );
      Test.startTest();   
        try {
        //insert mealBooking;
          RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmintestmethod(messmenuids1,null);
        
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmintestmethod1(messmenuids1,null);
        
       /*  RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids1,testContact.Id);
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids,null);
         RevaMealBookingController.bookMealByMessAdmintestmethod2(messmenuids1,null); */
    } catch (DmlException e) {
        System.assert(
            e.getMessage().contains('Duplicate meal booking found with the same Menu, Date, Type, and Contact'),
            'Expected validation error was not found in the exception message.'
        );
    }
        
        
        // Test case 1: Valid contactId, future booking exists
       
        
         
        Test.stopTest();

    }
    
    /***********************************************************************/
     @isTest
static void testIsNotStudentRecordType() {
    // Step 1: Retrieve the appropriate RecordType for the Contact
    RecordType nonStudentRecordType = [SELECT Id, Name FROM RecordType WHERE 
        SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
	User adminUser = [SELECT Id, UserRoleId, IsActive FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL AND IsActive = TRUE LIMIT 1];

    //User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
    
    // Step 2: Create a Contact with the fetched non-student RecordType
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@example.com',
        RecordTypeId = nonStudentRecordType.Id,
        AccountId = testAccount.Id
    );
    insert testContact;

    // Step 3: Create a Profile for the test user
    Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];

    // Step 4: Create a User associated with the Contact
    User testUser = new User(
        Username = 'testuser741meal001@example.com',
        LastName = 'Test',
        Email = 'testuser741@example.com',
        Alias = 'testu',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = nonTeachingProfile.Id,
        ContactId = testContact.Id,
        IsActive = true
    );
    insert testUser;

    // Step 5: Create a Student_Fee__c record matching the query criteria
    Student_Fee__c studentFee = new Student_Fee__c(
        Contact__c = testContact.Id,
        Fee_Type__c = 'Missed Meal Fee'
    );
    insert studentFee;

    // Step 6: Start test execution
    Test.startTest();
    System.runAs(testUser) {
        Boolean result = RevaMealBookingController.isNotStudentRecordType();
        System.debug('Is not student record type: ' + result);
        System.assert(result, 'The result should be true since the fee record matches the criteria.');
    }
    Test.stopTest();
}

    /*************************************************************************/
   @isTest
static void testGetMessPenaltyUrl() {
    // Step 1: Retrieve the appropriate RecordType for the Contact
    RecordType nonStudentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
	User adminUser = [SELECT Id, UserRoleId, IsActive FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL AND IsActive = TRUE LIMIT 1];

    //User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
    // Step 2: Create a Contact with the fetched RecordType
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@example.com',
        RecordTypeId = nonStudentRecordType.Id,
        AccountId = testAccount.Id
    );
    insert testContact;

    // Step 3: Create a Profile for the test user
    Profile nonTeachingProfile = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1];

    // Step 4: Create a User associated with the Contact
    User testUser = new User(
        Username = 'testuser741meal006@example.com',
        LastName = 'Test',
        Email = 'testuser741@example.com',
        Alias = 'testu',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = nonTeachingProfile.Id,
        ContactId = testContact.Id,
        IsActive = true
    );
    insert testUser;

    // Step 5: Create a Student_Fee__c record with a related payment
    Student_Fee__c studentFee = new Student_Fee__c(
        Contact__c = testContact.Id,
        Fee_Type__c = 'Missed Meal Fee',
        Amount_Pending__c = 1000.0
    );
    insert studentFee;

    // Step 6: Create a Student_Payment__c record with 'Payment Link Created' status
    Student_Payment__c studentPayment = new Student_Payment__c(
        //Student_Fee__c = studentFee.Id, // Ensure proper relation to Student Fee
        Amount__c = 500.0,
        Payment_Status__c = 'Payment Link Created'
    );
    insert studentPayment;

    // Step 7: Use a mock community domain URL in the test context
    String mockDomain = 'testcommunity.force.com';

    // Step 8: Start test execution
    Test.startTest();
    System.runAs(testUser) {
        String paymentUrl = RevaMealBookingController.getMessPenaltyUrl();
        System.debug('Generated Payment URL: ' + paymentUrl);

        // Step 9: Validate the result
       // System.assert(paymentUrl != null, 'The payment URL should not be null.');
        //System.assert(paymentUrl.contains(mockDomain), 'The payment URL should contain the community domain.');
       // System.assert(paymentUrl.contains('contactId=' + testContact.Id), 'The payment URL should contain the contact ID.');
       // System.assert(paymentUrl.contains('stupayid=' + studentPayment.Id), 'The payment URL should contain the student payment ID.');
    }
    Test.stopTest();
}


     /*************************************************************************/
  /* @IsTest
static void testGetMissedMealCount() {
    // Start test context
    Test.startTest();
    
    // Create a test Contact record
    Contact testContact = new Contact(
        LastName = 'Test User',
        Email = 'srinivaschundru@yopmail.com'
    );
    insert testContact;
    
    // Create test Reva_Mess_Menu__c records
    Date today = Date.today();
    Date futureDate = today.addDays(1);
    
    Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
        Date__c = today,
        Type__c = 'Lunch',
        Start_Time__c = Time.newInstance(12, 0, 0, 0),
        End_Time__c = Time.newInstance(13, 0, 0, 0),
        Mess_Items__c = 'Bread'
    );
    insert messMenuToday;
    
    Reva_Mess_Menu__c messMenuFuture = new Reva_Mess_Menu__c(
        Date__c = futureDate,
        Type__c = 'Dinner',
        Start_Time__c = Time.newInstance(8, 0, 0, 0),
        End_Time__c = Time.newInstance(9, 0, 0, 0),
        Mess_Items__c = 'Bread'
    );
    insert messMenuFuture;

    // Create a Reva_Meal_Booking__c record
    Reva_Meal_Booking__c mealBooking = new Reva_Meal_Booking__c(
        Reva_Mess_Menu__c = messMenuFuture.Id,
        Booking_For__c = testContact.Id,
        Reva_Meal_Booking_Status__c = 'Booked',
        Reva_Meal_Booking_Date__c = today
    );
    insert mealBooking;
    
    // Create test data for missed meals and other statuses
    Date startOfMonth = today.toStartOfMonth();
    Integer daysInMonth = Date.daysInMonth(today.year(), today.month());
    Date endOfMonth = Date.newInstance(today.year(), today.month(), daysInMonth);

    // Records with status 'Missed Meal' in the current month
    List<Reva_Meal_Booking__c> missedMealRecords = new List<Reva_Meal_Booking__c>();
    for (Integer i = 1; i <= 5; i++) {
        missedMealRecords.add(new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Mess_Menu__c = messMenuToday.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Date__c = startOfMonth.addDays(i)
        ));
    }

    // Records with a different status in the current month
    List<Reva_Meal_Booking__c> otherStatusRecords = new List<Reva_Meal_Booking__c>();
    for (Integer i = 1; i <= 3; i++) {
        otherStatusRecords.add(new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Availed',
            Reva_Mess_Menu__c = messMenuToday.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Date__c = startOfMonth.addDays(i)
        ));
    }

    // Records outside the current month
    List<Reva_Meal_Booking__c> outOfMonthRecords = new List<Reva_Meal_Booking__c>();
    for (Integer i = 1; i <= 2; i++) {
        outOfMonthRecords.add(new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Missed Meal',
            Reva_Mess_Menu__c = messMenuToday.Id,
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Date__c = startOfMonth.addMonths(-1).addDays(i)
        ));
    }

    // Insert test data
    insert missedMealRecords;
    insert otherStatusRecords;
    insert outOfMonthRecords;

    // Call the method and assert the result
    Integer missedMealCount = RevaMealBookingController.getMissedMealCount();
    //System.assertEquals(5, missedMealCount, 'Missed meal count should be 5 for the current month');
    
    // End test context
    Test.stopTest();
}*/

    
    @IsTest
static void testGetMissedMealCount() {
    // Start test context
    User adminUser = [SELECT Id, UserRoleId, IsActive FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL AND IsActive = TRUE LIMIT 1];

   // User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != NULL LIMIT 1];
        // Create test Account with the admin user as the Owner
        Account testAccount = new Account(
            Name = 'Test Student Account',
            OwnerId = adminUser.Id // Ensuring the account owner has a role
        );
        insert testAccount;
    Test.startTest();
    
    // Create a test Contact record
    Contact testContact = new Contact(
        LastName = 'Test User',
        Email = 'testuser@yopmail.com',
        AccountId = testAccount.Id
    );
    insert testContact;
    
    // Create a test User with Student Profile
    Profile studentProfile = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
    User testUser = new User(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@yopmail.com',
        Username = 'testuser@yopmail.com' + System.currentTimeMillis(),
        Alias = 'tuser',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = studentProfile.Id,
        LanguageLocaleKey = 'en_US',
        ContactId = testContact.Id
    );
    insert testUser;
    
    // Set the test user as the current user
    System.runAs(testUser) {
        // Create test Reva_Mess_Menu__c records
        Date today = Date.today();
        Date startOfMonth = today.toStartOfMonth();
        Integer daysInMonth = Date.daysInMonth(today.year(), today.month());
        Date endOfMonth = Date.newInstance(today.year(), today.month(), daysInMonth);
        
        Reva_Mess_Menu__c messMenuToday = new Reva_Mess_Menu__c(
            Date__c = today,
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0),
            End_Time__c = Time.newInstance(13, 0, 0, 0),
            Mess_Items__c = 'Bread'
        );
        insert messMenuToday;
        
        // Create records with status 'Missed Meal' in the current month
        List<Reva_Meal_Booking__c> missedMealRecords = new List<Reva_Meal_Booking__c>();
        for (Integer i = 1; i <= 5; i++) {
            missedMealRecords.add(new Reva_Meal_Booking__c(
                Reva_Meal_Booking_Status__c = 'Missed Meal',
                Reva_Mess_Menu__c = messMenuToday.Id,
                Booking_For__c = testContact.Id
            ));
        }
        insert missedMealRecords;

        // Call the method and assert the result
        Integer missedMealCount = RevaMealBookingController.getMissedMealCount();
        System.assertEquals(5, missedMealCount, 'Missed meal count should be 5 for the current month');
    }
    
    // End test context
    Test.stopTest();
}

    
   
    /***********************************************************************************/
  
    @isTest
    static void testCheckMissedMealsCount() {
        // Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Total_missed_meals_this_month__c = 10 // Set to 10 to trigger the condition
        );
        insert testContact;

        // Call the method and verify it returns true (missed meals >= 10)
        Test.startTest();
        Boolean result = RevaMealBookingController.checkMissedMealsCount(testContact.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'The method should return true for missed meals >= 10');

       
    }


    /************************************************************************************/
    
}