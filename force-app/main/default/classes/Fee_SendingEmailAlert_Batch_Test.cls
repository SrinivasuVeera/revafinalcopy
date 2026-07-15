@Istest
global class Fee_SendingEmailAlert_Batch_Test 
{
    global static TestMethod void Fee_DueDate()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = new Account();
        objAcc.Name = 'School of Applied Sciences';
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 =  new Account();
        objAccount1.Name = 'Bachelor of Commerce';
        objAccount1.Program_Type__c = 'UG';
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Bioinformatics, Statistics and Computer Science-(2021-2024)',
             hed__Start_Date__c = system.today().addyears(-1),
        hed__End_Date__c = system.today().addyears(+1),
           hed__Account__c = objAccount1.id
        );
        insert programBatch;
        
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = new contact();
        objCon.FirstName = 'test';
        objCon.LastName = 'con';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        //objCon.Program_Type__c = 'UG';
        //objCon.School__c =objAccount1.Id ;
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Quota__c='Management Quota';
        objCon.Email='testing1234@reva.edu.in';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objCon.Student_Status__c = 'Pursuing';
        objCon.Program_Batch__c = programBatch.id;
        objCon.School__c=objAcc.id;
        objCon.Primary_Academic_Program__c = objAccount1.id;
        Insert objCon; 
        
        Fee_Payment_Criteria__c objFeeCriteris = new Fee_Payment_Criteria__c();
        objFeeCriteris.Name = 'University Fee';
        objFeeCriteris.Payment_Type__c = 'Full Payment';
        Insert objFeeCriteris;
        
        hed__Program_Enrollment__c objProgenroll = new hed__Program_Enrollment__c(); //
        objProgenroll.hed__Contact__c = objCon.Id;
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();   //'Academic Fee');
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Due_Date__c = Date.today();
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        //objStudentFee.Program_Batch__c = '(2022-203)';
        objStudentFee.Fee_Year__c ='2nd year';
        objStudentFee.session__c = '2nd Year';
        objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
       //objStudentFee.Program_Batch_Start_Year__c = programBatch.Name != null ? programBatch.Name.mid(10, 4) : null;
        objStudentFee.Amount_Paid__c = 6000;
        objStudentFee.Amount_Pending__c = 2000;
        Insert objStudentFee;
        
        Test.startTest();
        Fee_SendingEmailAlert_Batch Batch = new Fee_SendingEmailAlert_Batch();
        database.executeBatch(Batch);
        Test.stopTest();
        system.assertEquals(objStudentFee.Id,objStudentFee.Id);        
    }
}