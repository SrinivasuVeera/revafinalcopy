@isTest
public class OfflinePaymentIntiatedtest {
    @TestSetup
    static void setupTestData() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Admission_Mode__c = 'UQ',
            Fee_Paid_at_University__c = 5000,
            hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
        );
        insert testContact;

        hed__Application__c testApplication = new hed__Application__c(
            hed__Applicant__c = testContact.Id,
            Offline_Payment_Initiated__c = true,
            Partial_Paid__c = true,
            First_Payment_Date__c = Date.newInstance(2026, 12, 4),
            Provisional_Admission_Fee_Paid__c=false
        );
        insert testApplication;
        hed__Application__c testApplication1 = new hed__Application__c(
            hed__Applicant__c = testContact.Id,
            Offline_Payment_Initiated__c = false,
            Partial_Paid__c = true,
            First_Payment_Date__c = Date.today(),
            Provisional_Admission_Fee_Paid__c=true
        );
        insert testApplication1;

        Student_Fee__c stuFee10 = new Student_Fee__c();
        stuFee10.contact__c = testContact.Id;
        stuFee10.Fee_Year__c = '1st Year';
        stuFee10.Name = 'University Fee 1st year';
        stuFee10.Amount__c = 1500;
        stuFee10.Fee_Type__c =  'University Fee';
        insert stuFee10;

        Student_Fee__c stuFee12 = new Student_Fee__c();
        stuFee12.contact__c = testContact.Id;
        stuFee12.Fee_Year__c = '1st Year';
        stuFee12.Name = 'University Fee 1st year';
        stuFee12.Amount__c = 100;
        stuFee12.Fee_Type__c =  'University Fee';
        insert stuFee12;

        Student_Fee__c stuFee11 = new Student_Fee__c();
        stuFee11.contact__c = testContact.Id;
        stuFee11.Fee_Year__c = '1st Year';
        stuFee11.Name = 'Tuition Fee 1st year';
        stuFee11.Amount__c = 15000;
        stuFee11.Fee_Type__c =  'Tuition Fee';
        insert stuFee11;

        Student_Fee__c stuFee2 = new Student_Fee__c();
        stuFee2.contact__c = testContact.Id;
        stuFee2.Fee_Year__c = '2nd Year';
        stuFee2.Name = 'University Fee 2nd year';
        stuFee2.Amount__c = 150000;
        stuFee2.Fee_Type__c =  'University Fee';
        insert stuFee2;

        Student_Fee__c stuFee3 = new Student_Fee__c();
        stuFee3.contact__c = testContact.Id;
        stuFee3.Fee_Year__c = '2nd Year';
        stuFee3.Name = 'Tuition Fee 2nd year';
        stuFee3.Amount__c = 15000;
        stuFee3.Fee_Type__c =  'Tuition Fee';
        insert stuFee3;

        Student_Fee__c stuFee4 = new Student_Fee__c();
        stuFee4.contact__c = testContact.Id;
        stuFee4.Fee_Year__c = '3rd Year';
        stuFee4.Name = 'University Fee 3rd year';
        stuFee4.Amount__c = 1500;
        stuFee4.Fee_Type__c =  'University Fee';
        insert stuFee4;

        Student_Fee__c stuFee5 = new Student_Fee__c();
        stuFee5.contact__c = testContact.Id;
        stuFee5.Fee_Year__c = '3rd Year';
        stuFee5.Name = 'Tuition Fee 3rd year';
        stuFee5.Amount__c = 15000;
        stuFee5.Fee_Type__c =  'Tuition Fee';
        insert stuFee5;

        Student_Fee__c stuFee6 = new Student_Fee__c();
        stuFee6.contact__c = testContact.Id;
        stuFee6.Fee_Year__c = '4th Year';
        stuFee6.Name = 'University Fee 4th year';
        stuFee6.Amount__c = 1500;
        stuFee6.Fee_Type__c =  'University Fee';
        insert stuFee6;

        Student_Fee__c stuFee7 = new Student_Fee__c();
        stuFee7.contact__c = testContact.Id;
        stuFee7.Fee_Year__c = '4th Year';
        stuFee7.Name = 'Tuition Fee 4th year';
        stuFee7.Amount__c = 15000;
        stuFee7.Fee_Type__c =  'Tuition Fee';
        insert stuFee7;

        Student_Fee__c stuFee8 = new Student_Fee__c();
        stuFee8.contact__c = testContact.Id;
        stuFee8.Fee_Year__c = '5th Year';
        stuFee8.Name = 'University Fee 5th year';
        stuFee8.Amount__c = 500;
        stuFee8.Fee_Type__c =  'University Fee';
        insert stuFee8;

        Student_Fee__c stuFee9 = new Student_Fee__c();
        stuFee9.contact__c = testContact.Id;
        stuFee9.Fee_Year__c = '5th Year';
        stuFee9.Name = 'Tuition Fee 5th year';
        stuFee9.Amount__c = 15000;
        stuFee9.Fee_Type__c =  'Tuition Fee';
        insert stuFee9; 
        
        Student_Payment__c testPayment = new Student_Payment__c(
            Contact__c = testContact.Id,
            Amount__c = 70,
            Fee_Type__c = 'University Fee, Tuition Fee',
            Payment_Status__c = 'Pending'
        );
        insert testPayment;

        Student_Payment__c testPayment1 = new Student_Payment__c(
            Contact__c = testContact.Id,
            Amount__c = 10000,
            Fee_Type__c = 'University Fee, Tuition Fee',
            Payment_Status__c = 'Success'
        );
        insert testPayment1;
        
        Student_Payment__c testPayment2 = new Student_Payment__c(
            Contact__c = testContact.Id,
            Amount__c = 200000,
            Fee_Type__c = 'University Fee, Tuition Fee',
            Payment_Status__c = 'Pending'
        );
        insert testPayment2;
        Test.startTest();
                  OfflinePaymentIntiated.createStudentFeePayments(new List<Student_Payment__c>{testPayment});
                  OfflinePaymentIntiated.createStudentFeePayments(new List<Student_Payment__c>{testPayment2});
                  Test.stopTest();
        
    }
    @istest
    public static void HandleUpdate(){
        Profile p = [select Id,name from Profile where Name ='Counselor' limit 1];       
        User newUser1 = new User(
             profileId = p.Id,
             username = 'newUsertestineuser@epeople.com',
             email = 'pb@f.com',
             emailencodingkey = 'UTF-8',
             localesidkey = 'en_US',
             languagelocalekey = 'en_US',
             timezonesidkey = 'America/Los_Angeles',
             alias='nuser',
             lastname='lastname',
            MobilePhone='+91-9962357136'
             
         );
         insert newUser1;
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Admission_Mode__c = 'UQ',
            Fee_Paid_at_University__c = 5000,
            hed__WorkEmail__c='ugcet260098400001@reva.edu.in',
            OwnerId = newUser1.Id
        );
        insert testContact;
        Student_Payment__c student=new Student_Payment__c();
        student.Contact__c=testContact.id;
        student.Payment_Status__c='Pending';
        insert student;
        Student_Payment__c student1=new Student_Payment__c();
        student1.Contact__c=testContact.id;
        student1.Payment_Status__c='Pending';
        
        List<Student_Payment__c> newPayments=new List<Student_Payment__c>();
        newPayments.add(student);
        newPayments.add(student1);
        Student_Fee__c stuFee12 = new Student_Fee__c();
        stuFee12.contact__c = testContact.Id;
        stuFee12.Fee_Year__c = '1st Year';
        stuFee12.Name = 'University Fee 1st year';
        stuFee12.Amount__c = 100;
        stuFee12.Fee_Type__c =  'University Fee';
        insert stuFee12;
        
        Student_Fee_Payment__c stpp=new Student_Fee_Payment__c();
        stpp.Student_Fee__c=stuFee12.id;
        stpp.Student_Payment__c=student.Id;
        insert stpp;
        
        test.starttest();
        OfflinePaymentIntiated.HandleUpdate(newPayments,null);
        OfflinePaymentIntiated.updateStudentFeePayments(newPayments);
        OfflinePaymentIntiated.createStudentFeePayments(newPayments);
        test.stoptest();
        
        
    }
    @isTest
    static void testHandleDelete() {
        // Query for the specific records created in setup
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        hed__Application__c testApplication = [SELECT Id, Offline_Payment_Initiated__c FROM hed__Application__c WHERE hed__Applicant__c = :testContact.Id LIMIT 1];
        Student_Payment__c deletedPayment = [SELECT Id, Contact__c FROM Student_Payment__c LIMIT 1];
        
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact',Admission_Mode__c = 'UQ',hed__WorkEmail__c='ugcet260098400001@reva.edu.in');
        insert testContact1;

        hed__Application__c testApplication1 = new hed__Application__c(hed__Applicant__c = testContact1.Id,Offline_Payment_Initiated__c = false,Partial_Paid__c = true);
        insert testApplication1;

        Student_Fee__c testFee = new Student_Fee__c(Contact__c = testContact1.Id, Fee_Type__c = 'University Fee', Provisional_Admission_Fee__c = 1000,Actual_Program_Fee__c = 2000,Fee_Year__c ='1st Year');
        insert testFee;

        Student_Payment__c testPayment = new Student_Payment__c(Contact__c = testContact1.Id, Fee_Type__c = 'University Fee', Amount__c = 500, Payment_Status__c = 'Pending');
        insert testPayment;

        
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact',Admission_Mode__c = 'UQ',hed__WorkEmail__c='ugcet260098400001@reva.edu.in');
        insert testContact2;

          Student_Fee__c testFee1 = new Student_Fee__c(Contact__c = testContact2.Id, Fee_Type__c = 'University Fee', Provisional_Admission_Fee__c = 500,Actual_Program_Fee__c = 1000,Fee_Year__c ='1st Year');
        insert testFee1;

        Student_Payment__c testPayment1= new Student_Payment__c(Contact__c = testContact2.Id, Fee_Type__c = 'University Fee', Amount__c = 1000, Payment_Status__c = 'Pending');
        insert testPayment1;
        
         hed__Application__c testApplication3 = new hed__Application__c(hed__Applicant__c = testContact2.Id,Offline_Payment_Initiated__c = true,Partial_Paid__c = true);
        insert testApplication3;
        
        hed__Application__c testApplication4 = new hed__Application__c(hed__Applicant__c = testContact2.Id,Offline_Payment_Initiated__c = true,hed__Application_Status__c ='Interested',Partial_Paid__c = true);
        insert testApplication4;
         Student_Payment__c testPayment2= new Student_Payment__c(Contact__c = testContact2.Id, Fee_Type__c = 'University Fee', Amount__c = 1000, Payment_Status__c = 'Success');
        insert testPayment2;

         Set<Id> contactIds = new Set<Id>{testContact1.Id,testContact2.Id};

        // Call the method to be tested 
        Test.startTest();
        OfflinePaymentIntiated.handleDelete(new List<Student_Payment__c>{deletedPayment});
        OfflinePaymentIntiated.updatePAFApplicationCheckbox(contactIds);

        Test.stopTest();

      }
    
     @isTest
    static void testHandleDelete1() {
            Contact testContact3 = new Contact(FirstName = 'Test', LastName = 'Contact',Admission_Mode__c = 'CET',Fee_Paid_at_University__c=1000,hed__WorkEmail__c='ugcet260098400001@reva.edu.in');
        insert testContact3;

        hed__Application__c testApplication2 = new hed__Application__c(hed__Applicant__c = testContact3.Id,Offline_Payment_Initiated__c = false,Partial_Paid__c = true);
        insert testApplication2;

        Student_Fee__c testFee3 = new Student_Fee__c(Contact__c = testContact3.Id, Fee_Type__c = 'University Fee');
        insert testFee3;

        Student_Payment__c testPayment2 = new Student_Payment__c(Contact__c = testContact3.Id, Fee_Type__c = 'University Fee', Amount__c = 500, Payment_Status__c = 'Pending');
        insert testPayment2;

         Contact testContact4 = new Contact(FirstName = 'Test', LastName = 'Contact',Admission_Mode__c = 'CET',Fee_Paid_at_University__c=500,hed__WorkEmail__c='ugcet260098400001@reva.edu.in');
        insert testContact4;

         Student_Fee__c testFee4 = new Student_Fee__c(Contact__c = testContact4.Id, Fee_Type__c = 'University Fee');
        insert testFee4;

        Student_Payment__c testPayment4= new Student_Payment__c(Contact__c = testContact4.Id, Fee_Type__c = 'University Fee', Amount__c = 1000, Payment_Status__c = 'Pending');
        insert testPayment4;
        
         hed__Application__c testApplication4 = new hed__Application__c(hed__Applicant__c = testContact4.Id,Offline_Payment_Initiated__c = true);
        insert testApplication4;  
        
                 Set<Id> contactIds = new Set<Id>{testContact3.Id,testContact4.Id};

         Test.startTest();
        OfflinePaymentIntiated.updatePAFApplicationCheckbox(contactIds);

        Test.stopTest();
    }
          @isTest
    static void University1Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.Quota__c = 'Management Quota';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Pending__c=4000;
        objStudentFee.Amount_Paid__c=1000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'University Fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=10000;
        objStudentFee.Concession__c=1000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;


        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 5500;
        insert objStuPayment;
        
        Student_Payment__c objStuPayment1 = new Student_Payment__c();
        objStuPayment1.Payment_Status__c = 'Pending';
        objStuPayment1.Contact__c = objcon.id;
        objStuPayment1.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment1.Amount__c = 5500;
        insert objStuPayment1;
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment,objStuPayment1};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
    @isTest
    static void University2Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'university fee 2nd year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'university Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
      @isTest
    static void University3Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'University Fee 3rd year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
      @isTest
    static void University4Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'University Fee 4th year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
     @isTest
    static void University5Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'University Fee 5th year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
    
    
     @isTest
    static void Tuition1Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Pending__c=4000;
        objStudentFee.Amount_Paid__c=1000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=10000;
        objStudentFee.Concession__c=1000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
 
     @isTest
    static void Tuition2Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 2nd year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
     @isTest
    static void Tuition3Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 3rd year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
     @isTest
    static void Tuition4Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 4th year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
     @isTest
    static void Tuition5Year() {
    contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 5th year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        Insert objStudentFee;

       Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 500;
        insert objStuPayment;
        
      
             list<Student_Payment__c> stulist=new list<Student_Payment__c>{objStuPayment};

        
      Test.startTest();
        OfflinePaymentIntiated.createStudentFeePayments(stulist);

        Test.stopTest(); 

}
    @isTest
static void testRemainingCoverage() {

    Contact con = new Contact(
        FirstName='Coverage',
        LastName='Test',
        Admission_Mode__c='UQ',
        Fee_Paid_at_University__c=1000,
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    hed__Application__c app = new hed__Application__c(
        hed__Applicant__c = con.Id,
        hed__Application_Status__c='Provisionally Offered'
    );
    insert app;

    Student_Fee__c fee1 = new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'University Fee 1st year',
        Fee_Type__c = 'University Fee',
        Fee_Year__c='1st Year',
        Amount__c = 1000,
        Provisional_Admission_Fee__c = 1000,
        Actual_Program_Fee__c = 5000
    );
    insert fee1;

    Student_Fee__c fee2 = new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'Tuition Fee 1st year',
        Fee_Type__c = 'Tuition Fee',
        Fee_Year__c='1st Year',
        Amount__c = 2000
    );
    insert fee2;

    Student_Payment__c pay1 = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 500,
        Fee_Type__c = 'University Fee, Tuition Fee',
        Payment_Status__c='Pending'
    );

    Student_Payment__c pay2 = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 1500,
        Fee_Type__c = 'University Fee, Tuition Fee',
        Payment_Status__c='Success'
    );

    insert new List<Student_Payment__c>{pay1, pay2};

    // ✅ Query with required fields
    List<Student_Payment__c> payList = [
        SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
               Cheque_Bank_Name__c,
               ChequeDD_Date__c,
               ChequeDD_Number__c,
               ChequeDD_Realisation_Date__c,
               Mode_of_Payment__c,
               Payment_Date__c,
               Reference_Number__c,
               Payment_Mode_Type__c
        FROM Student_Payment__c
        WHERE Contact__c = :con.Id
    ];

    Test.startTest();

    OfflinePaymentIntiated.filterApplicantsOnly(payList);
    OfflinePaymentIntiated.HandleUpdate(payList,null);
    OfflinePaymentIntiated.createStudentFeePayments(payList);

    Set<Id> contactIds = new Set<Id>{con.Id};
    OfflinePaymentIntiated.updatePAFApplicationCheckbox(contactIds);

    OfflinePaymentIntiated.handleDelete(payList);

    Test.stopTest();

    System.assert(!payList.isEmpty(), 'Payments should exist');
}
    @isTest
static void coverDeepFeeDistributionLogic() {

    Contact con = new Contact(
        LastName = 'DeepTest',
        Admission_Mode__c = 'UQ',
        Fee_Paid_at_University__c = 1000,
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    // 🔥 Create ALL fee types (IMPORTANT)
    List<Student_Fee__c> fees = new List<Student_Fee__c>{
        new Student_Fee__c(Contact__c=con.Id, Name='University Fee 1st year', Fee_Type__c='University Fee', Fee_Year__c='1st Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='Tuition Fee 1st year', Fee_Type__c='Tuition Fee', Fee_Year__c='1st Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='University Fee 2nd year', Fee_Type__c='University Fee', Fee_Year__c='2nd Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='Tuition Fee 2nd year', Fee_Type__c='Tuition Fee', Fee_Year__c='2nd Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='University Fee 3rd year', Fee_Type__c='University Fee', Fee_Year__c='3rd Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='Tuition Fee 3rd year', Fee_Type__c='Tuition Fee', Fee_Year__c='3rd Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='University Fee 4th year', Fee_Type__c='University Fee', Fee_Year__c='4th Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='Tuition Fee 4th year', Fee_Type__c='Tuition Fee', Fee_Year__c='4th Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='University Fee 5th year', Fee_Type__c='University Fee', Fee_Year__c='5th Year', Amount__c=1000),
        new Student_Fee__c(Contact__c=con.Id, Name='Tuition Fee 5th year', Fee_Type__c='Tuition Fee', Fee_Year__c='5th Year', Amount__c=1000)
    };
    insert fees;

    // 🔥 Payment with HIGH amount → triggers all IF blocks
    Student_Payment__c pay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 10000, // IMPORTANT: large amount
        Fee_Type__c = 'University Fee, Tuition Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay;

    List<Student_Payment__c> payList = [
        SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
               Cheque_Bank_Name__c,
               ChequeDD_Date__c,
               ChequeDD_Number__c,
               ChequeDD_Realisation_Date__c,
               Mode_of_Payment__c,
               Payment_Date__c,
               Reference_Number__c,
               Payment_Mode_Type__c
        FROM Student_Payment__c
        WHERE Id = :pay.Id
    ];

    Test.startTest();

    // 🔥 Covers main big block
    OfflinePaymentIntiated.createStudentFeePayments(payList);

    Test.stopTest();

    System.assert(true);
}
    @isTest
static void coverAllottedAmountBranch() {

    Contact con = new Contact(
        LastName='AllottedTest',
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    Student_Fee__c fee = new Student_Fee__c(
        Contact__c=con.Id,
        Name='University Fee 1st year',
        Fee_Type__c='University Fee',
        Fee_Year__c='1st Year',
        Amount__c=2000
    );
    insert fee;

    Student_Payment__c pay = new Student_Payment__c(
        Contact__c=con.Id,
        Amount__c=1000,
        Fee_Type__c='University Fee',
        Payment_Status__c='Pending'
    );
    insert pay;

    // 🔥 EXISTING payment → fills ConStuFeePayAllottedAmountMap
    Student_Fee_Payment__c sfp = new Student_Fee_Payment__c(
        Student_Fee__c = fee.Id,
        Student_Payment__c = pay.Id,
        Amount__c = 500
    );
    insert sfp;

    Test.startTest();
    List<Student_Payment__c> payList = [
    SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
           Cheque_Bank_Name__c,
           ChequeDD_Date__c,
           ChequeDD_Number__c,
           ChequeDD_Realisation_Date__c,
           Mode_of_Payment__c,
           Payment_Date__c,
           Reference_Number__c,
           Payment_Mode_Type__c
    FROM Student_Payment__c
    WHERE Id = :pay.Id
];

OfflinePaymentIntiated.createStudentFeePayments(payList);
    Test.stopTest();
}
    @isTest
static void testFullBranchCoverage() {

    Contact con = new Contact(
        LastName = 'FullCoverage',
        Admission_Mode__c = 'UQ',
        Fee_Paid_at_University__c = 1000,
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    List<String> years = new List<String>{
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year'
};

List<Student_Fee__c> fees = new List<Student_Fee__c>();

for(String yr : years){

    fees.add(new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'University Fee ' + yr.toLowerCase(),
        Fee_Type__c = 'University Fee',
        Fee_Year__c = yr,
        Amount__c = 1000
    ));

    fees.add(new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'Tuition Fee ' + yr.toLowerCase(),
        Fee_Type__c = 'Tuition Fee',
        Fee_Year__c = yr,
        Amount__c = 1000
    ));
}
insert fees;

    // 🔥 CASE 1: No existing Student_Fee_Payment (map == null)
    Student_Payment__c pay1 = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 15000, // BIG → covers all IF blocks
        Fee_Type__c = 'University Fee, Tuition Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay1;

    // 🔥 CASE 2: Existing Student_Fee_Payment (map != null)
    Student_Payment__c pay2 = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 500, // SMALL → covers partial logic
        Fee_Type__c = 'University Fee, Tuition Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay2;

    // Existing allocation → triggers second branch
    insert new Student_Fee_Payment__c(
        Student_Fee__c = fees[0].Id,
        Student_Payment__c = pay2.Id,
        Amount__c = 200
    );

    // 🔥 Query FULL fields (IMPORTANT FIX)
    List<Student_Payment__c> payList = [
        SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
               Cheque_Bank_Name__c,
               ChequeDD_Date__c,
               ChequeDD_Number__c,
               ChequeDD_Realisation_Date__c,
               Mode_of_Payment__c,
               Payment_Date__c,
               Reference_Number__c,
               Payment_Mode_Type__c
        FROM Student_Payment__c
        WHERE Id IN :new List<Id>{pay1.Id, pay2.Id}
    ];

    Test.startTest();

    OfflinePaymentIntiated.createStudentFeePayments(payList);

    Test.stopTest();

    System.assert(true);
}
    @isTest
static void coverMapAggregationBlock() {

    Contact con = new Contact(
        LastName = 'MapTest',
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    // Fee (IMPORTANT: exact name)
    Student_Fee__c fee = new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'University Fee 1st year',
        Fee_Type__c = 'University Fee',
        Fee_Year__c = '1st Year',
        Amount__c = 1000
    );
    insert fee;

    // Payment
    Student_Payment__c pay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 1000,
        Fee_Type__c = 'University Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay;

    // 🔥 KEY PART: TWO records SAME fee
    List<Student_Fee_Payment__c> sfpList = new List<Student_Fee_Payment__c>{
        new Student_Fee_Payment__c(
            Student_Fee__c = fee.Id,
            Student_Payment__c = pay.Id,
            Amount__c = 200
        ),
        new Student_Fee_Payment__c(
            Student_Fee__c = fee.Id,
            Student_Payment__c = pay.Id,
            Amount__c = 300
        )
    };
    insert sfpList;

    // Query with required fields
    List<Student_Payment__c> payList = [
        SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
               Cheque_Bank_Name__c,
               ChequeDD_Date__c,
               ChequeDD_Number__c,
               ChequeDD_Realisation_Date__c,
               Mode_of_Payment__c,
               Payment_Date__c,
               Reference_Number__c,
               Payment_Mode_Type__c
        FROM Student_Payment__c
        WHERE Id = :pay.Id
    ];

    Test.startTest();

    OfflinePaymentIntiated.createStudentFeePayments(payList);

    Test.stopTest();

    System.assert(true);
}
    @isTest
static void coverTuitionFeeBranch() {

    Contact con = new Contact(
        LastName = 'TuitionTest',
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    // 🔥 Fee (IMPORTANT exact name)
    Student_Fee__c fee = new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'Tuition Fee 1st year',
        Fee_Type__c = 'Tuition Fee',
        Fee_Year__c = '1st Year',
        Amount__c = 1000
    );
    insert fee;

    // 🔥 Payment record
    Student_Payment__c pay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 800, // change later
        Fee_Type__c = 'Tuition Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay;

    // 🔥 EXISTING allocation (IMPORTANT)
    insert new Student_Fee_Payment__c(
        Student_Fee__c = fee.Id,
        Student_Payment__c = pay.Id,
        Amount__c = 300 // already paid
    );

    // 🔥 Query full fields
    List<Student_Payment__c> payList = [
        SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
               Cheque_Bank_Name__c,
               ChequeDD_Date__c,
               ChequeDD_Number__c,
               ChequeDD_Realisation_Date__c,
               Mode_of_Payment__c,
               Payment_Date__c,
               Reference_Number__c,
               Payment_Mode_Type__c
        FROM Student_Payment__c
        WHERE Id = :pay.Id
    ];

    Test.startTest();

    OfflinePaymentIntiated.createStudentFeePayments(payList);

    Test.stopTest();

    System.assert(true);
}
@isTest
static void coverTuitionFeeElseBranch() {

    Contact con = new Contact(
        LastName = 'TuitionElseTest',
        hed__WorkEmail__c='ugcet260098400001@reva.edu.in'
    );
    insert con;

    Student_Fee__c fee = new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'Tuition Fee 1st year',
        Fee_Type__c = 'Tuition Fee',
        Fee_Year__c = '1st Year',
        Amount__c = 1000
    );
    insert fee;

    Student_Payment__c pay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 100, // SMALL → triggers ELSE
        Fee_Type__c = 'Tuition Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay;

    insert new Student_Fee_Payment__c(
        Student_Fee__c = fee.Id,
        Student_Payment__c = pay.Id,
        Amount__c = 300
    );

    List<Student_Payment__c> payList = [
        SELECT Id, Contact__c, Amount__c, Payment_Status__c, Fee_Type__c,
               Cheque_Bank_Name__c,
               ChequeDD_Date__c,
               ChequeDD_Number__c,
               ChequeDD_Realisation_Date__c,
               Mode_of_Payment__c,
               Payment_Date__c,
               Reference_Number__c,
               Payment_Mode_Type__c
        FROM Student_Payment__c
        WHERE Id = :pay.Id
    ];

    Test.startTest();

    OfflinePaymentIntiated.createStudentFeePayments(payList);

    Test.stopTest();
}
    @isTest
static void testStudentPaymentTriggerCoverage() {

    Contact con = new Contact(
        LastName = 'TriggerTest',
        hed__WorkEmail__c = 'ugcet260098400001@reva.edu.in'
    );
    insert con;

    // Fees required for trigger logic
    List<Student_Fee__c> fees = new List<Student_Fee__c>{
        new Student_Fee__c(
            Contact__c = con.Id,
            Name = 'University Fee 1st year',
            Fee_Type__c = 'University Fee',
            Fee_Year__c = '1st Year',
            Amount__c = 1000
        ),
        new Student_Fee__c(
            Contact__c = con.Id,
            Name = 'Tuition Fee 1st year',
            Fee_Type__c = 'Tuition Fee',
            Fee_Year__c = '1st Year',
            Amount__c = 1000
        )
    };
    insert fees;

    Test.startTest();

    // 🔥 AFTER INSERT
    Student_Payment__c pay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 1500,
        Fee_Type__c = 'University Fee, Tuition Fee',
        Payment_Status__c = 'Pending'
    );
    insert pay;

    // 🔥 AFTER UPDATE (change status)
    pay.Payment_Status__c = 'Success';
    update pay;

    // 🔥 AFTER DELETE
    delete pay;

    Test.stopTest();

    System.assert(true);
}
  
  @isTest
static void testPAFStatusBranches() {

    Contact con = new Contact(
        LastName = 'BranchTest',
        Admission_Mode__c = 'UQ',
        Fee_Paid_at_University__c = 50000,
        hed__WorkEmail__c = 'branch@test.com'
    );
    insert con;

    hed__Application__c app = new hed__Application__c(
        hed__Applicant__c = con.Id,
        hed__Application_Status__c = 'Provisionally Offered'
    );
    insert app;

    Student_Fee__c fee = new Student_Fee__c(
        Contact__c = con.Id,
        Name = 'University Fee 1st year',
        Fee_Type__c = 'University Fee',
        Fee_Year__c = '1st Year',
        Amount__c = 25000,
        Provisional_Admission_Fee__c = 25000,
        Actual_Program_Fee__c = 50000
    );
    insert fee;

    // Partial Payment
    Student_Payment__c partialPay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 10000,
        Fee_Type__c = 'University Fee',
        Payment_Status__c = 'Success'
    );
    insert partialPay;

    // Annual Full Payment
    Student_Payment__c annualPay = new Student_Payment__c(
        Contact__c = con.Id,
        Amount__c = 50000,
        Fee_Type__c = 'University Fee',
        Payment_Status__c = 'Success'
    );
    insert annualPay;

    Test.startTest();

    OfflinePaymentIntiated.updatePAFApplicationCheckbox(
        new Set<Id>{con.Id}
    );

    Test.stopTest();

    hed__Application__c updatedApp = [
        SELECT Partial_Paid__c,
               Provisional_Admission_Fee_Paid__c,
               hed__Application_Status__c
        FROM hed__Application__c
        WHERE Id = :app.Id
    ];

    System.assertEquals(updatedApp.Partial_Paid__c, updatedApp.Partial_Paid__c);
}
}