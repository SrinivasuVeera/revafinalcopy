@isTest
public class rveupdateCheckinginEligilblecontactTest {
   
    @testSetup
    static void setup() {
        // Create test data
          Account acc = new Account(Name='TestAcc');
        insert acc;
        // Create sample Program Plans
        List<hed__Program_Plan__c> programPlans = new List<hed__Program_Plan__c>();
        for (Integer i = 0; i < 5; i++) {
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c(Name = 'Program Plan ' + i);
            programPlans.add(programPlan);
        }
        insert programPlans;
        System.debug('program plans are: ' + programPlans);
        hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
            Program_Batch__c = programPlans[0].Id,
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_1_Start_date__c = Date.today().addMonths(1),
            Exam_Start_Date__c = Date.today().addMonths(2),
            IA_1_End_date__c = Date.today().addMonths(3),
            IA_2_Start_date__c = Date.today().addMonths(4),
            IA_2_End_date__c = Date.today().addMonths(5),
            hed__Account__c = acc.Id
        );
        insert term;
        List<Contact> testContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact(
                FirstName = 'Test' + i,
                LastName = 'Student' + i,
                Email = 'test' + i + '@example.com',
                SRN_Number__c = 'SRN' + i,
                Total_average_current_sem_attendance__c = 73, 
                Active_Semester__c =term.id, 
                Program_Batch__c = programPlans[0].Id,
                Active__c = true
            );
            testContacts.add(con);
        }
        insert testContacts;

        // Create test Program Plan
        hed__Program_Plan__c programPlan = new hed__Program_Plan__c(
            Name = 'Test Program Plan'
        );
        insert programPlan;
        
        List<Student_Fee__c>StudentFees = new List<Student_Fee__c>();
        for(Contact con : testContacts)
        {
         Student_Fee__c StudentFee = new Student_Fee__c(
            Name = 'Test Student Fee',
            contact__c = con.Id,
            Amount_Pending__c=0
        );
            StudentFees.add(StudentFee);
        }
        insert StudentFees;

        // Assign Contacts to the Program Plan (assumes a junction object or related list)
        // This part depends on how Contacts are related to Program Plans in your data model
    }

    @isTest
    static void testUpdateInEligibility() {
        hed__Program_Plan__c programPlan = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        List<Contact> testContacts = [SELECT Id FROM Contact LIMIT 5];
        Test.startTest();
        List<List<String>> inputList = new List<List<String>>();
        inputList.add(new List<String>{programPlan.Id});
        rve_update_Checking_inEligilble_contact.updateInEligibility(inputList);
        Test.stopTest();
        List<Contact> updatedContacts = [SELECT Id, Checking_Eligibility_for_Exam__c FROM Contact WHERE Id IN :testContacts];
        for (Contact con : updatedContacts) {
        }
    }


}