@isTest
global class FEE_UpdateDueDateBatch_Test 
{
    global static  testmethod void DueDateMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        hed__Program_Plan__c  objProgPlan =  FEE_TestDataFactory.createProgramPlan('B.Tech. in Civil Engineering-(2023-2027)');
        objProgPlan.hed__Start_Date__c = system.today()-1;
        objProgPlan.hed__End_Date__c = system.today()+1;
        insert objProgPlan;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Enrollment_Type__c = 'Regular Entry';
        objcon.Application_Number__c = 'test12';
        objcon.SRN_Number__c ='123';
        objCon.Student_Status__c = 'Pursuing';
        objcon.hed__WorkEmail__c  = 'test12@reva.edu.in';
        objcon.Nationality__c ='Indian';
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Tuition Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
               
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,objProgPlan.id);
        objProgEnroll.hed__Contact__c = objCon.Id;
        objProgEnroll.hed__Start_Date__c = system.today()-1; 
        objProgEnroll.hed__End_Date__c =  system.today()+1; 
        objProgEnroll.hed__Program_Plan__c = objProgPlan.Id;
        Insert objProgenroll;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm.Program_Batch__c = objProgPlan.id;
        objTerm.IA_1_Start_date__c = system.today()+1;
        objTerm.IA_1_Start_date__c = system.today()-1;
        objTerm.Term_Number__c =1;
        insert objTerm;
        
        hed__Term__c objTerm1 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm1.Program_Batch__c = objProgPlan.id;
       objTerm1.hed__Start_Date__c =system.today()-1;  
        objTerm1.IA_1_Start_date__c = system.today()+1;
        objTerm1.Term_Number__c =3;
        insert objTerm1;
        
        hed__Term__c objTerm2 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm2.Program_Batch__c = objProgPlan.id;
        objTerm2.hed__Start_Date__c =system.today()-1; 
        objTerm2.IA_1_Start_date__c = system.today()+1;
        objTerm2.Term_Number__c =5;
        insert objTerm2;
        
        hed__Term__c objTerm3 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm3.Program_Batch__c = objProgPlan.id;
         objTerm3.hed__Start_Date__c =system.today()-1;
        objTerm3.IA_1_Start_date__c = system.today()+1;
        objTerm3.Term_Number__c =7;
        insert objTerm3;
        
        hed__Term__c objTerm4 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm4.Program_Batch__c = objProgPlan.id;
        objTerm4.IA_1_Start_date__c =system.today()-1; 
        objTerm4.IA_2_Start_date__c =system.today()+1;
        objTerm4.Term_Number__c =9;
        insert objTerm4;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
        objStudentFee.Actual_Program_Fee__c = 50000;
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Number_of_Installments__c =3;
        objStudentFee.Paid_Installments__c =1;
        //objStudentFee.Exam_Application_Number__c ='123';
        objStudentFee.Session__c='1st Year';
        Insert objStudentFee;
        
        Student_Fee__c objStuFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
        objStuFee.Actual_Program_Fee__c = 500000;
        objStuFee.Amount__c = 500000;
        objStuFee.Amount_Pending__c=400000;
        objStuFee.Amount_Paid__c=100000;
        objStuFee.Number_of_Installments__c =2;
        objStuFee.Paid_Installments__c =1;
        //objStuFee.Exam_Application_Number__c ='1234';
        objStuFee.Session__c='2nd Year';
        Insert objStuFee;
        
        Student_Fee__c objStuFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
        objStuFee1.Actual_Program_Fee__c = 5000;
        objStuFee1.Amount__c = 5000;
        objStuFee1.Amount_Pending__c=4000;
        objStuFee1.Amount_Paid__c=1000;
        objStuFee1.Number_of_Installments__c =4;
        objStuFee1.Paid_Installments__c =1;
        //objStuFee1.Exam_Application_Number__c ='12345';
        objStuFee1.Session__c='3rd Year';
        Insert objStuFee1;
        
        Student_Fee__c objStuFee2 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
        objStuFee2.Actual_Program_Fee__c = 500;
        objStuFee2.Amount__c = 500;
        objStuFee2.Amount_Pending__c=400;
        objStuFee2.Amount_Paid__c=100;
        objStuFee2.Number_of_Installments__c =2;
        objStuFee2.Paid_Installments__c =1;
        //objStuFee2.Exam_Application_Number__c ='145';
        objStuFee2.Session__c='4th Year';
        Insert objStuFee2;
        
        Student_Fee__c objStuFee3 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
        objStuFee3.Actual_Program_Fee__c = 600;
        objStuFee3.Amount__c = 600;
        objStuFee3.Amount_Pending__c=500;
        objStuFee3.Amount_Paid__c=100;
        objStuFee3.Number_of_Installments__c =3;
        objStuFee3.Paid_Installments__c =1;
        //objStuFee3.Exam_Application_Number__c ='879';
        objStuFee3.Session__c='5th Year';
        Insert objStuFee3;
        
        test.starttest();
        FEE_UpdateDueDateBatch btch = new FEE_UpdateDueDateBatch();
        database.executebatch(btch);
        test.stoptest();
        system.assertEquals(objStuFee3.Session__c, '5th Year');
    }
}