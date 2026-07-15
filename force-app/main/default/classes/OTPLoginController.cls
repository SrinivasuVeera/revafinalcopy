/**
 * -----------------------------------------------------------------------------
 * Class Name      : OTPLoginController
 * Description     : passwordless OTP login controller
 *                   supporting Email and SMS authentication.
 *
 * Notes:
 * - Email verification is checked BEFORE sending OTP 
 * - Active user validation
 * - Experience Cloud compatible
 * -----------------------------------------------------------------------------
 */

public without sharing class OTPLoginController {

    /**
     * Wrapper response returned to LWC/Aura
     */
    public class OTPResponse {

        @AuraEnabled
        public String message;

        @AuraEnabled
        public String loginIdentifier;

        public OTPResponse(
            String message,
            String loginIdentifier
        ) {
            this.message = message;
            this.loginIdentifier = loginIdentifier;
        }
    }

    /**
     * Sends OTP using Email or SMS
     */
    @AuraEnabled
    public static OTPResponse sendOTP(String identifier) {

        try {

            if (String.isBlank(identifier)) {
                throw new AuraHandledException(
                    'Email is required.'
                );
            }

            identifier = identifier.trim();

            User targetUser;
            Auth.VerificationMethod verificationMethod;

            /*
             * EMAIL LOGIN FLOW
             */
            if (identifier.contains('@')) {

                List<User> users = [
                    SELECT Id,
                           Email,
                           IsActive,
                           HasUserVerifiedEmail
                    FROM User
                    WHERE Email = :identifier
                    AND IsActive = true
                    AND Profile.Name = 'Applicant Profile'
                    LIMIT 1
                ];

                if (users.isEmpty()) {
                    throw new AuraHandledException(
                        'No active user found with this email.'
                    );
                }

                targetUser = users[0];

                /*
                 * VERIFY EMAIL BEFORE SENDING OTP
                 */
                if (!targetUser.HasUserVerifiedEmail) {

                    try {

                       System.UserManagement.sendAsyncEmailConfirmation(
                            targetUser.Id,
                            null,
                            Network.getNetworkId(),
                            '/s/otp-email-verification'
                        );

                    } catch (Exception emailEx) {

                        System.debug(
                            LoggingLevel.ERROR,
                            'Email confirmation failed: '
                            + emailEx.getMessage()
                        );
                    }

                    throw new AuraHandledException(
                        'Your email is not verified. '
                        + 'A verification email has been sent.'
                    );
                }

                verificationMethod =
                    Auth.VerificationMethod.EMAIL;
            }

            /*
             * MOBILE LOGIN FLOW
             */
            else {

                List<User> users = [
                    SELECT Id,
                           MobilePhone,
                           IsActive
                    FROM User
                    WHERE MobilePhone = :identifier
                    AND IsActive = true
                    LIMIT 1
                ];

                if (users.isEmpty()) {
                    throw new AuraHandledException(
                        'No active user found with this mobile number.'
                    );
                }

                targetUser = users[0];
                verificationMethod =
                    Auth.VerificationMethod.SMS;              
            }

            /*
             * SEND OTP
             */
            String loginIdentifier =
                UserManagement.initPasswordlessLogin(
                    targetUser.Id,
                    verificationMethod
                );
            
            System.debug('loginIdentifier ::'+loginIdentifier);

            return new OTPResponse(
                'OTP sent successfully.',
                loginIdentifier
            );

        } catch (AuraHandledException ex) {

            throw ex;

        } catch (Exception ex) {

            System.debug(
                LoggingLevel.ERROR,
                'sendOTP Error: ' + ex.getMessage()
            );

            throw new AuraHandledException(
                'Unable to send OTP at the moment.'
            );
        }
    }

    /**
     * Verifies OTP and returns redirect URL
     */
    @AuraEnabled
    public static String verifyOTP(
        String identifier,
        String otp,
        String loginIdentifier,
        String startUrl
    ) {

        try {

            /*
             * VALIDATIONS
             */
            if (String.isBlank(identifier)) {
                throw new AuraHandledException(
                    'Identifier is required.'
                );
            }

            if (String.isBlank(otp)) {
                throw new AuraHandledException(
                    'OTP is required.'
                );
            }

            if (String.isBlank(loginIdentifier)) {
                throw new AuraHandledException(
                    'Login session expired. Please retry.'
                );
            }

            identifier = identifier.trim();

            User targetUser;
            Auth.VerificationMethod verificationMethod;

            /*
             * EMAIL LOGIN
             */
            if (identifier.contains('@')) {

                List<User> users = [
                    SELECT Id,
                           IsActive
                    FROM User
                    WHERE Email = :identifier
                    AND IsActive = true
                    LIMIT 1
                ];

                if (users.isEmpty()) {
                    throw new AuraHandledException(
                        'User not found.'
                    );
                }

                targetUser = users[0];

                verificationMethod =
                    Auth.VerificationMethod.EMAIL;
            }

            /*
             * MOBILE LOGIN
             */
            else {

                List<User> users = [
                    SELECT Id,
                           IsActive
                    FROM User
                    WHERE MobilePhone = :identifier
                    AND IsActive = true
                    LIMIT 1
                ];

                if (users.isEmpty()) {
                    throw new AuraHandledException(
                        'User not found.'
                    );
                }
                System.debug('MOBILE LOGIN :: Condition ');
                targetUser = users[0];
                
                // verificationMethod = Auth.VerificationMethod.SMS;
            }

            /*
             * VERIFY OTP
             */
            Auth.VerificationResult verificationResult =
                UserManagement.verifyPasswordlessLogin(
                    targetUser.Id,
                    verificationMethod,
                    loginIdentifier,
                    otp,
                    startUrl
                );

            if (
                verificationResult != null &&
                verificationResult.success &&
                verificationResult.redirect != null
            ) {
                return verificationResult.redirect.getUrl();
            }

            throw new AuraHandledException(
                'Invalid OTP.'
            );

        } catch (AuraHandledException ex) {

            throw ex;

        } catch (Exception ex) {

            System.debug(
                LoggingLevel.ERROR,
                'verifyOTP Error: ' + ex.getMessage()
            );

            throw new AuraHandledException(
                'OTP verification failed.'
            );
        }
    }    
}