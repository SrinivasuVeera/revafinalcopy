@isTest
public class ProvisionalAdmissionFeeChallan_Test {
    @isTest
    public static Void pafChallanChequetest(){
        //Create test account record
        Account accTestRec = New Account(
        Name = 'Bachelor of Science in Interior Design'
        );
        insert accTestRec;
        
        //Create test contact record
        Contact testContact1 = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@test.com',
            Phone = '9999999999',
            Application_Number__c = '23150100034',
            Primary_Academic_Program__c = accTestRec.Id
        );
        insert testContact1;
        
        hed__Application__c testApplication = new hed__Application__c();
        testApplication.hed__Applicant__c = testContact1.Id;
        insert testApplication;
        
        Student_Payment__c stuPayment1 = new Student_Payment__c();{
        stuPayment1.Offline_Receipt_Number__c = 'RU23000031';
        stuPayment1.Payment_Mode_Type__c = 'Cheque / DD';
        stuPayment1.Amount__c = 500;
        stuPayment1.Contact__c = testContact1.Id;
        stuPayment1.Mode_of_Payment__c = 'Offline';
        stuPayment1.Payment_Status__c = 'Pending';
        stuPayment1.Fee_Type__c = 'University Fee, Tuition Fee';
        }
        insert stuPayment1;
        // Create test Student_Fee__c record and link it to the test Contact record
        Student_Fee__c testUniversityFirstYear1 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Name = 'University Fee 1st year',
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
            Contact__c = testContact1.Id,
            Name = 'Tuition Fee 1st year',
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 500.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
            
        );
        insert testTuitionFirstYear;
        
        Student_Fee_Payment__c stuFeePaymentUniversityTest1 = new Student_Fee_Payment__c(); {
            stuFeePaymentUniversityTest1.Payment_Mode_Type__c = 'Cheque / DD';
            stuFeePaymentUniversityTest1.Cheque_DD_Number__c = '1452';
            stuFeePaymentUniversityTest1.Cheque_DD_Date__c = system.today();
            stuFeePaymentUniversityTest1.Mode_of_Payment__c = 'Offline';
            stuFeePaymentUniversityTest1.Amount__c = 250.0;
            stuFeePaymentUniversityTest1.Student_Fee__c = testUniversityFirstYear1.Id;
            stuFeePaymentUniversityTest1.Student_Payment__c = stuPayment1.ID;
        }
        insert stuFeePaymentUniversityTest1;
        Student_Fee_Payment__c stuFeePaymentTuitionTest1 = new Student_Fee_Payment__c(); {
            stuFeePaymentTuitionTest1.Payment_Mode_Type__c = 'Cheque / DD';
            stuFeePaymentTuitionTest1.Cheque_DD_Number__c = '1452';
            stuFeePaymentTuitionTest1.Cheque_DD_Date__c = system.today();
            stuFeePaymentTuitionTest1.Mode_of_Payment__c = 'Offline';
            stuFeePaymentTuitionTest1.Amount__c = 250.0;
            stuFeePaymentTuitionTest1.Student_Fee__c = testTuitionFirstYear.Id;
            stuFeePaymentTuitionTest1.Student_Payment__c = stuPayment1.ID;
        }
        insert stuFeePaymentTuitionTest1;
        //Cash Test Setup
      
        Contact testContact2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Email = 'test1@test.com',
            Phone = '9999999999',
            Application_Number__c = '23150100035',
            Primary_Academic_Program__c = accTestRec.Id
        );
        insert testContact2;
        
        Student_Payment__c stuPayment2 = new Student_Payment__c();{
        stuPayment2.Offline_Receipt_Number__c = 'RU23000032';
        stuPayment2.Payment_Mode_Type__c = 'Cash';
        stuPayment2.Amount__c = 500;
        stuPayment2.Contact__c = testContact2.ID;
        stuPayment2.ChequeDD_Number__c = '16357625';
        stuPayment2.ChequeDD_Date__c=system.today();
        stuPayment2.Payment_Status__c = 'Pending';
        stuPayment2.Fee_Type__c ='University Fee';
        }
        insert stuPayment2;
        // Create test Student_Fee__c record and link it to the test Contact record
        Student_Fee__c testUniversityFirstYear2 = new Student_Fee__c(
            Contact__c = testContact2.Id,
            Name = 'University Fee 1st year',
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 500.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversityFirstYear2;
        Student_Fee__c testTuitionFirstYear1 = new Student_Fee__c(
            Contact__c = testContact2.Id,
            Name = 'Tuition Fee 1st year',
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 500.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
            
        );
        insert testTuitionFirstYear1;
        Contact con1 = [Select Id, Name from Contact Where LastName = 'Contact1' limit 1];
        hed__Application__c testApplication1 = [Select Id, hed__Applicant__c From hed__Application__c Where hed__Applicant__c = : con1.Id Limit 1];
        Test.startTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(testApplication1);
        ProvisionalAdmissionFeeChallan_Extension pafTest = new ProvisionalAdmissionFeeChallan_Extension(sc);
        Test.stopTest();
    }
    @isTest
    public static Void pafChallanCashtest(){
        Account accTestRec1 = New Account(
        Name = 'Bachelor of Science in Interior Design'
        );
        insert accTestRec1;
        //Cash Test Setup
        Contact testContact2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Email = 'test1@test.com',
            Phone = '9999999999',
            Application_Number__c = '23150100035',
            Primary_Academic_Program__c = accTestRec1.Id
        );
        insert testContact2;
        
        hed__Application__c testApplication1 = new hed__Application__c();
        testApplication1.hed__Applicant__c = testContact2.Id;
        insert testApplication1;
        
        Student_Payment__c stuPayment2 = new Student_Payment__c();{
        stuPayment2.Offline_Receipt_Number__c = 'RU23000032';
        stuPayment2.Payment_Mode_Type__c = 'Cash';
        stuPayment2.Amount__c = 500;
        stuPayment2.Contact__c = testContact2.ID;
        stuPayment2.Mode_of_Payment__c = 'Offline';
        stuPayment2.Payment_Status__c = 'Pending';            
        stuPayment2.ChequeDD_Number__c = '16357625';
        stuPayment2.ChequeDD_Date__c=system.today();
            stuPayment2.Payment_Status__c = 'Pending';
            stuPayment2.Fee_Type__c ='University Fee';
        }
        insert stuPayment2;
        // Create test Student_Fee__c record and link it to the test Contact record
        Student_Fee__c testUniversityFirstYear2 = new Student_Fee__c(
            Contact__c = testContact2.Id,
            Name = 'University Fee 1st year',
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'University Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 500.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
        );
        insert testUniversityFirstYear2;
        Student_Fee__c testTuitionFirstYear1 = new Student_Fee__c(
            Contact__c = testContact2.Id,
            Name = 'Tuition Fee 1st year',
            Fee_Year__c = '1st Year',
            Fee_Type__c = 'Tuition Fee',
            Actual_Program_Fee__c = 1000.0,
            Provisional_Admission_Fee__c = 500.0,
            Premium__c = 100.0,
            Scholarship__c = 50.0,
            Concession__c = 0.0
            
        );
        insert testTuitionFirstYear1;
       Student_Fee_Payment__c stuFeePaymentUniversityTest2 = new Student_Fee_Payment__c(); {
            stuFeePaymentUniversityTest2.Payment_Mode_Type__c = 'Cash';
            stuFeePaymentUniversityTest2.Mode_of_Payment__c = 'Offline';
            stuFeePaymentUniversityTest2.Amount__c = 250.0;
            stuFeePaymentUniversityTest2.Student_Fee__c = testUniversityFirstYear2.Id;
            stuFeePaymentUniversityTest2.Student_Payment__c = stuPayment2.ID;
        }
        insert stuFeePaymentUniversityTest2;
        Student_Fee_Payment__c stuFeePaymentTutionTest2 = new Student_Fee_Payment__c(); {
            stuFeePaymentTutionTest2.Payment_Mode_Type__c = 'Cash';
            stuFeePaymentTutionTest2.Mode_of_Payment__c = 'Offline';
            stuFeePaymentTutionTest2.Amount__c = 250.0;
            stuFeePaymentTutionTest2.Student_Fee__c = testTuitionFirstYear1.Id;
            stuFeePaymentTutionTest2.Student_Payment__c = stuPayment2.ID;
        }
        insert stuFeePaymentTutionTest2;
        Contact con2 = [Select Id, Name from Contact Where LastName = 'Contact2' limit 1];
        hed__Application__c testApplication2 = [Select Id, hed__Applicant__c From hed__Application__c Where hed__Applicant__c = : con2.Id Limit 1];
        Test.startTest(); 
        ApexPages.StandardController scCash = new ApexPages.StandardController(testApplication2);
        ProvisionalAdmissionFeeChallan_Extension pafTestCash = new ProvisionalAdmissionFeeChallan_Extension(scCash);
        Test.stopTest();
    }
}