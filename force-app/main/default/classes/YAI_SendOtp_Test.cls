@isTest
public class YAI_SendOtp_Test {
    
    @isTest
    public static void sendOtpLeadTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Tesla',Status='Verified',Country_Code__c='India (+91)',MobilePhone ='9876543211',Mobile_OTP_Code__c='7377',Mobile_OTP_Expiration__c=system.now(),Email_OTP_Code__c='1555',Email_OTP_Expiration__c=system.now());
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = '/services/apexrest/sendOtp';
        req.httpMethod = 'POST';
        YAI_Wrapper.APIRequest testApiRequest = new YAI_Wrapper.APIRequest();
        testApiRequest.leadOrContactId = testLead.Id;
        testApiRequest.otpDestination = 'Email';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpDestination":"email"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_SendOtp.sendOtp();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
        testApiResponse.status = 'Success';
        System.assertNotEquals(null, testApiResponse.status);
        
        
    }
    @isTest
    public static void sendOtpunverifiedLeadTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        List<Sobject> sobjList= new List<Sobject>();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Tesla',Status='Unverified',Country_Code__c='India (+91)',MobilePhone ='9876543211',Mobile_OTP_Code__c='7377',Mobile_OTP_Expiration__c=system.now(),Email_OTP_Code__c='1555',Email_OTP_Expiration__c=system.now());
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        sobjList.add(testlead);
        req.requestURI = '/services/apexrest/sendOtp';
        req.httpMethod = 'POST';
        YAI_Wrapper.APIRequest testApiRequest = new YAI_Wrapper.APIRequest();
        testApiRequest.leadOrContactId = testLead.Id;
        testApiRequest.otpDestination = 'Email';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpDestination":"mobile"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_SendOtp.sendOtp();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
        testApiResponse.status = 'Success';
        System.assertNotEquals(null, testApiResponse.status);
        
        
    }
    @isTest
    public static void sendOtpUnVerifiedLead(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Tesla',Status='Unverified',Country_Code__c='India (+91)',MobilePhone ='9876543211',Mobile_OTP_Code__c='7377',Mobile_OTP_Expiration__c=system.now(),Email_OTP_Code__c='1555',Email_OTP_Expiration__c=system.now());
        insert testLead;
        string testLeadId = string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/checkApplicant';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpDestination":"email"}';
        system.debug('22222'+Body);
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_SendOtp.sendOtp();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
        testApiResponse.status = 'Success';
        System.assertNotEquals(null, testApiResponse.status);
        
        
    }
    
    @isTest
    public static void sendOtpContactTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        contact testContact = new contact(Email='tesla@gmail.com', FirstName='Star', LastName='Link',Revisit_OTP_Code__c='9900',Revisit_OTP_Expiration__c=system.now());
        insert testContact;
        string testContactId= string.valueOf(testContact.Id);
        req.requestURI = '/services/apexrest/sendOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testcontact.Id +'","otpDestination":"Email"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_SendOtp.sendOtp();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMocks_Test());
        testApiResponse.status = 'Success';
        System.assertNotEquals(null, testApiResponse.status);
        
        
    }
    @isTest
    public static void jsonExceptionSendOtpTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/sendOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"0031s00000w3zXTyAY"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_SendOtp.sendOtp();
       
        testApiResponse.errorDescription = 'Invalid Argument';
        
    }
    
    
}