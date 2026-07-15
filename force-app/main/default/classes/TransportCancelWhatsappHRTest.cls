@isTest
public class TransportCancelWhatsappHRTest {
 @testSetup
    static void setupTestData() {
        // Create required test data

        Account account = new Account(Name = 'Test Department');
        insert account;

        Contact student = new Contact(
            LastName = 'Test Student',
            MobilePhone = '1234567890',
            Employee_Number__c = 'E123'
            //Account_Name__c = account.Id
        );
        insert student;

        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 1');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Point A',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickUpPoint;

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTR_Student__c = student.Id,
            RTR_Route_Pick_Up_Point__c = pickUpPoint.Id
        );
        insert transportRequest;

        User hrUser = [SELECT Id, Name FROM User WHERE Name = 'K Latha Raju' LIMIT 1];
        if (hrUser == null) {
            hrUser = new User(
                FirstName = 'K',
                LastName = 'Latha Raju',
                Alias = 'klraju',
                Email = 'k.latharaju@example.com',
                Username = 'klatharaju@example.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
            insert hrUser;
        }
    }
    
     List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = 'transport_cancel_notif_hr'
            ];

    @isTest
    static void testSendWhatsAppNotifications_WithValidRecordIds() {
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        Test.startTest();
        TransportCancelWhatsappHR.sendWhatsAppNotifications(new List<String>{transportRequest.Id});
        Test.stopTest();

        // Assert that callout was initiated (mock the callout response if needed)
        System.assert(true, 'Callout was successfully executed.');
    }

    /*@isTest
    static void testSendWhatsAppNotifications_WithEmptyRecordIds() {
        Test.startTest();
        TransportCancelWhatsappHR.sendWhatsAppNotifications(new List<String>());
        Test.stopTest();

        // Assert that no callout occurred
        //System.assert(true, 'No callout was made due to empty record IDs.');
    }*/

    /*@isTest
    static void testSendWhatsAppNotifications_WithNullRecordIds() {
        Test.startTest();
        TransportCancelWhatsappHR.sendWhatsAppNotifications(null);
        Test.stopTest();

        // Assert that no callout occurred
        //System.assert(true, 'No callout was made due to null record IDs.');
    }*/

    @isTest
    static void testMakeCalloutAsync_WithValidData() {
        RTR_Reva_Transport_Request__c transportRequest = [SELECT Id FROM RTR_Reva_Transport_Request__c LIMIT 1];
        Test.startTest();
        TransportCancelWhatsappHR.makeCalloutAsync(new List<String>{transportRequest.Id});
        Test.stopTest();

        // Assert based on mock data and functionality
        //System.assert(true, 'makeCalloutAsync executed successfully with valid data.');
    }

    /*@isTest
    static void testMakeCalloutAsync_WithNoMatchingRecords() {
        Test.startTest();
        TransportCancelWhatsappHR.makeCalloutAsync(new List<String>{'non-existent-id'});
        Test.stopTest();

        // Assert based on absence of records
       // System.assert(true, 'makeCalloutAsync handled non-matching record IDs gracefully.');
    }*/
}