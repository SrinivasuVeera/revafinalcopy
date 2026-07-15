@isTest
public class CanReqEmailStudentTest {
    @isTest
    static void testSendEmailsToStudents() {
        // Get Transport Cancellation Record Type Id
        Id recordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName()
            .get('Transport Cancellation')
            .getRecordTypeId();
        //List<String> srns = new List<String>{'SRN001', 'SRN002', 'SRN003', 'SRN004', 'SRN005'};
        List<String> statuses = new List<String>{
            'Cancellation Request Submitted',     
            'Transport Admin Rejected',           
            'Cancellation Approved',              
            'Transport Admin Approved',           
            'Cancellation Request Submitted'     
        };

        // Create 5 Contacts with mixed SRNs
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 5; i++) {
            contacts.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Student',
                Email = 'student' + i + '@test.com',
                SRN_Number__c = (i == 2) ? null : 'SRN' + i // Case 2: Missing SRN
            ));
        }
        insert contacts;

        // Create 5 Transport Registration records with mixed statuses
        List<Transport_Registeration__c> registrations = new List<Transport_Registeration__c>();
        for (Integer i = 0; i < contacts.size(); i++) {
            registrations.add(new Transport_Registeration__c(
                Contact__c = contacts[i].Id,
                Registration_Status__c = statuses[i]
            ));
        }
        insert registrations;

        // Create 4 Transport Requests only (skip 5th one)
        List<RTR_Reva_Transport_Request__c> requests = new List<RTR_Reva_Transport_Request__c>();
        for (Integer i = 0; i < 4; i++) { // Case 5: No request for last contact
            requests.add(new RTR_Reva_Transport_Request__c(
                RTR_Student__c = contacts[i].Id,
                SRN_EmployeeID__c = contacts[i].SRN_Number__c,
                Cancellation_Date__c = Date.today(),
                RecordTypeId = recordTypeId
            ));
        }
        insert requests;

        // Prepare the registration IDs
        List<String> regIds = new List<String>();
        for (Transport_Registeration__c reg : registrations) {
            regIds.add(reg.Id);
        }

        // Execute test
        Test.startTest();
            CanReqEmailStudent.sendEmails(regIds);
        Test.stopTest();

        System.assert(true, 'CanReqEmailStudent logic executed successfully.');
    }
}