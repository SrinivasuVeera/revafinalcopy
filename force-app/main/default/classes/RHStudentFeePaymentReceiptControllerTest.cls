@isTest
public class RHStudentFeePaymentReceiptControllerTest {
  
    public class MockNumberToWordConversion implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"amountInWords": "Five Thousand"}'); // Customize this as needed
        res.setStatusCode(200);
        return res;
    }
}
    
    
    @testSetup
    static void setup() {
        // Create test data
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B. Tech in Civil Engineering-(2020-2024)'
        );
        insert programBatch;
        System.debug('Inserted Program Batch: ' + programBatch.Id);

        Account academicProgram = new Account(Name = 'TestAcademicProgram',
                                              Program_Alias__c = 'MT-CSE(F)',
                                              Program_Type__c = 'PG',
                                              Program_Code__c = 'TC',
                                              Number_of_Semesters__c = 4,
                                              No_of_Years__c = 2);
        insert academicProgram;
        System.debug('Inserted Academic Program: ' + academicProgram.Id);

        hed__Term__c activeSemester = new hed__Term__c(
            Name = 'BT-CE-2020-2024-Sem-7',
            hed__Account__c = academicProgram.Id
        );
        insert activeSemester;
        System.debug('Inserted Active Semester: ' + activeSemester.Id);

        Contact studentContact = new Contact(
            LastName = 'Test Student',
            Program_Batch__c = programBatch.Id,
            Active_Semester__c = activeSemester.Id
        );
        insert studentContact;
        System.debug('Inserted Student Contact: ' + studentContact.Id);

        Student_Fee__c studentFee = new Student_Fee__c(Contact__c = studentContact.Id, Payment_Type__c = 'Full Payment');
        insert studentFee;
        System.debug('Inserted Student Fee: ' + studentFee.Id);

        Student_Fee_Payment__c studentFeePayment = new Student_Fee_Payment__c(
            Student_Fee__c = studentFee.Id,
            Amount__c = 5000,
            Mode_of_Payment__c = 'Online',
            Transaction_Date_Time__c = DateTime.now(),
            Line_Item_Payment_Status__c = 'Success'
        );
        insert studentFeePayment;
        System.debug('Inserted Student Fee Payment: ' + studentFeePayment.Id);

        Test.setCurrentPageReference(new PageReference('/apex/RHStudentFeePaymentReceiptPage'));
        ApexPages.currentPage().getParameters().put('paymentId', studentFeePayment.Id);
        System.debug('Set page parameter paymentId: ' + studentFeePayment.Id);
    }

  @isTest
    static void testController() {
        
         Test.setMock(HttpCalloutMock.class, new MockNumberToWordConversion());
        // Initialize the controller
        RHStudentFeePaymentReceiptController controller = new RHStudentFeePaymentReceiptController();
       
        Boolean paymentAmountFound = false;
        Boolean studentNameFound = false;
        Boolean paymentStatusFound = false;

        for (RHStudentFeePaymentReceiptController.PaymentInfo info : controller.receiptInfoList) {
            System.debug('Field: ' + info.field + ', Value: ' + info.value);
            if (info.field == 'Payment Amount' && info.value == '1,00,000.00') {
                paymentAmountFound = true;
            }
            if (info.field == 'Student Name' && info.value == 'Test Student') {
                studentNameFound = true;
            }
            if (info.field == 'Payment Status' && info.value == 'Success') {
                paymentStatusFound = true;
            }
            if (info.field == 'Course' && info.value == 'B. Tech in Civil Engineering-(2020-2024)') {
                paymentStatusFound = true;
            }
            if (info.field == 'Year of Study' && info.value == 'BT-CE-2020-2024-Sem-7') {
                paymentStatusFound = true;
            }
             if (info.field == 'Payment Mode' && info.value == 'Online') {
                paymentStatusFound = true;
            } if (info.field == 'Payment Type' && info.value == 'Full Payment') {
                paymentStatusFound = true;
            }
        }
    }
 
    @isTest
    static void testConstructor() {
        // Arrange
        String expectedField = 'CreditCard';
        String expectedValue = '1234-5678-9012-3456';
        
        // Act
        RHStudentFeePaymentReceiptController.PaymentInfo paymentInfo = new RHStudentFeePaymentReceiptController.PaymentInfo(expectedField, expectedValue);
        
   
    }
  @isTest
    static void testReceiptInfoList1() {
        // Create related records
        Contact testContact = new Contact(LastName='Test Contact');
        insert testContact;
        
          Account academicProgram = new Account(Name = 'Test School');
        insert academicProgram;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestIAProgramBatch';
        ProgramBatch.hed__Account__c = academicProgram.Id;
        insert ProgramBatch;
        
            hed__Term__c activeSemester = new hed__Term__c(
            Name = 'BT-CE-2020-2024-Sem-7',
            hed__Account__c = academicProgram.Id
        );
        insert activeSemester;
        
        Student_Fee__c testStudentFee = new Student_Fee__c(
            Contact__c = testContact.Id,
            Payment_Type__c = 'Full Payment'
        );
        insert testStudentFee;
        
        Student_Fee_Payment__c testPayment = new Student_Fee_Payment__c(
            Amount__c = 100,
            Student_Fee__c = testStudentFee.Id,
            Mode_of_Payment__c = 'Online',
            Transaction_Date_Time__c = System.now(),
            Line_Item_Payment_Status__c = 'Success'
        );
        insert testPayment;
        
        // Set up test parameters
        Test.setCurrentPage(Page.RevaHostelStudentFeePaymentReceiptpage); // Ensure you have a Visualforce page called MyTestPage for this test
        ApexPages.currentPage().getParameters().put('paymentId', testPayment.Id);
        
        // Instantiate the controller
        RHStudentFeePaymentReceiptController controller = new RHStudentFeePaymentReceiptController();
       
    }
        
        
}