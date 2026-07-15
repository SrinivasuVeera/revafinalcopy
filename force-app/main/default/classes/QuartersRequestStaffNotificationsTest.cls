@isTest
public class QuartersRequestStaffNotificationsTest {

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
            Username = 'teyy4674stuserrrrr7bhdsjrstaff001@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuserrrr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            MobilePhone = '98765432109',
            EmailEncodingKey = 'UTF-8',
            ProfileId =nonTeachingProfileId,
            ContactId =testContact2.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        Staff_Quarters_Room__c stRooms = new Staff_Quarters_Room__c();
        stRooms.Floor__c ='Ground Floor';
        stRooms.Availability__c = true;
        stRooms.Type__c ='2 BHK';
        insert stRooms;
        
        // Create a Reva_Hostel_Request__c record with required fields
        Staff_Quarters_Request__c quaterRequest = new Staff_Quarters_Request__c();
        quaterRequest.Quarter_Request_For__c = testContact.Id;
        quaterRequest.Employee_Salary__c = 5000;
        quaterRequest.Type__c ='2 BHK';
        //quaterRequest.Staff_Quarters_Room__c = stRooms.Id;
        //quaterRequest.HCM_Approval_Status__c = 'Deduction Approved';
        quaterRequest.Staff_Quarters_Joining_Date__c = Date.today();
        quaterRequest.Quarters_Request_Type__c = 'NonTeachingStaff';
        quaterRequest.Admin_Director__c = testUser.Id;
         quaterRequest.HR_Lead__c = testUser.Id;
         quaterRequest.Reporting_Manager__c = testUser.Id;
         quaterRequest.Hostel_Officer__c = testUser.Id;
        insert quaterRequest;
    }
    
    @IsTest
    static void bookedNotificationTest(){
        List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        Test.startTest();
        quaterReqs[0].Status__c = 'Booked';
       quaterReqs[0].Approved_by_ReportingManager__c = false;
        update quaterReqs;
        QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(new set<id>{quaterReqs[0].Id});
        QuartersRequestStaffNotifications.sendHostelBulkSMS(new set<id>{quaterReqs[0].Id});
        Test.stopTest();
       
    }
    
         @IsTest
    static void allotedNotifactionsTest(){
    List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        Test.startTest();
        quaterReqs[0].Status__c = 'Room Allotted';
        quaterReqs[0].Is_HCM_Salary_Deduction_CNF__c = true;
        update quaterReqs;
        QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(new set<id>{quaterReqs[0].Id});
        QuartersRequestStaffNotifications.sendHostelBulkSMS(new set<id>{quaterReqs[0].Id});
        Test.stopTest();
    }
    
      @IsTest
    static void bookedNotifactionsAdminDireTest(){
      List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        Test.startTest();
        quaterReqs[0].Status__c = 'Booked';
        quaterReqs[0] .Approved_by_ReportingManager__c= true;
        quaterReqs[0].Approved_by_AdminDirector__c = false;
        update quaterReqs;
        QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(new set<id>{quaterReqs[0].Id});
        QuartersRequestStaffNotifications.sendHostelBulkSMS(new set<id>{quaterReqs[0].Id});
        Test.stopTest();
    }
    
     @IsTest
    static void bookedNotifactionsHrTest(){
      List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        Test.startTest();
        quaterReqs[0].Status__c = 'Booked';
        quaterReqs[0] .Approved_by_AdminDirector__c= true;
        quaterReqs[0] .Approved_by_ReportingManager__c= true;
         quaterReqs[0].Approved_by_HR_Lead__c = false;
        update quaterReqs;
        QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(new set<id>{quaterReqs[0].Id});
        QuartersRequestStaffNotifications.sendHostelBulkSMS(new set<id>{quaterReqs[0].Id});
        Test.stopTest();
    }
    
     @IsTest
    static void bookedNotifactionsOfficeTest(){
 List<Staff_Quarters_Request__c> quaterReqs = [SELECT Id ,HCM_Approval_Status__c FROM Staff_Quarters_Request__c LIMIT 1];
        Test.startTest();
        quaterReqs[0].Status__c = 'Approved';
        quaterReqs[0] .Approved_by_HR_Lead__c= true;
        quaterReqs[0] .Approved_by_ReportingManager__c= true;
         quaterReqs[0].Approved_by_Hostel_Office__c = true;
        quaterReqs[0].Is_HCM_Salary_Deduction_CNF__c = true;
        update quaterReqs;
        QuartersRequestStaffNotifications.sendQuarterBulkWhatsappNotifications(new set<id>{quaterReqs[0].Id});
        QuartersRequestStaffNotifications.sendHostelBulkSMS(new set<id>{quaterReqs[0].Id});
        Test.stopTest();
    }
}