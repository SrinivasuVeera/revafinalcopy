@isTest
public class YAI_ValidateOTP_Test {
    @isTest
    public static void ValidateOtpVerifiedLead(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',status ='Verified',Revisit_OTP_Code__c='5422',Revisit_OTP_Expiration__c=system.now());
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5439","validationType":"Revisit"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
      
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);   
    }
    @isTest
    public static void ValidateOtpVerified2(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',status ='Verified',Revisit_OTP_Code__c='5422',Revisit_OTP_Expiration__c=system.now());
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5422","validationType":"Revisit"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
       // testApiResponse.status = 'invalid';
       // testApiResponse.reason = 'expired';
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);    
    }
     @isTest
    public static void ValidateOtpVerified3(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',status ='Verified',Revisit_OTP_Code__c='5422',Revisit_OTP_Expiration__c=system.now().addMinutes(2));
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5422","validationType":"Revisit"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse.status='valid';
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('valid', testApiResponse.status);   
    }
    
    @isTest
    public static void ValidateOtpThroughMobile(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',Country_code__c= 'India (+91)');
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5122","validationType":"New"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);    
    }
    
     @isTest
    public static void ValidateOtpThroughMobile1(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',Country_code__c= 'India (+91)',Mobile_OTP_Code__c='5122',Mobile_OTP_Expiration__c=system.now().addMinutes(2));
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5122","validationType":"New"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('valid', testApiResponse.status);    
    }
      @isTest
    public static void ValidateOtpThroughMobile2(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',Country_code__c= 'India (+91)',Mobile_OTP_Code__c='5122',Mobile_OTP_Expiration__c=system.now());
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5122","validationType":"New"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);   
    }
	
    @isTest
    public static void ValidateOtpThroughEmail(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',Country_code__c= 'Australia (+61)');
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5122","validationType":"New"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);
            
    }
     @isTest
    public static void ValidateOtpThroughEmail1(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',Country_code__c= 'Australia (+61)',Email_OTP_Code__c='5122',Email_OTP_Expiration__c=system.now());
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5122","validationType":"New"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);    
    }
     @isTest
    public static void ValidateOtpThroughEmail2(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Lead testLead = new Lead(Email='test@gmail.com', FirstName='Test', LastName='Lead',Country_code__c= 'Australia (+61)',Email_OTP_Code__c='5122',Email_OTP_Expiration__c=system.now().addMinutes(2));
        insert testLead;
        string testleadId=string.valueOf(testLead.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testLeadId +'","otpText":"5122","validationType":"New"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('valid', testApiResponse.status);    
    }
    @isTest
    public static void ValidateContactOtp(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Contact testContact = new Contact(FirstName='Test', LastName='Contact');
        insert testContact;
        string testContactId=string.valueOf(testContact.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testContactId +'","otpText":"5122","validationType":"Revisit"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);    
    }
     @isTest
    public static void ValidateContactOtp1(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Contact testContact = new Contact(FirstName='Test', LastName='Contact',Revisit_OTP_Code__c='5422',Revisit_OTP_Expiration__c=system.now());
        insert testContact;
        string testContactId=string.valueOf(testContact.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testContactId +'","otpText":"5422","validationType":"Revisit"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('invalid', testApiResponse.status);    
    }
     @isTest
    public static void ValidateContactOtp2(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Contact testContact = new Contact(FirstName='Test', LastName='Contact',Revisit_OTP_Code__c='5422',Revisit_OTP_Expiration__c=system.now().addMinutes(2));
        insert testContact;
        string testContactId=string.valueOf(testContact.Id);
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"leadOrContactId":"'+testContactId +'","otpText":"5422","validationType":"Revisit"}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        System.assertEquals('valid', testApiResponse.status);   
    }
 @isTest
    public static void jsonExceptionValidateOTPTest(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/validateOtp';
        req.httpMethod = 'POST';
        String Body = '{"email":"test@yai.com}';
        Blob requestBody = Blob.valueOf(Body);
        req.requestBody=requestBody;
        RestContext.request = req;
        RestContext.response = res;
        YAI_Wrapper.APIResponse testApiResponse = new YAI_Wrapper.APIResponse();
        testApiResponse = YAI_ValidateOTP.validateOtp();
        
        testApiResponse.errorDescription = 'Invalid Argument';

    }

}