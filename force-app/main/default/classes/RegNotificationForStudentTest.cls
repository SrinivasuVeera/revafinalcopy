@isTest
private class RegNotificationForStudentTest {
    
   static testMethod void testBatchExecution() {              

        // Test data setup for hed__Application__c and hed__Applicant__c
        List<Contact> contacts = new List<Contact>();
       
            Contact con = new Contact(
                FirstName = 'TestFirstName1',
                LastName = 'TestLastName1',
                MobilePhone = '1234567890',                
                SRN_Number__c = '656TY',
                hed__WorkEmail__c = 'sanm@gmail.com'
            );           
       
        	insert con;
       
         String contactId = con.Id;
         String semName = 'MCA-3rd-Sem';
         String srnNum = 'SRN786';       

        // Start the batch
        Test.startTest();
        RegNotificationForStudent batch = new RegNotificationForStudent(contactId,semName,srnNum);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}