@isTest
public class UpdateStudentFeePaymentBatch_Test {
    
    @testSetup
    static void setup() {
        // Create test Student_Payment__c record
        Student_Payment__c studentPayment = new Student_Payment__c(
            Payment_Gateway__c = 'Billdesk',
            Payment_Date_Time__c = DateTime.now(),
            Transaction_ID__c = 'TestTransaction123',
            Mode_of_Payment__c = 'Online'
        );
        insert studentPayment;
        
        // Create test Student_Fee_Payment__c record with null values
        Student_Fee_Payment__c feePayment = new Student_Fee_Payment__c(
            Line_Item_Payment_Status__c = 'Success',
            Student_Payment__c = studentPayment.Id
            //CreatedDate = DateTime.newInstance(2024, 2, 1, 0, 0, 0) // Set a valid date
        );
        insert feePayment;
    }
    
    @isTest
    static void testBatchProcessing() {
        // Retrieve the test data created in the test setup
        Student_Fee_Payment__c feePayment = [SELECT Id, Line_Item_Payment_Gateway__c, Transaction_Date_Time__c, SF_Transaction_ID__c 
                                             FROM Student_Fee_Payment__c 
                                             LIMIT 1];
        
        // Ensure that initial values are null
        System.assertEquals(null, feePayment.Line_Item_Payment_Gateway__c);
        System.assertEquals(null, feePayment.Transaction_Date_Time__c);
        System.assertEquals(null, feePayment.SF_Transaction_ID__c);
        
        // Run the batch
        Test.startTest();
        UpdateStudentFeePaymentBatch batch = new UpdateStudentFeePaymentBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        
        // Refresh the test data to get the updated values
        feePayment = [SELECT Line_Item_Payment_Gateway__c, Transaction_Date_Time__c, SF_Transaction_ID__c,Student_Payment__c 
                      FROM Student_Fee_Payment__c 
                      WHERE Id = :feePayment.Id];
        
        // Retrieve the corresponding Student_Payment__c record
        Student_Payment__c studentPayment = [SELECT Payment_Gateway__c, Payment_Date_Time__c, Transaction_ID__c 
                                             FROM Student_Payment__c 
                                             WHERE Id = :feePayment.Student_Payment__c];

        // Assert that the fields have been correctly updated
        System.assertEquals(studentPayment.Payment_Gateway__c, feePayment.Line_Item_Payment_Gateway__c);
        System.assertEquals(studentPayment.Payment_Date_Time__c, feePayment.Transaction_Date_Time__c);
        System.assertEquals(studentPayment.Transaction_ID__c, feePayment.SF_Transaction_ID__c);
    }
}