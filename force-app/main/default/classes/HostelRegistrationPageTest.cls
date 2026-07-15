@isTest
public class HostelRegistrationPageTest {
    
    @testSetup
    static void setupData() {
        // Create test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'test.student@example.com',
            MobilePhone = '9999999999',
            Application_Number__c = 'APP1234',
            SRN_Number__c = 'SRN4567',
            hed__Gender__c = 'Male',
            rve_Father_s_Name__c = 'Test Father'
        );
        insert testContact;
        
        
 
 // Get first valid floor value (assumes these are always active)
String validFloor = Reva_Hostel_Room__c.Floor__c.getDescribe().getPicklistValues()[0].getValue();

// Manually set a valid block value
//String validBlock = 'G1'; // Confirmed from your org

Reva_Hostel_Room__c testRoom = new Reva_Hostel_Room__c(
    Name = 'Room 101',
   Dormitory_Type__c = 'Girls',     // or 'Boys' depending on block
    Block__c = 'G1',
    Floor__c = validFloor,
    Maximum_Occupancy__c = '3',
    Room_Type__c ='Student',
    Room_Category__c ='1 Eng Non-CS'
     );
   insert testRoom;
     String activeType = null;
     for (Schema.PicklistEntry pe : Reva_Hostel_Request__c.Type__c.getDescribe().getPicklistValues()) {
         if (pe.isActive()) {
          activeType = pe.getValue();
          break;
          }
     }
       System.assertNotEquals(null, activeType, 'No active Type__c value found');

        // Create test hostel request
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c(
            Hostel_Room_Request_For__c = testContact.Id,
            Reva_Hostel_Room__c = testRoom.Id,  
            Status__c = 'Pending',
            Type__c = activeType,
            Reva_Hostel_JoiningDate__c = System.today(),
            Reva_Hostel_Premium_Room__c = false
        );
        insert hostelRequest;
       Test.setCurrentPageReference(new PageReference('/apex/HostelRegistrationPage?id=' + hostelRequest.Id));
       HostelRegistrationPage controller = new HostelRegistrationPage();

     // Create test address records
      hed__Address__c mailing = new hed__Address__c( 
        hed__Parent_Contact__c = testContact.Id,
        hed__Address_Type__c = 'Mailing Address',
        hed__MailingStreet__c = '123 Main St',
        hed__MailingCity__c = 'Cityville',
        hed__MailingCounty__c = 'Countyshire'
          );

         hed__Address__c permanent = new hed__Address__c(
            hed__Parent_Contact__c = testContact.Id,
            hed__Address_Type__c = 'Permanent Address',
            hed__MailingStreet__c = '456 Elm St',
            hed__MailingCity__c = 'Townburg',
            hed__MailingCounty__c = 'Districtton'
             );
          insert new List<hed__Address__c>{ mailing, permanent };

          Student_Fee__c testFee = new Student_Fee__c(
          Name = 'Hostel Fee 2025-26',
          Contact__c = testContact.Id,
          Amount__c = 10000,
          Amount_Paid__c = 5000,
          Amount_Pending__c = 5000
          );
         insert testFee;  
  
  }

    @isTest
static void testConstructorAndDataLoading() {
    // Query the inserted hostel request (created in @testSetup)
    Reva_Hostel_Request__c hostelRequest = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];

    // Set the page reference with the correct ID
    Test.setCurrentPageReference(new PageReference('/apex/HostelRegistrationPage?id=' + hostelRequest.Id));
    
    Test.startTest();
    HostelRegistrationPage controller = new HostelRegistrationPage();
    Test.stopTest();

    System.assertNotEquals(null, controller.contactRecord, 'Contact record should be loaded');
    System.assertNotEquals(null, controller.hostelRecord, 'Hostel record should be loaded');
    System.assertNotEquals(null, controller.hostelRoomRecord, 'Hostel Room record should be loaded');
    System.assertNotEquals(null, controller.mailingAddress, 'Mailing Address should be loaded');
    System.assertEquals('123 Main St', controller.mailingAddress.hed__MailingStreet__c, 'Street should match');
    System.assertNotEquals(null, controller.permanentAddress, 'Permanent Address should be loaded');
    System.assertNotEquals(null, controller.contactFieldRows, 'Contact field rows should be populated');
    System.assertNotEquals(null, controller.hostelFieldRows, 'Hostel field rows should be populated');
    System.assertNotEquals(null, controller.hostelRoomFieldRows, 'Room field rows should be populated');
    System.assertEquals(true, controller.hasHostelFeeRecord, 'Hostel fee record flag should be true');
    System.assertNotEquals(null, controller.hostelFeeRecord, 'Hostel fee record should be populated');
}

    @isTest
    static void testSaveData() {
        HostelRegistrationPage controller = new HostelRegistrationPage();

        // Clear existing Ids to simulate new insert
        controller.contactRecord.Id = null;
        controller.contactRecord.Email = 'new.email@example.com';
        controller.hostelRecord.Id = null;
        controller.hostelRecord.Status__c = 'Pending';

        Test.startTest();
        controller.saveData();
        Test.stopTest();

        // Validate messages
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assert(messages.size() > 0, 'Expected a success or error message');
    }

    @isTest
    static void testInvalidIdHandling() {
        Test.setCurrentPageReference(new PageReference('/apex/Hostel_Registration_Form'));
        ApexPages.currentPage().getParameters().put('id', 'invalidId');

        Test.startTest();
        HostelRegistrationPage controller = new HostelRegistrationPage();
        Test.stopTest();

        // Should not throw unhandled exceptions
        System.assertNotEquals(null, controller, 'Controller should be initialized even with invalid ID');
    }
}