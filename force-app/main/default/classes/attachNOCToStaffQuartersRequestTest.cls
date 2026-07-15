@isTest
public class attachNOCToStaffQuartersRequestTest {

     public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.debug('req--->'+req.getEndpoint());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req--- ins>');
            res.setBody('{"Employee_Number":"12345", "Employee_Name":"John Doe", "Salary_Range":1000.0}');
            res.setStatusCode(200);
            return res;
        }
    }

    
    @isTest
    static void testCreateStaffQuartersRequestAttachment() {
        // Create test data
        Profile wardenProfile = [SELECT Id FROM Profile WHERE Name = 'Warden' LIMIT 1];
        
        User testUser = new User(
            LastName = 'Test warden',
            Username = 'testuserWarden@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = wardenProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CommunityNickname = 'testuser'
        );
        insert testUser;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = testUser.Email);
        insert testContact;
        Staff_Quarters_Request__c testRequest = new Staff_Quarters_Request__c(
            Room_Request_For__c = testUser.Id,
            Type__c = '1 BHK',
            Status__c = 'Room Allotted',
            Quarter_Request_For__c =testContact.Id
        );
        insert testRequest;
        
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        attachNOCToStaffQuatresRequest.createStaffQuartersRequestAttachment(testRequest.Id);
        Test.stopTest();
        
        // Verify Attachment creation
        List<Attachment> attachments = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId = :testRequest.Id];
        System.assertEquals(1, attachments.size(), 'One attachment should have been created.');
        System.assertEquals('HostelManagementNOC.pdf', attachments[0].Name, 'Attachment name should be correct.');
        System.assertEquals('This is a mock PDF content for testing.', attachments[0].Body.toString(), 'Attachment body should match the mock PDF content.');
    }
}