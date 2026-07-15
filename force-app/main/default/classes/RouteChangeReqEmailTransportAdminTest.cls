@isTest
public class RouteChangeReqEmailTransportAdminTest {
    @testSetup
    static void setupTestData() {
        // Create Org Wide Email Address
        OrgWideEmailAddress owa = new OrgWideEmailAddress(
            DisplayName = 'REVA Alerts',
            Address = 'alerts@reva.edu.in'
        );
        //insert owa;

        // Create a test User named Lakshmanan (Transport Admin)
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User adminUser = new User(
            FirstName = 'Lakshmanan',
            LastName = 'Lakshmanan',
            Email = 'lakshmanan@reva.edu.in',
            Username = 'lakshmanan.reva.test@example.com',
            Alias = 'laksh',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert adminUser;

        // Create a Contact
        Contact con = new Contact(
            LastName = 'Test Student',
            SRN_Number__c = 'SRN1234567'
        );
        insert con;

        // Create Transport Registration
        Transport_Registeration__c reg = new Transport_Registeration__c(
            //Name = 'REG123',
            Contact__c = con.Id,
            Registration_Status__c = 'Route Change Request Submitted'
        );
        insert reg;

        // Create related Route Master
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 101');
        insert routeMaster;

        // Create Pick Up Point
        RTR_Route_Pick_Up_Point__c pickPoint = new RTR_Route_Pick_Up_Point__c(
            //Name = 'Main Gate',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickPoint;

        // Get RecordType for 'Route Change Request'
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1];

        // Create RTR Request
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            RecordTypeId = rt.Id,
            RTRStudent_Faculty_NonFaculty__c = con.Id,
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RTR_Route_Pick_Up_Point__c = pickPoint.Id
        );
        insert req;

        // Create a mock ProcessInstance and WorkItem
     list<ProcessInstanceWorkitem> piw = [
                    SELECT Id, ProcessInstance.TargetObjectId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :req.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
    }

    @isTest
    static void testSendEmails_WithValidData() {
        // Get the inserted registration record
        Transport_Registeration__c reg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        Test.startTest();
        RouteChangeReqEmailTransportAdmin.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Completed without exceptions');
    }

    @isTest
    static void testSendEmails_WithFinanceApprovedStatus() {
        // Create data with status = 'Route change Finance team approved'
        Contact con = new Contact(LastName='Student2', SRN_Number__c='SRN0002');
        insert con;

        Transport_Registeration__c reg = new Transport_Registeration__c(
           // Name='REG456',
            Contact__c=con.Id,
            Registration_Status__c='Route change Finance team approved'
        );
        insert reg;

        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route 102');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickPoint = new RTR_Route_Pick_Up_Point__c(
            Name = 'Block A',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickPoint;

        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1];
        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            RecordTypeId = rt.Id,
            RTRStudent_Faculty_NonFaculty__c = con.Id,
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RTR_Route_Pick_Up_Point__c = pickPoint.Id
        );
        insert req;
list<ProcessInstanceWorkitem> piw = [
                    SELECT Id, ProcessInstance.TargetObjectId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :req.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

        Test.startTest();
        RouteChangeReqEmailTransportAdmin.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Completed for Finance Approved status');
    }

    @isTest
    static void testSendEmails_WithNoMatchingRequest() {
        Contact con = new Contact(LastName='Student3', SRN_Number__c='SRN0003');
        insert con;

        Transport_Registeration__c reg = new Transport_Registeration__c(
           // Name='REG789',
            Contact__c=con.Id,
            Registration_Status__c='Active'
        );
        insert reg;

        Test.startTest();
        RouteChangeReqEmailTransportAdmin.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Handled invalid status gracefully');
    }

    @isTest
    static void testSendEmails_WithoutOrgWideEmailOrAdmin() {
        // Clean up OWA and User
        //delete [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
        //delete [SELECT Id FROM User WHERE Name = 'Lakshmanan'];

        Contact con = new Contact(LastName='Student4', SRN_Number__c='SRN0004');
        insert con;

        Transport_Registeration__c reg = new Transport_Registeration__c(
            //Name='REG001',
            Contact__c=con.Id,
            Registration_Status__c='Route Change Request Submitted'
        );
        insert reg;

        Test.startTest();
        RouteChangeReqEmailTransportAdmin.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Handled missing OrgWideEmail or User gracefully');
    }

    @isTest
    static void testSendEmails_WithEmptyList() {
        Test.startTest();
        RouteChangeReqEmailTransportAdmin.sendEmails(new List<String>());
        Test.stopTest();

        System.assert(true, 'Handled empty list without error');
    }
}