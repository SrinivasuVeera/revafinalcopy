@isTest
public class OneTimeOwnerChangeTest {
  @isTest
    static void testBatchExecution() {
        // Create test data for Contact
        User newUser = new User(
            FirstName = '',
            LastName = 'Aman V C',
            Alias = 'oldaman',
            Email = 'oldaman@example.com',
            Username = 'oldaman@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'counselor'].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert newUser;

        User oldUser = new User(
            FirstName = 'New',
            LastName = 'Aman V C',
            Alias = 'newaman',
            Email = 'newaman@example.com',
            Username = 'newaman@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'counselor'].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert oldUser;

         Account testAccount = new Account(Name = 'Test Account', OwnerId = newUser.Id);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', OwnerId = newUser.Id);
        insert testContact;
        
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', OwnerId = newUser.Id);
        insert testLead;
        
        hed__Application__c testapp = new hed__Application__c(OwnerId = newUser.Id);
        insert testapp;
              
       //randa__Application_Review__c testAppRe = new randa__Application_Review__c(OwnerId = newUser.Id);
        //insert testAppRe;
        
        Student_fee__c StuFee = new Student_fee__c(contact__c=testContact.Id,OwnerId = newUser.Id);
        insert StuFee;
        
        Student_payment__c StuPay = new Student_payment__c(contact__c=testContact.Id,OwnerId = newUser.Id);
        insert StuPay;
        
       student_Fee_payment__c StuFeePay = new student_Fee_payment__c(OwnerId = newUser.Id);
        insert StuFeePay;        
        
   
       Test.startTest();
        OneTimeOwnerChange batchClassInstance = new OneTimeOwnerChange();
        Database.executeBatch(batchClassInstance);
        Test.stopTest();
}
}