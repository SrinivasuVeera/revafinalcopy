@IsTest
global class Fee_AlertFirstYear_Batch_Test 
{
    global static TestMethod void Fee_DueDate()
    {
        // Create necessary records and set up test data
        String householdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Account objAcc = new Account(Name = 'Test Account', RecordTypeId = householdRecId);
        insert objAcc;
        
        String acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account objAccount1 = new Account(Name = 'Test Account1', RecordTypeId = acaRecId, ParentId = objAcc.Id, Program_Type__c = 'UG');
        insert objAccount1;
        
        hed__Program_Plan__c programBatch = new hed__Program_Plan__c(
            Name = 'B.Sc in Physics, Mathematics, and Computer Science-(2022-2025)',
            hed__Start_Date__c = System.today().addDays(-5),
            hed__End_Date__c = System.today().addYears(1),
            hed__Account__c = objAccount1.Id
        );
        insert programBatch;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
         Date firstNotificationDate = System.today().addDays(27);
        hed__Term__c objTerm = FEE_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
        objTerm.Program_Batch__c = programBatch.id;
        objTerm.hed__Start_Date__c = firstNotificationDate;
        objTerm.hed__End_Date__c = firstNotificationDate.addDays(1);
        objTerm.Term_Number__c =1;
        insert objTerm;
        
        String studentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objCon = new Contact(
            FirstName = 'Test', LastName = 'User', AccountId = objAcc.Id, MobilePhone = '9090909090', Aadhar_Card_Number__c = '098765435612', 
            RecordTypeId = studentRecId, Application_Number__c = 'test123', SRN_Number__c = '123', 
            Quota__c = 'Management Quota', Email = 'testing1234@reva.edu.in', Personal_Email__c = 'naveen123978@gmail.com', 
            hed__Preferred_Email__c = 'Personal Email', hed__WorkEmail__c = '23110200761@reva.edu.in', Nationality__c = 'Indian', Active__c = true, 
            Student_Status__c = 'Pursuing', Program_Batch__c = programBatch.Id, Primary_Academic_Program__c = objAccount1.Id
        );
        insert objCon;
        
        Fee_Payment_Criteria__c objFeeCriteris = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
        Insert objFeeCriteris;
        
              
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteris.Id, objCon.Id,'University Fee');   //'Academic Fee');
        objStudentFee.Contact__c = objCon.Id;
        objStudentFee.Fee_Payment_Criteria__c = objFeeCriteris.Id;
        objStudentFee.Name = 'Fee';
        objStudentFee.Fee_Year__c='1st year';
        objStudentFee.Due_Date__c = system.today()+58;
        //objStudentFee.Due_Date__c = system.today()-10;
        objStudentFee.Amount__c = 5000;
        objStudentFee.Actual_Program_Fee__c = 5000;
        objStudentFee.Amount_Paid__c = 0;
        objStudentFee.Amount_Pending__c = 5000;
        Insert objStudentFee;
        
        
        Test.startTest();
        Fee_AlertFirstYear_Batch batch = new Fee_AlertFirstYear_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        
    }
}