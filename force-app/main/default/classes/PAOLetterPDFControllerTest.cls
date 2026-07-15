@isTest
public class PAOLetterPDFControllerTest {

    @isTest
    static void testPAOLetterPDFPage() {

        // Create Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Student',
            Email = 'student@test.com',
            Application_Number__c = 'APP123'
        );
        insert con;

        // Create Student Fees
        List<Student_Fee__c> feeList = new List<Student_Fee__c>();

        feeList.add(new Student_Fee__c(
            Contact__c = con.Id,
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '1st Year',
            Actual_Program_Fee__c = 50000,
            Scholarship__c = 5000
        ));

        feeList.add(new Student_Fee__c(
            Contact__c = con.Id,
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '1st Year',
            Actual_Program_Fee__c = 10000,
            Scholarship__c = 1000
        ));

        insert feeList;

        // Create Student Payment
        Student_Payment__c payment = new Student_Payment__c(
            Contact__c = con.Id,
            Fee_Type__c = 'Tuition Fee',
            Amount__c = 10000,
            Payment_Status__c = 'Pending',
            Payment_Date_Time__c = System.now()
        );
        insert payment;

        // Simulate VF Page call
        Test.setCurrentPage(Page.PAOLetterPDF);

        ApexPages.currentPage().getParameters().put('id', con.Id);
        ApexPages.currentPage().getParameters().put('payUrl', 'https://testpayment.com');

        Test.startTest();

        PAOLetterPDFController controller = new PAOLetterPDFController();

        Test.stopTest();

        System.assertNotEquals(null, controller);
    }
}