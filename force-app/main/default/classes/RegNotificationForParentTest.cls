@isTest
private class RegNotificationForParentTest {
    
   static testMethod void testBatchExecution() {              

        // Test data setup for hed__Application__c and hed__Applicant__c
       // List<Contact> contacts = new List<Contact>();
       
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
       
       Contact parent1 = new Contact(
            FirstName = 'Parent',
            LastName = 'One',
            Email = 'parent1@example.com',
           MobilePhone = '9900990089'
        );
        Contact parent2 = new Contact(
            FirstName = 'Parent',
            LastName = 'Two',
            Email = 'parent2@example.com',
            MobilePhone = '9900990088'
        );
       List<Contact> parentList = new List<Contact> { parent1, parent2 };  
        insert parentList;
       
       

        // Start the batch
        Test.startTest();
        RegNotificationForParent batch = new RegNotificationForParent(con,parentList,semName);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}