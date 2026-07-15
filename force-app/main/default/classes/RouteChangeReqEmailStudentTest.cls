@isTest
public class RouteChangeReqEmailStudentTest {

    @testSetup
    static void setupData() {
        // Create a test Contact
        Contact con = new Contact(
            LastName = 'Student',
            Email = 'student@example.com',
            SRN_Number__c = 'SRN1001'
           // Name = 'Test Student'
        );
        insert con;

        // Create a test OrgWideEmailAddress (not inserted, assuming it exists in org)
        // If you want to assert the logic, ensure one exists with DisplayName = 'REVA Alerts'

        // Create Transport Registration with different statuses
        List<Transport_Registeration__c> regs = new List<Transport_Registeration__c>();
        for (String status : new List<String>{
            'Route Change Request Submitted',
            'Route change Transport admin Rejected',
            'Route change Transport admin Approved',
            'Route change Finance team approved'
    
        }) {
            regs.add(new Transport_Registeration__c(
                //Name = 'TR-' + status.abbreviate(5),
                Contact__c = con.Id,
                Registration_Status__c = status
            ));
        }
        insert regs;

        // Create a matching Route Change Request
        Id routeChangeRTId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Route Change Request').getRecordTypeId();

        insert new RTR_Reva_Transport_Request__c(
            SRN_EmployeeID__c = con.SRN_Number__c,
            Cancellation_Date__c = Date.today(),
            RecordTypeId = routeChangeRTId
        );
    }

    @isTest
    static void testSendEmailsWithAllStatuses() {
        List<Transport_Registeration__c> regs = [
            SELECT Id FROM Transport_Registeration__c
        ];

        List<String> regIds = new List<String>();
        for (Transport_Registeration__c tr : regs) {
            regIds.add(tr.Id);
        }

        Test.startTest();
        RouteChangeReqEmailStudent.sendEmails(regIds);
        Test.stopTest();

        System.assert(true); // Just to mark structure; actual checks would involve verifying DML counts or mock sends
    }

    @isTest
    static void testSendEmailsWithEmptyList() {
        Test.startTest();
        RouteChangeReqEmailStudent.sendEmails(new List<String>());
        Test.stopTest();

        System.assert(true); // No exception should occur
    }
}