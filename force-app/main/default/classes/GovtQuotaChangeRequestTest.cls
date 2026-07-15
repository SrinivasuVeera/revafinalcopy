@isTest
public class GovtQuotaChangeRequestTest {
    @isTest
    static void testCreateFeeRecordsForCETApplicant() {
        // Create a test contact
        hed__Program_Plan__c pb = new hed__Program_Plan__c();
        pb.Name='test';
        pb.Number_of_Years__c=2;
        Insert pb;
        
        Fee_Master__c fm = new  Fee_Master__c();
        fm.Fee_Amount__c=25000;
        fm.Program_Batch__c =pb.Id;
        fm.Applicant_Category__c='Indian (SAARC)';
        fm.Fee_Type__c ='University Fee';
        fm.Quota__c='CET';
        fm.Enrolment_Year__c = '2024';
        insert fm;
        
        Fee_Master__c fm1 = new  Fee_Master__c();
        fm1.Fee_Amount__c=20000;
        fm1.Program_Batch__c =pb.Id;
        fm1.Applicant_Category__c='Indian (SAARC)';
        fm1.Fee_Type__c ='Program Fee';
        fm1.Quota__c='CET';
        fm1.Enrolment_Year__c = '2024';
        insert fm1;
        
        Fee_Master__c fm3 = new  Fee_Master__c();
        fm3.Fee_Amount__c=22;
        fm3.Program_Batch__c =pb.Id;
        fm3.Applicant_Category__c='Indian (SAARC)';
        fm3.Fee_Type__c ='Final Year Special Fee';
        fm3.Quota__c='CET';
        fm3.Enrolment_Year__c = '2024';
        insert fm3;
        
      /*   Fee_Master__c fm2 = new  Fee_Master__c();
        fm2.Fee_Amount__c=23000;
        fm2.Program_Batch__c =pb.Id;
        fm2.Applicant_Category__c='Indian (SAARC)';
        fm2.Fee_Type__c ='Program Fee';
        fm2.Quota__c='CET';
        fm2.Enrolment_Year__c = '2023';
        insert fm2;
        
        Fee_Master__c fm4 = new  Fee_Master__c();
        fm4.Fee_Amount__c=22;
        fm4.Program_Batch__c =pb.Id;
        fm4.Applicant_Category__c='Indian (SAARC)';
        fm4.Fee_Type__c ='University Fee';
        fm4.Quota__c='CET';
        fm4.Enrolment_Year__c = '2023';
        insert fm4;*/
        
        Fee_Payment_Criteria__c fpc1 = new Fee_Payment_Criteria__c();
        fpc1.Name='test1';
        fpc1.Fee_Type__c='University Fee';
        fpc1.Maximum_Number_of_Installments__c=20;
        insert fpc1;
        
        Fee_Payment_Criteria__c fpc = new Fee_Payment_Criteria__c();
        fpc.Name='test1';
        fpc.Fee_Type__c='Tuition Fee';
        fpc.Maximum_Number_of_Installments__c=20;
        insert fpc;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName = 'Doe';
        testContact.Email = 'johndoe@test.com';
        testContact.MobilePhone = '1234567890';
        testContact.Select_Category__c = 'Karnataka';
        testContact.Fee_Paid_at_University__c= 24;
        testContact.Admission_Mode__c = 'CET';
        testContact.Program_Batch__c = pb.Id; // Replace with your own Program Batch Id
        insert testContact;

        // Set Fee_Paid_at_KEA__c and Fee_Paid_at_University__c fields
        testContact = [SELECT Id, Program_Batch__c, Program_Batch__r.Number_of_Years__c,
                              Select_Category__c, Admission_Mode__c,
                              Fee_Paid_at_KEA__c, Fee_Paid_at_University__c
                         FROM Contact
                        WHERE Id = :testContact.Id];
        testContact.Fee_Paid_at_KEA__c = 1000;
        testContact.Fee_Paid_at_University__c = 2000;
        update testContact;

        // Call the method to create fee records
        list<GovtQuotaChangeRequest.UtilityRequest> CETCreateRec = new list<GovtQuotaChangeRequest.UtilityRequest>();
        GovtQuotaChangeRequest.UtilityRequest CETCreateInstance = new GovtQuotaChangeRequest.UtilityRequest();
        CETCreateInstance.contactId = testContact.Id;
        CETCreateInstance.invocationType = 'CREATECETAPPLICANT';
        CETCreateRec.add(CETCreateInstance);
        
        Test.startTest();

        GovtQuotaChangeRequest.decideByInvocation(CETCreateRec);

        Test.stopTest();

        // Check if the fee records were created successfully
        List<Student_Fee__c> feeRecords = [SELECT Id, Name, Fee_Type__c, Fee_Year__c, Amount__c, Due_Date__c
                                              FROM Student_Fee__c
                                             WHERE Contact__c = :testContact.Id];

	  /*  System.assertEquals('Success', result);
        System.assertEquals('Tuition Fee', feeRecords[0].Fee_Type__c);
        System.assertEquals('University Fee', feeRecords[1].Fee_Type__c);
        System.assertEquals('Tuition Fee', feeRecords[2].Fee_Type__c); */
       
     
    }
     @isTest
    static void testupdateFeeRecordsForCETApplicant() {
        // Create a test contact
        hed__Program_Plan__c pb = new hed__Program_Plan__c();
        pb.Name='test';
        pb.Number_of_Years__c=1;
        Insert pb;
        
        Fee_Master__c fm = new  Fee_Master__c();
        fm.Fee_Amount__c=25000;
        fm.Program_Batch__c =pb.Id;
        fm.Applicant_Category__c='Indian (SAARC)';
        fm.Fee_Type__c ='University Fee';
        fm.Quota__c='DCET';
        fm.Enrolment_Year__c = '2024';
        insert fm;
        
        Fee_Master__c fm1 = new  Fee_Master__c();
        fm1.Fee_Amount__c=20000;
        fm1.Program_Batch__c =pb.Id;
        fm1.Applicant_Category__c='Indian (SAARC)';
        fm1.Fee_Type__c ='Program Fee';
        fm1.Quota__c='DCET';
        fm1.Enrolment_Year__c = '2024';
        insert fm1;
        
        Fee_Master__c fm3 = new  Fee_Master__c();
        fm3.Fee_Amount__c=22;
        fm3.Program_Batch__c =pb.Id;
        fm3.Applicant_Category__c='Indian (SAARC)';
        fm3.Fee_Type__c ='Final Year Special Fee';
        fm3.Quota__c='DCET';
        fm3.Enrolment_Year__c = '2024';
        insert fm3;
        
      /*   Fee_Master__c fm2 = new  Fee_Master__c();
        fm2.Fee_Amount__c=23000;
        fm2.Program_Batch__c =pb.Id;
        fm2.Applicant_Category__c='Indian (SAARC)';
        fm2.Fee_Type__c ='Program Fee';
        fm2.Quota__c='DCET';
        fm2.Enrolment_Year__c = '2023';
        insert fm2;
        
        Fee_Master__c fm4 = new  Fee_Master__c();
        fm4.Fee_Amount__c=22;
        fm4.Program_Batch__c =pb.Id;
        fm4.Applicant_Category__c='Indian (SAARC)';
        fm4.Fee_Type__c ='University Fee';
        fm4.Quota__c='DCET';
        fm4.Enrolment_Year__c = '2023';
        insert fm4;*/
        
        Fee_Payment_Criteria__c fpc1 = new Fee_Payment_Criteria__c();
        fpc1.Name='test1';
        fpc1.Fee_Type__c='University Fee';
        fpc1.Maximum_Number_of_Installments__c=20;
        insert fpc1;
        
        Fee_Payment_Criteria__c fpc = new Fee_Payment_Criteria__c();
        fpc.Name='test1';
        fpc.Fee_Type__c='Tuition Fee';
        fpc.Maximum_Number_of_Installments__c=20;
        insert fpc;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName = 'Doe';
        testContact.Email = 'johndoe@test.com';
        testContact.MobilePhone = '1234567890';
        testContact.Select_Category__c = 'Karnataka';
        testContact.Fee_Paid_at_University__c= 24;
        testContact.Admission_Mode__c = 'DCET';
        testContact.Program_Batch__c = pb.Id; // Replace with your own Program Batch Id
        insert testContact;

        // Set Fee_Paid_at_KEA__c and Fee_Paid_at_University__c fields
        testContact = [SELECT Id, Program_Batch__c, Program_Batch__r.Number_of_Years__c,
                              Select_Category__c, Admission_Mode__c,
                              Fee_Paid_at_KEA__c, Fee_Paid_at_University__c
                         FROM Contact
                        WHERE Id = :testContact.Id];
        testContact.Fee_Paid_at_KEA__c = 1000;
        testContact.Fee_Paid_at_University__c = 2000;
        update testContact;

        
        Student_Fee__c objStudentfee = new Student_Fee__c();
        objStudentfee.Fee_Payment_Criteria__c = fpc1.Id;
        objStudentfee.Contact__c = testContact.Id;
        objStudentfee.Fee_Type__c ='University Fee';
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Fee_Year__c = '1st Year';
        objStudentFee.Provisional_Admission_Fee__c = 50000;
            insert objStudentfee;
        
         Student_Fee__c objStudentfee1 = new Student_Fee__c();
        objStudentfee1.Fee_Payment_Criteria__c = fpc.Id;
        objStudentfee1.Contact__c = testContact.Id;
        objStudentfee1.Fee_Type__c ='Tuition Fee';
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=40000;
        objStudentFee1.Amount_Paid__c=10000;
		objStudentFee1.Fee_Year__c = '1st Year';
         objStudentFee1.Provisional_Admission_Fee__c = 50000;
        insert objStudentfee1;
        
        
        objStudentfee1 = [SELECT Fee_Type__c, Fee_Year__c, Provisional_Admission_Fee__c FROM Student_Fee__c where Id =:objStudentfee1.Id];
        
        objStudentfee1.Provisional_Admission_Fee__c = 60000;
        update objStudentfee1;
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Contact__c =  testContact.Id;
        insert objStuPayment;
        
        Student_Fee_Payment__c objStuFeePay = new Student_Fee_Payment__c();
        objStuFeePay.Student_Fee__c = objStudentfee.Id;
        objStuFeePay.Student_Payment__c = objStuPayment.Id;
        insert objStuFeePay;
        
        // Call the method to create fee records
        list<GovtQuotaChangeRequest.UtilityRequest> CETCreateRec = new list<GovtQuotaChangeRequest.UtilityRequest>();
        GovtQuotaChangeRequest.UtilityRequest CETCreateInstance = new GovtQuotaChangeRequest.UtilityRequest();
        CETCreateInstance.contactId = testContact.Id;
        CETCreateInstance.invocationType = 'UPDATECETAPPLICANT';
        CETCreateRec.add(CETCreateInstance);
        
        Test.startTest();

        // Call the method to create fee records
       GovtQuotaChangeRequest.decideByInvocation(CETCreateRec);

        Test.stopTest();

        // Check if the fee records were created successfully
        List<Student_Fee__c> feeRecords = [SELECT Id, Name, Fee_Type__c, Fee_Year__c, Amount__c, Due_Date__c
                                              FROM Student_Fee__c
                                             WHERE Contact__c = :testContact.Id];

	   /* System.assertEquals('Success', result);
        System.assertEquals('Tuition Fee', feeRecords[0].Fee_Type__c);
        System.assertEquals('University Fee', feeRecords[1].Fee_Type__c); */
       
       
     
    }
}