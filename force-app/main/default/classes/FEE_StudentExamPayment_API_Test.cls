@isTest
public class FEE_StudentExamPayment_API_Test 
{
    public static  testmethod void ExamPaymentMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test12';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test12@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;
        objStudentFee.Exam_Application_Number__c ='123';
        objStudentFee.Name='test student fee';
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id,objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c ='Payment Link Created';
        objStuFeePay.Amount__c = 100000;
        objStuFeePay.Mode_of_Payment__c = 'Online';
        objStuFeePay.Payment_Mode_Type__c='Eazypay';
        objStuFeePay.Line_Item_Payment_Gateway__c ='Eazypay';
        objStuFeePay.SF_Transaction_ID__c='12345';
        objStuFeePay.Transaction_Date_Time__c = system.now();
        insert objStuFeePay;
        
        FEE_StudentExamPayment_API.RequestWrp objRequestWrp = new FEE_StudentExamPayment_API.RequestWrp();
        
        FEE_StudentExamPayment_API.StudentFeePayWrp stuwrap = new FEE_StudentExamPayment_API.StudentFeePayWrp();
        stuwrap.FeeName = objStudentFee.Name;
        stuwrap.StudentApplicationNo='123';
        stuwrap.PaidAmount=string.valueof(objStudentFee.Amount_Paid__c);
        stuwrap.PaymentGateway=objStuFeePay.Line_Item_Payment_Gateway__c;
        stuwrap.PaymentMode=objStuFeePay.Mode_of_Payment__c;
        stuwrap.PaymentStatus=objStuFeePay.Line_Item_Payment_Status__c;
        stuwrap.PaymentType=objStuFeePay.Payment_Mode_Type__c;
        stuwrap.StudentSrnNumber='123';
        stuwrap.TotalAmount=string.valueof(objStudentFee.Amount__c);
        stuwrap.TransactionDateTime=string.valueOf(objStuFeePay.Transaction_Date_Time__c );
        stuwrap.TransactionId=objStuFeePay.SF_Transaction_ID__c;
        
        List<FEE_StudentExamPayment_API.StudentFeePayWrp> lst_stuwrap =  new List<FEE_StudentExamPayment_API.StudentFeePayWrp>();
        lst_stuwrap.add(stuwrap);
        
        objRequestWrp.studentFeePayment = lst_stuwrap;
        
        set<id> set_StudPayFee = new set<id>();
        set_StudPayFee.add(objStuFeePay.id);
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new FEE_RazorpayGetPaymentApiMock());
        FEE_StudentExamPayment_API.sendStudExamFee(set_StudPayFee);
        test.stoptest();
        system.assertEquals('123', objcon.SRN_Number__c);
    }
    
}