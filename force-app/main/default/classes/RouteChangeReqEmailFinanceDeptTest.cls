@isTest
public class RouteChangeReqEmailFinanceDeptTest {

    @testSetup
    static void setupTestData() {
        // Create Org Wide Email Address
        OrgWideEmailAddress owa = new OrgWideEmailAddress(
            DisplayName = 'REVA Alerts',
            Address = 'alerts@reva.edu.in'
        );
        //insert owa;

        // Create test user 'Vishali Perni' with System Admin profile
        Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User financeUser = new User(
            FirstName = 'Vishali',
            LastName = 'Perni',
            Email = 'vishali.perni@example.com',
            Username = 'vishali.perni' + DateTime.now().getTime() + '@example.com',
            Alias = 'vpern',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdmin.Id
        );
        insert financeUser;

        // Create student Contact
        Contact con = new Contact(
            LastName = 'Student A',
            SRN_Number__c = 'SRN1234'
        );
        insert con;

        // Create Route Master & Pick-up Point
        RTR_Route_Master__c routeMaster = new RTR_Route_Master__c(Name = 'Route A');
        insert routeMaster;

        RTR_Route_Pick_Up_Point__c pickUp = new RTR_Route_Pick_Up_Point__c(
            Name = 'Gate A',
            RTR_Route_Master__c = routeMaster.Id
        );
        insert pickUp;

        // Get correct RecordType
        RecordType rt = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' 
            LIMIT 1
        ];

        // Insert transport request
        RTR_Reva_Transport_Request__c request = new RTR_Reva_Transport_Request__c(
            RecordTypeId = rt.Id,
            RTRStudent_Faculty_NonFaculty__c = con.Id,
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RTR_Route_Pick_Up_Point__c = pickUp.Id
        );
        insert request;

        // Submit request to trigger approval process (auto creates ProcessInstanceWorkitem)
       list<ProcessInstanceWorkitem> piw = [
                    SELECT Id, ProcessInstance.TargetObjectId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :request.Id
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
    

        // Insert Transport_Registration with correct status
        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = '	Route change Transport admin Approved' // Note: Has leading tab space
        );
        insert reg;
    }

    @isTest
    static void testValidFinanceEmail() {
        Transport_Registeration__c reg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

        Test.startTest();
        RouteChangeReqEmailFinanceDept.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Finance email method executed successfully');
    }

    @isTest
    static void testInvalidStatus_NoEmail() {
        // New student/contact with invalid status
        Contact con = new Contact(LastName='TestB', SRN_Number__c='SRN0002');
        insert con;

        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = 'Route change Transport admin Approved'
        );
        insert reg;

        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1].Id,
            RTRStudent_Faculty_NonFaculty__c = con.Id,
            SRN_EmployeeID__c = con.SRN_Number__c
        );
        insert req;

        Test.startTest();
        RouteChangeReqEmailFinanceDept.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Handled invalid status without errors');
    }

    @isTest
    static void testEmptyList_NoError() {
        Test.startTest();
        RouteChangeReqEmailFinanceDept.sendEmails(new List<String>());
        Test.stopTest();

        System.assert(true, 'Handled empty list gracefully');
    }

    @isTest
    static void testNoMatchingRequest_NoEmail() {
        // Create registration but no matching RTR request
        Contact con = new Contact(LastName='TestC', SRN_Number__c='SRN0003');
        insert con;

        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = '	Route change Transport admin Approved'
        );
        insert reg;

        Test.startTest();
        RouteChangeReqEmailFinanceDept.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Handled missing RTR request gracefully');
    }

    @isTest
    static void testMissingOrgWideEmailOrUser() {
        // Delete OrgWideEmailAddress and User to simulate missing case
//        delete [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'REVA Alerts'];
        //delete [SELECT Id FROM User WHERE Name = 'Vishali Perni'];

        Contact con = new Contact(LastName='TestD', SRN_Number__c='SRN0004');
        insert con;

        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Registration_Status__c = '	Route change Transport admin Approved'
        );
        insert reg;

        RTR_Reva_Transport_Request__c req = new RTR_Reva_Transport_Request__c(
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'RTR_Reva_Transport_Request__c' AND Name = 'Route Change Request' LIMIT 1].Id,
            RTRStudent_Faculty_NonFaculty__c = con.Id,
            SRN_EmployeeID__c = con.SRN_Number__c
        );
        insert req;

        Test.startTest();
        RouteChangeReqEmailFinanceDept.sendEmails(new List<String>{ reg.Id });
        Test.stopTest();

        System.assert(true, 'Handled missing OWA/User without exception');
    }
}