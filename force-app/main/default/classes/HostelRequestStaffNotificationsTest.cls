@isTest
public class HostelRequestStaffNotificationsTest {
@TestSetup
    public static void setupTestData() {
     
         Id nonTeachingProfileId = [SELECT Id FROM Profile WHERE Name = 'Non Teaching Profile' LIMIT 1].Id;
         Id Non_teachiningRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Non Teaching').getRecordTypeId();

        Contact testContact = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching123@example.com',
            MobilePhone = '9876543210',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact;
        
         Contact testContact2 = new Contact(
            FirstName = 'NonTeaching',
            LastName = 'Staff',
            Email = 'nonteaching5678@example.com',
            MobilePhone = '98765432109',
            hed__Gender__c = 'Female',
            Employee_Number__c = 'REVA01462',
            RecordTypeId = Non_teachiningRecordTypeId
        );
        insert testContact2;
        
                User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'teyy4674stuserrrrr7bhdsjrhstl001@test.com',
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
    static void bookedNotifactionsTest(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Booked';
        update hostelReqs;
        HostelRequestStaffNotifications.sendBulkWhatsappNotifications(new set<id>{hostelReqs[0].Id});
        HostelRequestStaffNotifications.sendHostelBulkSMS(new set<id>{hostelReqs[0].Id});
        Test.stopTest();
        //Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        //System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
       @IsTest
    static void allotedNotifactionsTest(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id ,Status__c,Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Room Allotted';
        hostelReqs[0].Is_HCM_Salary_Deduction_CNF__c = true;
        update hostelReqs;
        HostelRequestStaffNotifications.sendBulkWhatsappNotifications(new set<id>{hostelReqs[0].Id});
        HostelRequestStaffNotifications.sendHostelBulkSMS(new set<id>{hostelReqs[0].Id});
        Test.stopTest();
        //Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        //System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
     @IsTest
    static void bookedNotifactionsAdminDireTest(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id,Status__c, Approved_by_ReportingManager__c FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Booked';
         hostelReqs[0] .Approved_by_ReportingManager__c= true;
         hostelReqs[0].Approved_by_AdminDirector__c = false;
        update hostelReqs;
        HostelRequestStaffNotifications.sendBulkWhatsappNotifications(new set<id>{hostelReqs[0].Id});
        HostelRequestStaffNotifications.sendHostelBulkSMS(new set<id>{hostelReqs[0].Id});
        Test.stopTest();
        //Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        //System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
     @IsTest
    static void bookedNotifactionsHrTest(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id,Status__c, Approved_by_ReportingManager__c FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Booked';
         hostelReqs[0] .Approved_by_AdminDirector__c= true;
        hostelReqs[0] .Approved_by_ReportingManager__c= true;
         hostelReqs[0].Approved_by_HR_Lead__c = false;
        update hostelReqs;
        HostelRequestStaffNotifications.sendBulkWhatsappNotifications(new set<id>{hostelReqs[0].Id});
        HostelRequestStaffNotifications.sendHostelBulkSMS(new set<id>{hostelReqs[0].Id});
        Test.stopTest();
        //Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        //System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
    
     @IsTest
    static void bookedNotifactionsOfficeTest(){
        List<Reva_Hostel_Request__c> hostelReqs = [SELECT Id,Status__c, Approved_by_ReportingManager__c FROM Reva_Hostel_Request__c LIMIT 1];
        Test.startTest();
        hostelReqs[0].Status__c = 'Booked';
         hostelReqs[0] .Approved_by_HR_Lead__c= true;
        hostelReqs[0] .Approved_by_ReportingManager__c= true;
         hostelReqs[0].Approved_by_Hostel_Office__c = false ;
        update hostelReqs;
        HostelRequestStaffNotifications.sendBulkWhatsappNotifications(new set<id>{hostelReqs[0].Id});
        HostelRequestStaffNotifications.sendHostelBulkSMS(new set<id>{hostelReqs[0].Id});
        Test.stopTest();
        //Reva_Hostel_Request__c updatedRequest = [SELECT Is_HCM_Salary_Deduction_CNF__c FROM Reva_Hostel_Request__c WHERE Id = :hostelReqs[0].Id];
        //System.assertEquals(true, updatedRequest.Is_HCM_Salary_Deduction_CNF__c);
    }
}