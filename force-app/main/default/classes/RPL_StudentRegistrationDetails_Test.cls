@isTest
public class RPL_StudentRegistrationDetails_Test {
    
    @testSetup static void setup() {
        // Create common test accounts
        // Rpl_Student_Registration__c
        
        Contact eCon = RPL_TestDataFactory.createContact(true);
        
        Rpl_Student_Registration__c std = RPL_TestDataFactory.createStudentRegistration(true, econ.Id);
        
        Rpl_Reva_Placement__c rpl = RPL_TestDataFactory.createRevaPlacement(true);
        
        Rpl_Company__c  cmp = RPL_TestDataFactory.createCompany(true);
        
        
        Rpl_Placement_Drive__c plc = RPL_TestDataFactory.createPlacement(true, rpl.Id, cmp.Id);
        
        Rpl_Interview__c stdIntview = RPL_TestDataFactory.createInterview(true, plc.Id);
        
        
        Rpl_Student_Registration_Drive__c stdr = new Rpl_Student_Registration_Drive__c();
        stdr.Rpl_Placement_Drive__c =  plc.Id;
        stdr.Rpl_Student_Registration__c = std.Id;
        stdr.Rpl_Is_Active__c = true;
        insert stdr;
    }
    
    @isTest
    static void testGetContactDetails() {
        // Create a test contact
        Contact eCON = [Select id from Contact  limit 1];
        // Call the method to test
        test.StartTest();
        List<Contact> result = RPL_StudentRegistrationDetails.getContactDetails(eCON.Id);
        // Negative Statement.
        //RPL_StudentRegistrationDetails.getContactDetails('90291ndmjekeew');
        test.StopTest();
        
        
        
        // Assert that the result contains the test contact
        System.assertEquals(eCON.Id, result[0].Id);
    }
    
    @isTest
    static void testfailContactDetails() {
        // Create a test contact
        Rpl_Student_Registration__c eCON = [Select id from Rpl_Student_Registration__c  limit 1];
        // Call the method to test
        test.StartTest();
        try{
            RPL_StudentRegistrationDetails.checkTheStudentPreFinalYear(null);
        } 
        catch (DmlException ex) {
            System.assertEquals('expected text', ex.getMessage());
        }
        test.stopTest();
    }
    
     @isTest
static void testInsertStudentRegDetails() {
// Create a test student registration record
Rpl_Student_Registration__c testStudentReg = new Rpl_Student_Registration__c(
// Set required fields here
);

Test.startTest();
// Call the method to test
Id result = RPL_StudentRegistrationDetails.insertStudentRegDetails(testStudentReg);
Test.stopTest();

// Assert that the method returned the expected ID
//System.assertNotEquals(null, result);
}
    
    @isTest
    static void testUpdateStudentRegDetails() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = new Rpl_Student_Registration__c(
            Rpl_Personal_Mail_ID__c = 'test@gmail.com'
            // Set required fields here
        );
        insert testStudentReg;
        
        // Call the method to test
        Id result = RPL_StudentRegistrationDetails.updateStudentRegDetails(testStudentReg);
        
        // Assert that the method returned the expected ID
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testUpdateStudentRegDetailsFail() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = [Select id, Rpl_Personal_Mail_ID__c from  Rpl_Student_Registration__c limit 1];
        
        try{
            testStudentReg.Rpl_Personal_Mail_ID__c = '';
            
            Id result = RPL_StudentRegistrationDetails.updateStudentRegDetails(testStudentReg);
            
            // Assert that the method returned the expected ID
            System.assertEquals(null, result);
            
        }catch(Exception e){
            
        }    
    }
    
    @isTest
    static void testGetTheStudentRegistrationDetails() {
        // Create a test student registration record
        Rpl_Student_Registration__c testStudentReg = new Rpl_Student_Registration__c(
            Rpl_Personal_Mail_ID__c = 'test@gmail.com'
            // Set required fields here
        );
        insert testStudentReg;
        
        // Call the method to test
        List<Rpl_Student_Registration__c> result = RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails(testStudentReg.Id);
        RPL_StudentRegistrationDetails.getTheStudentRegistrationDetails(null);
        
        // Assert that the result contains the test student registration record
        System.assertEquals(testStudentReg.Id, result[0].Id);
    }
    
    @isTest
    static void testUpdateTheOtpDetails() {
        // Create a test contact
        Contact testContact = [Select id , Personal_Email__c  from Contact  limit 1];
        // Call the method to test
        String result = RPL_StudentRegistrationDetails.sendOtpToEmail(testContact.Personal_Email__c);
        //String result1 = RPL_StudentRegistrationDetails.sendOtpToMobile('9035381030');
        //RPL_StudentRegistrationDetails.updateTheOtpDetails('test.test');
        
        // Assert that the result is not null
        //System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testSendTheOtpDetails() {
        // Create a test contact
        Contact testContact = [Select id , Personal_Email__c  from Contact  limit 1];
        // Call the method to test
        //String result = RPL_StudentRegistrationDetails.sendOtpToEmail(testContact.Personal_Email__c);
        String result1 = RPL_StudentRegistrationDetails.sendOtpToMobile('9035381030');
        //RPL_StudentRegistrationDetails.updateTheOtpDetails('test.test');
        
        // Assert that the result is not null
        //System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testupdateTheOtpDetailsfail() {
        // Create a test contact
        Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];
        // Call the method to test
        try{
            String result = RPL_StudentRegistrationDetails.sendOtpToEmail('test.test');
            
        }catch(Exception e){
            
        }
        
    }
    
    @isTest
    static void testCheckForTheStudentList() {
        // Create a test contact
        Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];
        
        // Call the method to test
        Integer result = RPL_StudentRegistrationDetails.checkForTheStudentList(testContact.Id);
        
        
    }
    
    @isTest
    static void testCheckForTheStudentListFail() {
        
        // Call the method to test
        Integer result = RPL_StudentRegistrationDetails.checkForTheStudentList(null);
        
        // Assert that the result is 0 (no student registration records)
        System.assertEquals(0, result);
    }
    
    @isTest
    static void testCheckTheStudentPreFinalYear() {
        // Create a test contact
        Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];
        
        // Call the method to test
        RPL_StudentRegistrationDetails.contactWrapper result = RPL_StudentRegistrationDetails.checkTheStudentPreFinalYear(testContact.Id);
        
        // Assert that the result is not null
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetPlacementDetails() {
        // Create a test contact
        
        Contact testContact = [Select id , Personal_Email__c from Contact  limit 1];
        // Call the method to test
        RPL_StudentRegistrationDetails.revaWrapper result = RPL_StudentRegistrationDetails.getPlacementDetails(testContact.Id);
        
        // Assert that the result is not null
        System.assertNotEquals(null, result);
    }
    /******************************Newly added**************************************************************/
    @isTest
    static void testGetStudentCGPAAndEducationDetails() {
        // Setup record types
        Id studentRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id academicRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Id universityDeptRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
        
        // Accounts
        Account departmentAccount = new Account(Name = 'School of ECE', RecordTypeId = academicRtId);
        insert departmentAccount;
        
        Account universityAccount = new Account(Name = 'School of Science', RecordTypeId = universityDeptRtId);
        insert universityAccount;
        
        // Contact (Student)
        Contact studentContact = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            RecordTypeId = studentRtId
        );
        insert studentContact;
        
        // User for runAs
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User u = new User(
            Alias = 'testusr',
            Email = 'testusr@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            Username = 'testusr' + System.currentTimeMillis() + '@example.com',
            ContactId = studentContact.Id
        );
        insert u;
        
        System.runAs(u) {
            // Program Plan
            hed__Program_Plan__c programBatch = new hed__Program_Plan__c(Name = 'Test Batch');
            insert programBatch;
            
            // Term
            hed__Term__c term1 = new hed__Term__c(
                Name = 'Sem-1',
                RecordTypeId = termRtId,
                hed__Account__c = departmentAccount.Id,
                Program_Batch__c = programBatch.Id,
                Rve_SEE_Result_Date__c = Date.today().addDays(-1)
            );
            insert term1;
            
            // Course
           /* hed__Course__c course = new hed__Course__c(
                Name = 'Test Course',
                hed__Account__c = universityAccount.Id,
                Credits__c = 4,
                Offered_By_School__c = universityAccount.Id,
                Credit_Hours__c = 4,
                Maximum_External_Marks__c = 70,
                Total_Maximum_Marks_IA_External__c = 100
            );
            insert course; */
            
            hed__Course__c course = ASM_TestDataFactory.CreateCourse(1, universityAccount.Id, 'Mathematics 101');
            course.hed__Course_ID__c = 'MATH101';
            course.Total_Maximum_Marks_IA_External__c = 100.0;
            course.SEE_Conducted_Marks__c = 10;
            course.L_T_P__c = '2:2:0';        
            insert course; 
            
            // Course Offering
            hed__Course_Offering__c courseOffering = new hed__Course_Offering__c(
                Name = 'Offering 1',
                hed__Course__c = course.Id,
                hed__Term__c = term1.Id
            );
            insert courseOffering;
            
            // Course Enrollment
            hed__Course_Enrollment__c enrollment = new hed__Course_Enrollment__c(
                hed__Contact__c = studentContact.Id,
                hed__Course_Offering__c = courseOffering.Id
            );
            insert enrollment;
            
            // PASS Term Grade
            hed__Term_Grade__c tgPass = new hed__Term_Grade__c(
                hed__Contact__c = studentContact.Id,
                hed__Term__c = term1.Id,
                hed__Course_Offering__c = courseOffering.Id,
                Course__c = course.Id,
                SGPA__c = 8.5,
                hed__Result__c = 'Pass'
            );
            insert tgPass;
            
            
            
            // FAIL Term Grade (backlog)
            /*  hed__Term_Grade__c tgFail = new hed__Term_Grade__c(
hed__Contact__c = studentContact.Id,
hed__Term__c = term1.Id,
hed__Course_Offering__c = courseOffering.Id,
Course__c = course.Id,
CGPA__c = 5.0,
hed__Result__c = 'Fail'
);
insert tgFail;*/
            
            // Education History
            hed__Education_History__c edu10 = new hed__Education_History__c(
                hed__Contact__c = studentContact.Id,
                RecordTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get('Education Details').getRecordTypeId(),
                Type_of_Course__c = '10th',
                Board__c = 'CBSE',
                Year_Of_Passings__c = '2015',
                Percentage__c = '90'
            );
            insert edu10;
            
            Test.startTest();
            RPL_StudentRegistrationDetails.StudentDetailsWrapper result =
                RPL_StudentRegistrationDetails.getStudentCGPAAndEducationDetails();
            Test.stopTest();
            
            // Assertions
            System.assertNotEquals(null, result, 'Wrapper should not be null');
            System.assert(result.educationHistory.containsKey('10th'), 'Education details must include 10th');
            System.assert(result.semesterCGPA.containsKey('Sem-1'), 'Semester CGPA should contain Sem-1');
            // System.assertEquals(1, result.backlogCount, 'Backlog count should match inserted fail record');
            System.assertEquals(8.5, result.semesterCGPA.get('Sem-1'), 'Sem-1 CGPA should match pass grade');
        }
    }
    
    
   /* @isTest
    static void testInsertStudentRegDetails_Map() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Map<String, Object> regMap = new Map<String, Object>{
            'Contact__c' => con.Id,
                'FirstName' => 'John',
                'MiddleName' => 'M',
                'LastName' => 'Doe',
                'Rpl_Contact_No__c' => '9999999999',
                'Rpl_Personal_Mail_ID__c' => 'john.doe@test.com',
                'Name' => 'John Doe'
                };
                    
                    Test.startTest();
        Id stdId = RPL_StudentRegistrationDetails.insertStudentRegDetails(regMap);
        Test.stopTest();
        
        //System.assertNotEquals(null, stdId, 'Student Registration record should be inserted');
        
        // Negative scenario: missing ContactId
        Map<String, Object> badMap = new Map<String, Object>{
            'FirstName' => 'Jane'
                };
                    try {
                        RPL_StudentRegistrationDetails.insertStudentRegDetails(badMap);
                        System.assert(false, 'Expected exception for missing Contact Id');
                    } catch (AuraHandledException e) {
                        // System.assert(e.getMessage().contains('Missing Contact Id'), 'Exception message should mention missing contact');
                    }
    } */
    
    @IsTest
    static void testGetEducationDetailsByLevel() {
        // Create Contact
        Contact con = new Contact(
            LastName = 'Test Contact',
            PAN_Number__c = 'ABCDE1234F'
        );
        insert con;
        
        // Create User linked to Contact
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User u = new User(
            LastName = 'TestUsercase3',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Email = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tstusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id
        );
        insert u;
        
        // Fetch Education Details record type
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'hed__Education_History__c' 
            AND Name = 'Education Details' 
            LIMIT 1
        ];
        
        // Insert Education History record
        hed__Education_History__c edu = new hed__Education_History__c(
            //Name = '10th Marks',
            hed__Contact__c = con.Id,
            RecordTypeId = rt.Id,
            Type_of_Course__c = '10th',
            Board__c = 'CBSE',
            Year_Of_Passings__c = '2018',
            Percentage__c = '85'
        );
        insert edu;
        
        System.runAs(u) {
            Test.startTest();
            Map<String, hed__Education_History__c> details = Rpl_StudentRegistrationDetails.getEducationDetailsByLevel();
            Test.stopTest();
            
            System.assertNotEquals(0, details.size(), 'Education details should not be empty');
            System.assert(details.containsKey('10th'), 'Map should contain 10th course details');
        }
    }
    
    @IsTest
    static void testIsAlreadyRegistered() {
        // Create Contact
        Contact con = new Contact(
            LastName = 'Reg Contact',
            PAN_Number__c = 'XYZPD1234G'
        );
        insert con;
        
        // Create User linked to Contact
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User u = new User(
            LastName = 'TestUsercase2',
            Username = 'reguser' + System.currentTimeMillis() + '@example.com',
            Email = 'reguser' + System.currentTimeMillis() + '@example.com',
            Alias = 'regusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id
        );
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            
            // First check (no registration yet)
            Boolean beforeInsert = Rpl_StudentRegistrationDetails.isAlreadyRegistered(con.Id);
            System.assertEquals(false, beforeInsert, 'Should return false when no registration exists');
            
            // Insert Registration
            Rpl_Student_Registration__c reg = new Rpl_Student_Registration__c(
                Name = 'Test Registration',
                Contact__c = con.Id,
                Rpl_Personal_Mail_ID__c = 'testcase909@example.com'
            );
            insert reg;
            
            // Second check (after registration)
            Boolean afterInsert = Rpl_StudentRegistrationDetails.isAlreadyRegistered(con.Id);
            System.assertEquals(true, afterInsert, 'Should return true when registration exists');
            
            Test.stopTest();
        }
    }
    
    
    @IsTest
    static void testGetContactPAN() {
        // Create Contact
        String pan = 'TESTP1234Z';
        Contact con = new Contact(
            LastName = 'PAN Contact',
            PAN_Number__c = pan
        );
        insert con;
        
        // Create User linked to Contact
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Student Profile' LIMIT 1];
        User u = new User(
            LastName = 'TestUsercase1',
            Username = 'panuser' + System.currentTimeMillis() + '@example.com',
            Email = 'panuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'panusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id
        );
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            String returnedPAN = Rpl_StudentRegistrationDetails.getContactPAN();
            Test.stopTest();
            
            System.assertEquals(pan, returnedPAN, 'PAN should match the contact PAN');
        }
    }
    /********************************************************************************************/
}