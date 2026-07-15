@isTest
public class Fee_ReminderToMentors_BatchTest {

    @isTest
    static void testBatchExecution() {
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAccount1 = new Account();
        objAccount1.Name = 'School of Electronics and Communication Engineering';
        objAccount1.RecordTypeid = AcaRecId;
        //objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
       Id AccountRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();        
        Contact mentorContact = new Contact(
            FirstName = 'Mentor',
            LastName = 'Lastname',
            AccountId = objAccount1.Id,
            hed__WorkEmail__c = 'mentor@example.com',
            RecordTypeId = AccountRecTypeId
        );
        insert mentorContact;
        
         Case testCase = new Case(
            Subject = 'Test Case',
            ContactId = mentorContact.Id
        );
         insert testCase;
        
		
        
         hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Tech in Agriculture Engineering-(2023-2027)',
             hed__Start_Date__c = system.today().addyears(-5),
        hed__End_Date__c = system.today().addyears(+1),
           hed__Account__c = objAccount1.id
        );
        insert programBatch;
        
 Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();      
        Contact studentContact = new Contact(
            FirstName = 'Student',
            LastName = 'Lastname',
            Mentor__c = mentorContact.Id,
            Student_Status__c = 'Pursuing',
           RecordTypeId = contactRecTypeId,
            Program_Batch__c = programBatch.id
        );
        insert studentContact;
        
		caseteammember member = new caseteammember(
        ParentId = testCase.Id,
         MemberId = studentContact.Id,
            TeamRoleId = '0B75j000000blr6CAA'
        );
        insert member;
       
        Student_Fee__c studentFee = new Student_Fee__c(
            Name = 'Fee Record',
            Due_Date__c = Date.today(),
            Actual_Program_Fee__c = 100,
            Amount__c = 100,
            Amount_Pending__c = 100,
            Contact__c = studentContact.Id
        );
        insert studentFee;

        Test.startTest();
        // Start the batch job
        Fee_ReminderToMentors_Batch batchJob = new Fee_ReminderToMentors_Batch();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Add assertions or queries to verify the expected results
        // Example: System.assertEquals(expectedValue, actualValue);
    }
}