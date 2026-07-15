@isTest
public class CanReqEmailParentTest {

    @isTest
    static void testSendEmailsToParents() {
        // Step 1: Create Parent Contacts
        List<Contact> parents = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            parents.add(new Contact(
                FirstName = 'Parent' + i,
                LastName = 'Test',
                Email = 'parent' + i + '@test.com'
            ));
        }
        insert parents;

        // Step 2: Create Student Contacts and link to parents
        List<Contact> students = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            students.add(new Contact(
                FirstName = 'Student' + i,
                LastName = 'Test',
                Email = 'student' + i + '@test.com',
                Father__c = parents[i].Id,
                Parent_Name__c = parents[i].FirstName + ' ' + parents[i].LastName,
                SRN_Number__c = 'SRN10' + i
            ));
        }
        insert students;

        // Step 3: Create Transport Registration records
        List<Transport_Registeration__c> registrations = new List<Transport_Registeration__c>();
        List<String> statuses = new List<String>{
            'Cancellation Request Submitted',
            'Cancellation Approved',
            'Transport Admin Rejected',
            'Cancellation Approved',
            'Transport Admin Approved'
        };
        for (Integer i = 0; i < 5; i++) {
            registrations.add(new Transport_Registeration__c(
                Contact__c = students[i].Id,
                Registration_Status__c = statuses[i]
            ));
        }
        insert registrations;

        // Step 4: Create RTR_Reva_Transport_Request__c records
        Id recordTypeId = Schema.SObjectType.RTR_Reva_Transport_Request__c
            .getRecordTypeInfosByName().get('Transport Cancellation').getRecordTypeId();

        List<RTR_Reva_Transport_Request__c> transportRequests = new List<RTR_Reva_Transport_Request__c>();
        for (Integer i = 0; i < 5; i++) {
            transportRequests.add(new RTR_Reva_Transport_Request__c(
                RTR_Student__c = students[i].Id,
                SRN_EmployeeID__c = students[i].SRN_Number__c,
                Cancellation_Date__c = Date.today(),
                RecordTypeId = recordTypeId,
                RTR_Status__c = statuses[i]
            ));
        }
        insert transportRequests;

        // Step 5: Collect registration record IDs
        List<String> regIds = new List<String>();
        for (Transport_Registeration__c reg : registrations) {
            regIds.add(reg.Id);
        }

        // Step 6: Execute the method under test
        Test.startTest();
            CanReqEmailParent.sendEmails(regIds);
        Test.stopTest();
    }
}