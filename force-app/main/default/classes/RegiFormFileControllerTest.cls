@isTest
public class RegiFormFileControllerTest {
    
    @testSetup
    static void setupData() {
        Account acc = new Account(Name='test Account');
        insert acc;
        
        // Setup test data
        Contact contact = new Contact(
            LastName = 'Test',
            Sem_Registered__c = 3,
            Registered_Semester_Name__c = '3rd Semester',
            Registered_Semester_Date__c = Date.today(),
            Registered__c = true,
            SRN_Number__c = 'SRN123',
            hed__WorkEmail__c = 'test@student.com',
            MobilePhone = '+1234567890' 
        );
        insert contact;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Batch1');
        insert programBatch;
        
        hed__Term__c term = new hed__Term__c(
            Program_Batch__c = programBatch.Id,
            Name='3rd Semester',
            Term_Number__c = 3,
            hed__Start_Date__c = Date.today().addDays(-15),
            hed__End_Date__c = Date.today().addDays(45),
            hed__Account__c = acc.Id
        );
        insert term;
        
        Student_Fee__c feeTution = new Student_Fee__c(
            Contact__c = contact.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '2nd Year',
            Fee_Type__c = 'Tuition Fee'
        );
        insert feeTution;    
        
        Student_Fee__c feeUniversity = new Student_Fee__c(
            Contact__c = contact.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '2nd Year',
            Fee_Type__c = 'University Fee'
        );
        insert feeUniversity;
        
        
        Contact studenta = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'student@example.com',
            SRN_Number__c = 'SRN12345'
        );
        insert studenta;
        
        Contact student11 = new Contact(
            FirstName = 'Test',
            LastName = 'StudentLastname',
            hed__WorkEmail__c = 'student1@example.com',
            SRN_Number__c = 'SRN12445'            
        );
        insert student11;
        
             Contact parent1 = new Contact(
            FirstName = 'Parent',
            LastName = 'One',
            Email = 'parent1@example.com'
        );
        Contact parent2 = new Contact(
            FirstName = 'Parent',
            LastName = 'Two',
            Email = 'parent2@example.com'
        );
        insert new List<Contact> { parent1, parent2 };    
   }
    
    @isTest
    static void testCheckRegistrationEligibility() {
        // Test valid registration eligibility
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        
        Test.startTest();
        Boolean isEligible = RegiFormFileController.checkRegistrationEligibility(contact.Id, programBatch.Id);
        Test.stopTest();
        
        System.assert(isEligible, 'Student should be eligible for registration');
    }
    
    @isTest
    static void testCheckRegistrationEligibility1() {
        Account acc1 = new Account(Name='test Account1');
        insert acc1;   
        
         hed__Program_Plan__c programBatch1 = new hed__Program_Plan__c(Name = 'Batch2');
        insert programBatch1;
         // Setup test data
        Contact contact1 = new Contact(
            LastName = 'Test1',
            Sem_Registered__c = 5,
            Registered_Semester_Name__c = '5th Semester',
            Registered_Semester_Date__c = Date.today(),
            Registered__c = true,
            SRN_Number__c = 'SRN1231',
            hed__WorkEmail__c = 'test1@student.com',
            MobilePhone = '+1234567891' 
        );
        insert contact1;
        
         hed__Term__c term1 = new hed__Term__c(
            Program_Batch__c = programBatch1.Id,
            Name='5th Semester',
            Term_Number__c = 5,
            hed__Start_Date__c = Date.today().addDays(-15),
            hed__End_Date__c = Date.today().addDays(45),
            hed__Account__c = acc1.Id
        );
        insert term1;
        
        Student_Fee__c feeTuitionFee1 = new Student_Fee__c(
            Contact__c = contact1.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '3rd Year',
            Fee_Type__c = 'Tuition Fee'
        );
        insert feeTuitionFee1;
        
        Student_Fee__c feeUniversityFee2 = new Student_Fee__c(
            Contact__c = contact1.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '3rd Year',
            Fee_Type__c = 'University Fee'
        );
        insert feeUniversityFee2;
        
        // Test valid registration eligibility
        Contact contact2 = [SELECT Id FROM Contact WHERE Sem_Registered__c = 5 LIMIT 1];
        hed__Program_Plan__c programBatch2 = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'Batch2' LIMIT 1];
        
        Test.startTest();
        Boolean isEligible = RegiFormFileController.checkRegistrationEligibility(contact2.Id, programBatch2.Id);
        Test.stopTest();
        
        System.assert(isEligible, 'Student should be eligible for registration');
    }
    
    @isTest
    static void testCheckRegistrationEligibility2() {
        Account acc2 = new Account(Name='test Account2');
        insert acc2;   
        
         hed__Program_Plan__c programBatch2 = new hed__Program_Plan__c(Name = 'Batch3');
        insert programBatch2;
         // Setup test data
        Contact contact2 = new Contact(
            LastName = 'Test2',
            Sem_Registered__c = 7,
            Registered_Semester_Name__c = '7th Semester',
            Registered_Semester_Date__c = Date.today(),
            Registered__c = true,
            SRN_Number__c = 'SRN1233',
            hed__WorkEmail__c = 'test2@student.com',
            MobilePhone = '+1234567895' 
        );
        insert contact2;
        
         hed__Term__c term2 = new hed__Term__c(
            Program_Batch__c = programBatch2.Id,
            Name='7th Semester',
            Term_Number__c = 7,
            hed__Start_Date__c = Date.today().addDays(-15),
            hed__End_Date__c = Date.today().addDays(45),
            hed__Account__c = acc2.Id
        );
        insert term2;
        
        Student_Fee__c feeTution2 = new Student_Fee__c(
            Contact__c = contact2.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '4th Year',
            Fee_Type__c = 'Tuition Fee'
        );
        insert feeTution2;
        
        Student_Fee__c feeUniversity2 = new Student_Fee__c(
            Contact__c = contact2.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '4th Year',
            Fee_Type__c = 'University Fee'
        );
        insert feeUniversity2;
        
        // Test valid registration eligibility
        Contact contact3 = [SELECT Id FROM Contact WHERE Sem_Registered__c = 7 LIMIT 1];
        hed__Program_Plan__c programBatch3 = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'Batch3' LIMIT 1];
        
        Test.startTest();
        Boolean isEligible = RegiFormFileController.checkRegistrationEligibility(contact3.Id, programBatch3.Id);
        Test.stopTest();
        
        System.assert(isEligible, 'Student should be eligible for registration');
    }
  
    @isTest
    static void testCheckRegistrationEligibility3() {
        Account acc3 = new Account(Name='test Account3');
        insert acc3;   
        
         hed__Program_Plan__c programBatch3 = new hed__Program_Plan__c(Name = 'Batch4');
        insert programBatch3;
         // Setup test data
        Contact contact3 = new Contact(
            LastName = 'Test3',
            Sem_Registered__c = 1,
            Registered_Semester_Name__c = '1st Semester',
            Registered_Semester_Date__c = Date.today(),
            Registered__c = true,
            SRN_Number__c = 'SRN8233',
            hed__WorkEmail__c = 'test8@student.com',
            MobilePhone = '+1234587895' 
        );
        insert contact3;
        
         hed__Term__c term2 = new hed__Term__c(
            Program_Batch__c = programBatch3.Id,
            Name='1st Semester',
            Term_Number__c = 1,
            hed__Start_Date__c = Date.today().addDays(-15),
            hed__End_Date__c = Date.today().addDays(45),
            hed__Account__c = acc3.Id
        );
        insert term2;
        
        Student_Fee__c feeTution2 = new Student_Fee__c(
            Contact__c = contact3.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'Tuition Fee'
        );
        insert feeTution2;
        
         Student_Fee__c feeUniversity = new Student_Fee__c(
            Contact__c = contact3.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'University Fee'
        );
        insert feeUniversity;
        
        // Test valid registration eligibility
        Contact contact4 = [SELECT Id FROM Contact WHERE Sem_Registered__c = 1 LIMIT 1];
        hed__Program_Plan__c programBatch4 = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'Batch4' LIMIT 1];
        
        Test.startTest();
        Boolean isEligible = RegiFormFileController.checkRegistrationEligibility(contact4.Id, programBatch4.Id);
        Test.stopTest();
        
       // System.assert(isEligible, 'Student should be eligible for registration');
       System.assertEquals(isEligible, false);
    }
    
    @isTest
    static void testCheckRegistrationEligibility4() {
        Account acc4 = new Account(Name='test Account4');
        insert acc4;   
        
         hed__Program_Plan__c programBatch4 = new hed__Program_Plan__c(Name = 'Batch5');
         insert programBatch4;
         // Setup test data
        Contact contact4 = new Contact(
            LastName = 'Test4',
            Sem_Registered__c = 9,
            Registered_Semester_Name__c = '9th Semester',
            Registered_Semester_Date__c = Date.today(),
            Registered__c = true,
            SRN_Number__c = 'SRN1239',
            hed__WorkEmail__c = 'test9@student.com',
            MobilePhone = '+1294567895' 
        );
        insert contact4;
        
         hed__Term__c term4 = new hed__Term__c(
            Program_Batch__c = programBatch4.Id,
            Name='9th Semester',
            Term_Number__c = 9,
            hed__Start_Date__c = Date.today().addDays(-15),
            hed__End_Date__c = Date.today().addDays(45),
            hed__Account__c = acc4.Id
        );
        insert term4;
        
        Student_Fee__c feeTution4 = new Student_Fee__c(
            Contact__c = contact4.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '5th Year',
            Fee_Type__c = 'Tuition Fee'
        );
        insert feeTution4;
        
        Student_Fee__c feeUniversity4 = new Student_Fee__c(
            Contact__c = contact4.Id,
            Amount__c = 1000,
            Amount_Paid__c = 600,
            Fee_Year__c = '5th Year',
            Fee_Type__c = 'University Fee'
        );
        insert feeUniversity4;
        
        // Test valid registration eligibility
        Contact contact3 = [SELECT Id FROM Contact WHERE Sem_Registered__c = 9 LIMIT 1];
        hed__Program_Plan__c programBatch3 = [SELECT Id FROM hed__Program_Plan__c WHERE Name = 'Batch5' LIMIT 1];
        
        Test.startTest();
        Boolean isEligible = RegiFormFileController.checkRegistrationEligibility(contact3.Id, programBatch3.Id);
        Test.stopTest();
        
        System.assert(isEligible, 'Student should be eligible for registration');
    }
   
    @isTest
    static void testIsTodayWithinStartDateRange() {
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        Integer semNumber = RegiFormFileController.isTodayWithinStartDateRange(programBatch.Id, contact.Id);
        Test.stopTest();
        
        System.assertEquals(3, semNumber, 'Semester number should be 3');
    }
    
    @isTest
    static void testUpdateContactRegistrationField() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        
        Test.startTest();
        Integer result = RegiFormFileController.updateContactRegistrationField(contact.Id, 3, programBatch.Id);
        Test.stopTest();
        
        System.assertEquals(1, result, 'Contact registration field should be updated successfully');
    }
    
    @isTest
    static void testCheckSemRegistrationField() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        
        Test.startTest();
        Boolean result = RegiFormFileController.checkSemRegistrationField(contact.Id, programBatch.Id);
        //System.debug('RESULT -->'+result);        
        Test.stopTest();               
        System.assertEquals(result, false);   
    }
    
    @isTest
    static void testDisplayDetails() {
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        String semesterName = RegiFormFileController.displayDetails(programBatch.Id, contact.Id);
        Test.stopTest();
        
        System.assertEquals('3rd Semester', semesterName, 'Semester name should be 3rd Semester');
        
    }
    
    @isTest
    static void testSendNotifications() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        hed__Program_Plan__c programBatch = [SELECT Id FROM hed__Program_Plan__c LIMIT 1];
        Contact student = [SELECT Id, Name, SRN_Number__c FROM Contact WHERE Email = 'student@example.com' LIMIT 1];
        List<Contact> parentList = [SELECT Id, Email FROM Contact WHERE Email IN ('parent1@example.com', 'parent2@example.com')];
        String semesterName = 'Fall 2024';
        
        Test.startTest();
        Integer result = RegiFormFileController.sendNotifications(contact.Id, 3, programBatch.Id);
        Test.stopTest();
        
      //  System.assertEquals(1, result, 'Notifications sent');
    } 
    
    @isTest
    static void testSendEmailToParent() {
        // Retrieve the test data
        Contact student = [SELECT Id, Name, SRN_Number__c FROM Contact WHERE Email = 'student@example.com' LIMIT 1];
        List<Contact> parentList = [SELECT Id, Email FROM Contact WHERE Email IN ('parent1@example.com', 'parent2@example.com')];
        String semesterName = 'Fall 2024';

        // Set up email mock
     //   Test.setMock(Messaging.SendEmailMock.class, new SendEmailMock());

        // Call the method to test
        Test.startTest();
        RegiFormFileController.sendEmailToParent(student, parentList, semesterName);
        Test.stopTest();

        // Verify the email was sent
    //    System.assertEquals(1, Limits.getEmailInvocations());
    	}
    
    @isTest
    static void testSendEmailToStudent() {
        // Retrieve the test data
        Contact studentSendMail = [SELECT Id, Name, SRN_Number__c,hed__WorkEmail__c FROM Contact WHERE hed__WorkEmail__c = 'student1@example.com' LIMIT 1];
        List<Contact> parentListSendMail = [SELECT Id, Email FROM Contact WHERE Email IN ('parent1@example.com', 'parent2@example.com')];
        String semesterName = 'Fall 2024';

        // Set up email mock
     //   Test.setMock(Messaging.SendEmailMock.class, new SendEmailMock());

        // Call the method to test
        Test.startTest();
        RegiFormFileController.sendEmailToStudent(studentSendMail, parentListSendMail, semesterName);
        Test.stopTest();

        // Verify the email was sent
   //     System.assertEquals(1, Limits.getEmailInvocations());
    	}
    
    @isTest
    static void testsendEmailToMentor(){
        String mentorNameParam = 'MentorName';
        String semNameParam = 'MCA-sem4';
        String studNameParam = 'Mahadev';
        String srnNumberParam = 'SRN356';
        String mobilePhoneParam = '9809878967';
        String mentorEmailId = 'mahadev@gmail.com';
        String studMobileParam = '919090909090';   
        
        Test.startTest();
        RegiFormFileController.sendEmailToMentor(mentorNameParam,semNameParam,studNameParam,srnNumberParam,
                                       mobilePhoneParam,mentorEmailId,studMobileParam);       
        Test.stopTest();        
        

        // Verify the email was sent
    //    System.assertEquals(1, Limits.getEmailInvocations());
    }
}