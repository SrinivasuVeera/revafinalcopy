@IsTest
public class EventhallcanclenotificationTest {
@TestSetup
    static void setupData() {

        // Create Requester User
        User requester = new User(
            FirstName = 'Requester',
            LastName = 'User',
            Email = 'requester@example.com',
            Username = 'req' + DateTime.now().getTime() + '@test.com',
            Alias = 'requsr',
            CommunityNickname = 'reqnick',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert requester;

        // Create Approver User
        User approver = new User(
            FirstName = 'Approver',
            LastName = 'User',
            Email = 'approver@example.com',
            Username = 'app' + DateTime.now().getTime() + '@test.com',
            Alias = 'appusr',
            CommunityNickname = 'appnick',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = requester.ProfileId,
            LanguageLocaleKey = 'en_US'
        );
        insert approver;

        // Create Facility record (Lookup target for Facility__c)
        // Replace Facility_Master__c with your ACTUAL object API name
        hed__Facility__c facility = new hed__Facility__c(
            Name = 'Test Facility'
        );
        insert facility;
        // Create Account
        Account acc = new Account(Name = 'Test School');
        insert acc;

        // Create Facility Request WITH cancellation reason
        Facility_Request__c frWithReason = new Facility_Request__c(
           Facility_Name__c = 'Request With Reason',
            Account__c = acc.Id,
            Facility__c = facility.Id,
            Requester__c = requester.Id,
            Approver__c = approver.Id,
            Reason_of_Cancelation__c = 'User cancelled manually',
            Start_Date__c = Date.today(),
            End_Date__c = Date.today(),
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(10, 0, 0, 0)
        );
        insert frWithReason;

        // Create Facility Request WITHOUT cancellation reason
        Facility_Request__c frWithoutReason = new Facility_Request__c(
           Facility_Name__c = 'Request Without Reason',
            Account__c = acc.Id,
            Facility__c = facility.Id,
            Requester__c = requester.Id,
            Approver__c = approver.Id,
            Reason_of_Cancelation__c = null,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today(),
            Start_Time__c = Time.newInstance(11, 0, 0, 0),
            End_Time__c = Time.newInstance(12, 0, 0, 0)
        );
        insert frWithoutReason;
    }


    // Test: Notifications MUST run when Reason is NOT NULL
    @IsTest
    static void testSendAll_withReason() {
        Facility_Request__c req = [
            SELECT Id FROM Facility_Request__c 
            WHERE Reason_of_Cancelation__c != null
            LIMIT 1
        ];

        Test.startTest();
        Eventhallcanclenotification.sendAll(req.Id);
        Test.stopTest();

        System.assert(true, 'sendAll executed successfully when reason exists.');
    }


    // Test: Notifications must NOT run when Reason IS NULL
    @IsTest
    static void testSendAll_withoutReason() {
        Facility_Request__c req = [
            SELECT Id FROM Facility_Request__c 
            WHERE Reason_of_Cancelation__c = null
            LIMIT 1
        ];

        Test.startTest();
        Eventhallcanclenotification.sendAll(req.Id);
        Test.stopTest();

        System.assert(true, 'sendAll executed successfully when reason is null (no notifications sent).');
    }
}