@isTest
public class getContactDetailsTest {
    
    @testSetup
    static void setup() {
        // Create parent Account
        Account accparent = new Account(Name = 'TestAccParent');
        insert accparent;
        
        // Create child Account with parentId
        Account acc = new Account(Name = 'TestAcc', ParentId = accparent.Id);
        insert acc;
        
        // Create Program Batch (hed__Program_Plan__c)
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'TestProgramBatch';
        programBatch.hed__Account__c = acc.Id;
        insert programBatch;
        
        // Create Semester (hed__Term__c)
        hed__Term__c semester = new hed__Term__c();
        semester.Name = '3rd Semester';
        semester.Program_Batch__c =ProgramBatch.id;
        semester.hed__Account__c = acc.Id;
        
        insert semester;
        
        // Create Contact
        Contact con = new Contact();
        con.FirstName = 'Suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = programBatch.Id;
        con.Active_Semester__c = semester.Id;
        con.SRN_Number__c = 'SA001';
        con.Active__c = true;
        insert con;
        
        // Create a User and associate it with the Contact
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Student Portal Profile' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testusejjhbdcr@test.com',
            ContactId = con.Id
        );
        insert testUser;
    }
    
    @isTest
    static void testContactDetails() {
        // Retrieve the test user
        Contact con = [Select Id from contact where lastname = 'Madala'];
        System.debug('con=> '+con);
        User testUser = [SELECT Id,ContactId FROM User WHERE lastname = 'TestUser' LIMIT 1];
        System.debug('testuser=> '+testUser.Id+' ContactId=> '+testuser.ContactId);
        
        System.runAs(testUser) {
            // Execute the method to be tested
            try{
                Test.startTest();
                getContactDetails.ContactDetails();
                Test.stopTest();
            }
            catch(exception e){
                system.debug('Line=> '+e.getLineNumber()+' exception test--->'+e.getmessage());
                
            }
            
            
            // Verify the results
            /* System.assertNotEquals(null, result, 'Contact should not be null');
System.assertEquals('Suraj Madala', result.Name, 'Name should match');
System.assertEquals('Suraj', result.FirstName, 'First name should match');
System.assertEquals('Madala', result.LastName, 'Last name should match');
System.assertEquals('TestProgramBatch', result.Program_Batch__r.Name, 'Program batch name should match');
System.assertEquals('3rd Semester', result.Active_Semester__r.Name, 'Active semester name should match');
System.assertEquals('SA001', result.SRN_Number__c, 'SRN Number should match');
System.assertTrue(result.Active__c, 'Active should be true');*/
            
           
        }
    }
     
/********************New test method************************/
    @isTest
static void testIsPGStudent() {
    // Get the RecordTypeId for Academic Program
    RecordType academicProgramRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Academic Program' LIMIT 1];

    // Create an Account with RecordType = Academic Program and Program_Type__c = 'PG'
    Account academicProgramAccount = new Account(
        Name = 'MSc Computer Science',
        RecordTypeId = academicProgramRT.Id,
        Program_Type__c = 'PG' // This field is assumed to exist and drives the formula on Contact
    );
    insert academicProgramAccount;

    // Get the test Contact and associate the Academic Program
    User testUser = [SELECT Id, ContactId FROM User WHERE LastName = 'TestUser' LIMIT 1];
    Contact con = [SELECT Id FROM Contact WHERE Id = :testUser.ContactId];

    con.Primary_Academic_Program__c = academicProgramAccount.Id;
    update con;

    // Run the method as the test user
    System.runAs(testUser) {
        Test.startTest();
        Boolean result = getContactDetails.isPGStudent();
        Test.stopTest();

        System.assertEquals(true, result, 'Expected PG student to return true based on academic program');
    }
}

}