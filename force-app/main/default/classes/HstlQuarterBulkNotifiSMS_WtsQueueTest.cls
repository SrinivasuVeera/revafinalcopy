@isTest
public class HstlQuarterBulkNotifiSMS_WtsQueueTest {
@TestSetup
    public static void setupTestData() {
     
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();

        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
         Contact testContact2 = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching@example.com',
            MobilePhone = '98765432109',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
        
                User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'teyy4674stuserrrrr7bhdsjr@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId =testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create a user for Hostel_Room_Request_For__c reference
        

        
        Reva_Hostel_Room__c hostelroom = new Reva_Hostel_Room__c(
        Room_Type__c = 'Student',
        Room_Category__c = '1 Eng',
        Dormitory_Type__c = 'Boys',
            Block__c = 'A'
        );
        insert hostelroom ;
 
        // Create a Reva_Hostel_Request__c record with required fields
        Reva_Hostel_Request__c hostelRequest = new Reva_Hostel_Request__c();
        hostelRequest.Hostel_Room_Request_For__c = testContact.Id;
        hostelRequest.Employee_Salary__c = 5000;
        //hostelRequest.Is_HCM_Salary_Deduction_CNF__c = false;
        //hostelRequest.Approved_by_Hostel_Office__c = true;
        //
      //  hostelRequest.Reva_Hostel_Room__c = hostelroom.Id;
        hostelRequest.Reva_Hostel_JoiningDate__c = Date.today();
        hostelRequest.Type__c = '4ExtraSpace';
        hostelRequest.Admin_Director__c = testUser.Id;
         hostelRequest.HR_Lead__c = testUser.Id;
         hostelRequest.Reporting_Manager__c = testUser.Id;
         hostelRequest.Hostel_Officer__c = testUser.Id;
        insert hostelRequest;
        
   
    }

    @IsTest
    static void bookedWhatsappNotifactionsTest(){
        Map<String, List<Yellow_AI_Utility.WhatsAppNotification>> phoneNumbersToNotifications = new Map<String, List<Yellow_AI_Utility.WhatsAppNotification>>();

        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id,Hostel_Room_Request_For__r.MobilePhone FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Booked';
        update hostelReqs;
      phoneNumbersToNotifications = HostelRequestStaffNotifications.staffBooking(hostelReqs[0].Id);
            System.enqueueJob(new HstlQuarterBulkNotifiSMS_WtsappQueueable.HostelQuarterWtsappBulkNotification(phoneNumbersToNotifications,new set<Id>{hostelReqs[0].Id},'Hostel'));
        Test.stopTest();
        //Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        //System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    @IsTest
    static void bookedSMSNotifactionsTest(){
Map<String, List<SMS_API_Utility.shortMessageWrp>> mapSms = new Map<String, List<SMS_API_Utility.shortMessageWrp>>();
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id,Hostel_Room_Request_For__r.MobilePhone FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Booked';
        update hostelReqs;
       
        mapSms = HostelRequestStaffNotifications.createMessageMap('Hostel_Request_Staff', 'Dear ' + 'Test' + ',\nYour Hostel request has been received. We will notify you once it is processed.\nRegards,\nREVA University.', 
                                '123456789', '1007240148112049281');
            System.enqueueJob(new HstlQuarterBulkNotifiSMS_WtsappQueueable.HostelQuarterSMSBulkNotification(mapSms));
        Test.stopTest();

    }
}