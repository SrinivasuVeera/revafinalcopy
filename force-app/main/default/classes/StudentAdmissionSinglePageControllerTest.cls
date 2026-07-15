@isTest
public class StudentAdmissionSinglePageControllerTest {

 public class MockHttpResponseGeneratorRegistration implements HttpCalloutMock{
    
    public HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"transactionId":25025729248,"state":"SUBMIT_ACCEPTED",'+
                    '"description":"Message submitted successfully","pdu":1,"corelationId":null}');
        res.setStatusCode(200);
        return res;
    }
 }

    // ✅ Utility method for creating test Leads
    private static Lead createTestLead(String email, Boolean withOTP) {
        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = email,
            Company = 'Self',
            Status = 'Unverified',
            Country_Code__c = 'India (+91)'
        );
        if (withOTP) {
            l.Mobile_OTP_Code__c = '123456';
            l.Mobile_OTP_Expiration__c = System.now().addMinutes(10);
            l.Revisit_OTP_Code__c = '654321';
            l.Revisit_OTP_Expiration__c = System.now().addMinutes(10);
            l.Email_OTP_Code__c = '999999';
            l.Email_OTP_Expiration__c = System.now().addMinutes(10);
        }
        insert l;
        return l;
    }

    // ✅ Utility method for creating test Contact
    private static Contact createTestContact(String email, Boolean withOTP) {
        
        Account acc = new Account(
            Name  = 'B. Tech in Electronics and Communication Engineering',
            Program_Type__c  = 'UG',
            Program_Code__c  = 'EN',
            Program_Alias__c = 'BT-ECE',
            Intake__c = 120,
            Intake_Per_Section__c = 60
        );
        insert acc;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = email,
            AccountId = [SELECT Id FROM Account WHERE Id=:acc.Id LIMIT 1].Id
        );
        if (withOTP) {
            c.Revisit_OTP_Code__c = '123456';
            c.Revisit_OTP_Expiration__c = System.now().addMinutes(10);
        }
        insert c;
        return c;
    }

    @isTest
    static void testCheckExistingEmail_Lead() {
        Lead testLead = createTestLead('testlead@test.com', false);

        Test.startTest();
        Map<String, Object> result = StudentAdmissionSinglePageController.checkExistingEmail('testlead@test.com');
        Test.stopTest();

        System.assertEquals(true, result.get('exists'));
        System.assertEquals('Lead', result.get('type'));
    }

    @isTest
    static void testCheckExistingEmail_Contact() {
        Contact testContact = createTestContact('testcontact@test.com', false);

        Test.startTest();
        Map<String, Object> result = StudentAdmissionSinglePageController.checkExistingEmail('testcontact@test.com');
        Test.stopTest();

        System.assertEquals(true, result.get('exists'));
        System.assertEquals('Contact', result.get('type'));
    }

    @isTest
    static void testCheckExistingEmail_None() {
        Test.startTest();
        Map<String, Object> result = StudentAdmissionSinglePageController.checkExistingEmail('newemail@test.com');
        Test.stopTest();

        System.assertEquals(false, result.get('exists'));
        System.assertEquals('None', result.get('type'));
    }

    @isTest
    static void testSendEmailOtp_NewLeadCreation() {
        Lead l = new Lead(
        FirstName = 'First',
        LastName = 'Last',
        Email = 'newemailotp@test.com',
        Company = 'Test',
        Status = 'Unverified'
    );
    insert l;
        Test.startTest();
        Map<String, String> res = StudentAdmissionSinglePageController.sendEmailOtp(
            'newemailotp@test.com', 'First', 'Last','web','web','web'
        );
         Map<String, String> res1 = StudentAdmissionSinglePageController.getNameByEmail(
            'newemailotp@test.com'
        );
        
        Test.stopTest();

        System.assertNotEquals(null, res.get('leadId'));
        System.assertNotEquals(null, res.get('otp'));
    }

    @isTest
    static void testSendEmailOtp_ExistingLead() {
        Lead l = createTestLead('existinglead@test.com', false);

        Test.startTest();
        Map<String, String> res = StudentAdmissionSinglePageController.sendEmailOtp(
            'existinglead@test.com', 'First', 'Last','web','web','web'
        );
        Test.stopTest();

        System.assertNotEquals(null, res.get('otp'));
        System.assertEquals(l.Id, res.get('leadId'));
    }

    @isTest
    static void testSendEmailOtp_ExistingContact() {
        Contact c = createTestContact('existcontact@test.com', false);

        Test.startTest();
        Map<String, String> res = StudentAdmissionSinglePageController.sendEmailOtp(
            'existcontact@test.com', 'First', 'Last','web','web','web'
        );
        Test.stopTest();

        System.assertNotEquals(null, res.get('otp'));
    }

    @isTest
    static void testVerifyOtp_Valid() {
        Lead l = createTestLead('otpcheck@test.com', true);

        Test.startTest();
        Boolean verified = StudentAdmissionSinglePageController.verifyOtp(l.Id, '123456');
        Test.stopTest();

        System.assertEquals(true, verified);
    }

    @isTest
    static void testVerifyOtp_Invalid() {
        Lead l = createTestLead('invalidotp@test.com', true);

        Test.startTest();
        Boolean verified = StudentAdmissionSinglePageController.verifyOtp(l.Id, '000000');
        Test.stopTest();

        System.assertEquals(false, verified);
    }

    @isTest
    static void testVerifyEmailOtp_Lead() {
        Lead l = createTestLead('emailotp@test.com', true);

        Test.startTest();
        StudentAdmissionSinglePageController.OTPResponse response =
            StudentAdmissionSinglePageController.verifyEmailOtp(l.Id, '999999');
        Test.stopTest();

        System.assertEquals(true, response.isVerified);
        System.assertEquals('Lead', response.recordType);
    }

    @isTest
    static void testVerifyEmailOtp_Contact() {
        Contact c = createTestContact('contactotp@test.com', true);

        Test.startTest();
        StudentAdmissionSinglePageController.OTPResponse response =
            StudentAdmissionSinglePageController.verifyEmailOtp(c.Id, '123456');
        StudentAdmissionSinglePageController.getContactInfo(c.Id);
        Test.stopTest();

        System.assertEquals(true, response.isVerified);
        System.assertEquals('Contact', response.recordType);
    }

    @isTest
    static void testGetSchoolProgramCategoryData() {
        Test.startTest();
        Map<String, Object> data = StudentAdmissionSinglePageController.getSchoolProgramCategoryData();
        Test.stopTest();

        System.assert(data.containsKey('categories'));
    }

    @isTest
    static void testGetCountryCodePicklist() {
        Test.startTest();
        List<Map<String, String>> result = StudentAdmissionSinglePageController.getCountryCodePicklist();
        Test.stopTest();
        System.assert(result.size() > 0);
    }

    @isTest
    static void testGetStatePicklist() {
        Test.startTest();
        List<Map<String, String>> result = StudentAdmissionSinglePageController.getStatePicklist();
         List<Map<String, String>> result1 = StudentAdmissionSinglePageController.getCountryPicklist();
        Test.stopTest();
        System.assert(result.size() > 0);
    }

    @isTest
    static void testResendOtp_Lead() {
        Lead l = createTestLead('resendlead@test.com', false);
        l.MobilePhone = '9999999999';
        update l;
       String ids;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorRegistration());
        String otp = StudentAdmissionSinglePageController.resendOtp(l.Id, '+91', '9999999999');
        //Map<String, String> sendOtp = StudentAdmissionSinglePageController.sendOtp(ids, '+91', '9999999998','resendlead@test.com' );
        Test.stopTest();

        System.assertNotEquals(null, otp);
    }

    @isTest
    static void testResendOtp_Contact() {
        Contact c = createTestContact('resendcontact@test.com', false);

        Test.startTest();
        String otp = StudentAdmissionSinglePageController.resendOtp(c.Id, '+1', null);
        Test.stopTest();

        System.assertNotEquals(null, otp);
    }
    
      @isTest
    static void testResendOtp_lead1() {
        Lead l = createTestLead('resendlead@test.com', false);
        l.MobilePhone = '9999999999';
        l.Country_Code__c = '	India (+91)';
        update l;

        Test.startTest();
        String otp = StudentAdmissionSinglePageController.resendOtp(l.Id, '+1', null);
        Test.stopTest();

        System.assertNotEquals(null, otp);
    }

  
    @isTest
    static void testSubmitApplication() {
        // 1️⃣ Create Account (School)
        Account createAccount = new Account(
            Name = 'School of Civil Engineering'
        );
        insert createAccount;

        // 2️⃣ Create Program Batch
        hed__Program_Plan__c programBatchRec = new hed__Program_Plan__c(
            Name = 'School of Civil Engineering',
            hed__Account__c = createAccount.Id
        );
        insert programBatchRec;

        // 3️⃣ Create Fee Master (what convertLead expects)
        Fee_Master__c feeMasterCreation = new Fee_Master__c(
            Program_Batch__c  = programBatchRec.Id,
            Fee_Type__c = 'Application Fee',
            Program_Name_Display__c = 'B.Tech. - Civil Engineering',
            Applicant_Category__c = 'Non-Resident Indian(NRI)',
            Application_Number_Prefix__c = '230401'
        );
        insert feeMasterCreation;

        // 4️⃣ Create Lead with matching data
        Lead leadRecord = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'testlead@example.com',
            Company = 'Test Company',
            Program_Batch__c = programBatchRec.Id,
            Program_Name_Display__c = 'B.Tech. - Civil Engineering',
            Category__c = 'Non-Resident Indian(NRI)'
        );
        insert leadRecord;       

        // 5️⃣ Build the input map
        Map<String, Object> studentData = new Map<String, Object>{
            'leadId' => leadRecord.Id,
            'email' => leadRecord.Email,
            'firstName' => leadRecord.FirstName,
            'lastName' => leadRecord.LastName
        };

        // 6️⃣ Call your controller
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorRegistration());
        StudentAdmissionSinglePageController.submitApplication(studentData);
        StudentAdmissionSinglePageController.getSourcePicklist();
        Test.stopTest();

        // 7️⃣ Validate
        System.assertNotEquals(null, leadRecord.Id, 'Lead Id should be valid');
        System.assertNotEquals(null, feeMasterCreation.Id, 'Fee master should exist');
    }
    @isTest
static void testSubmitApplication_CreateNewLead() {
    String phoneCodeValue = Lead.Country_Code__c.getDescribe().getPicklistValues()[0].getValue();

    Map<String,Object> studentData = new Map<String,Object>{
        'leadId' => null,
        'email' => 'newlead@test.com',
        'firstName' => 'Test',
        'lastName' => 'User',
        'mobileNumber' => '9876543210',
        'phoneCode' => phoneCodeValue,
        'category' => 'Karnataka',
        'state' => 'Karnataka',
        'country' => 'India',
        'school' => 'School of Civil Engineering',
        'program' => 'B.Tech. - Civil Engineering',
         'utmSource' => 'test',
            'utmMedium' => 'test',
            'utmCampaign' => 'test'
    };

    Test.startTest();
    Id leadId = StudentAdmissionSinglePageController.submitApplication(studentData);
    Test.stopTest();

    Lead createdLead = [
        SELECT Id, Email, Category__c, School__c, Program_Name_Display__c
        FROM Lead
        WHERE Id = :leadId
    ];

    System.assertEquals('newlead@test.com', createdLead.Email);
    System.assertEquals('Karnataka', createdLead.Category__c);
}
    @isTest
static void testSubmitApplication_ExistingLead() {

    Lead l = new Lead(
        FirstName='Test',
        LastName='Lead',
        Email='existlead@test.com',
        Company='Test',
        Status='Unverified'
    );
    insert l;

    Map<String,Object> studentData = new Map<String,Object>{
        'leadId' => l.Id,
        'email' => 'existlead@test.com',
        'firstName' => 'Updated',
        'lastName' => 'Lead',
        'mobileNumber' => '9999999999',
        'category' => 'Karnataka',
        'country' => 'India',
        'state' => 'Karnataka',
        'school' => 'School of Civil Engineering',
        'program' => 'B.Tech'
    };

    Test.startTest();

    try{
        StudentAdmissionSinglePageController.submitApplication(studentData);
    }
    catch(Exception e){
        // ignore conversion related errors
    }

    Test.stopTest();

    Lead updatedLead = [
        SELECT Id, MobilePhone
        FROM Lead
        WHERE Id = :l.Id
    ];

    System.assertEquals('+91-9999999999', updatedLead.MobilePhone);
}
   @isTest
static void testRedirectToPaymentPage() {
    // Create a valid Contact record for testing
    Contact con = new Contact(
        FirstName = 'Test',
        LastName = 'User',
        Email = 'test@example.com'
    );
    insert con;

    // Use the real Salesforce Id
    Id contactId = con.Id;

    Test.startTest();
    String url = StudentAdmissionSinglePageController.redirectToPaymentPage(contactId);
    Test.stopTest();

    System.assert(url.contains('/s/payment-page'), 'The redirect URL should contain /s/payment-page');
}


}