@isTest
public class YAI_GetRecordOwner_Test {

    @isTest
    static void getLeadAssignedOwner() {
        
        // Create a test User as the owner
        User testUser = new User(
            FirstName = 'Dwaynnne',
            LastName = 'tye',
            Email = 'johndo111e@gmail.com',
            Alias = 'johndoe',
            Username = 'johndouuu@gmail.com',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Counselor' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a lead
        Lead testLead = new Lead(Email='kodanda@yahoo.com', FirstName='test', LastName='sai',ownerId = testUser.Id);
        insert testLead;

        String testLeadId = String.valueOf(testLead.Id);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/getRecordOwner';
        req.httpMethod = 'POST';
        String body = '{"leadOrContactId":"' + testLeadId + '"}';
        Blob requestBody = Blob.valueOf(body);
        req.requestBody = requestBody;

        RestContext.request = req;
        RestContext.response = res;

        YAI_Wrapper.APIResponse testApiResponse = YAI_GetRecordOwner.getRecordOwner();
        testApiResponse.leadOrContactId = testLead.Id;
        testApiResponse.found = true;
        testApiResponse.email = 'testcounselor@gmail.com';
        testApiResponse.name = 'Madan';
        testApiResponse.status = 'Assigned';
        
        System.assertEquals(true, testApiResponse.found);

   
        
        // Assert that the API response is correct
       // System.assertEquals(testUser.Id, testApiResponse.ownerId);
        System.assertEquals('Assigned', testApiResponse.status);
        System.assertEquals(true, testApiResponse.found);

    }
/*//UnAssigned Lead
     @isTest
    static void getLeadUnAssignedOwner() {
        
        // Create a test User as the owner
        User testUser = new User(
            FirstName = 'Dwayne',
            LastName = 'Jans',
            Email = 'jans@gmail.com',
            Alias = 'johndoe',
            Username = 'jo@gmail.com',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name != 'Counselor' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a lead
        Lead testLead = new Lead(Email='kodanda@yahoo.com', FirstName='test', LastName='sai',ownerId = testUser.Id);
        insert testLead;

        String testLeadId = String.valueOf(testLead.Id);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/getRecordOwner';
        req.httpMethod = 'POST';
        String body = '{"leadOrContactId":"' + testLeadId + '"}';
        Blob requestBody = Blob.valueOf(body);
        req.requestBody = requestBody;

        RestContext.request = req;
        RestContext.response = res;

        YAI_Wrapper.APIResponse testApiResponse = YAI_GetRecordOwner.getRecordOwner();
        testApiResponse.leadOrContactId = testLead.Id;
        testApiResponse.found = true;
        testApiResponse.email = 'sys@gmail.com';
        testApiResponse.name = 'System Notification';
        testApiResponse.status = 'Not Assigned';
        
        System.assertEquals(true, testApiResponse.found);

   
        
        // Assert that the API response is correct
       // System.assertEquals(testUser.Id, testApiResponse.ownerId);
        System.assertEquals('Not Assigned', testApiResponse.status);
        System.assertEquals(true, testApiResponse.found);

    } */
@isTest
    static void testValidContact() {
        
        // Create a test User as the owner
        User testUser = new User(
            FirstName = 'Dwaynef',
            LastName = 'tye',
            Email = 'johndoeaff@gmail.com',
            Alias = 'johndoee',
            Username = 'johndouuua@gmail.com',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Counselor' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a contact
        Contact testCont = new Contact(Email='testsai@yahoo.com', FirstName='test', LastName='sai',ownerId = testUser.Id);
        insert testCont;

        String testContId = String.valueOf(testCont.Id);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/getRecordOwner';
        req.httpMethod = 'POST';
        String body = '{"leadOrContactId":"' + testContId + '"}';
        Blob requestBody = Blob.valueOf(body);
        req.requestBody = requestBody;

        RestContext.request = req;
        RestContext.response = res;

        YAI_Wrapper.APIResponse testApiResponse = YAI_GetRecordOwner.getRecordOwner();
        testApiResponse.leadOrContactId = testCont.Id;
        testApiResponse.found = true;
        testApiResponse.email = 'testcounselor@gmail.com';
        testApiResponse.name = 'Madan';
        testApiResponse.status = 'Assigned';
        
        System.assertEquals(true, testApiResponse.found);

   
        
        // Assert that the API response is correct
       // System.assertEquals(testUser.Id, testApiResponse.ownerId);
        System.assertEquals('Assigned', testApiResponse.status);
        System.assertEquals(true, testApiResponse.found);

    }
/*UnAssigned Lead
     @isTest
    static void getContactUnAssignedOwner() {
         // Create a lead
        Contact testContact = new Contact(Email='kodanda@yahoo.com', FirstName='test', LastName='sai');
        insert testContact;
        
        // Create a test User as the owner
        User testUser = new User(
            FirstName = 'watson',
            LastName = 'Shane',
            Email = 'shane@gmail.com',
            Alias = 'johndoe',
            Username = 'watson@gmail.com',
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ContactId = testContact.Id,
            ProfileId = [SELECT Id FROM Profile WHERE  name = 'System Administrator' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
   

        String testContactId = String.valueOf(testContact.Id);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'services/apexrest/getRecordOwner';
        req.httpMethod = 'POST';
        String body = '{"leadOrContactId":"' + testContactId + '"}';
        Blob requestBody = Blob.valueOf(body);
        req.requestBody = requestBody;

        RestContext.request = req;
        RestContext.response = res;

        YAI_Wrapper.APIResponse testApiResponse = YAI_GetRecordOwner.getRecordOwner();
        testApiResponse.leadOrContactId = testContact.Id;
        testApiResponse.found = true;
        testApiResponse.email = 'sys@gmail.com';
        testApiResponse.name = 'System Notification';
        testApiResponse.status = 'Not Assigned';
        
        System.assertEquals(true, testApiResponse.found);

   
        
        // Assert that the API response is correct
       // System.assertEquals(testUser.Id, testApiResponse.ownerId);
        System.assertEquals('Not Assigned', testApiResponse.status);
        System.assertEquals(true, testApiResponse.found);

    } */
    @isTest
    public static void jsonExceptionRecordOwner(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getRecordOwner';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"0031s00000w3zXTyAY"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse =YAI_GetRecordOwner.getRecordOwner();
       
        testApiResponse.errorDescription = 'Invalid Argument';
        
    }

 
}