@isTest
public class FEE_StudentExamFee_API_Test 
{
    public static  testmethod void ExamFeeMethod()
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
        objProgenroll.hed__Start_Date__c = system.today();
        objProgenroll.hed__End_Date__c = system.today();
        objProgenroll.SRN_Number__c ='123';
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
        
        FEE_StudentExamFee_API.ResultWpr reswrap = new FEE_StudentExamFee_API.ResultWpr();
        reswrap.error='success';
        reswrap.status='success';
        reswrap.studentExamAppNo='123';
        
        list<FEE_StudentExamFee_API.ResultWpr> lst_reswrap = new list<FEE_StudentExamFee_API.ResultWpr>();
        lst_reswrap.add(reswrap);
        
        FEE_StudentExamFee_API.ExamFeeRespWrap examWrap = new FEE_StudentExamFee_API.ExamFeeRespWrap();
        examWrap.status='success';
        examWrap.message='success';
        examWrap.result = lst_reswrap;
        
        FEE_StudentExamFee_API.StudentFeePayement stuwrap = new FEE_StudentExamFee_API.StudentFeePayement();
        stuwrap.Amount='50000';
        // stuwrap.DueDate=String.valueof(system.today());
        stuwrap.FeeName='test student fee';
        stuwrap.StudentExamAppNo='123';
        stuwrap.StudentSrnNumber='123';
        
        list<FEE_StudentExamFee_API.StudentFeePayement> lst_stuwrap = new list<FEE_StudentExamFee_API.StudentFeePayement>();
        lst_stuwrap.add(stuwrap);
        
        FEE_StudentExamFee_API.ReqExamWrp reqwrap = new FEE_StudentExamFee_API.ReqExamWrp();
        reqwrap.studentfee=lst_stuwrap;
        
        String jsonBody = JSON.serialize(reqwrap);      
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/StudentExamFeeAPI/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        test.starttest();
        FEE_StudentExamFee_API.createDemandDetails();
        test.stoptest();
    }   
    public static  testmethod void ExamFeeMethod1()
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
        objProgenroll.hed__Start_Date__c = system.today();
        objProgenroll.hed__End_Date__c = system.today();
        objProgenroll.SRN_Number__c ='123';
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
        
        FEE_StudentExamFee_API.ResultWpr reswrap = new FEE_StudentExamFee_API.ResultWpr();
        reswrap.error='success';
        reswrap.status='success';
        reswrap.studentExamAppNo='123';
        
        list<FEE_StudentExamFee_API.ResultWpr> lst_reswrap = new list<FEE_StudentExamFee_API.ResultWpr>();
        lst_reswrap.add(reswrap);
        
        FEE_StudentExamFee_API.ExamFeeRespWrap examWrap = new FEE_StudentExamFee_API.ExamFeeRespWrap();
        examWrap.status='success';
        examWrap.message='success';
        examWrap.result = lst_reswrap;
        
        FEE_StudentExamFee_API.StudentFeePayement stuwrap = new FEE_StudentExamFee_API.StudentFeePayement();
        stuwrap.Amount='50000';
        stuwrap.DueDate=String.valueof(system.today());
        stuwrap.FeeName='test student fee';
        stuwrap.StudentExamAppNo='123';
        stuwrap.StudentSrnNumber='123';
        
        list<FEE_StudentExamFee_API.StudentFeePayement> lst_stuwrap = new list<FEE_StudentExamFee_API.StudentFeePayement>();
        lst_stuwrap.add(stuwrap);
        
        FEE_StudentExamFee_API.ReqExamWrp reqwrap = new FEE_StudentExamFee_API.ReqExamWrp();
        //reqwrap.studentfee=lst_stuwrap;
        
        String jsonBody = JSON.serialize(reqwrap);      
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/StudentExamFeeAPI/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        test.starttest();
        FEE_StudentExamFee_API.createDemandDetails();
        test.stoptest();
    }   
    public static  testmethod void ExamFeeMethod2()
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
        objProgenroll.hed__Start_Date__c = system.today();
        objProgenroll.hed__End_Date__c = system.today();
        objProgenroll.SRN_Number__c ='123';
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
        
        FEE_StudentExamFee_API.ResultWpr reswrap = new FEE_StudentExamFee_API.ResultWpr();
        reswrap.error='success';
        reswrap.status='success';
        reswrap.studentExamAppNo='123';
        
        list<FEE_StudentExamFee_API.ResultWpr> lst_reswrap = new list<FEE_StudentExamFee_API.ResultWpr>();
        lst_reswrap.add(reswrap);
        
        FEE_StudentExamFee_API.ExamFeeRespWrap examWrap = new FEE_StudentExamFee_API.ExamFeeRespWrap();
        examWrap.status='success';
        examWrap.message='success';
        examWrap.result = lst_reswrap;
        
        FEE_StudentExamFee_API.StudentFeePayement stuwrap = new FEE_StudentExamFee_API.StudentFeePayement();
        stuwrap.Amount='50000';
        stuwrap.DueDate=String.valueof(system.today());
        stuwrap.FeeName='test student fee';
        stuwrap.StudentExamAppNo='123';
        stuwrap.StudentSrnNumber='123';
        
        list<FEE_StudentExamFee_API.StudentFeePayement> lst_stuwrap = new list<FEE_StudentExamFee_API.StudentFeePayement>();
        lst_stuwrap.add(stuwrap);
        
        FEE_StudentExamFee_API.ReqExamWrp reqwrap = new FEE_StudentExamFee_API.ReqExamWrp();
        reqwrap.studentfee=lst_stuwrap;
        
        String jsonBody = JSON.serialize(reqwrap);      
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/StudentExamFeeAPI/';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');   
        req.requestBody = blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response= res;
        
        test.starttest();
        FEE_StudentExamFee_API.createDemandDetails();
        test.stoptest();
    }   
    
}