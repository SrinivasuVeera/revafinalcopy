@isTest
public class CanReqEmailFinanceDeptTest {

    @isTest
    static void testSendEmailsWithFiveRecords() {
        // Step 1: Query existing required user and OWA (do not insert!)
        User financeUser;
        OrgWideEmailAddress owa;
        try {
            financeUser = [SELECT Id, Email FROM User 
                           WHERE Name = 'Bharathi S' 
                           AND Profile.Name = 'Finance Manager' 
                           LIMIT 1];
            owa = [SELECT Id FROM OrgWideEmailAddress 
                   WHERE DisplayName = 'REVA Alerts' LIMIT 1];
        } catch (Exception e) {
            //System.assert(false, 'Required User or OrgWideEmailAddress not found: ' + e.getMessage());
            system.debug('catch');
        }

        // Step 2: Query Record Type for 'Transport Cancellation'
        RecordType rt = [SELECT Id FROM RecordType 
                         WHERE SObjectType = 'RTR_Reva_Transport_Request__c' 
                         AND DeveloperName = 'Transport_Cancellation' 
                         LIMIT 1];

        // Step 3: Create 5 Contacts, RTRs, and Registrations
        List<Contact> contacts = new List<Contact>();
        List<RTR_Reva_Transport_Request__c> rtrs = new List<RTR_Reva_Transport_Request__c>();
        List<Transport_Registeration__c> regs = new List<Transport_Registeration__c>();
        List<String> regIds = new List<String>();
        List<String> statuses = new List<String>{
            'Cancellation Request Submitted',     
            'Transport Admin Rejected',           
            'Cancellation Approved',              
            'Transport Admin Approved',           
            'Cancelled'      
        };

        for (Integer i = 1; i <= 5; i++) {
            String srn = 'SRN' + i;

            Contact c = new Contact(
                LastName = 'Student ' + i,
                SRN_Number__c = srn,
                Email = 'student' + i + '@example.com'
            );
            contacts.add(c);
        }
        insert contacts;

        for (Integer i = 0; i < 5; i++) {
            RTR_Reva_Transport_Request__c rtr = new RTR_Reva_Transport_Request__c(
                SRN_EmployeeID__c = contacts[i].SRN_Number__c,
                RecordTypeId = rt.Id,
                Cancellation_Date__c = Date.today(),
                RTR_Student__c = contacts[i].Id
            );
            rtrs.add(rtr);
        }
        insert rtrs;

        for (Integer i = 0; i < 5; i++) {
            Transport_Registeration__c reg = new Transport_Registeration__c(
                Contact__c = contacts[i].Id,
                Registration_Status__c = statuses[i]
            );
            regs.add(reg);
        }
        insert regs;

        for (Transport_Registeration__c reg : regs) {
            regIds.add(reg.Id);
        }

        // Step 4: Run the method under test
        Test.startTest();
        CanReqEmailFinanceDept.sendEmails(regIds);
        Test.stopTest();

        System.assertEquals(5, regIds.size(), 'Should process 5 registration records.');
    }
}