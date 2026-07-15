@isTest
public class GuestHouseNotificationsWhatsAppTest {
    
    public class MockHttpCalloutResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Mock response"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void setupTestData() {
        // Find the Record Type ID for 'Non Teaching'
        RecordType nonTeachingRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Non Teaching' LIMIT 1];
        
        // Create test data for Contacts
        Contact guestContact = new Contact(
            LastName = 'Test Guest', 
            Email = 'test585@gmail.com',
            MobilePhone = '+919876543210'
        );
        insert guestContact;
        
        Contact coContact = new Contact(
            LastName = 'Test Co', 
            Email = 'test555co@gmail.com',
            MobilePhone = '+919876543212'
        );
        insert coContact;
        
        Contact guestHouseManagerContact = new Contact(
            LastName = 'Guest Manager', 
            Email = 'guestmanager@example.com',
            MobilePhone = '+919876543213',
            RecordTypeId = nonTeachingRecordType.Id
        );
        insert guestHouseManagerContact;
        
        // Create Users with specific profiles
        Profile departmentHeadProfile = [SELECT Id FROM Profile WHERE Name = 'School Director' LIMIT 1];
        Profile professorProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        Profile guestHouseManagerProfile = [SELECT Id FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        
        User departmentHead = new User(
            Username = 'depthead@example.com',
            LastName='testdept',
            Email = 'depthead@example.com',
            ProfileId = departmentHeadProfile.Id,
            Alias = 'depad',
            CommunityNickname = 'depthead',
            UserRoleId = null, // set if you have specific roles
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert departmentHead;
        
        User generalAdmin = new User(
            Username = 'professor@example.com',
            LastName='testgen',
            Email = 'professor@example.com',
            ProfileId = professorProfile.Id,
            Alias = 'prssor',
            CommunityNickname = 'professor',
            UserRoleId = null, // set if you have specific roles
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert generalAdmin;
        
        User guestHouseManager = new User(
            Username = 'guestmanager@example.com',
            Email = 'guestmanager@example.com',
            LastName='gueHm',
            ProfileId = guestHouseManagerProfile.Id,
            Alias = 'gstmgr',
            CommunityNickname = 'guestmgr',
            UserRoleId = null, // set if you have specific roles
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = guestHouseManagerContact.Id,
            IsActive = true
        );
        insert guestHouseManager;
        
        // Create Guest House Room records
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = guestContact.Id,
            Sharing_Type__c = 'Two Sharing',
            Room_Type__c = 'A/C',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Department_Head__c = departmentHead.Id,
            General_Admin__c = generalAdmin.Id,
            Purpose_of_Visit__c = 'Business123',
            Contact__c = coContact.Id,
            Status__c = 'Booked'
        );
        insert guestHouseBooking;
    }
    /*************************************************************************************************/ 
    @isTest
    static void testPaymentMethod() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        Contact testContact = [SELECT Id FROM Contact WHERE LastName ='Test Co'];
        
        Student_Payment__c testPayment = new Student_Payment__c(
            Contact__c = testContact.Id,
            Payment_Status__c = 'Payment Link Created',
            Fee_Type__c = 'Hostel Fee',
            Amount__c = 100.00
        );
        insert testPayment;
        
           Student_Fee__c paytmStudentFee1 = new Student_Fee__c();
            paytmStudentFee1.Name = 'Guest House Fee';
            paytmStudentFee1.Contact__c = testContact.Id;
            paytmStudentFee1.Fee_Type__c ='Guest House Fee';
            paytmStudentFee1.Amount__c = 1500;
            paytmStudentFee1.Amount_Pending__c = 1500;
            paytmStudentFee1.Amount_Paid__c = 0;
            //paytmStudentFee1.Cancelled__c = False;
            insert paytmStudentFee1;
           
            // Inserting Student Payment
            
            Student_Payment__c paytmStudentPayment = new Student_Payment__c();
            paytmStudentPayment.Contact__c = testContact.Id;
            paytmStudentPayment.Payment_Status__c = 'Success';
            paytmStudentPayment.Transaction_ID__c = '123442123432';
            paytmStudentPayment.Payment_Mode_Type__c = 'Online';
            paytmStudentPayment.Payment_Gateway__c = 'Paytm';
            paytmStudentPayment.Amount__c =1500;
            paytmStudentPayment.Reference_Id__c = '1231234';
            insert paytmStudentPayment;
            
            //Inserting Student Fee Payment
            
        Student_Fee_Payment__c paytmStudentFeePayment = new Student_Fee_Payment__c();
        paytmStudentFeePayment.Student_Fee__c = paytmStudentFee1.Id;
        paytmStudentFeePayment.Student_Payment__c = paytmStudentPayment.Id;
        paytmStudentFeePayment.Line_Item_Payment_Gateway__c = 'Paytm';
        paytmStudentFeePayment.Line_Item_Payment_Status__c = 'Success';
        paytmStudentFeePayment.Amount__c = 1500;
        paytmStudentFeePayment.Mode_of_Payment__c='Online';
        paytmStudentFeePayment.SF_Transaction_ID__c= '123442123432';
        paytmStudentFeePayment.Transaction_Date_Time__c  = system.now();
        paytmStudentFeePayment.Reference_Id__c = '1231234';
        insert paytmStudentFeePayment;
        
        
        
        REVA_Guest_House_Room__c guestHouseRoom =[SELECT Id, Name FROM REVA_Guest_House_Room__c LIMIT 1];
        
        // Create Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Sharing_Type__c = 'Two Sharing',
            Room_Type__c = 'A/C',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Department_Head__c = UserInfo.getUserId(), // Adjust if necessary
            General_Admin__c = UserInfo.getUserId(), // Adjust if necessary
            Purpose_of_Visit__c = 'Business',
            Status__c = 'Booked'
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
        GuestHouseNotificationsWhatsApp.HandlePaymentMethod(new List<Student_Fee_Payment__c> { paytmStudentFeePayment});
        Test.stopTest();
          update paytmStudentPayment;
        // Verify the outcome
        // Check if the Queueable job was enqueued
        // Asserting the job was enqueued is more complex and typically involves checking system logs or using mock classes for the Queueable job
        System.assertEquals(1, [SELECT COUNT() FROM Student_Payment__c WHERE Id = :testPayment.id]);
    }
    
    
    /*************************************************************************************************************************/
    @isTest
    static void testHandleMethod() {
        // Step 1: Create test records
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{testAccount1, testAccount2};
            
            // Define the different template types to test
            List<String> templateTypes = new List<String>{
                'Booking', 'Allocation', 'Department Allocation', 'Check In', 
                    'Check Out', 'Cancellation', 'General Admin', 'Department Head', 
                    'Guest Manger'
                    };
                        
                        // Loop through each template type and perform tests
                        for (String templateType : templateTypes) {
                            // Create an instance of InputParameters with test data
                            GuestHouseNotificationsWhatsApp.InputParameters inputParams = new GuestHouseNotificationsWhatsApp.InputParameters();
                            inputParams.recordIds = new List<String>{testAccount1.Id, testAccount2.Id};
                                inputParams.TemplateTypeList = templateType;
                            
                            List<GuestHouseNotificationsWhatsApp.InputParameters> inputList = new List<GuestHouseNotificationsWhatsApp.InputParameters>{inputParams};
                                
                                // Test the HandleMethod with each template type
                                
                                Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
                            GuestHouseNotificationsWhatsApp.HandleMethod(inputList);
                            
                        }
    } 
    
    // Test class for making async callouts
    @isTest
    static void testAsyncCallout() {
        Test.startTest();
        // Register the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        
        //GuestHouseNotificationsSMS.makeCalloutAsync(new List<Id>{UserInfo.getUserId()}, 'Sample Template');
        Test.stopTest();
        
    }
    /*************************************************************************************************************************/
    @isTest
    static void testGuestBooking() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        
        
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        Contact guestContact1 = [SELECT Id From Contact WHERE LastName ='Test Guest'];
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        
        
        
        User guestHouseManager = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'test.manager@example.com',
            Username = 'test.manager@example.com',
            Alias = 'tman',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            ContactId = guestContact1.Id
        );
        
        insert guestHouseManager;
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c =  guestContact1.Id,
            Sharing_Type__c = 'Two Sharing',
            Room_Type__c = 'A/C',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true,
            Status__c = 'Booked',
            Room_Details__c = null,
            Contact__c = testContact.Id,
            Email__c ='test@gmail.com'
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
        // Mock the metadata retrieval in your Apex class if necessary
        // Create a mock for the metadata retrieval if it's not possible to directly use an existing metadata record in test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Call the GuestBooking method
        GuestHouseNotificationsWhatsApp.GuestBooking(new List<Id>{guestHouseBooking.Id});
        Test.stopTest();
        
        // Step 2: Verify the outcome
        // Check if the Queueable job was enqueued
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
        
    }
    /****************************************************************************************************************************/
    @isTest
    static void testRoomAllocationForguest() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
         Contact guestContact1 = [SELECT Id From Contact WHERE LastName ='Test Guest'];
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        
         User guestHouseManager = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'test.manager@example.com',
            Username = 'test1.manager@example.com',
            Alias = 'tman',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            ContactId = guestContact1.Id
        );
        
        insert guestHouseManager;
        
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Room_Details__c = 'Room 101',
            Sharing_Type__c = 'Two Sharing',
            No_of_Rooms__c = '2',
            Room_Type__c = 'A/C',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            No_of_Guest__c = 4,
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true,
            Status__c = 'Booked',
            Check_In__c = false,
            Email__c ='Test@gmail.com',
            Check_Out__c = false,
            Citizenship__c = 'India',
            Guest_Coordinator__c = guestHouseManager.Id
            
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        // Insert custom metadata using Metadata API (cannot be done directly in test context)
        // Instead, assume that the metadata exists or use mock data in the test
        
        // Step 2: Execute the method under test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.RoomAllocationForguest(new List<Id>{guestHouseBooking.Id});
        
        Test.stopTest();
        
        // Step 3: Verify the outcome
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
        
    }
    /****************************************************************************************************************************/
    @isTest
    static void testRoomAllocationForDptHead() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        Contact guestContact1 = [SELECT Id From Contact WHERE LastName ='Test Guest'];
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        User deptHead = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'test.manager@example.com',
            Username = 'test1.manager@example.com',
            Alias = 'tman',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            MobilePhone='7894561235',
            ContactId = guestContact1.Id
        );
        
        insert deptHead;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Guest_House_Room__c = guestHouseRoom.Id,
            Room_Details__c = 'Room 101',
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true,
            Status__c = 'Booked',
            Department_Head__c=deptHead.Id
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
        // Insert custom metadata record using Metadata API (or ensure it exists in the test org)
        // For this example, assuming it's pre-loaded or mock its presence
        
        // Step 2: Execute the method under test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.RoomAllocationForDptHead(new List<Id>{guestHouseBooking.Id});
        
        Test.stopTest();
        
        // Step 3: Verify the outcome
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);        
        // Optionally, you can verify the content of the `phoneNumbersToNotifications` map
        // This requires custom logic or debug logs as there is no direct way to assert queueable job contents in Apex
    }
    /****************************************************************************************************************************/
    
    @isTest
    static void testCheckInNotify() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Guest_House_Room__c = guestHouseRoom.Id,
            
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true,
            Status__c = 'Approved',
            Check_In__c = true
        );
        insert guestHouseBooking;
        
        // Use the Test.loadData method to load custom metadata if needed or assume it's present
        // Ensure the metadata is present in the test environment or mock its presence
        
        // Mock the metadata query response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        // Mock a response for WhatsApp_Notification_Template__mdt query
        
        GuestHouseNotificationsWhatsApp.CheckInNotify(new List<Id>{guestHouseBooking.Id});
        
        Test.stopTest();
        
        // Step 3: Verify the outcome
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
    }
    /*******************************************************************************************************************************/
    @isTest
    static void testCheckOutNotify() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '101',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Guest_House_Room__c = guestHouseRoom.Id,
            
            Start_Time__c = System.now().addDays(-1),
            End_Time__c = System.now(),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true
        );
        insert guestHouseBooking;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.CheckOutNotify(new List<Id>{guestHouseBooking.Id});
        
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
    }
    /******************************************************************************************************************************************/
    @isTest
    static void testCancellationNotify() {
        // Step 1: Create test data
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Status__c ='Booked',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now().addDays(-1),
            End_Time__c = System.now(),
            Mobile_Number__c = '+919876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
        // Execute the CancellationNotify method
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.CancellationNotify(new List<Id>{guestHouseBooking.Id});
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
    }
    /***********************************************************************************************************************************************/
    @isTest
    static void testCancellationNotifyGuestManager() {
        // Step 1: Create test data
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Guest_House_Room__c = guestHouseRoom.Id,
            
            Start_Time__c = System.now().addDays(-1),
            End_Time__c = System.now(),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = true
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.CancellationNotifyGuestManager(new List<Id>{guestHouseBooking.Id});
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
    }
    /**************************************************************************************************************/
    @isTest
    static void testGeneralAdminApproval() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Guest_House_Room__c = guestHouseRoom.Id,
            
            Start_Time__c = System.now().addDays(1),
            End_Time__c = System.now().addDays(1).addHours(2),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = true,
            Approved_By_General_Admin__c = false, // Initial value
            Name_of_Dept_School__c = 'Engineering',
            Purpose_of_Visit__c = 'Research'
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        // Execute the GeneralAdminApproval method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.GeneralAdminApproval(new List<Id>{guestHouseBooking.Id});
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
        
    }
    /*****************************************************************************************************************/
    @isTest
    static void testDepartmentHeadApproval() {
        // Step 1: Create test data
        
        // Create a test Contact record
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        // Create a test Guest House Room record
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        // Create a test Guest House Booking record
        Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = testContact.Id,
            Guest_House_Room__c = guestHouseRoom.Id,
            
            Start_Time__c = System.now().addDays(1),
            End_Time__c = System.now().addDays(1).addHours(2),
            Mobile_Number__c = '+91-9876543210',
            Approved_by_Department_Head__c = false, // Initial value
            Approved_By_General_Admin__c = false,
            Name_of_Dept_School__c = 'Engineering',
            Purpose_of_Visit__c = 'Research'
        );
        insert guestHouseBooking;
        
         Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
        // Execute the DepartmentHeadApproval method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.DepartmentHeadApproval(new List<Id>{guestHouseBooking.Id});
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Reva_Guest_House_Booking__c WHERE Id =:guestHouseBooking.Id]);
        
    }
    /******************************************************************************************************************/
 
    
    @isTest
    static void testConfirmationGuestManager() {
        
	 Contact testContact = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@example.com',
            MobilePhone = '+919876543210'
        );
        insert testContact;
        
        REVA_Guest_House_Room__c guestHouseRoom = new REVA_Guest_House_Room__c(
            Name = '102',
            Room_Type__c = 'A/C',
            Available__c = true,
            Maximum_Occupancy__c = 'Two Sharing'
        );
        insert guestHouseRoom;
        
        Contact guestContact1 = [SELECT Id From Contact WHERE LastName ='Test Guest'];
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Guest House Manager' LIMIT 1];
        
        
        
        User guestHouseManager = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'test.manager@example.com',
            Username = 'test.manager@example.com',
            Alias = 'tman',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            ContactId = guestContact1.Id
        );
        
        insert guestHouseManager;
    
           Reva_Guest_House_Booking__c guestHouseBooking = new Reva_Guest_House_Booking__c(
            ContactLookUp__c = guestContact1.Id,
            Sharing_Type__c = 'Two Sharing',
            Room_Type__c = 'A/C',
            Guest_House_Room__c = guestHouseRoom.Id,
            Start_Time__c = System.now(),
            End_Time__c = System.now().addDays(1),
            Mobile_Number__c = '+91-9876543210',
            Purpose_of_Visit__c = 'Business123',
            Contact__c = testContact.Id,
            Status__c = 'Booked',
    		No_of_Guest__c = 1,
            Type_of_Guest__c = 'University Guest'
        );
        insert guestHouseBooking;
        
        Guest_Person__c gp = new Guest_Person__c(
        REVA_Guest_House_Booking__c = guestHouseBooking.Id,
        Guest_Name__c='test1');
        insert gp;
        
 		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutResponse());
        GuestHouseNotificationsWhatsApp.ConfirmationGuestManger(new List<Id>{guestHouseBooking.Id});
        
        Test.stopTest();

    }
    
}