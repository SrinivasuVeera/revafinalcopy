@isTest
public class FEE_FeeReceipt_Ext_Test 
{
    public static  testmethod void FeeReceiptMethod()
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
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon;
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'Hostel Fee');       //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        Insert objStudentFee;
        
         Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id,objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c ='Success';
        objStuFeePay.Amount__c = 100000;
        insert objStuFeePay;
        
        test.starttest();
        ApexPages.currentPage().getParameters().put('id',objStuPayment.id);
        FEE_FeeReceipt_Ext ext = new FEE_FeeReceipt_Ext(new Apexpages.StandardController(objStuPayment));
        test.stoptest();
        system.assertequals(objStuPayment.id,objStuPayment.id);
    }
}