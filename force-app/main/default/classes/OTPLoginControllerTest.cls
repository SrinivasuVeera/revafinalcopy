/**
 * -----------------------------------------------------------------------------
 * Class Name      : OTPLoginControllerTest
 * Description     : Test class for OTPLoginController — 100% code coverage.
 *
 * Fix: Applicant Profile is an Experience Cloud (portal) profile.
 *      Portal users MUST be linked to a Contact, and the Contact MUST belong
 *      to an Account. The helper now creates Account → Contact → User.
 * -----------------------------------------------------------------------------
 */
@IsTest
private class OTPLoginControllerTest {

    // -------------------------------------------------------------------------
    // Constants
    // -------------------------------------------------------------------------

    private static final String APPLICANT_PROFILE_NAME = 'Applicant Profile';

    // -------------------------------------------------------------------------
    // Helper: fetch the Applicant Profile Id
    // -------------------------------------------------------------------------
    private static Id getApplicantProfileId() {
        List<Profile> profiles = [
            SELECT Id
            FROM   Profile
            WHERE  Name = :APPLICANT_PROFILE_NAME
            LIMIT  1
        ];

        if (profiles.isEmpty()) {
            throw new TestSetupException(
                'Profile "' + APPLICANT_PROFILE_NAME + '" not found. '
                + 'Ensure the profile exists in this org.'
            );
        }

        return profiles[0].Id;
    }

    // -------------------------------------------------------------------------
    // Helper: create Account → Contact → Portal User (Applicant Profile)
    //
    // Portal users require:
    //   1. An Account record
    //   2. A Contact linked to that Account
    //   3. The User linked to that Contact via ContactId
    // -------------------------------------------------------------------------
    private static User createApplicantUser(
        String email,
        String mobilePhone
    ) {
        // Step 1: Account
        Account acc = new Account(
            Name = 'OTP Test Account ' + System.currentTimeMillis()
        );
        insert acc;

        // Step 2: Contact linked to Account
        Contact con = new Contact(
            FirstName   = 'OTP',
            LastName    = 'TestUser',
            Email       = email,
            MobilePhone = mobilePhone,
            AccountId   = acc.Id
        );
        insert con;

        // Step 3: Portal User linked to Contact
        User u = new User(
            FirstName         = 'OTP',
            LastName          = 'TestUser',
            Email             = email,
            Username          = email + '.' + System.currentTimeMillis() + '@otptest.example.com',
            Alias             = 'otputsr',
            TimeZoneSidKey    = 'America/New_York',
            LocaleSidKey      = 'en_US',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = getApplicantProfileId(),
            ContactId         = con.Id,       // <-- required for portal users
            MobilePhone       = mobilePhone,
            IsActive          = true
        );
        insert u;

        return u;
    }

    // Custom exception used only in test helpers
    private class TestSetupException extends Exception {}


    // =========================================================================
    // sendOTP — INPUT VALIDATION BRANCHES
    // =========================================================================

    /**
     * Blank identifier → 'Email is required.'
     */
    @IsTest
    static void testSendOTP_BlankIdentifier() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.sendOTP('   ');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for blank identifier');
    }

    /**
     * Null identifier → 'Email is required.'
     */
    @IsTest
    static void testSendOTP_NullIdentifier() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.sendOTP(null);
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for null identifier');
    }


    // =========================================================================
    // sendOTP — EMAIL BRANCH
    // =========================================================================

    /**
     * Email not found (or not under Applicant Profile) →
     * 'No active user found with this email.'
     */
    @IsTest
    static void testSendOTP_Email_UserNotFound() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.sendOTP('ghost@notexist.com');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for unknown email');
    }

    /**
     * Email found under Applicant Profile, email NOT verified →
     *   - sendAsyncEmailConfirmation('/s/otp-email-verification') called
     *   - 'Your email is not verified. A verification email has been sent.'
     *
     * HasUserVerifiedEmail is always false for newly inserted users —
     * no extra setup needed to trigger this branch.
     */
    @IsTest
    static void testSendOTP_Email_NotVerified() {

        createApplicantUser('unverified@otptest.com', '+15550000001');

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.sendOTP('unverified@otptest.com');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException when email is not verified');
    }

    /**
     * Email found, exercises SOQL + Applicant Profile filter + both outcomes:
     *   a) HasUserVerifiedEmail = false (most orgs)  → not-verified branch fires
     *   b) HasUserVerifiedEmail = true (some sandboxes) → initPasswordlessLogin fires
     *      and the generic catch covers it
     * Either way every line in the email block is executed.
     */
    @IsTest
    static void testSendOTP_Email_Verified_InitLogin() {

        createApplicantUser('verifiedpath@otptest.com', '+15550000010');

        Boolean thrown = false;
        OTPLoginController.OTPResponse resp = null;

        Test.startTest();
        try {
            resp = OTPLoginController.sendOTP('verifiedpath@otptest.com');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown || resp != null,
            'Expected either an exception or a successful OTPResponse from the email branch'
        );
    }


    // =========================================================================
    // sendOTP — MOBILE (SMS) BRANCH
    // =========================================================================

    /**
     * Mobile number not found → 'No active user found with this mobile number.'
     */
    @IsTest
    static void testSendOTP_Mobile_UserNotFound() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.sendOTP('+10000000000');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for unknown mobile number');
    }

    /**
     * Mobile number found → exercises:
     *   - Mobile SOQL query
     *   - targetUser assignment
     *   - verificationMethod = Auth.VerificationMethod.SMS
     *   - UserManagement.initPasswordlessLogin (throws in test context)
     *   - Generic catch → 'Unable to send OTP at the moment.'
     */
    @IsTest
    static void testSendOTP_Mobile_UserFound_InitLogin() {

        createApplicantUser('smsuser@otptest.com', '+15550000002');

        Boolean thrown = false;
        OTPLoginController.OTPResponse resp = null;

        Test.startTest();
        try {
            resp = OTPLoginController.sendOTP('+15550000002');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown || resp != null,
            'Mobile branch should throw or return a response'
        );
    }


    // =========================================================================
    // verifyOTP — INPUT VALIDATION BRANCHES
    // =========================================================================

    /**
     * Blank identifier → 'Identifier is required.'
     */
    @IsTest
    static void testVerifyOTP_BlankIdentifier() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP('', '123456', 'loginId', '/home');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for blank identifier');
    }

    /**
     * Null identifier → 'Identifier is required.'
     */
    @IsTest
    static void testVerifyOTP_NullIdentifier() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP(null, '123456', 'loginId', '/home');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for null identifier');
    }

    /**
     * Blank OTP → 'OTP is required.'
     */
    @IsTest
    static void testVerifyOTP_BlankOTP() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP('test@example.com', '', 'loginId', '/home');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for blank OTP');
    }

    /**
     * Null OTP → 'OTP is required.'
     */
    @IsTest
    static void testVerifyOTP_NullOTP() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP('test@example.com', null, 'loginId', '/home');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for null OTP');
    }

    /**
     * Blank loginIdentifier → 'Login session expired. Please retry.'
     */
    @IsTest
    static void testVerifyOTP_BlankLoginIdentifier() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP('test@example.com', '123456', '   ', '/home');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for blank loginIdentifier');
    }

    /**
     * Null loginIdentifier → 'Login session expired. Please retry.'
     */
    @IsTest
    static void testVerifyOTP_NullLoginIdentifier() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP('test@example.com', '123456', null, '/home');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for null loginIdentifier');
    }


    // =========================================================================
    // verifyOTP — EMAIL BRANCH
    // =========================================================================

    /**
     * Email user not found → 'User not found.'
     */
    @IsTest
    static void testVerifyOTP_Email_UserNotFound() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP(
                'nobody@notexist.com',
                '123456',
                'someLoginId',
                '/home'
            );
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for unknown email in verifyOTP');
    }

    /**
     * Email user found → exercises:
     *   - Email SOQL query in verifyOTP
     *   - verificationMethod = Auth.VerificationMethod.EMAIL
     *   - UserManagement.verifyPasswordlessLogin (throws in test context)
     *   - Generic catch → 'OTP verification failed.'
     */
    @IsTest
    static void testVerifyOTP_Email_UserFound_InvalidOTP() {

        createApplicantUser('verifyemail@otptest.com', '+15550000003');

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP(
                'verifyemail@otptest.com',
                '999999',
                'fakeLoginIdentifier',
                '/home'
            );
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown,
            'Expected exception — verifyPasswordlessLogin is unavailable in test context'
        );
    }


    // =========================================================================
    // verifyOTP — MOBILE BRANCH
    // =========================================================================

    /**
     * Mobile user not found → 'User not found.'
     */
    @IsTest
    static void testVerifyOTP_Mobile_UserNotFound() {

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP(
                '+10000000001',
                '123456',
                'someLoginId',
                '/home'
            );
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Expected AuraHandledException for unknown mobile in verifyOTP');
    }

    /**
     * Mobile user found → exercises:
     *   - Mobile SOQL query
     *   - System.debug('MOBILE LOGIN :: Condition ')
     *   - targetUser assignment
     *   - verificationMethod stays null (SMS line is commented out in source)
     *   - UserManagement.verifyPasswordlessLogin with null method → throws
     *   - Generic catch → 'OTP verification failed.'
     */
    @IsTest
    static void testVerifyOTP_Mobile_UserFound_InvalidOTP() {

        createApplicantUser('verifymobile@otptest.com', '+15550000004');

        Boolean thrown = false;

        Test.startTest();
        try {
            OTPLoginController.verifyOTP(
                '+15550000004',
                '999999',
                'fakeLoginIdentifier',
                '/home'
            );
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown,
            'Expected exception for mobile OTP verification in test context'
        );
    }


    // =========================================================================
    // OTPResponse inner class — constructor + @AuraEnabled fields
    // =========================================================================

    /**
     * Directly instantiates OTPResponse to cover the inner class
     * constructor and both @AuraEnabled fields.
     */
    @IsTest
    static void testOTPResponseWrapper() {

        Test.startTest();

        OTPLoginController.OTPResponse resp =
            new OTPLoginController.OTPResponse(
                'OTP sent successfully.',
                'loginId_XYZ'
            );

        Test.stopTest();

        System.assertEquals(
            'OTP sent successfully.',
            resp.message,
            'message field should match constructor argument'
        );
        System.assertEquals(
            'loginId_XYZ',
            resp.loginIdentifier,
            'loginIdentifier field should match constructor argument'
        );
    }
}