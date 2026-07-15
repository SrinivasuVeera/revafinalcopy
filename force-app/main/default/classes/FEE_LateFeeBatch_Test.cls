@Istest
public class FEE_LateFeeBatch_Test 
{
    public static TestMethod void LateFeeMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = FEE_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        hed__Program_Plan__c  objProgPlan =  FEE_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAccount1.id;
        objProgPlan.Exclude_Late_Fee_Charges_PB__c  =false;
        insert objProgPlan;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = objProgPlan.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        objCon.Exclude_Late_Fee_Charges_Student__c =false;
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        objProgenroll.hed__Program_Plan__c = objProgPlan.id;
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Paid__c = 6000;
        objStudentFee.Amount_Pending__c = 2000;
        objStudentFee.Program_Enrollment__c = objProgenroll.id;
        objStudentFee.Exclude_Late_Fee_Charges_Fee__c  =false;
        objStudentFee.Fee_Type__c  ='Hostel Fee';
        Insert objStudentFee;
        
        Student_Fee__c objFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objFee.Contact__c = objCon.Id;
        objFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objFee.Name = 'Fee test';
        objFee.Due_Date__c = system.today()-5;
        objFee.Amount__c = 500;
        objFee.Amount_Paid__c = 600;
        objFee.Amount_Pending__c = 200;
        objFee.Program_Enrollment__c = objProgenroll.id;
        objFee.Exclude_Late_Fee_Charges_Fee__c  =false;
        objFee.Parent_Student_Fee__c =objStudentFee.id;
        objFee.Fee_Type__c  ='Hostel Fee';
        Insert objFee;
        
        Late_Fee_Charges__c objLatefeeCh = new Late_Fee_Charges__c();
        objLatefeeCh.Amount__c = 10000;
        objLatefeeCh.To_Day__c =15;
        objLatefeeCh.From_Day__c = 1;
        objLatefeeCh.Program_Batch__c = objProgPlan.Id;
        objLatefeeCh.Fee_Type__c = 'Hostel Fee';
        objLatefeeCh.Late_Fee_Calculation_Type__c ='Daily Basis';
        insert objLatefeeCh;
       
        test.startTest();
        FEE_LateFeeBatch btch = new FEE_LateFeeBatch();
        database.executeBatch(btch);
        test.stopTest();
    }
    public static TestMethod void LateFeeMethod1()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = FEE_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        hed__Program_Plan__c  objProgPlan =  FEE_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAccount1.id;
        objProgPlan.Exclude_Late_Fee_Charges_PB__c  =false;
        insert objProgPlan;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = objProgPlan.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        objCon.Exclude_Late_Fee_Charges_Student__c =false;
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        objProgenroll.hed__Program_Plan__c = objProgPlan.id;
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Paid__c = 6000;
        objStudentFee.Amount_Pending__c = 2000;
        objStudentFee.Program_Enrollment__c = objProgenroll.id;
        objStudentFee.Exclude_Late_Fee_Charges_Fee__c  =false;
        objStudentFee.Fee_Type__c  ='Tuition Fee';
        Insert objStudentFee;
        
        Student_Fee__c objFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objFee.Contact__c = objCon.Id;
        objFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objFee.Name = 'Fee test';
        objFee.Due_Date__c = system.today()-5;
        objFee.Amount__c = 500;
        objFee.Amount_Paid__c = 600;
        objFee.Amount_Pending__c = 200;
        objFee.Program_Enrollment__c = objProgenroll.id;
        objFee.Exclude_Late_Fee_Charges_Fee__c  =false;
        //objFee.Parent_Student_Fee__c =objStudentFee.id;
        objFee.Fee_Type__c  ='Tuition Fee';
        Insert objFee;
        
        Late_Fee_Charges__c objLatefeeCh = new Late_Fee_Charges__c();
        objLatefeeCh.Amount__c = 10000;
        objLatefeeCh.To_Day__c = 15;
        objLatefeeCh.From_Day__c = 10;
        objLatefeeCh.Program_Batch__c = objProgPlan.Id;
        objLatefeeCh.Fee_Type__c = 'Tuition Fee';
        objLatefeeCh.Late_Fee_Calculation_Type__c ='Daily Basis';
        insert objLatefeeCh;
        
        test.startTest();
        FEE_LateFeeBatch btch = new FEE_LateFeeBatch();
        database.executeBatch(btch);
        test.stopTest();
    }
     public static TestMethod void LateFeeMethod2()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = FEE_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        hed__Program_Plan__c  objProgPlan =  FEE_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAccount1.id;
        objProgPlan.Exclude_Late_Fee_Charges_PB__c  =false;
        insert objProgPlan;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = objProgPlan.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        objCon.Exclude_Late_Fee_Charges_Student__c =false;
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        objProgenroll.hed__Program_Plan__c = objProgPlan.id;
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Paid__c = 6000;
        objStudentFee.Amount_Pending__c = 2000;
        objStudentFee.Program_Enrollment__c = objProgenroll.id;
        objStudentFee.Exclude_Late_Fee_Charges_Fee__c  =false;
        objStudentFee.Fee_Type__c  ='Tuition Fee';
        Insert objStudentFee;
        
        Student_Fee__c objFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objFee.Contact__c = objCon.Id;
        objFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objFee.Name = 'Fee test';
        objFee.Due_Date__c = system.today()-5;
        objFee.Amount__c = 500;
        objFee.Amount_Paid__c = 600;
        objFee.Amount_Pending__c = 200;
        objFee.Program_Enrollment__c = objProgenroll.id;
        objFee.Exclude_Late_Fee_Charges_Fee__c  =false;
        //objFee.Parent_Student_Fee__c =objStudentFee.id;
        objFee.Fee_Type__c  ='Tuition Fee';
        Insert objFee;
        
        Late_Fee_Charges__c objLatefeeCh = new Late_Fee_Charges__c();
        objLatefeeCh.Amount__c = 10000;
        objLatefeeCh.To_Day__c = 5;
        objLatefeeCh.From_Day__c = 5;
        objLatefeeCh.Program_Batch__c = objProgPlan.Id;
        objLatefeeCh.Fee_Type__c = 'Tuition Fee';
        objLatefeeCh.Late_Fee_Calculation_Type__c ='Date Range';
        insert objLatefeeCh;
        
        test.startTest();
        FEE_LateFeeBatch btch = new FEE_LateFeeBatch();
        database.executeBatch(btch);
        test.stopTest();
    }
}