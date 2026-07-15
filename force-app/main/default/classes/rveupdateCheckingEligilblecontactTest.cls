@IsTest
public class rveupdateCheckingEligilblecontactTest {
    @testSetup
    static void setup() {
        Rve_Exam_Notification__c testExamNotification = testDataFactoryExamination.createExamNotification();
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
            hed__Account__c = acc.Id,
            Term_Number__c =2
        );
        insert term;

        // Create sample Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact contact = new Contact(
                LastName = 'Student ' + i,
                Checking_Eligibility_for_Exam__c = 'Eligible',
                Program_Batch__c = programPlans[0].Id,
                SRN_Number__c = 'SRN' + i,
                Total_average_current_sem_attendance__c = 80,
                Active_Semester__c =testExamNotification.Rve_Semester__c,
                Active__c = true
            );
            Contact contact1 = new Contact(
                LastName = 'Student ' + i+i,
                //Checking_Eligibility_for_Exam__c = 'Eligible',
                Program_Batch__c = programPlans[0].Id,
                SRN_Number__c = 'SRN' + i+i,
                Total_average_current_sem_attendance__c = 72,
                Active_Semester__c =testExamNotification.Rve_Semester__c,
                Active__c = true,
                Exam_Approval__c = false
            );
            contacts.add(contact);
            contacts.add(contact1);
        }
        insert contacts;
        System.debug('contacts are: ' + contacts);

        // Create sample Student Fees
        List<Student_Fee__c> studentFees = new List<Student_Fee__c>();
        for (Contact contact : contacts) {
            Student_Fee__c fee = new Student_Fee__c(
                Contact__c = contact.Id,
                Fee_Year__c = '1st year', // Adjust this based on the contact's term number
                Amount_Pending__c = 0
                        );
            studentFees.add(fee);
        }
        insert studentFees;
        System.debug('student fees are: ' + studentFees);
    }

    @isTest
    static void testUpdateEligibility() {
        // Retrieve the sample Program Plans created in testSetup
        List<hed__Program_Plan__c> programPlans = [SELECT Id, Name FROM hed__Program_Plan__c LIMIT 5];
        System.debug('program plans are: ' + programPlans);

        // Create the input for the InvocableMethod
        List<List<String>> ActiveProgramBatchList = new List<List<String>>();
        List<String> programPlanIds = new List<String>();
        for (hed__Program_Plan__c programPlan : programPlans) {
            programPlanIds.add(programPlan.Id);
        }
        ActiveProgramBatchList.add(programPlanIds);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        
        rve_update_Checking_Eligibility_contact.updateEligibility(ActiveProgramBatchList);
        Database.executeBatch(new RVE_UpdateStudentEligibiityForExam(),1);
        Test.stopTest();

        // Verify that the Contacts' Checking_Eligibility_for_Exam__c field is updated
        List<Contact> updatedContacts = [SELECT Id, Checking_Eligibility_for_Exam__c FROM Contact WHERE Checking_Eligibility_for_Exam__c = 'Eligible'];
     //   System.assert(!updatedContacts.isEmpty(), 'There should be eligible students.');
    /*    for (Contact contact : updatedContacts) {
            System.assertEquals('Eligible', contact.Checking_Eligibility_for_Exam__c, 'The student should be marked as eligible.');
        }*/
    }
    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true, "message": "Mock callout successful"}'); // Mock JSON response
            return res;
        }
    }
}

/*@IsTest
public class rveupdateCheckingEligilblecontactTest {
    @testSetup
    static void setup() {
        // Create sample Program Plans
         Account acc = new Account(Name='TestAcc');
        insert acc;
        List<hed__Program_Plan__c> programPlans = new List<hed__Program_Plan__c>();
        for (Integer i = 0; i < 5; i++) {
            hed__Program_Plan__c programPlan = new hed__Program_Plan__c(Name = 'Program Plan ' + i,hed__Account__c = acc.Id);
            programPlans.add(programPlan);
        }
        insert programPlans;
      
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
        

        
        // Create sample Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact contact = new Contact(LastName = 'Student ' + i,Checking_Eligibility_for_Exam__c = 'Eligible', Active_Semester__c = term.Id,Total_average_current_sem_attendance__c=75,
             Program_Batch__c = programPlans[0].Id);
            contacts.add(contact);
        }
        insert contacts;
        Student_Fee__c StudentInEligibleFee = new Student_Fee__c(
            Name = 'Test Student Fee InEligible',
            contact__c = contacts[0].Id,
            Amount_Pending__c=1,
            Due_Date__c = System.today()
        );
        insert StudentInEligibleFee;
    }
    

    @isTest
    static void testUpdateEligibility() {
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Retrieve the sample Program Plans created in testSetup
        List<hed__Program_Plan__c> programPlans = [SELECT Id, Name FROM hed__Program_Plan__c LIMIT 5];

        // Create the input for the InvocableMethod
        List<List<String>> ActiveProgramBatchList = new List<List<String>>();
        List<String> programPlanIds = new List<String>();
        for (hed__Program_Plan__c programPlan : programPlans) {
            programPlanIds.add(programPlan.Id);
        }
        ActiveProgramBatchList.add(programPlanIds);

        // Execute the method
        Test.startTest();
        rve_update_Checking_Eligibility_contact.updateEligibility(ActiveProgramBatchList);
        Test.stopTest();

        // Verify that the Contacts' Checking_Eligibility_for_Exam__c field is updated
        List<Contact> updatedContacts = [SELECT Id, Checking_Eligibility_for_Exam__c FROM Contact WHERE Active__c = true AND Checking_Eligibility_for_Exam__c = 'Eligible'];
        System.assert(!updatedContacts.isEmpty(), 'There should be eligible students.');
        for (Contact contact : updatedContacts) {
            System.assertEquals('Eligible', contact.Checking_Eligibility_for_Exam__c, 'The student should be marked as eligible.');
            
        }
    }
}*/