@isTest
public class getMealBookingRecordTest {
    
    @isTest
    static void testGetRecord() {
        // Step 1: Create a test Contact record
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com'
        );
        insert testContact;
        
        // Step 2: Create a test REVA_Mess_Menu__c record with mandatory fields
        REVA_Mess_Menu__c testMenu = new REVA_Mess_Menu__c(
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Example start time: 09:00 AM
            End_Time__c = Time.newInstance(13, 0, 0, 0),   // Example end time: 05:00 PM
            Date__c = System.today() // Example date: today's date
        );
        insert testMenu;
        
        // Step 3: Create a test Reva_Meal_Booking__c record with all mandatory fields
        Reva_Meal_Booking__c testRecord = new Reva_Meal_Booking__c(
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = System.today(),
            Reva_Mess_Menu__c = testMenu.Id,
            Booking_For__c = testContact.Id
        );
        insert testRecord;
        
        // Step 4: Call the method
        Test.startTest();
        Reva_Meal_Booking__c result = getMealBookingRecord.getRecord(testRecord.Id);
        Test.stopTest();
        
        // Step 5: Assertions
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(testRecord.Id, result.Id, 'The record ID should match.');
        System.assertEquals('Booked', result.Reva_Meal_Booking_Status__c, 'The meal booking status should match.');
        /*System.assertEquals(System.today(), result.Reva_Meal_Booking_Date__c, 'The meal booking date should match.');
        System.assertEquals(testMenu.Id, result.Reva_Mess_Menu__c, 'The mess menu ID should match.');
        System.assertEquals(testContact.Id, result.Booking_For__c, 'The contact ID should match.');*/
    }


  
    @IsTest
    static void testGetContactImage() {
        // Create test data
        // Step 1: Create a Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            SRN_Number__c = 'SRN12345',
            Application_Number__c = 'APP12345',
            Email = 'john2.doe@example.com'
        );
        insert testContact;

        REVA_Mess_Menu__c testMenu = new REVA_Mess_Menu__c(
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Example start time: 09:00 AM
            End_Time__c = Time.newInstance(13, 0, 0, 0),   // Example end time: 05:00 PM
            Date__c = System.today() // Example date: today's date
        );
        insert testMenu;

        // Step 2: Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c testMealBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = System.today(),
            Reva_Mess_Menu__c = testMenu.Id
           
        );
        insert testMealBooking;

        // Step 3: Create a Document record in the 'student images' folder
        Folder studentImagesFolder = [SELECT Id FROM Folder WHERE Name = 'student images' LIMIT 1];
       /* if (studentImagesFolder == null) {
            studentImagesFolder = new Folder(Name = 'student images', DeveloperName = 'student_images', AccessType = 'Public');
            insert studentImagesFolder;
        } */

        Document testDocument = new Document(
            Name = 'SRN12345_test_image.jpg',
            FolderId = studentImagesFolder.Id,
            ContentType = 'image/jpeg',
            Body = Blob.valueOf('Dummy Image Content'),
            IsPublic = true
        );
        insert testDocument;

        // Step 4: Create a dummy ContentDocument and link it to the Contact
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Passport Photo',
            PathOnClient = 'passport_photo.jpg',
            VersionData = Blob.valueOf('Dummy Image Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        //ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId];
         // Re-query ContentVersion to get the ContentDocumentId
        contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            LinkedEntityId = testContact.Id,
            ContentDocumentId = contentVersion.ContentDocumentId,
            ShareType = 'V'
        );
        insert contentDocumentLink;

        // Step 5: Test the getContactImage method
        Test.startTest();
        String imageUrl = getMealBookingRecord.getContactImage(testMealBooking.Id);
        Test.stopTest();

        // Validate the result
        System.assertNotEquals(null, imageUrl, 'Image URL should not be null');
        System.assert(imageUrl.contains('data:image'), 'Image URL should be in base64 format');
    }
    
     @IsTest
    static void testGetContactImageFromDocument() {
         Contact testContact = new Contact(
            LastName = 'Test Contact',
            SRN_Number__c = 'SRN12345',
            Application_Number__c = 'APP12345',
            Email = 'john2.doe@example.com'
        );
        insert testContact;

        REVA_Mess_Menu__c testMenu = new REVA_Mess_Menu__c(
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Example start time: 09:00 AM
            End_Time__c = Time.newInstance(13, 0, 0, 0),   // Example end time: 05:00 PM
            Date__c = System.today() // Example date: today's date
        );
        insert testMenu;

        // Step 2: Create a Reva_Meal_Booking__c record
        Reva_Meal_Booking__c testMealBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = System.today(),
            Reva_Mess_Menu__c = testMenu.Id
           
        );
        insert testMealBooking;

        // Step 3: Create a Document record in the 'student images' folder
        Folder studentImagesFolder = [SELECT Id FROM Folder WHERE Name = 'student images' LIMIT 1];
       /* if (studentImagesFolder == null) {
            studentImagesFolder = new Folder(Name = 'student images', DeveloperName = 'student_images', AccessType = 'Public');
            insert studentImagesFolder;
        } */

        Document testDocument = new Document(
            Name = 'SRN12345_test_image.jpg',
            FolderId = studentImagesFolder.Id,
            ContentType = 'image/jpeg',
            Body = Blob.valueOf('Dummy Image Content'),
            IsPublic = true
        );
        insert testDocument;
        
        
         // Step 5: Test the getContactImage method
        Test.startTest();
        String imageUrl = getMealBookingRecord.getContactImage(testMealBooking.Id);
        Test.stopTest();

    }

    @IsTest
    static void testGetContactImage_NoImage() {
        // Create test data
        Contact testContact = new Contact(LastName = 'Test Contact 2',Email = 'john2.doe@example.com');
        insert testContact;

        REVA_Mess_Menu__c testMenu = new REVA_Mess_Menu__c(
            Type__c = 'Lunch',
            Start_Time__c = Time.newInstance(12, 0, 0, 0), // Example start time: 09:00 AM
            End_Time__c = Time.newInstance(13, 0, 0, 0),   // Example end time: 05:00 PM
            Date__c = System.today() // Example date: today's date
        );
        insert testMenu;

        Reva_Meal_Booking__c testMealBooking = new Reva_Meal_Booking__c(
            Booking_For__c = testContact.Id,
            Reva_Meal_Booking_Status__c = 'Booked',
            Reva_Meal_Booking_Date__c = System.today(),
            Reva_Mess_Menu__c = testMenu.Id
        );
        insert testMealBooking;

        // Test when no image is found
        Test.startTest();
        String imageUrl = getMealBookingRecord.getContactImage(testMealBooking.Id);
        Test.stopTest();

        // Validate the result
        System.assertEquals('', imageUrl, 'Image URL should be empty if no image is found');
    }

    @IsTest
    static void testGetContactImage_InvalidRecordId() {
        // Test with invalid record ID
        Test.startTest();
        String imageUrl = getMealBookingRecord.getContactImage(null);
        Test.stopTest();

        // Validate the result
        System.assertEquals('', imageUrl, 'Image URL should be empty for null record ID');
    }


}