@isTest
public with sharing class ResetPasswordSendEmailTest {

    @isTest
    public static void testUserExists() {
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        
        Contact testContact1 = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@test.com',
            Phone = '9999999999'
        );
        insert testContact1;

        User us = new User(
            FirstName ='ankit',
            LastName ='test',
            Email='test1@test.com',
            isActive = true,
            Username = 'ankit@acme.com.TestingOrg',  
            Alias ='lal',
            TimeZoneSidKey ='Asia/Kolkata', 
            LocaleSidKey='en_IN',
            EmailEncodingKey ='UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = pr.Id
        );
        insert us;

        List<ResetPasswordSendEmail.EmailTemplateInput> emailList = new List<ResetPasswordSendEmail.EmailTemplateInput>();
        ResetPasswordSendEmail.EmailTemplateInput input = new ResetPasswordSendEmail.EmailTemplateInput();
        input.contactId = testContact1.Id;
        emailList.add(input);

        Test.startTest();
        List<String> result = ResetPasswordSendEmail.sendEmail(emailList);
        Test.stopTest();

        
        System.assertEquals(0, result.size(), 'No error messages should be generated');
    }

    @isTest
    public static void testUserDoesNotExist() {
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        
        Contact testContact2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Email = 'test2@test.com', 
            Phone = '8888888888'
        );
        insert testContact2;

        List<ResetPasswordSendEmail.EmailTemplateInput> emailList = new List<ResetPasswordSendEmail.EmailTemplateInput>();
        ResetPasswordSendEmail.EmailTemplateInput input = new ResetPasswordSendEmail.EmailTemplateInput();
        input.contactId = testContact2.Id;
        emailList.add(input);

        Test.startTest();
        List<String> result = ResetPasswordSendEmail.sendEmail(emailList);
        Test.stopTest();

        
        System.assertEquals(1, result.size(), 'One error message should be generated for "User is not available"');
        System.assertEquals('User is not available', result[0], 'Error message should be "User is not available"');
    }

    @isTest
    public static void testContactDoesNotExist() {
        Profile pr = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        
        Id invalidContactId = '003000000000000AAA';

        List<ResetPasswordSendEmail.EmailTemplateInput> emailList = new List<ResetPasswordSendEmail.EmailTemplateInput>();
        ResetPasswordSendEmail.EmailTemplateInput input = new ResetPasswordSendEmail.EmailTemplateInput();
        input.contactId = invalidContactId;
        emailList.add(input);

        Test.startTest();
        List<String> result = ResetPasswordSendEmail.sendEmail(emailList);
        Test.stopTest();

        
        System.assertEquals(1, result.size(), 'One error message should be generated for "Contact is not available"');
        System.assertEquals('Contact is not available', result[0], 'Error message should be "Contact is not available"');
    }
}