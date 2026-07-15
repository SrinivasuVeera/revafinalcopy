@isTest
public class YAI_CheckApplicant_Test {
    
    @isTest
    public static void checkApplicantLeadTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='pavansai.kodanda@stratos.studio', FirstName='pavan', LastName='sai',Status='Unverfied');
        insert testLead;
        
        req.requestURI = 'services/apexrest/checkApplicant';
        req.httpMethod = 'POST';
        String Body = '{"email":"pavansai.kodanda@stratos.studio"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_CheckApplicant.checkApplicant();
        testApiResponse.leadOrContactId = testLead.Id;
        testApiResponse.Found = true;
        testApiResponse.status = testLead.Status;
        System.assertEquals(true, testApiResponse.found);
       
        
    }
    @isTest
    public static void checkApplicantContactTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        contact testcontact = new contact(Email='pavansai.kodanda@stratos.studio', FirstName='pavan', LastName='sai',Application_Fee_Paid__c =False);
        insert testcontact;
        
        req.requestURI = 'services/apexrest/checkApplicant';
        req.httpMethod = 'POST';
        String Body = '{"email":"pavansai.kodanda@stratos.studio"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_CheckApplicant.checkApplicant();
        testApiResponse.leadOrContactId = testContact.Id;
        testApiResponse.Found = true;
        testApiResponse.status = 'Application Fee Not Paid';
        System.assertEquals(true, testApiResponse.found);
    
    }
     @isTest
    public static void checkApplicantContactTest1(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        contact testcontact = new contact(Email='pavansai.kodanda@stratos.studio', FirstName='pavan', LastName='sai',Application_Fee_Paid__c =True);
        insert testcontact;
        
        req.requestURI = 'services/apexrest/checkApplicant';
        req.httpMethod = 'POST';
        String Body = '{"email":"pavansai.kodanda@stratos.studio"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_CheckApplicant.checkApplicant();
        testApiResponse.leadOrContactId = testContact.Id;
        testApiResponse.Found = true;
        testApiResponse.status = 'Application Fee Paid';
        System.assertEquals(true, testApiResponse.found);
    
    }
    @isTest
    public static void notFoundCheckApplicantTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/checkApplicant';
        req.httpMethod = 'POST';
        String Body = '{"email":"test@yai.com"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_CheckApplicant.checkApplicant();
        testApiResponse.leadOrContactId = null;
        testApiResponse.Found = false;

    }
     @isTest
    public static void jsonExceptionCheckApplicantTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/checkApplicant';
        req.httpMethod = 'POST';
        String Body = '{"email":"test@yai.com}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_CheckApplicant.checkApplicant();
        testApiResponse.leadOrContactId = null;
        testApiResponse.Found = false;
        testApiResponse.errorDescription = 'Invalid Argument';

    }
    
}