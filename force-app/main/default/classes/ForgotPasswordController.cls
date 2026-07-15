public without sharing class ForgotPasswordController {

    public String username {get; set;}   

    public ForgotPasswordController() {}

    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);

        if (success) {
            return pr;
        }
        return null;
    }

    @AuraEnabled
    public static String handleForgotPassword(String username) {

        if (String.isBlank(username)) {
            return 'ERROR:Please enter your username.';
        }

        try {

            if (!username.toLowerCase().endsWith('@reva.edu.in')) {

                List<Contact> conList = [
                    SELECT Application_Number__c,Email
                    FROM Contact
                    WHERE Email = :username
                    LIMIT 1
                ];

                if (!conList.isEmpty() &&
                    String.isNotBlank(conList[0].Application_Number__c)) {

                    String suggestedUsername =
                        conList[0].Application_Number__c + '@reva.edu.in';

                    return 'SUGGEST:' + suggestedUsername;
                }

                return 'ERROR:No account found with this email.';
            }

            Boolean success = Site.forgotPassword(username);

            if (success) {
                return 'Success';
            }

            return 'ERROR:Password reset failed.';

        } catch (Exception e) {
            System.debug('Unexpected Error: ' + e.getMessage());
            return 'ERROR:Something went wrong.';
        }
    }

}