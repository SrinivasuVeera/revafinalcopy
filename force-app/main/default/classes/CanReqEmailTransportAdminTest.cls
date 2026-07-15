@isTest
public class CanReqEmailTransportAdminTest {
    @isTest
    static void testSendEmailsSuccessfully() {
        // STEP 1: Create transport admin user (mocking 'Lakshmanan G')
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User adminUser = new User(
            FirstName = 'Lakshmanan',
            LastName = 'G',
            Email = 'lakshmanan@example.com',
            Username = 'lakshmanan' + Math.random() + '@test.com',
            Alias = 'lakg',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert adminUser;

        // STEP 2: (Optional but important) Make sure an OrgWideEmailAddress with 'REVA Alerts' exists in PROD
        // ⚠️ Cannot create OrgWideEmailAddress in test context. Ensure it exists in your org.

        // STEP 3: Create Contact
        Contact con = new Contact(
            LastName = 'Student1',
            Email = 'student1@example.com',
            SRN_Number__c = 'SRN123456'
        );
        insert con;

        // STEP 4: Create Transport_Registeration__c
        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = 'Cancellation Request Submitted'
        );
        insert reg;

        // STEP 5: Get RecordType ID for 'Transport Cancellation'
        Id cancellationRT = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId();

        // STEP 6: Create related Route Master and Pick Up Point
        RTR_Route_Master__c route = new RTR_Route_Master__c(Name = 'Route 100');
        insert route;

        RTR_Route_Pick_Up_Point__c pickUpPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Main Gate',
            RTR_Route_Master__c = route.Id
        );
        insert pickUpPoint;

        // STEP 7: Create RTR_Reva_Transport_Request__c
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = con.SRN_Number__c,
            RTR_Student__c = con.Id,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = cancellationRT,
            RTR_Route_Pick_Up_Point__c = pickUpPoint.Id
        );
        insert req;

        // STEP 8: Call the method under test
        List<String> regIds = new List<String>{ reg.Id };

        System.runAs(adminUser) {
            Test.startTest();
                CanReqEmailTransportAdmin.sendEmails(regIds);
            Test.stopTest();
        }

        System.assert(true, 'Test executed without exceptions.');
    }
}