@isTest
public class RevaHosteLeaveRequestControllerTest {
    @isTest
    static void testGetApprovalHistory() {
        
         Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Professor' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuserteaching@example.com',
            FirstName = 'Test',
            LastName = 'User',
            CompanyName = 'Test Company'
        );
        insert testUser;
        // Setup: Create Contact and Staff Quarters Request
        RecordType professorRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Professor' LIMIT 1];
        Contact testContact = new Contact(
            LastName = 'Test',
            FirstName = 'Professor',
            hed__WorkEmail__c = 'test@gmail.com',
            MobilePhone = '1234567890',
            RecordTypeId = professorRecordType.Id
        );
        insert testContact;

        Staff_Quarters_Request__c quartersReq = new Staff_Quarters_Request__c(
            Type__c = '2 BHK',
            Staff_Quarters_Joining_Date__c = System.today(),
            Status__c = 'Booked',
            Employee_Salary__c = 500.00,
            Quarter_Request_For__c = testContact.Id,
            Quarters_Request_Type__c ='TeachingStaff',
            HR_Lead__c=testUser.Id,
            Hostel_Officer__c=testUser.Id,
            Admin_Director__c	=testUser.Id,
            Reporting_Manager__c =testUser.Id
        );
        insert quartersReq;

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(quartersReq.Id);
        req.setComments('Submitting for approval.');
        Approval.ProcessResult result = Approval.process(req);

        if (!result.getNewWorkItemIds().isEmpty()) {
            Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();
            workItemRequest.setAction('Approve');
            workItemRequest.setComments('Approved.');
            workItemRequest.setWorkItemId(result.getNewWorkItemIds()[0]);
            Approval.process(workItemRequest);
        }

        // Test: Fetch approval history
        Test.startTest();
        List<RevaHosteLeaveRequestController.ApprovalHistoryWrapper> approvalHistory =
            RevaHosteLeaveRequestController.getApprovalHistory(quartersReq.Id);
        Test.stopTest();

        System.assertNotEquals(null, approvalHistory, 'Approval history should not be null.');
        System.assert(approvalHistory.size() > 0, 'Approval history should contain steps or pending items.');
    }
}