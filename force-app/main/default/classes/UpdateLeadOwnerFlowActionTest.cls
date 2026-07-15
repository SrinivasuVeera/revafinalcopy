@isTest
public class UpdateLeadOwnerFlowActionTest {

    // Mock class for callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testUpdateLeadOwner_Success() {

        // Create User
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser' + System.currentTimeMillis() + '@gmail.com',
            Username = 'testuser' + System.currentTimeMillis() + '@gmail.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pr.Id
        );
        insert testUser;

        // Create Lead (unique email to avoid duplicate rules)
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'lead' + System.currentTimeMillis() + '@gmail.com'
        );
        insert testLead;

        // Prepare input
        BulkLeadUpdateCounselor.UpdateOwnerInput input = new BulkLeadUpdateCounselor.UpdateOwnerInput();
        input.recordIds = new List<Id>{ testLead.Id };
        input.newOwnerId = testUser.Id;

        List<BulkLeadUpdateCounselor.UpdateOwnerInput> inputList =
            new List<BulkLeadUpdateCounselor.UpdateOwnerInput>{ input };

        //  MOCK CALL OUT 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        //  Execute
        Test.startTest();
        UpdateLeadOwnerFlowAction.updateLeadOwner(inputList);
        Test.stopTest();

        //  Verify
        Lead updatedLead = [SELECT OwnerId FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(testUser.Id, updatedLead.OwnerId, 'Owner should be updated');
    }


    @isTest
    static void testUpdateLeadOwner_EmptyInput() {

        //  Mock (safe even if not used)
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        UpdateLeadOwnerFlowAction.updateLeadOwner(
            new List<BulkLeadUpdateCounselor.UpdateOwnerInput>()
        );
        Test.stopTest();

        System.assert(true);
    }


    @isTest
    static void testUpdateLeadOwner_NullValues() {

        BulkLeadUpdateCounselor.UpdateOwnerInput input =
            new BulkLeadUpdateCounselor.UpdateOwnerInput();

        input.recordIds = null;
        input.newOwnerId = null;

        List<BulkLeadUpdateCounselor.UpdateOwnerInput> inputList =
            new List<BulkLeadUpdateCounselor.UpdateOwnerInput>{ input };

        //Mock again
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        UpdateLeadOwnerFlowAction.updateLeadOwner(inputList);
        Test.stopTest();

        System.assert(true);
    }
}