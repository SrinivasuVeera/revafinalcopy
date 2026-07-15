@isTest
public class LogisysAPIUtility_Test 
{
    public static testMethod void LogisysUtlityMethod()
    {
        FEE_StudentExamPayment_API.RequestWrp objReqWrp = new FEE_StudentExamPayment_API.RequestWrp();
        FEE_StudentExamPayment_API.StudentFeePayWrp objStudFeePay = new FEE_StudentExamPayment_API.StudentFeePayWrp();
        objStudFeePay.StudentApplicationNo = '123456789';
        objStudFeePay.FeeName = 'Exam Fee of Semester 1';
        objStudFeePay.PaidAmount = '6000';
        objStudFeePay.PaymentGateway = 'Billdesk';
        objStudFeePay.PaymentMode = 'Online';
        objStudFeePay.PaymentStatus = 'Success';
        objStudFeePay.StudentSrnNumber = 'R22IC236';
        objStudFeePay.TotalAmount = '6000';
        objStudFeePay.TransactionDateTime = '2022-07-14 12:00:00';
        objStudFeePay.TransactionId = 'U1230002464832';
        objStudFeePay.PaymentType = 'NetBanking';
        objReqWrp.studentFeePayment.add(objStudFeePay);
        
        String jsonBody = JSON.serialize(objReqWrp);
        
        test.startTest();
        LogisysAPIUtility.mapRequest('FEE_StudentExamPayment_API', jsonBody);
        test.stopTest();
    }
}