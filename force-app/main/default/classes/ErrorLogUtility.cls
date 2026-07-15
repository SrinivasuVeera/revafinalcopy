public class ErrorLogUtility {
    public static void logError(Exception ex) {
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Error_Message__c = ex.getMessage();
        errorLog.Stack_Trace__c = ex.getStackTraceString();
        errorLog.Error_Type__c = ex.getTypeName(); // You can customize error types based on your needs.
        errorLog.Time_stamp__c = System.now();
        errorLog.Line_Number__c = ex.getLineNumber();
        try {
            insert errorLog;
            sendErrorEmail(ex, errorLog.Id);
        } catch (Exception e) {
            // Handle the exception if there's an issue inserting the error log.
            System.debug('Error inserting error log record: ' + e.getMessage());
        }
    }
    
    private static void sendErrorEmail(Exception ex, Id errorLogId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String recordPageUrl = URL.getOrgDomainURL().toExternalForm() + '/' + errorLogId;
        System.debug('Record URL ' + recordPageUrl);
        email.setSubject('Error Notification');
        email.setPlainTextBody(
            'An error occurred:\n\n' +
            'Error Message: ' + ex.getMessage() + '\n' +
            'Stack Trace: ' + ex.getStackTraceString() + '\n' +
            'Error Type: ' + ex.getTypeName() + '\n' +
            'Line Number: ' + ex.getLineNumber() + '\n\n' +
            'For more details, check here: ' + recordPageUrl
        );
		String recipientEmail = UserInfo.getUserEmail();    
        System.debug('Recipient Email ' + recipientEmail);
        email.setToAddresses(new String[] { recipientEmail }); // Replace with the recipient's email address

        // Optionally, you can set additional parameters for the email, such as CC, BCC, etc.

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            System.debug('Emaill ' + email);
        } catch (Exception e) {
            // Handle the exception if there's an issue sending the email.
            System.debug('Error sending email notification: ' + e.getMessage());
        }
    }
}