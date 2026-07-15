@isTest
public class NewLeadCreationTest {
    public class MockHttpResponseGeneratorRegistration implements HttpCalloutMock{
    
    public HttpResponse respond(HttpRequest req) {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"transactionId":25025729248,"state":"SUBMIT_ACCEPTED",'+
                    '"description":"Message submitted successfully","pdu":1,"corelationId":null}');
        res.setStatusCode(200);
        return res;
    }
 }
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
    static void testSubmitApplication() {        
        Account createAccount = new Account(
            Name = 'School of Civil Engineering'
        );
        insert createAccount;

        hed__Program_Plan__c programBatchRec = new hed__Program_Plan__c(
            Name = 'School of Civil Engineering',
            hed__Account__c = createAccount.Id
        );
        insert programBatchRec;
        
        Fee_Master__c fm = new Fee_Master__c(
    Program_Batch__c = programBatchRec.Id,
    Program_Name_Display__c = 'B.Tech. - Civil Engineering',   
    Applicant_Category__c = 'Non-Resident Indian(NRI)',
    Fee_Type__c = 'Application Fee',
    Application_Number_Prefix__c = '240401',
    Fee_Amount__c = 1000,
    IsActive__c = true
);
insert fm;

        Lead leadRecord = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'testlead@example.com',
            Company = 'Test Company',
            Program_Batch__c = programBatchRec.Id,
            Program_Name_Display__c = 'B.Tech. - Civil Engineering',
            Category__c = 'Non-Resident Indian(NRI)',
            School__c = 'School of Civil Engineering',            
            LeadSource = 'Started'                      
        );
        insert leadRecord;

        Map<String, Object> studentData = new Map<String, Object>{
            'leadId' => leadRecord.Id,
            'email' => leadRecord.Email,
            'firstName' => leadRecord.FirstName,
            'lastName' => leadRecord.LastName
        };

        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorRegistration());
        NewLeadCreation.submitApplication(studentData);
        //StudentAdmissionSinglePageController.getSourcePicklist();
        Test.stopTest();

        // 7️⃣ Validate
        System.assertNotEquals(null, leadRecord.Id, 'Lead Id should be valid');
        System.assertNotEquals(null, fm.Id, 'Fee master should exist');
    }
    @isTest
static void testGetSiteURL() {

    Test.startTest();
    String url = NewLeadCreation.getSiteURL();
    Test.stopTest();

    System.assertNotEquals(null, url);
}
    @isTest
static void testSubmitApplication_BlankLeadId() {

    Map<String, Object> studentData = new Map<String, Object>{
        'firstName'   => 'New',
        'lastName'    => 'Student',
        'email'       => 'blanklead@test.com',
        'mobileNumber'=> '9999999991',
        'phoneCode'   => 'India (+91)',
        'category'    => 'Karnataka',
        'state'       => 'Karnataka',
        'country'     => 'India',
        'school'      => 'School of Civil Engineering',
        'program'     => 'B.Tech',
        'source'      => 'Website',
        'utmSource'   => 'Google',
        'utmMedium'   => 'CPC',
        'utmCampaign' => 'Summer2026'
    };

    Test.startTest();

    Id leadId = NewLeadCreation.submitApplication(studentData);

    Test.stopTest();

    System.assertNotEquals(null, leadId);

    Lead l = [
        SELECT Id, Email, UTM_Source__c
        FROM Lead
        WHERE Id = :leadId
    ];

    System.assertEquals('blanklead@test.com', l.Email);
}
    @isTest
static void testRecSubmitApplication_BlankLeadId() {

    Map<String, Object> studentData = new Map<String, Object>{
        'firstName'   => 'Reception',
        'lastName'    => 'Student',
        'email'       => 'reception@test.com',
        'mobileNumber'=> '9999999992',
        'phoneCode'   => 'India (+91)',
        'category'    => 'Karnataka',
        'state'       => 'Karnataka',
        'country'     => 'India',
        'school'      => 'School of Civil Engineering',
        'program'     => 'B.Tech',
        'source'      => 'Walk-In'
    };

    Test.startTest();

    Id leadId = NewLeadCreation.recsubmitApplication(studentData);

    Test.stopTest();

    System.assertNotEquals(null, leadId);
}
    @isTest
static void testValidateLead() {

    Lead l = new Lead(
        FirstName = 'Dup',
        LastName  = 'Lead',
        Email     = 'duplicate@test.com',
        Phone     = '8888888888',
        Company   = 'Self',
        Status    = 'Unverified'
    );
    insert l;

    Test.startTest();

    String result = NewLeadCreation.validateLead(
        'duplicate@test.com',
        '8888888888',
        'India (+91)'
    );

    Test.stopTest();

    System.assertEquals('EMAIL_MOBILE_EXISTS', result);
}
    @isTest
static void testUpdateLeadBeforeOTP() {

    Lead l = new Lead(
        FirstName = 'OTP',
        LastName  = 'Lead',
        Email     = 'otp@test.com',
        Company   = 'Self',
        Status    = 'Unverified'
    );
    insert l;

    Test.startTest();

    NewLeadCreation.updateLeadBeforeOTP(
        l.Id,
        'India (+91)',
        '7777777777'
    );

    Test.stopTest();

    Lead updatedLead = [
        SELECT MobilePhone, Country_Code__c
        FROM Lead
        WHERE Id = :l.Id
    ];

    System.assertEquals('+91-7777777777', updatedLead.MobilePhone);
}
    @isTest
static void testRecConvertLead() {

    Account acc = new Account(
        Name = 'School of Civil Engineering'
    );
    insert acc;

    hed__Program_Plan__c pp = new hed__Program_Plan__c(
        Name = 'Civil Program',
        hed__Account__c = acc.Id
    );
    insert pp;

    Fee_Master__c fm = new Fee_Master__c(
        Program_Batch__c = pp.Id,
        Program_Name_Display__c = 'B.Tech',
        Applicant_Category__c = 'Indian (SAARC)',
        Fee_Type__c = 'Application Fee',
        Application_Number_Prefix__c = '240401',
        Fee_Amount__c = 1000,
        IsActive__c = true
    );
    insert fm;

    Lead l = new Lead(
        FirstName = 'Convert',
        LastName  = 'Lead',
        Email     = 'convert@test.com',
        Company   = 'Self',
        Status    = 'Unverified',
        Category__c = 'Karnataka',
        Program_Name_Display__c = 'B.Tech',
        Program_Batch__c = pp.Id
    );
    insert l;

    Test.startTest();

    List<NewLeadCreation.UtilityResponse> res =
        NewLeadCreation.recconvertLead(l.Id, fm.Id);

    Test.stopTest();

    System.assertNotEquals(null, res);
    System.assert(res.size() > 0);
}
    @isTest
static void testConvertLead() {

    Account acc = new Account(
        Name = 'School of Civil Engineering'
    );
    insert acc;

    hed__Program_Plan__c pp = new hed__Program_Plan__c(
        Name = 'Civil Program',
        hed__Account__c = acc.Id
    );
    insert pp;

    Fee_Master__c fm = new Fee_Master__c(
        Program_Batch__c = pp.Id,
        Program_Name_Display__c = 'B.Tech',
        Applicant_Category__c = 'Indian (SAARC)',
        Fee_Type__c = 'Application Fee',
        Application_Number_Prefix__c = '240401',
        Fee_Amount__c = 1000,
        IsActive__c = true
    );
    insert fm;

    Lead l = new Lead(
        FirstName = 'Convert',
        LastName  = 'Lead',
        Email     = 'convert@test.com',
        Company   = 'Self',
        Status    = 'Unverified',
        Category__c = 'Karnataka',
        Program_Name_Display__c = 'B.Tech',
        Program_Batch__c = pp.Id
    );
    insert l;

    Test.startTest();

    List<NewLeadCreation.UtilityResponse> res =
        NewLeadCreation.convertLead(l.Id, fm.Id);

    Test.stopTest();

    System.assertNotEquals(null, res);
    System.assert(res.size() > 0);
}
     @isTest
    static void testSubmitApplication1() {        
        Account createAccount = new Account(
            Name = 'School of Civil Engineering'
        );
        insert createAccount;

        hed__Program_Plan__c programBatchRec = new hed__Program_Plan__c(
            Name = 'School of Civil Engineering',
            hed__Account__c = createAccount.Id
        );
        insert programBatchRec;
        
        Fee_Master__c feeMasterCreation = new Fee_Master__c(
            Program_Batch__c  = programBatchRec.Id,
            Fee_Type__c = 'Application Fee',
            Program_Name_Display__c = 'B.Tech. - Civil Engineering',
            Applicant_Category__c = 'Non-Resident Indian(NRI)',
            Application_Number_Prefix__c = '230401'
        );
        insert feeMasterCreation;

        Lead leadRecord = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'testlead@example.com',
            Company = 'Test Company',
            mobilephone = '9999999999',
            Program_Batch__c = programBatchRec.Id,
            Program_Name_Display__c = 'B.Tech. - Civil Engineering',
            Category__c = 'Non-Resident Indian(NRI)',
            School__c = 'School of Civil Engineering'
        );
        insert leadRecord;

        Map<String, Object> studentData = new Map<String, Object>{
            'leadId' => leadRecord.Id,
            'email' => leadRecord.Email,
            'firstName' => leadRecord.FirstName,
            'lastName' => leadRecord.LastName
        };

        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorRegistration());
        NewLeadCreation.recsubmitApplication(studentData);
        //NewLeadCreation.getSourcePicklist();
        Test.stopTest();

        // 7️⃣ Validate
        System.assertNotEquals(null, leadRecord.Id, 'Lead Id should be valid');
        System.assertNotEquals(null, feeMasterCreation.Id, 'Fee master should exist');
    }
    @isTest
static void testSendEmailOtp_NewLeadCreation() {

    Lead l = new Lead(
        FirstName = 'First',
        LastName  = 'Last',
        Email     = 'newemailotp@test.com',
        Company   = 'Self',
        Status    = 'Unverified'
    );
    insert l;

    Test.startTest();

    Map<String, String> res = NewLeadCreation.sendEmailOtp(
        'newemailotp@test.com',
        'First',
        'Last',
        l.Id
    );

    Test.stopTest();

    System.assertNotEquals(null, res.get('leadId'));
    System.assertNotEquals(null, res.get('otp'));
}

   @isTest
static void testSendEmailOtp_ExistingLead() {

    Lead l = createTestLead('existinglead@test.com', false);

    Test.startTest();

    Map<String, String> res = NewLeadCreation.sendEmailOtp(
        'existinglead@test.com',
        'First',
        'Last',
        l.Id
    );

    Test.stopTest();

    System.assertNotEquals(null, res.get('otp'));
    System.assertEquals(l.Id, res.get('leadId'));
}

    @isTest
static void testSendEmailOtp_ExistingContact() {

    Contact c = createTestContact('existcontact@test.com', false);

    Lead l = new Lead(
        FirstName = 'Test',
        LastName  = 'Lead',
        Email     = 'existcontact@test.com',
        Company   = 'Self',
        Status    = 'Unverified'
    );
    insert l;

    Test.startTest();

    Map<String, String> res = NewLeadCreation.sendEmailOtp(
        'existcontact@test.com',
        'First',
        'Last',
        l.Id
    );

    Test.stopTest();

    System.assertNotEquals(null, res.get('otp'));
}
    @isTest
    static void testrecSendEmailOtp_NewLeadCreation() {
        Test.startTest();
        Map<String, String> res = NewLeadCreation.recsendEmailOtp(
            'newemailotp@test.com', 'First', 'Last'
        );         
        
        Test.stopTest();

        System.assertNotEquals(null, res.get('leadId'));
        System.assertNotEquals(null, res.get('otp'));
    }

   /* Due Validation for reception i command on 08-05-2026
     @isTest
    static void testrecSendEmailOtp_ExistingLead() {
        Lead l = createTestLead('existinglead@test.com', false);

        Test.startTest();
        Map<String, String> res = NewLeadCreation.recsendEmailOtp(
            'existinglead@test.com', 'First', 'Last'
        );
        Test.stopTest();

        System.assertNotEquals(null, res.get('otp'));
        System.assertEquals(l.Id, res.get('leadId'));
    }

    @isTest
    static void testrecSendEmailOtp_ExistingContact() {
        Contact c = createTestContact('existcontact@test.com', false);

        Test.startTest();
        Map<String, String> res = NewLeadCreation.recsendEmailOtp(
            'existcontact@test.com', 'First', 'Last'
        );
        Test.stopTest();

        System.assertNotEquals(null, res.get('otp'));
    } */

}