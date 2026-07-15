@isTest
public class ErrorLogUtilityTest {

    @isTest
    static void testLogError() {
        // Create a mock exception for testing
        try {
            // Trigger an exception for testing purposes
            Integer i = 1 / 0;
        } catch (Exception ex) {
            // Call the logError method with the mock exception
            Test.startTest();
            ErrorLogUtility.logError(ex);
            Test.stopTest();

            // Query the inserted error log record and assert its values
            Error_Log__c[] errorLogs = [SELECT Id, Error_Message__c, Stack_Trace__c, Error_Type__c, Time_Stamp__c, Line_Number__c FROM Error_Log__c LIMIT 1];

            System.assertEquals(1, errorLogs.size(), 'One error log record should be inserted');

            Error_Log__c errorLog = errorLogs[0];

            // Assert the values of the error log record
            System.assertEquals(ex.getMessage(), errorLog.Error_Message__c, 'Error message should match');
            System.assertEquals(ex.getStackTraceString(), errorLog.Stack_Trace__c, 'Stack trace should match');
            System.assertEquals(ex.getTypeName(), errorLog.Error_Type__c, 'Error type should match');
            System.assertNotEquals(null, errorLog.Time_Stamp__c, 'Timestamp should not be null');
            System.assertNotEquals(null, errorLog.Line_Number__c, 'Line number should not be null');
        }
    }

    // Add more test methods if needed
}