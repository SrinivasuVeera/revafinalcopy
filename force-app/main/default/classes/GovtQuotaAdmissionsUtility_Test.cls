@isTest
public class GovtQuotaAdmissionsUtility_Test {

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
        
      /*    Fee_Master__c fm4 = new  Fee_Master__c();
        fm4.Fee_Amount__c=22;
        fm4.Program_Batch__c =pb.Id;
        fm4.Applicant_Category__c='Indian (SAARC)';
        fm4.Fee_Type__c ='Tuition Fee';
        fm4.Quota__c='CET';
        fm4.Enrolment_Year__c = '2024';
        insert fm4;

         Fee_Master__c fm2 = new  Fee_Master__c();
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
        insert fm4;
        */
        Fee_Payment_Criteria__c fpc1 = new Fee_Payment_Criteria__c();
        fpc1.Name='test1';
        fpc1.Fee_Type__c='Tuition Fee';
        fpc1.Maximum_Number_of_Installments__c=20;
        insert fpc1;
        
        Fee_Payment_Criteria__c fpc = new Fee_Payment_Criteria__c();
        fpc.Name='test1';
        fpc.Fee_Type__c='University Fee';
        fpc.Maximum_Number_of_Installments__c=20;
        insert fpc;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName = 'Doe';
        testContact.Email = 'johndoe@test.com';
        testContact.MobilePhone = '1234567890';
        testContact.CET_COMEDK_Number__c='234567';
        testContact.Select_Category__c = 'Karnataka';
        testContact.Fee_Paid_at_University__c= 24;
        testContact.Admission_Mode__c = 'CET';
        testContact.Application_Number__c='23100201268';
        testContact.Program_Batch__c = pb.Id; // Replace with your own Program Batch Id
        insert testContact;

        
  Student_Fee__c testStuFee = new Student_Fee__c();
        testStuFee.Name = 'tuition fee 1st year';
        testStuFee.Fee_Type__c = 'tuition fee';
        testStuFee.Fee_Year__c = '1st year';
        testStuFee.Display_No__c = 2;  
        testStuFee.contact__c=testContact.Id;
        testStuFee.Fee_Master__c = fm.id;
        testStuFee.Fee_Payment_Criteria__c = fpc.id;
        testStuFee.Number_of_Installments__c = 4;
        testStuFee.Actual_Program_Fee__c = 6000;
        testStuFee.Amount__c = 6000; //tuition fee
        testStuFee.Provisional_Admission_Fee__c =5000; //Set on both TF & UF 1st Year records
        testStuFee.Amount_Pending__c =  3000;
        testStuFee.Amount_Paid__c =3000;
        insert testStuFee;
        
         Student_Payment__c sp = new Student_Payment__c();
        sp.Payment_Date_Time__c = Datetime.now();
        sp.Contact__c = testContact.Id;
        sp.Mode_of_payment__c = 'Offline';
        sp.Fee_Type__c	= 'Tuition Fee'; 
        sp.Payment_Status__c	= 'Success';
        sp.Payment_Mode_Type__c = 'Paid at KEA';
        sp.Transaction_ID__c	= testContact.CET_COMEDK_Number__c ;  //CET Enrollment ID here
        sp.Amount__c	=testContact.Amount__c;
        sp.Description__c = 'Fee paid at CET/COMEDK Cell';
      
      insert sp;
        
        // Set Fee_Paid_at_KEA__c and Fee_Paid_at_University__c fields
        testContact = [SELECT Id, Program_Batch__c, Program_Batch__r.Number_of_Years__c,
                              Select_Category__c, Admission_Mode__c,
                              Fee_Paid_at_KEA__c, Fee_Paid_at_University__c
                         FROM Contact
                        WHERE Id = :testContact.Id];
        testContact.Fee_Paid_at_KEA__c = 1000;
        testContact.Fee_Paid_at_University__c = 2000;
        update testContact;

        Test.startTest();

        // Call the method to create fee records
        String result = GovtQuotaAdmissionsUtility.createFeeRecordsForCETApplicant(testContact.Id);

        Test.stopTest();

        // Check if the fee records were created successfully
        List<Student_Fee__c> feeRecords = [SELECT Id, Name, Fee_Type__c, Fee_Year__c, Amount__c, Due_Date__c
                                              FROM Student_Fee__c
                                             WHERE Contact__c = :testContact.Id];

	 /*   System.assertEquals('Success', result);
        System.assertEquals('Tuition Fee', feeRecords[0].Fee_Type__c);
        System.assertEquals('University Fee', feeRecords[1].Fee_Type__c);
        System.assertEquals('Tuition Fee', feeRecords[2].Fee_Type__c);
       
     */
    }
    
  @isTest
    static void testCreateFeeRecordsForDCETApplicant() {
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
        fm3.Enrolment_Year__c = '2023';
        insert fm3;
        
     /*    Fee_Master__c fm2 = new  Fee_Master__c();
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

        
         Student_Fee__c testStuFee = new Student_Fee__c();
        testStuFee.Name = 'tuition fee 1st year';
        testStuFee.Fee_Type__c = 'tuition fee';
        testStuFee.Fee_Year__c = '1st year';
        testStuFee.Display_No__c = 2;  
        testStuFee.contact__c=testContact.Id;
        testStuFee.Fee_Master__c = fm.id;
        testStuFee.Fee_Payment_Criteria__c = fpc.id;
        testStuFee.Number_of_Installments__c = 4;
        testStuFee.Actual_Program_Fee__c = 6000;
        testStuFee.Amount__c = 6000; //tuition fee
        testStuFee.Provisional_Admission_Fee__c =5000; //Set on both TF & UF 1st Year records
        testStuFee.Amount_Pending__c =  3000;
        testStuFee.Amount_Paid__c =3000;
        insert testStuFee;
        
         Student_Payment__c sp = new Student_Payment__c();
        sp.Payment_Date_Time__c = Datetime.now();
        sp.Contact__c = testContact.Id;
        sp.Mode_of_payment__c = 'Offline';
        sp.Fee_Type__c	= 'Tuition Fee'; 
        sp.Payment_Status__c	= 'Success';
        sp.Payment_Mode_Type__c = 'Paid at KEA';
        sp.Transaction_ID__c	= testContact.CET_COMEDK_Number__c ;  //CET Enrollment ID here
        sp.Amount__c	=testContact.Amount__c;
        sp.Description__c = 'Fee paid at CET/COMEDK Cell';
      
      insert sp;
        // Set Fee_Paid_at_KEA__c and Fee_Paid_at_University__c fields
        testContact = [SELECT Id, Program_Batch__c, Program_Batch__r.Number_of_Years__c,
                              Select_Category__c, Admission_Mode__c,
                              Fee_Paid_at_KEA__c, Fee_Paid_at_University__c
                         FROM Contact
                        WHERE Id = :testContact.Id];
        testContact.Fee_Paid_at_KEA__c = 1000;
        testContact.Fee_Paid_at_University__c = 2000;
        update testContact;

        Test.startTest();

        // Call the method to create fee records
        String result = GovtQuotaAdmissionsUtility.createFeeRecordsForCETApplicant(testContact.Id);

        Test.stopTest();

        // Check if the fee records were created successfully
        List<Student_Fee__c> feeRecords = [SELECT Id, Name, Fee_Type__c, Fee_Year__c, Amount__c, Due_Date__c
                                              FROM Student_Fee__c
                                             WHERE Contact__c = :testContact.Id];

	 /*   System.assertEquals('Success', result);
        System.assertEquals('Tuition Fee', feeRecords[0].Fee_Type__c);
        System.assertEquals('University Fee', feeRecords[1].Fee_Type__c);*/
       
      
     
    } 
    
  

    @isTest
    static void testGetInitializedSFRec() {
         hed__Program_Plan__c pb = new hed__Program_Plan__c();
        pb.Name='test';
        pb.Number_of_Years__c=2;
        Insert pb;
        
        // Create a test Contact
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

        // Set up test data
        Integer testIndex = 0;

        // Call the method to be tested
        Student_Fee__c initializedRecord = GovtQuotaAdmissionsUtility.getInitializedSFRec(testContact, testIndex);

      
    }

    @isTest
    static void testInsertGovtStuFeePayment() {
         hed__Program_Plan__c pb = new hed__Program_Plan__c();
        pb.Name='test';
        pb.Number_of_Years__c=2;
        Insert pb;
        
         Fee_Master__c fm4 = new  Fee_Master__c();
        fm4.Fee_Amount__c=22;
        fm4.Program_Batch__c =pb.Id;
        fm4.Applicant_Category__c='Indian (SAARC)';
        fm4.Fee_Type__c ='University Fee';
        fm4.Quota__c='CET';
        fm4.Enrolment_Year__c = '2024';
        insert fm4;
        System.debug('test fm4'+fm4);
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
        // Create test data
        Student_Payment__c testStuPay = new Student_Payment__c(/* Add necessary fields */);
         testStuPay.Contact__c=testContact.id;
        testStuPay.Amount__c=5000;
        insert testStuPay;

        Student_Fee__c testStuFee = new Student_Fee__c(/* Add necessary fields */);
        testStuFee.Name = 'tuition fee 1st year';
        testStuFee.Fee_Type__c = 'tuition fee';
        testStuFee.Fee_Year__c = '1st year';
        testStuFee.Display_No__c = 2;       
        testStuFee.Fee_Master__c = fm4.id;
        testStuFee.Fee_Payment_Criteria__c = fpc.id;
        testStuFee.Number_of_Installments__c = 4;
        testStuFee.Actual_Program_Fee__c = 6000;
        testStuFee.Amount__c = 6000; //tuition fee
        testStuFee.Provisional_Admission_Fee__c =5000; //Set on both TF & UF 1st Year records
        testStuFee.Amount_Pending__c =  3000;
        testStuFee.Amount_Paid__c =3000;
        insert testStuFee;

        // Call the method
        Test.startTest();
        GovtQuotaAdmissionsUtility.insertGovtStuFeePayment(testStuPay, 100.00, testStuFee.Id, 'COMEDK123');
        Test.stopTest();

        // Retrieve the inserted record
        Student_Fee_Payment__c insertedStuFeePay = [SELECT Id, Amount__c FROM Student_Fee_Payment__c WHERE Student_Payment__c = :testStuPay.Id LIMIT 1];

        // Assert that the record was inserted successfully
        System.assertEquals(100.00, insertedStuFeePay.Amount__c);
        // Add more assertions as needed for other fields

        // Clean up (optional)
        delete insertedStuFeePay;
        delete testStuFee;
        delete testStuPay;
    }


}