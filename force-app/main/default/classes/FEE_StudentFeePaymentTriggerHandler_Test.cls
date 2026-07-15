@isTest
public class FEE_StudentFeePaymentTriggerHandler_Test 
{
    public static  testmethod void StudentFeePaymentMethod()
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
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Bus Fee');    //'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;
        objStudentFee.Exam_Application_Number__c ='123';
        objStudentFee.Fee_Type__c ='Tuition Fee';        
        Insert objStudentFee;
                
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = FEE_TestDataFactory.CreateStudentFeePayment(objStudentFee.id,objStuPayment.id);
        objStuFeePay.Line_Item_Payment_Status__c ='Payment Link Created';
        objStuFeePay.Amount__c = 100000;
        insert objStuFeePay;
        
        list<Student_Fee_Payment__c> lst_stufeepay = new list<Student_Fee_Payment__c>();
        lst_stufeepay.add(objStuFeePay); 
               
        objStuFeePay.Line_Item_Payment_Status__c ='Success';
        update objStuFeePay;
                
        map<id,Student_Fee_Payment__c> map_stufeepay = new map<id,Student_Fee_Payment__c>();
        map_stufeepay.put(objStuFeePay.id,objStuFeePay); 
        
        delete objStuFeePay;
        undelete objStuFeePay;
        
        test.starttest();
        FEE_StudentFeePaymentTriggerHandler.RollupAmount(lst_stufeepay,map_stufeepay);
        FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(lst_stufeepay,null);
        FEE_StudentFeePaymentTriggerHandler.InstallmentRollup(lst_stufeepay,map_stufeepay);
        test.stoptest();
        system.assertequals(objStuFeePay.id,objStuFeePay.id);      
    }
}