@isTest
public class UpdateContactActiveFieldTest {
    @isTest
    static void testContactFieldUp() {
        // Create test data
        Contact testContact = new Contact();
        testContact.FirstName = 'testing';
        testContact.LastName = 'vasu';
        testContact.Active__c = false;
        insert testContact;
        
        // Create a map with the Contact ID and desired Active__c value
        Map<Id, Boolean> userConIDMap = new Map<Id, Boolean>();
        userConIDMap.put(testContact.Id, true);
        
        // Call the future method
        Test.startTest();
        UpdateContactActiveField.ContactFieldUp(userConIDMap);
        Test.stopTest();
        
        // Verify the results
        Contact updatedContact = [SELECT Id, Active__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, updatedContact.Active__c);
    }
}