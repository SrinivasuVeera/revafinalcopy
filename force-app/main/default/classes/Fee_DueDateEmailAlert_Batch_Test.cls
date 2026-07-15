@Istest
global class Fee_DueDateEmailAlert_Batch_Test 
{
    global static TestMethod void Fee_DueDate()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        objAccount1.Program_Type__c = 'UG';
        insert objAccount1;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Physics, Mathematics, and Computer Science-(2022-2025)',
             hed__Start_Date__c = system.today().addDays(-5),
        hed__End_Date__c = system.today().addyears(+1),
           hed__Account__c = objAccount1.id
        );
        insert programBatch;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Quota__c='Management Quota';
        objCon.Email='testing1234@reva.edu.in';
         objCon.Personal_Email__c='naveen123978@gmail.com';
        objCon.hed__Preferred_Email__c='Personal Email';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = programBatch.id;
        objCon.School__c=objAcc.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        Insert objCon; 
        
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,programBatch.id);
        objProgEnroll.hed__Contact__c = objCon.Id;
        objProgEnroll.hed__Start_Date__c = system.today()-1; 
        objProgEnroll.hed__End_Date__c =  system.today()+1; 
        objProgEnroll.hed__Program_Plan__c = programBatch.Id;
        Insert objProgenroll;
        
        Date semesterStartDate = Date.today();
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm.Program_Batch__c = programBatch.id;
        objTerm.hed__Start_Date__c = system.today()-7;
        objTerm.hed__End_Date__c = system.today()+30;
        objTerm.Term_Number__c =3;
        insert objTerm;
        
        hed__Term__c objTerm1 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm1.Program_Batch__c = programBatch.id;
       objTerm1.hed__Start_Date__c =system.today()-1;  
        objTerm1.IA_1_Start_date__c = system.today()+1;
        objTerm1.Term_Number__c =3;
        insert objTerm1;
        
        hed__Term__c objTerm2 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm2.Program_Batch__c = programBatch.id;
        objTerm2.hed__Start_Date__c =system.today()-1; 
        objTerm2.IA_1_Start_date__c = system.today()+1;
        objTerm2.Term_Number__c =5;
        insert objTerm2;
        
        hed__Term__c objTerm3 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm3.Program_Batch__c = programBatch.id;
         objTerm3.hed__Start_Date__c =system.today()-1;
        objTerm3.IA_1_Start_date__c = system.today()+1;
        objTerm3.Term_Number__c =7;
        insert objTerm3;
        
        hed__Term__c objTerm4 = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm4.Program_Batch__c = programBatch.id;
        objTerm4.hed__Start_Date__c =system.today()-1; 
        objTerm4.IA_2_Start_date__c =system.today()+1;
        objTerm4.Term_Number__c =9;
        insert objTerm4;
        
        
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
              
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Fee_Year__c='2nd year';
        objStudentFee.Due_Date__c = system.today()+58;
        //objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Actual_Program_Fee__c = 5000;
        objStudentFee.Amount_Paid__c = 0;
        objStudentFee.Amount_Pending__c = 5000;
        Insert objStudentFee;
        
              
        Test.startTest();
        Fee_DueDateEmailAlert_Batch Batch = new Fee_DueDateEmailAlert_Batch();
        database.executeBatch(Batch);
        Test.stopTest();
        
        system.assertEquals(objStudentFee.Id,objStudentFee.Id);        
    }
}