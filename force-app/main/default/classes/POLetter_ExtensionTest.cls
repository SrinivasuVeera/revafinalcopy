@isTest
public class POLetter_ExtensionTest {
    @isTest
    public static Void SetupApplicationWithSFtest(){
        //Create test Account record
        Account testAccount = new Account(
            Name = 'Test Program',
            No_of_Years__c	= 4
             );
            insert testAccount;
        
        //Create test contact record
        Contact testContact = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@test.com',
            Phone = '9999999999'
        );
        insert testContact;
       
        //Create test hed__Application__c record and link it to the test contact record
        hed__Application__c testApplication = new hed__Application__c(
            hed__Applicant__c = testContact.Id,
            hed__Application_Status__c = 'New',
            Concession_Status__c = 'Initiated',
            School__c = 'Test School',
            Application_Number__c = '1234',
            Concession_1st_Year__c = 0.0,
            Concession_2nd_Year__c = 0.0,
            Concession_3rd_Year__c = 0.0,
            Concession_4th_Year__c = 0.0,
            Concession_5th_Year__c =0.0,
            hed__Applying_To__c = testAccount.Id
        );
        insert testApplication;
        // Create test Student_Fee__c record and link it to the test Contact record
        Student_Fee__c testUniversityFirstYear1 = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 500.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversityFirstYear1;
        Student_Fee__c testTuitionFirstYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 0.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testTuitionFirstYear;
        Student_Fee__c testUniversitySecondYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '2nd Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversitySecondYear;
        Student_Fee__c testTuitionSecondYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '2nd Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testTuitionSecondYear;
        Student_Fee__c testUniversityThirdYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '3rd Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversityThirdYear;
        Student_Fee__c testTuitionThirdYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '3rd Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testTuitionThirdYear;
        Student_Fee__c testUniversityFourthYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '4th Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversityFourthYear;
        Student_Fee__c testTuitionFourthYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '4th Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testTuitionFourthYear;
        Student_Fee__c testUniversityFifthYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '5th Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversityFifthYear;
            Student_Fee__c testTuitionFifthYear = new Student_Fee__c(
            Contact__c = testContact.Id,
            Fee_Year__c = '5th Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Premium__c = 0.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testTuitionFifthYear;
        Student_Payment__c studentpayment = new Student_Payment__c(
            Contact__c = testContact.Id,
            Fee_Type__c = 'Tuition Fee',
            Amount__c = 1000.0,
            Payment_Date_Time__c = System.now(),
            Payment_Status__c = 'Success'
        );
        insert studentpayment;

        Test.startTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testApplication);
        POLetter_Extension po = new POLetter_Extension(sc);
        Test.stopTest();
    }
      @isTest
    public static Void SetupApplicationWithSFtest1(){
        //Create test Account record
        Account testAccount1 = new Account(
            Name = 'Test Program',
            No_of_Years__c	= 4
             );
            insert testAccount1;
        
        //Create test contact record
        Contact testContact1 = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@test.com',
            Phone = '9999999999'
        );
        insert testContact1;
       
        //Create test hed__Application__c record and link it to the test contact record
        hed__Application__c testApplication1 = new hed__Application__c(
            hed__Applicant__c = testContact1.Id,
            hed__Application_Status__c = 'New',
            Concession_Status__c = 'Initiated',
            School__c = 'Test School',
            Application_Number__c = '1234',
            Concession_1st_Year__c = null,
            Concession_2nd_Year__c = 0.0,
            Concession_3rd_Year__c = 0.0,
            Concession_4th_Year__c = 0.0,
            Concession_5th_Year__c =0.0,
            hed__Applying_To__c = testAccount1.Id
        );
        insert testApplication1;
       
        Test.startTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testApplication1);
        POLetter_Extension po = new POLetter_Extension(sc);
        Test.stopTest();
    }
    
   }