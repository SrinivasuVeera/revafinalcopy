@isTest
public class RTR_TransportRegInfoTest {

    @testSetup
    static void setupTestData() {
        
        hed__Program_Plan__c programbatches = TestDataFactory.createProgramBatch();
        // Create Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            SRN_Number__c = 'SRN12345',
            Application_Number__c = 'APP12345',
            File_Passport_Size_Photo__c='data:image/jpeg;base64',
            Program_Batch__c = programbatches.Id
        );
        insert testContact;

        // Create Route Master
        RTR_Route_Master__c routemaster = testDataFactory.createRouteMaster();

        // Create Reva Transport
        Reva_Transport__c revaTransport = testDataFactory.createRevaTransport();
        
        RTR_Route_Pick_Up_Point__c pickupPoint = TestDataFactory.createPickUpPoint();

        
        
        // Create Transport Registration
        Transport_Registeration__c transReg = new Transport_Registeration__c(
            Bus_Pass_No__c = 'RU-0123',
            Bus_Pass_No_ShortDistance__c= 123,
            Contact__c = testContact.Id,
            Route_Master__c = routemaster.Id,
            Reva_Transport__c = revaTransport.Id,
            Route_Pick_Up_Point__c = pickupPoint.Id,
            rtr_Status__c = 'Payment Completed',
            rtr_Start_Date__c = Date.today(),
            Registration_Status__c = 'Active',
            Amount_Paid__c = 1000,
            Valid_UpTo__c = Date.today().addMonths(6)
        );
        insert transReg;

        // Create Student Fee
        Student_Fee__c studentFee = new Student_Fee__c(
            RTR_Transport_Registration__c = transReg.Id,
            Contact__c = testContact.Id
        );
        insert studentFee;

        // Create Student Fee Payment
        Student_Fee_Payment__c feePayment = new Student_Fee_Payment__c(
            Student_Fee__c = studentFee.Id,
            Amount__c = 1000,
            Line_Item_Payment_Status__c = 'Success',
            Transaction_Date_Time__c = DateTime.now()
        );
        insert feePayment;
        
    }
   

    @isTest
    static void testRTR_TransportRegInfo() {
        // Get the test data
        Transport_Registeration__c transReg = [SELECT Id FROM Transport_Registeration__c LIMIT 1];

         // Set the current page reference with the 'id' parameter
        PageReference pageRef = Page.RTR_BusPassTemplate;
        pageRef.getParameters().put('id', transReg.Id);
        Test.setCurrentPage(pageRef);

        // Create a StandardController instance
        ApexPages.StandardController sc = new ApexPages.StandardController(transReg);

        // Instantiate the RTR_TransportRegInfo class
        RTR_TransportRegInfo rtrTransInfo = new RTR_TransportRegInfo(sc);

        // Verify the pageId parameter
        System.assertEquals(transReg.Id, ApexPages.currentPage().getParameters().get('id'), 'Page ID should match the transport registration ID');

        // Call the transportRegistration method
        rtrTransInfo.transportRegistration(transReg.Id);
		RTR_TransportRegInfo.testCover();
        
        // Verify the outputs
        System.assertNotEquals(rtrTransInfo.transRegList, null, 'transRegList should not be null');
        System.assertEquals(rtrTransInfo.StuSRNNumber, 'SRN12345', 'StuSRNNumber should match SRN12345');
        System.assertNotEquals(rtrTransInfo.rtrFeePaymentRec, null, 'rtrFeePaymentRec should not be null');
        System.assertNotEquals(rtrTransInfo.paymentDetails, null, 'paymentDetails should not be null');
        System.assertEquals(rtrTransInfo.paymentDetails.size(), 1, 'There should be one payment detail');
        System.assertEquals(rtrTransInfo.paymentDetails[0].amountPaid, 1000, 'The amount paid should be 1000');
        System.assertEquals(rtrTransInfo.paymentDetails[0].paymentDate, DateTime.now().format('dd/MM/yyyy'), 'The payment date should match today\'s date');
        
    }
}