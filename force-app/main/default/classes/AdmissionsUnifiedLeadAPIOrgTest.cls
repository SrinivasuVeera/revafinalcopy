@IsTest
private class AdmissionsUnifiedLeadAPIOrgTest {

     // Mock class to simulate HTTP response for callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
    // =========================================
    // TEST SETUP (Common Test Data)
    // =========================================
    @TestSetup
    static void setupData() {
         String programName = 'Bachelor of Architecture';
       RecordType academicProgramRT = [Select id FROM RecordType Where DeveloperName = 'Academic_Program' Limit 1];
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        
        Account createAccount = new Account(
            Name = 'School of Civil Engineering'
        );
        insert createAccount;
        
        Account program= new Account(
        	Name = programName,
            RecordTypeId = academicProgramRT.Id,    
            Program_Alias__c = 'Barch',
            Program_Type__c = 'UG',
            Program_Code__c = 'RA',
            Intake__c = 80,
            Intake_Per_Section__c = 40,
            ParentId = createAccount.Id           
        );
        insert program;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
        	Name = 'Bachelor of Architecture-(2023-2028)',
            hed__Account__c=program.id
        );
        insert programBatch;
        
    
        
        // Create Fee Master record
        Fee_Master__c fm = new Fee_Master__c(
            Program_Batch__c =programBatch.Id,
           Applicant_Category__c = 'Indian (SAARC)',
            Fee_Type__c = 'Application Fee',
            IsActive__c = true,
            Enrolment_Year__c = '2026',
            Application_Number_Prefix__c = '24MBA'
        );
        insert fm;
    }

    // =========================================
    // TEST: VERIFY EMAIL (New Lead Flow)
    // =========================================
    @IsTest
    static void testVerifyEmail_NewLead() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'VERIFY_EMAIL',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john@test.com'
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

      //  System.assertEquals('OTP_SENT', response.status);
      //  System.assertNotEquals(null, response.reference);
    }
    
      @IsTest
    static void testRevisitLead() {
  
        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'john@test.com'
            );
        insert l;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'VERIFY_EMAIL',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john@test.com'
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

        System.assertEquals('OTP_SENT', response.status);
        System.assertNotEquals(null, response.reference);
    }
    
    
       @IsTest
    static void testRevisitContact() {
  
     contact l = new contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'john@test.com'
            );
        insert l;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'VERIFY_EMAIL',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john@test.com'
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

        System.assertEquals('OTP_SENT', response.status);
        System.assertNotEquals(null, response.reference);
    }
    
    
    @IsTest
    static void testResendOTP() {

         Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'john@test.com'
            );
        insert l;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'RESEND_EMAIL_OTP',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'email' => 'john@test.com'
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

       }

    // =========================================
    // TEST: VERIFY EMAIL OTP
    // =========================================
    @IsTest
    static void testVerifyEmailOtp() {

        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'otp@test.com',
            Email_OTP_Code__c = '123456',
            Email_OTP_Expiration__c = System.now().addMinutes(10)
        );
        insert l;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'VERIFY_EMAIL_OTP',
            'email' => 'otp@test.com',
            'emailOtp' => '123456'
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

        System.assertEquals('OTP_VERIFIED', response.status);
    }
    
      @IsTest
    static void testReSendVerifyEmailOtp() {

        Lead l = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'otp@test.com',
            Email_OTP_Code__c = '123456',
            Email_OTP_Expiration__c = System.now().addMinutes(10)
        );
        insert l;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'RESEND_MOBILE_OTP',
            'email' => 'otp@test.com',
            'emailOtp' => '123456'
        }));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

  
    }

    // =========================================
    // TEST: MOBILE OTP FLOW
    // =========================================
    // 
     @IsTest
    static void testMobileOtpFlow() {

        Lead l = new Lead(
            FirstName = 'Mobile',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'mobile@test.com',
            Email_OTP_Verified__c = true
        );
        insert l;

        // SEND MOBILE OTP
        RestRequest req1 = new RestRequest();
        req1.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req1.httpMethod = 'POST';
        req1.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'SEND_MOBILE_OTP',
            'email' => 'mobile@test.com',
            'mobile' => '9999999999',
            'countryCode' => '+91'
        }));

        RestContext.request = req1;
        RestContext.response = new RestResponse();

        Test.startTest();
        
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();
        
    }
    @IsTest
    static void testVerifyMobileOtpFlow() {

        Lead l = new Lead(
            FirstName = 'Mobile',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'mobile@test.com',
            Email_OTP_Verified__c = true
        );
        insert l;

        // SEND MOBILE OTP
        RestRequest req1 = new RestRequest();
        req1.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req1.httpMethod = 'POST';
        req1.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'SEND_MOBILE_OTP',
            'email' => 'mobile@test.com',
            'mobile' => '9999999999',
            'countryCode' => '+91'
        }));

        RestContext.request = req1;
        RestContext.response = new RestResponse();


        Lead updatedLead = [SELECT Mobile_OTP_Code__c, Mobile_OTP_Expiration__c
                            FROM Lead WHERE Email='mobile@test.com'];

        // VERIFY MOBILE OTP
        RestRequest req2 = new RestRequest();
        req2.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req2.httpMethod = 'POST';
        req2.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'VERIFY_MOBILE_OTP',
            'email' => 'mobile@test.com',
            'mobileOtp' => updatedLead.Mobile_OTP_Code__c
        }));


        
        RestContext.request = req2;
        RestContext.response = new RestResponse();

                  Lead l2 = new Lead(
            FirstName = 'Mobile',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'mobile@test2.com',
            Email_OTP_Verified__c = true,
            mobilephone = '9999999999',
              Mobile_OTP_Expiration__c = system.now()
        );
        insert l2;
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        // AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response1 =
            AdmissionsUnifiedLeadAPIOrg.sendMobileOtpSms(l2.Id);
        Test.stopTest();

        System.assertEquals('OTP_VERIFIED', response.status);
    }

    // =========================================
    // TEST: FINAL SUBMIT
    // =========================================
    @IsTest
    static void testFinalSubmit() {

        Lead l = new Lead(
            FirstName = 'Final',
            LastName = 'User',
            Company = 'Test',
            Status = 'New',
            Email = 'final@test.com',
            Email_OTP_Verified__c = true,
            Mobile_OTP_Verified__c = true,
            Category__c = 'Karnataka'
        );
        insert l;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'FINAL_SUBMIT',
            'email' => 'final@test.com',
            'school' => 'Test School',
            'programBatch' => 'MBA'
        }));

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

       // System.assertEquals('FINAL_SUBMIT_SUCCESS', response.status);
    }

    // =========================================
    // TEST: GET SCHOOL PROGRAMS
    // =========================================
    @IsTest
    static void testGetSchoolPrograms() {
        String enrolmentYear = AdmissionsUnifiedLeadAPIOrg.getCurrentEnrolmentYear();

    // 🔹 STEP 2: Create Parent School (Group B to test normalization)
    Account school = new Account(
        Name = 'School of Computer Science and Engineering - Group B'
    );
    insert school;

    // 🔹 STEP 3: Academic Program RecordType
    RecordType academicProgramRT = [
        SELECT Id FROM RecordType
        WHERE DeveloperName = 'Academic_Program'
        LIMIT 1
    ];

    // 🔹 STEP 4: Program Account (child of school)
    Account program = new Account(
        Name = 'B.Tech CSE',
        RecordTypeId = academicProgramRT.Id,
        ParentId = school.Id
    );
    insert program;

    // 🔹 STEP 5: Program Batch
    hed__Program_Plan__c batch = new hed__Program_Plan__c(
        Name = 'B.Tech CSE (2026-2030)',
        hed__Account__c = program.Id
    );
    insert batch;

    // 🔹 STEP 6: Insert Fee Master (IMPORTANT: enrolmentYear must match CMDT)
    Fee_Master__c fm = new Fee_Master__c(
        Program_Batch__c = batch.Id,
        Applicant_Category__c = 'Indian (SAARC)',
        Fee_Type__c = 'Application Fee',
        IsActive__c = true,
        Enrolment_Year__c = enrolmentYear,   // 🔥 MUST MATCH
        Application_Number_Prefix__c = '24MBA',
        Program_Name_Display__c = 'B.Tech CSE'
    );
    insert fm;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit?type=schoolPrograms&selectionMode=ApplicationFee';
        req.httpMethod = 'GET';
        req.addParameter('type', 'schoolPrograms');
        req.addParameter('selectionMode', 'ApplicationFee');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        String response = AdmissionsUnifiedLeadAPIOrg.getData();
        Test.stopTest();

        System.assertNotEquals(null, response);
        
        Map<String, Object> result =
        (Map<String, Object>) JSON.deserializeUntyped(response);

    System.assert(
        result.containsKey('School of Computer Science and Engineering')
    );
    }
    
      @IsTest
    static void testGetSchoolProgramsQuote() {

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit?type=schoolPrograms&selectionMode=ApplicationFee';
        req.httpMethod = 'GET';
        req.addParameter('type', 'schoolPrograms');
        req.addParameter('selectionMode', 'ManagementFee');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        String response = AdmissionsUnifiedLeadAPIOrg.getData();
        Test.stopTest();

        System.assertNotEquals(null, response);
    }

    // =========================================
    // TEST: CONTACT REVISIT FLOW
    // =========================================
    @IsTest
    static void testContactRevisitFlow() {

        Contact con = new Contact(
            LastName = 'Revisit',
            Email = 'contact@test.com',
            Revisit_OTP_Code__c = '111111',
            Revisit_OTP_Expiration__c = System.now().addMinutes(10),
            Application_Fee_Paid__c = true
        );
        insert con;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'action' => 'VERIFY_EMAIL_OTP',
            'email' => 'contact@test.com',
            'emailOtp' => '111111'
        }));

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
            AdmissionsUnifiedLeadAPIOrg.submit();
        Test.stopTest();

      //  System.assertEquals('PAYMENT_COMPLETED', response.status);
    }
    
    @IsTest
static void testFinalSubmit_NewLead_Success() {

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'FINAL_SUBMIT',
        'firstName' => 'Test',
        'lastName' => 'User',
        'email' => 'newlead@test.com',
        'mobile' => '9876543210',
        'countryCode' => 'India (+91)',
        'category' => 'Karnataka',
        'country' => 'India',
        'state' => 'KA',
        'school' => 'Test School',
        'programBatch' => 'MBA'
    }));

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();
    Test.stopTest();

    //System.assertEquals('LEAD_CREATED', response.status);
}

@IsTest
static void testFinalSubmit_InvalidMobile() {

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'FINAL_SUBMIT',
        'firstName' => 'Test',
        'email' => 'invalid@test.com',
        'mobile' => '12345', // ❌ invalid
        'countryCode' => 'India (+91)'
    }));

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();
    Test.stopTest();

    //System.assertEquals('INVALID_MOBILE', response.status);
}

@IsTest
static void testFinalSubmit_DuplicateMobile() {

    // Existing Lead with same formatted mobile
    Lead existing = new Lead(
        FirstName = 'Dup',
        LastName = 'User',
        Company = 'Test',
        Status = 'New',
        MobilePhone = '+91-9876543210'
    );
    insert existing;

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'FINAL_SUBMIT',
        'firstName' => 'Test',
        'email' => 'dup@test.com',
        'mobile' => '9876543210',
        'countryCode' => 'India (+91)'
    }));

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();
    Test.stopTest();

  //  System.assertEquals('MOBILE_ALREADY_REGISTERED', response.status);
}

@IsTest
static void testFinalSubmit_NoCountryCode() {

    RestRequest req = new RestRequest();
    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'FINAL_SUBMIT',
        'firstName' => 'Test',
        'email' => 'nocode@test.com',
        'mobile' => '9876543210'
    }));

    RestContext.request = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();
    Test.stopTest();

  //  System.assertEquals('INVALID_COUNTRY_CODE', response.status);
}
    
    @IsTest
static void testVerifyEmailOtp_PaymentCompleted() {

    // Get existing Program Batch from TestSetup
    hed__Program_Plan__c pb = [
        SELECT Id, Name
        FROM hed__Program_Plan__c
        LIMIT 1
    ];

    // Create School Account
    Account school = new Account(
        Name = 'Test School'
    );
    insert school;

    // Create Contact
    Contact con = new Contact(
        FirstName = 'Revisit',
        LastName = 'User',
        Email = 'payment@test.com',
        Revisit_OTP_Code__c = '123456',
        Revisit_OTP_Expiration__c = System.now().addMinutes(10),
        Application_Fee_Paid__c = true,
        Application_Number__c = 'APP12345'
       // School__c = school.Id,
        //Program_Batch__c = pb.Id
    );
    insert con;

  Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
           USer newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;

    // Prepare REST Request
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'VERIFY_EMAIL_OTP',
        'email' => 'payment@test.com',
        'emailOtp' => '123456'
    }));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();

    Test.stopTest();
}
    @IsTest
static void testCompleteRegistration_LeadNotFound() {

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'COMPLETE_REGISTRATION',
        'email' => 'notfound@test.com'
    }));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();

    Test.stopTest();

    System.assertEquals('LEAD_NOT_FOUND', response.status);
}
    @IsTest
static void testCompleteRegistration_EmailNotVerified() {

    Lead ld = new Lead(
        FirstName = 'Test',
        LastName = 'User',
        Company = 'Test',
        Status = 'Open',
        Email = 'complete@test.com',
        Email_OTP_Verified__c = false
    );
    insert ld;

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'COMPLETE_REGISTRATION',
        'email' => 'complete@test.com'
    }));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();

    Test.stopTest();

    System.assertEquals('EMAIL_NOT_VERIFIED', response.status);
}
    @IsTest
static void testCompleteRegistration_MobileNotVerified() {

    Lead ld = new Lead(
        FirstName = 'Test',
        LastName = 'User',
        Company = 'Test',
        Status = 'Open',
        Email = 'india@test.com',
        Email_OTP_Verified__c = true,
        Mobile_OTP_Verified__c = false,
        Country_Code__c = 'India (+91)'
    );
    insert ld;

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'COMPLETE_REGISTRATION',
        'email' => 'india@test.com'
    }));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();

    AdmissionsUnifiedLeadAPIOrg.ResponseWrapper response =
        AdmissionsUnifiedLeadAPIOrg.submit();

    Test.stopTest();

    System.assertEquals('MOBILE_NOT_VERIFIED', response.status);
}
    @IsTest
static void testCompleteRegistration_UpdateLeadFields() {

    Lead ld = new Lead(
        FirstName = 'Test',
        LastName = 'User',
        Company = 'Test',
        Status = 'Open',
        Email = 'updatelead@test.com',
        Email_OTP_Verified__c = true,
        Mobile_OTP_Verified__c = true
    );
    insert ld;

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestUri = '/services/apexrest/AdmissionsOrg/lead/submit';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'action' => 'COMPLETE_REGISTRATION',
        'email' => 'updatelead@test.com',
        'category' => 'Karnataka',
        'school' => 'School of Civil Engineering',
        'programBatch' => 'Bachelor of Architecture',
        'state' => 'Karnataka',
        'country' => 'India',
        'mobile' => '9876543210',
        'countryCode' => '+91'
    }));

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    AdmissionsUnifiedLeadAPIOrg.submit();
    Test.stopTest();

    Lead updatedLead = [
        SELECT Category__c,
               School__c,
               Program_Name_Display__c,
               State__c,
               Country__c,
               MobilePhone,
               Country_Code__c
        FROM Lead
        WHERE Id = :ld.Id
    ];

    System.assertEquals('Karnataka', updatedLead.Category__c);
    System.assertEquals('School of Civil Engineering', updatedLead.School__c);
    System.assertEquals('Bachelor of Architecture', updatedLead.Program_Name_Display__c);
    System.assertEquals('Karnataka', updatedLead.State__c);
    System.assertEquals('India', updatedLead.Country__c);
    System.assertEquals('+91-9876543210', updatedLead.MobilePhone);
    System.assertEquals('India (+91)', updatedLead.Country_Code__c);
}
}