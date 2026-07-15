@isTest
private class BulkOfflineCheckPaymentTest {
    @isTest
      static void testGetStudentFeePaymentRelatedRecords() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id,Application_Number__c='1234');
        insert testContact;
        Student_Payment__c testPayment = new Student_Payment__c(Contact__c = testContact.Id, Amount__c = 1000, Payment_Status__c = 'Pending', Mode_of_Payment__c = 'Offline');
        insert testPayment;
        Student_Fee_Payment__c testFeePayment = new Student_Fee_Payment__c(Student_Payment__c = testPayment.Id, Cheque_Bank_Name__c = 'Axis Bank',Mode_of_Payment__c = 'Offline', Line_Item_Payment_Status__c = 'Pending', Payment_Mode_Type__c = 'Cheque / DD');
        insert testFeePayment;

        // Call the method being tested
        Test.startTest();
        List<BulkOfflineCheckPayment.OfflinePaymentWrapperClass> result = BulkOfflineCheckPayment.getStudentFeePaymentRelatedRecords();
        Test.stopTest();

        // Verify the results
        System.debug(result);
      
        System.assertEquals(1, result.size());
        System.assertEquals('Axis Bank', result[0].ChequeBankName);
      
        System.assertEquals(1000, result[0].StudentPaymentAmount);
        System.assertEquals('Test Contact', result[0].ContactName);
        }

    @isTest
    static void testGetBankNames() {
        // Call the method being tested
        List<String> results = BulkOfflineCheckPayment.getBankNames();

        // Assert the results
        System.assertNotEquals(null, results);
    }
}