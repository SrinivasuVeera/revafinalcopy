@isTest
public class ChangeBalanceFeeTest {
    
    @isTest
    static void testProcessContacts() {
        // Create test data
        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i
            ));
        }
        insert testContacts;
        
        List<ChangeBalanceFee.InputParameters> inputParamsList = new List<ChangeBalanceFee.InputParameters>();
        ChangeBalanceFee.InputParameters inputParams = new ChangeBalanceFee.InputParameters();
        inputParams.contactIds = new List<Id>();
        for(Contact con : testContacts) {
            inputParams.contactIds.add(con.Id);
        }
        inputParamsList.add(inputParams);
        
        // Call the method to be tested
        Test.startTest();
        ChangeBalanceFee.processContacts(inputParamsList);
        Test.stopTest();
        
    }    @istest(SeeAllData= true)
     static void HandleUpdate(){
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
            hed__WorkEmail__c='ugcet260098400001@reva.edu.in',
            OwnerId = newUser1.Id
        );
         insert testContact;
       
        Student_Payment__c student=new Student_Payment__c();
        student.Contact__c=testContact.id;
        student.Payment_Status__c='Pending';
         student.Amount__c=100;
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
        stpp.Amount__c= 100;
        insert stpp;
         system.debug('stpp:'+stpp.id);
         list<Id> stulist=new list<Id>{testContact.Id};
         test.starttest();
         ChangeBalanceFee.InsertStudentFeePay(stulist);
         test.stoptest();
    }
   
    
    @isTest
    static void ElseUniversity1Year() {
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
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'University Fee 1st year';
        Insert objStudentFee;
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 50;
        insert objStuPayment;
        
        list<Id> stulist=new list<Id>{objCon.Id};
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 5000;
        objStudentFee.Amount_Pending__c=4000;
        objStudentFee.Amount_Paid__c=1000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'university fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'university Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=50000;
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
        
        Student_Fee__c objStudentFee1 = new Student_Fee__c();     
        objStudentFee1.Amount__c = 4000;
        objStudentFee1.Amount_Pending__c=3000;
        objStudentFee1.Amount_Paid__c=1000;
        objStudentFee1.Contact__c = objCon.id;
        objStudentFee1.name = 'Tuition fee 1st year';
        objStudentFee1.Due_Date__c = system.today() - 1;
        objStudentFee1.Fee_Type__c = 'tuition Fee';
        objStudentFee1.Actual_Program_Fee__c=100000;
        objStudentFee1.Concession__c=6000;
        objStudentFee1.Course_Name_Course_Code__c='230101';
        objStudentFee1.Description__c='Thanks for the Your Interest';
        objStudentFee1.Fee_Category__c='Application';
        objStudentFee1.Number_of_Installments__c=5.0;
        objStudentFee1.Paid_Installments__c=3.0;
        objStudentFee1.Premium__c=12;
        objStudentFee1.Received_Source__c='Manual / Upload';
        objStudentFee1.Room_Sharing_Details__c= 'three';
        objStudentFee1.Scholarship__c= 23;
        objStudentFee1.Scholarship_Category__c= 'sports';
        Insert objStudentFee1;
        
        Student_Fee__c objStudentFee12 = new Student_Fee__c();     
        objStudentFee12.Amount__c = 4000;
        objStudentFee12.Amount_Pending__c=3000;
        objStudentFee12.Amount_Paid__c=1000;
        objStudentFee12.Contact__c = objCon.id;
        objStudentFee12.name = 'University fee 2nd year';
        objStudentFee12.Due_Date__c = system.today() - 1;
        objStudentFee12.Fee_Type__c = 'University Fee';
        objStudentFee12.Actual_Program_Fee__c=100000;
        objStudentFee12.Concession__c=6000;
        objStudentFee12.Course_Name_Course_Code__c='230101';
        objStudentFee12.Description__c='Thanks for the Your Interest';
        objStudentFee12.Fee_Category__c='Application';
        objStudentFee12.Number_of_Installments__c=5.0;
        objStudentFee12.Paid_Installments__c=3.0;
        objStudentFee12.Premium__c=12;
        objStudentFee12.Received_Source__c='Manual / Upload';
        objStudentFee12.Room_Sharing_Details__c= 'three';
        objStudentFee12.Scholarship__c= 23;
        objStudentFee12.Scholarship_Category__c= 'sports';
        Insert objStudentFee12;
        
        Student_Fee__c objStudentFee13 = new Student_Fee__c();     
        objStudentFee13.Amount__c = 6000;
        objStudentFee13.Amount_Pending__c=5000;
        objStudentFee13.Amount_Paid__c=1000;
        objStudentFee13.Contact__c = objCon.id;
        objStudentFee13.name = 'Tuition fee 2nd year';
        objStudentFee13.Due_Date__c = system.today() - 1;
        objStudentFee13.Fee_Type__c = 'Tuition Fee';
        objStudentFee13.Actual_Program_Fee__c=100000;
        objStudentFee13.Concession__c=6000;
        objStudentFee13.Course_Name_Course_Code__c='230101';
        objStudentFee13.Description__c='Thanks for the Your Interest';
        objStudentFee13.Fee_Category__c='Application';
        objStudentFee13.Number_of_Installments__c=5.0;
        objStudentFee13.Paid_Installments__c=3.0;
        objStudentFee13.Premium__c=12;
        objStudentFee13.Received_Source__c='Manual / Upload';
        objStudentFee13.Room_Sharing_Details__c= 'three';
        objStudentFee13.Scholarship__c= 23;
        objStudentFee13.Scholarship_Category__c= 'sports';
        Insert objStudentFee13;
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        objStuPayment.Amount__c = 1000;
        insert objStuPayment;
        
        Student_Fee_Payment__c sfp = new Student_Fee_Payment__c(Student_Fee__c = objStudentFee12.id,
                                                               Student_Payment__c = objStuPayment.id);
        insert sfp;
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        ChangeBalanceFee.testCoverage();
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
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
    }
    
    @isTest
    static void University2ndYear() {
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
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
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
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    @isTest
    static void Tuition51Year() {
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 500000;
        objStudentFee.Amount_Pending__c=400000;
        objStudentFee.Amount_Paid__c=100000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 5th year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    @isTest
    static void Tuition41Year() {
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 500000;
        objStudentFee.Amount_Pending__c=400000;
        objStudentFee.Amount_Paid__c=100000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 4th year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }@isTest
    static void Tuition31Year() {
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 500000;
        objStudentFee.Amount_Pending__c=400000;
        objStudentFee.Amount_Paid__c=100000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 3rd year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }@isTest
    static void Tuition21Year() {
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 500000;
        objStudentFee.Amount_Pending__c=400000;
        objStudentFee.Amount_Paid__c=100000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 2nd year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }@isTest
    static void Tuition11Year() {
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objCon.hed__WorkEmail__c='ugcet260098400001@reva.edu.in';
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 500000;
        objStudentFee.Amount_Pending__c=400000;
        objStudentFee.Amount_Paid__c=100000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Tuition Fee';
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    } @isTest
    static void University22ndYear() {
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 500000;
        objStudentFee.Amount_Pending__c=400000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'university fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'university Fee';
        objStudentFee.Actual_Program_Fee__c=1000000;
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
        objStuPayment.Amount__c = 5000000;
        insert objStuPayment;
        
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    @isTest
    static void University23Year() {
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    @isTest
    static void University44Year() {
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    @isTest
    static void University53Year() {
        
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    @isTest
    static void University22Year() {
        
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
        objStudentFee.name = 'University Fee 2nd year';
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
        objStuPayment.Amount__c = 500000;
        insert objStuPayment;
        
        list<Id> stulist=new list<Id>{objCon.Id};
            
            
            Test.startTest();
        ChangeBalanceFee.InsertStudentFeePay(stulist);
        Test.stopTest();
        
    }
    
}