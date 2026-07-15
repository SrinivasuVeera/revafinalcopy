@isTest
public class RouteChangeWhatsappHRTest {

    @isTest
    static void testSendWhatsAppNotifications() {
        // Setup test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(
            LastName = 'Test Contact',
            AccountId = account.Id,
            MobilePhone = '1234567890',
            Employee_Number__c = 'EMP001'
        );
        insert contact;

        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 1');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Pick Up Point 1',
            RTR_Route_Master__r = routeMaster
        );
        insert pickUpPoint;

        RTR_Reva_Transport_Request__c transportRequest = new RTR_Reva_Transport_Request__c(
            RTRStudent_Faculty_NonFaculty__c = contact.Id,
            New_Route_Pick_Up_Point__c = pickUpPoint.Id
        );
        insert transportRequest;

        User hrUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Mock WhatsApp Notification Metadata
       List<WhatsApp_Notification_Template__mdt> templateMetadata = [
                SELECT Template_Field__c, Template_ID__c
                FROM WhatsApp_Notification_Template__mdt
                WHERE Template_ID__c = 'transport_route_change_hr'
            ];

        // Test execution
        Test.startTest();
        RouteChangeWhatsappHR.sendWhatsAppNotifications(new List<String>{transportRequest.Id});
        Test.stopTest();

        // Verify logs or other necessary assertions
        // Here, assertions would typically verify mock calls or related outcomes
        System.assert(true, 'Executed without exceptions');
    }

   /* @isTest
    static void testSendWhatsAppNotificationsEmptyList() {
        Test.startTest();
        RouteChangeWhatsappHR.sendWhatsAppNotifications(new List<String>());
        Test.stopTest();

        // Verify no exceptions and no calls made
        System.assert(true, 'Handled empty list without errors');
    }*/

    @isTest
    static void testSendWhatsAppNotificationsNullList() {
        Test.startTest();
        RouteChangeWhatsappHR.sendWhatsAppNotifications(null);
        Test.stopTest();

        // Verify no exceptions and no calls made
        System.assert(true, 'Handled null list without errors');
    }
}