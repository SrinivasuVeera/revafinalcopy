@isTest
public class TransportCancellationPrintControllerTest {

    @isTest
    static void testController() {

        Contact con = new Contact(
            LastName = 'Test Student',
            Email = 'test@test.com',
            MobilePhone = '9999999999'
        );
        insert con;

        RTR_Route_Master__c route = new RTR_Route_Master__c(
            Name = 'Test Route'
        );
        insert route;

        // Remove formula field assignment here
        Transport_Registeration__c reg = new Transport_Registeration__c(
            Contact__c = con.Id,
            Route_Master__c = route.Id,
            rtr_Status__c = 'Active',
            Amount_Paid__c = 1000
        );
        insert reg;

        Student_Fee__c fee = new Student_Fee__c(
            Contact__c = con.Id,
            Fee_Type__c = 'Transportation Fee',
            Amount_Paid__c = 1000
        );
        insert fee;

        Student_Fee_Payment__c pay = new Student_Fee_Payment__c(
            Student_Fee__c = fee.Id,
            Line_Item_Payment_Status__c = 'Success',
            Transaction_Date_Time__c = System.now()
        );
        insert pay;

        RTR_Reva_Transport_Request__c transport =
            new RTR_Reva_Transport_Request__c(
                RTR_Student__c = con.Id,
                Amount_to_be_Refunded__c = 500,
                Cancellation_Date__c = System.today()
            );
        insert transport;

        Test.startTest();

        PageReference pageRef =
            new PageReference('/apex/TransportCancellationPrintPage');
        pageRef.getParameters().put('id', transport.Id);
        pageRef.getParameters().put('testMode','true');
        Test.setCurrentPage(pageRef);

        TransportCancellationPrintController ctrl =
            new TransportCancellationPrintController();

        Test.stopTest();

        System.assertNotEquals(null, ctrl.transport);
        System.assertNotEquals(null, ctrl.student);
        System.assertNotEquals(null, ctrl.transportReg);
        System.assertNotEquals(null, ctrl.payment);
        System.assertNotEquals(null, ctrl.approvalWrappers);
    }
}