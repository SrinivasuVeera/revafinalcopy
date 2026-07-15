@isTest
public class StudentPaymentTriggerHandler_Test {
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"unicode":"false","sender":"REVAUN","message":{"text":"1234 is your One Time Password(OTP) for REVA. This OTP is valid till 5Mins - REVA University","recipient":"918951419170"},"extra":{"templateId":null,"dltContentId":"1007494991024424186","corelationId":null}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    public static final String CONST_APPLICANT_RECTYPE = 'Applicant';
    @TestSetup
    public static void createData(){
        // create test data
        String enteredCouponCode = 'REVA1234';
        String enteredCouponCode1 = 'REVADMIN2023';
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        RecordType academicProgramRT = [Select id FROM RecordType Where DeveloperName = 'Academic_Program' Limit 1];
        Profile p = [select Id,name from Profile where Name ='Counselor' limit 1];       
        User newUser1 = new User(
             profileId = p.Id,
             username = 'newUser@epeople.com',
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
        Account program= new Account(
            Name = 'Bachelor of Architecture',
            RecordTypeId = academicProgramRT.Id,    
            Program_Alias__c = 'Barch',
            Program_Type__c = 'UG',
            Program_Code__c = 'RA',
            Intake__c = 80,
            Intake_Per_Section__c = 40
        );
        insert program;
        List<Contact> lstCon =new List<Contact>();
        Contact conObj = new Contact();
        conObj.FirstName = 'John';
        conObj.LastName = 'Doe';
        conObj.Email = 'jai@gmail.com';
        conObj.Application_Fee_Paid__c = false;
        conObj.MobilePhone = '+91-9876543210';
        conObj.Country_Code__c = 'India (+91)';
        conObj.Application_Number__C = '98653214712';
        conObj.RecordTypeId = conRecId;
        conObj.Quota__c = 'Management Quota';
        conObj.Enrollment_Type__c = 'Regular Entry';
        conObj.Admission_Mode__c = 'UQ';
        conObj.OwnerId = newUser1.Id;
        // insert conObj;
        lstCon.add(conObj);
        
        Contact conObj1 = new Contact();
        conObj1.FirstName = 'John1';
        conObj1.LastName = 'Doe1';
        conObj1.Email = 'jun@gmail.com';
        conObj1.Application_Fee_Paid__c = false;
        conObj1.MobilePhone = '+91-9876543210';
        conObj1.Country_Code__c = 'India (+91)';
        conObj1.Application_Number__C = '98653214712';
        conObj1.RecordTypeId = conRecId;
        conObj1.Quota__c = 'Government Quota';
        conObj1.Enrollment_Type__c = 'Regular Entry';
        conObj1.Admission_Mode__c = 'UQ';
        // insert conObj1;
        lstCon.add(conObj1);
        
        Contact conObj2 = new Contact();
        conObj2.FirstName = 'John1';
        conObj2.LastName = 'Doe1';
        conObj2.Email = 'jun1@gmail.com';
        conObj2.Application_Fee_Paid__c = true;
        conObj2.MobilePhone = '+91-9876543210';
        conObj2.Country_Code__c = 'India (+91)';
        conObj2.Application_Number__C = '98653214712';
        conObj2.RecordTypeId = conRecId;
        // conObj2.Quota__c = 'Management Quota';
        // conObj2.Enrollment_Type__c = 'Regular Entry';
        // conObj2.Admission_Mode__c = 'UQ';
        // insert conObj2;
        lstCon.add(conObj2);

    //     Contact conObj3 = new Contact();
    //     conObj3.FirstName = 'John1';
    //     conObj3.LastName = 'Doe1';
    //     conObj3.Email = 'jun12@gmail.com';
    //     conObj3.Application_Fee_Paid__c = true;
    //     conObj3.MobilePhone = '+91-9876543210';
    //     conObj3.Country_Code__c = 'India (+91)';
    //     conObj3.Application_Number__C = '98653214712';
    //     conObj3.RecordTypeId = conRecId;
    //     conObj3.OwnerId = newUser1.Id;
    //     // conObj2.Quota__c = 'Management Quota';
    //     // conObj2.Enrollment_Type__c = 'Regular Entry';
    //     // conObj2.Admission_Mode__c = 'UQ';
    //     // insert conObj2;
    //     lstCon.add(conObj3);

        insert lstCon;

    //     Student_Payment__c stuPayt3 = new Student_Payment__c();
    //     stuPayt3.Contact__c = conObj3.Id;
    //     stuPayt3.Payment_Gateway__c = 'RazorPay';
    //     stuPayt3.Payment_Status__c = 'Pending';
    //     stuPayt3.Fee_Type__c = 'University Fee, Tuition Fee';
    //     stuPayt3.Mode_of_Payment__c = 'Online';
    //     stuPayt3.Amount__c = 10000;
        
    //     Student_Fee__c stuFee13 = new Student_Fee__c();
    //     stuFee13.contact__c = conObj3.Id;
    //     stuFee13.Fee_Year__c = '1st Year';
    //     stuFee13.Name = 'University Fee 1st year';
    //     stuFee13.Amount__c = 1500;
    //     stuFee13.Fee_Type__c =  'University Fee';
    //     //insert stuFee10;

    //     Student_Fee__c stuFee14 = new Student_Fee__c();
    //     stuFee14.contact__c = conObj3.Id;
    //     stuFee14.Fee_Year__c = '1st Year';
    //     stuFee14.Name = 'University Fee 1st year';
    //     stuFee14.Amount__c = 100;
    //     stuFee14.Fee_Type__c =  'University Fee';
    //    // insert stuFee12;

    //     Student_Fee__c stuFee15 = new Student_Fee__c();
    //     stuFee15.contact__c = conObj3.Id;
    //     stuFee15.Fee_Year__c = '1st Year';
    //     stuFee15.Name = 'Tuition Fee 1st year';
    //     stuFee15.Amount__c = 100;
    //     stuFee15.Fee_Type__c =  'Tuition Fee';
    //    // insert stuFee11;

    //     Student_Fee__c stuFee16 = new Student_Fee__c();
    //     stuFee16.contact__c = conObj3.Id;
    //     stuFee16.Fee_Year__c = '2nd Year';
    //     stuFee16.Name = 'University Fee 2nd year';
    //     stuFee16.Amount__c = 900;
    //     stuFee16.Fee_Type__c =  'University Fee';

        List<Student_Payment__c> lstStuPay = new List<Student_Payment__c>();
        Student_Payment__c stuPay = new Student_Payment__c();
        stuPay.Contact__c = conObj.Id;
        stuPay.Payment_Gateway__c = 'RazorPay';
        stuPay.Payment_Status__c = 'Payment Link Created';
        stuPay.Fee_Type__c = 'Application Fee';
        stuPay.Amount__c = 1000;
        stuPay.Mode_of_Payment__c='Online';
        // insert stuPay;
        lstStuPay.add(stuPay);
        
        Student_Payment__c stuPayt = new Student_Payment__c();
        stuPayt.Contact__c = conObj1.Id;
        stuPayt.Payment_Gateway__c = 'RazorPay';
        stuPayt.Payment_Status__c = 'Payment Link Created';
        stuPayt.Fee_Type__c = 'Application Fee';
        stuPayt.Amount__c = 1000;
        stuPayt.Mode_of_Payment__c='Online';
        // insert stuPayt;
        lstStuPay.add(stuPayt);
        
        Student_Payment__c stuPayt1 = new Student_Payment__c();
        stuPayt1.Contact__c = conObj2.Id;
        stuPayt1.Payment_Gateway__c = 'RazorPay';
        stuPayt1.Payment_Status__c = 'Success';
        stuPayt1.Fee_Type__c = 'University Fee';
        stuPayt1.Mode_of_Payment__c = 'Online';
        stuPayt1.Amount__c = 1000;
        // insert stuPayt1;
        lstStuPay.add(stuPayt1);

        Student_Payment__c stuPayt2 = new Student_Payment__c();
        stuPayt2.Contact__c = conObj2.Id;
        stuPayt2.Payment_Gateway__c = 'RazorPay';
        stuPayt2.Payment_Status__c = 'Pending';
        stuPayt2.Fee_Type__c = 'University Fee';
        stuPayt2.Mode_of_Payment__c = 'Online';
        stuPayt2.Amount__c = 10;
        // insert stuPayt2;
        lstStuPay.add(stuPayt2);
        
         Student_Payment__c stuPayt20 = new Student_Payment__c();
        stuPayt20.Contact__c = conObj2.Id;
        stuPayt20.Payment_Gateway__c = 'RazorPay';
        stuPayt20.Payment_Status__c = 'Pending';
        stuPayt20.Fee_Type__c = 'Hostel Fee';
        stuPayt20.Mode_of_Payment__c = 'Online';
        stuPayt20.Amount__c = 10;
        // insert stuPayt2;
        lstStuPay.add(stuPayt20);
        
           Student_Payment__c stuPayt21 = new Student_Payment__c();
        stuPayt21.Contact__c = conObj2.Id;
        stuPayt21.Payment_Gateway__c = 'RazorPay';
        stuPayt21.Payment_Status__c = 'Failed';
        stuPayt21.Fee_Type__c = 'Hostel Fee';
        stuPayt21.Mode_of_Payment__c = 'Online';
        stuPayt21.Amount__c = 10;
        // insert stuPayt2;
        lstStuPay.add(stuPayt21);
        
         Student_Payment__c stuPayt22 = new Student_Payment__c();
        stuPayt22.Contact__c = conObj2.Id;
        stuPayt22.Payment_Gateway__c = 'Billdesk';
        stuPayt22.Payment_Status__c = 'Failed';
        stuPayt22.Fee_Type__c = 'Hostel Fee';
        stuPayt22.Mode_of_Payment__c = 'Online';
        stuPayt22.Amount__c = 10;
        // insert stuPayt2;
        lstStuPay.add(stuPayt22);

        
         Student_Payment__c stuPayt23 = new Student_Payment__c();
        stuPayt23.Contact__c = conObj2.Id;
        stuPayt23.Payment_Gateway__c = 'Paytm';
        stuPayt23.Payment_Status__c = 'Failed';
        stuPayt23.Fee_Type__c = 'Hostel Fee';
        stuPayt23.Mode_of_Payment__c = 'Online';
        stuPayt23.Amount__c = 10;
        // insert stuPayt2;
        lstStuPay.add(stuPayt23);
        
        List<Student_Payment__c> lstStuPay1 = new List<Student_Payment__c>();
        Student_Payment__c stuPayObj = new Student_Payment__c();
        stuPayObj.Contact__c = conObj1.Id;
        stuPayObj.Payment_Gateway__c = 'Billdesk';
        stuPayObj.Payment_Status__c = 'Payment Link Created';
        stuPayObj.Fee_Type__c = 'Application Fee';
        stuPayObj.Amount__c = 1000;
        stuPayObj.Mode_of_Payment__c='Online';
        // insert stuPayObj;
        lstStuPay1.add(stuPayObj);
        
        Student_Payment__c stuPayment = new Student_Payment__c();
        stuPayment.Contact__c = conObj.Id;
        stuPayment.Payment_Gateway__c = 'Billdesk';
        stuPayment.Payment_Status__c = 'Payment Link Created';
        stuPayment.Fee_Type__c = 'Application Fee';
        stuPayment.Amount__c = 1000;
        stuPayment.Mode_of_Payment__c='Online';
        // insert stuPayment;
        lstStuPay1.add(stuPayment);

     Student_Payment__c stuPayment10 = new Student_Payment__c();
        stuPayment.Contact__c = conObj.Id;
        stuPayment.Payment_Gateway__c = 'Billdesk';
        stuPayment.Payment_Status__c = 'Payment Link Created';
        stuPayment.Fee_Type__c = 'Hostel Fee';
        stuPayment.Amount__c = 1000;
        stuPayment.Mode_of_Payment__c='Online';
        // insert stuPayment;
        lstStuPay1.add(stuPayment10);
        
         Student_Payment__c stuPayment19 = new Student_Payment__c();
        stuPayment19.Contact__c = conObj.Id;
        stuPayment19.Payment_Gateway__c = 'Billdesk';
        stuPayment19.Payment_Status__c = 'Failed';
        stuPayment19.Fee_Type__c = 'Hostel Fee';
        stuPayment19.Amount__c = 1000;
        stuPayment19.Mode_of_Payment__c='Online';
        // insert stuPayment;
        lstStuPay1.add(stuPayment19);
        
        Student_Payment__c stuPayment1 = new Student_Payment__c();
        stuPayment1.Contact__c = conObj2.Id;
        stuPayment1.Payment_Gateway__c = 'Billdesk';
        stuPayment1.Payment_Status__c = 'Success';
        stuPayment1.Fee_Type__c = 'University Fee';
        stuPayment1.Mode_of_Payment__c = 'Online';
        stuPayment1.Amount__c = 50000;
        // insert stuPayment1;
        lstStuPay1.add(stuPayment1);
       

        List<Student_Payment__c> lstStuPay11 = new List<Student_Payment__c>();
        Student_Payment__c stuPayObj1 = new Student_Payment__c();
        stuPayObj1.Contact__c = conObj1.Id;
        stuPayObj1.Payment_Gateway__c = 'Paytm';
        stuPayObj1.Payment_Status__c = 'Success';
        stuPayObj1.Fee_Type__c = 'Application Fee';
        stuPayObj1.Amount__c = 15;
        stuPayObj1.Mode_of_Payment__c='Online';
       // insert stuPayObj1;
        lstStuPay11.add(stuPayObj1);
        
        Student_Payment__c stuPayment11 = new Student_Payment__c();
        stuPayment11.Contact__c = conObj.Id;
        stuPayment11.Payment_Gateway__c = 'Paytm';
        stuPayment11.Payment_Status__c = 'Payment Link Created';
        stuPayment11.Fee_Type__c = 'Application Fee';
        stuPayment11.Amount__c = 15;
        stuPayment11.Mode_of_Payment__c='Online';
       // insert stuPayment11;
        lstStuPay11.add(stuPayment11);
        
        Student_Payment__c testPayment = new Student_Payment__c();
        testPayment.Contact__c = conObj2.Id;
        testPayment.Payment_Gateway__c = 'Paytm';
        testPayment.Payment_Status__c = 'Pending';
        testPayment.Fee_Type__c = 'University Fee';
        testPayment.Mode_of_Payment__c = 'Online';
        testPayment.Cheque_Bank_Name__c = 'HDFC Bank';
        testPayment.ChequeDD_Date__c = System.today();
        testPayment.ChequeDD_Number__c = '1235';
        testPayment.ChequeDD_Realisation_Date__c = System.today();
        testPayment.Amount__c = 15;
        // insert testPayment;
        lstStuPay1.add(testPayment);
        insert lstStuPay1;

        Student_Fee__c stuFee10 = new Student_Fee__c();
        stuFee10.contact__c = conObj2.Id;
        stuFee10.Fee_Year__c = '1st Year';
        stuFee10.Name = 'University Fee 1st year';
        stuFee10.Amount__c = 1500;
        stuFee10.Fee_Type__c =  'University Fee';
        
        //insert stuFee10;

        Student_Fee__c stuFee12 = new Student_Fee__c();
        stuFee12.contact__c = conObj2.Id;
        stuFee12.Fee_Year__c = '1st Year';
        stuFee12.Name = 'University Fee 1st year';
        stuFee12.Amount__c = 100;
        stuFee12.Fee_Type__c =  'University Fee';
       // insert stuFee12;

        Student_Fee__c stuFee11 = new Student_Fee__c();
        stuFee11.contact__c = conObj2.Id;
        stuFee11.Fee_Year__c = '1st Year';
        stuFee11.Name = 'Tuition Fee 1st year';
        stuFee11.Amount__c = 15000;
        stuFee11.Fee_Type__c =  'Tuition Fee';
       // insert stuFee11;

        Student_Fee__c stuFee2 = new Student_Fee__c();
        stuFee2.contact__c = conObj2.Id;
        stuFee2.Fee_Year__c = '2nd Year';
        stuFee2.Name = 'University Fee 2nd year';
        stuFee2.Amount__c = 1500;
        stuFee2.Fee_Type__c =  'University Fee';
        //insert stuFee2;

        Student_Fee__c stuFee3 = new Student_Fee__c();
        stuFee3.contact__c = conObj2.Id;
        stuFee3.Fee_Year__c = '2nd Year';
        stuFee3.Name = 'Tuition Fee 2nd year';
        stuFee3.Amount__c = 15000;
        stuFee3.Fee_Type__c =  'Tuition Fee';
       // insert stuFee3;

        Student_Fee__c stuFee4 = new Student_Fee__c();
        stuFee4.contact__c = conObj2.Id;
        stuFee4.Fee_Year__c = '3rd Year';
        stuFee4.Name = 'University Fee 3rd year';
        stuFee4.Amount__c = 1500;
        stuFee4.Fee_Type__c =  'University Fee';
       // insert stuFee4;

        Student_Fee__c stuFee5 = new Student_Fee__c();
        stuFee5.contact__c = conObj2.Id;
        stuFee5.Fee_Year__c = '3rd Year';
        stuFee5.Name = 'Tuition Fee 3rd year';
        stuFee5.Amount__c = 15000;
        stuFee5.Fee_Type__c =  'Tuition Fee';
      //  insert stuFee5;

        Student_Fee__c stuFee6 = new Student_Fee__c();
        stuFee6.contact__c = conObj2.Id;
        stuFee6.Fee_Year__c = '4th Year';
        stuFee6.Name = 'University Fee 4th year';
        stuFee6.Amount__c = 1500;
        stuFee6.Fee_Type__c =  'University Fee';
       // insert stuFee6;

        Student_Fee__c stuFee7 = new Student_Fee__c();
        stuFee7.contact__c = conObj2.Id;
        stuFee7.Fee_Year__c = '4th Year';
        stuFee7.Name = 'Tuition Fee 4th year';
        stuFee7.Amount__c = 15000;
        stuFee7.Fee_Type__c =  'Tuition Fee';
       // insert stuFee7;

        Student_Fee__c stuFee8 = new Student_Fee__c();
        stuFee8.contact__c = conObj2.Id;
        stuFee8.Fee_Year__c = '5th Year';
        stuFee8.Name = 'University Fee 5th year';
        stuFee8.Amount__c = 1500;
        stuFee8.Fee_Type__c =  'University Fee';
       // insert stuFee8;

        Student_Fee__c stuFee9 = new Student_Fee__c();
        stuFee9.contact__c = conObj2.Id;
        stuFee9.Fee_Year__c = '5th Year';
        stuFee9.Name = 'Tuition Fee 5th year';
        stuFee9.Amount__c = 15000;
        stuFee9.Fee_Type__c =  'Tuition Fee';
       // insert stuFee9;

       insert new List<Student_Fee__c>{stuFee10, stuFee12,stuFee11,stuFee2,stuFee3,stuFee5,stuFee6,stuFee7,stuFee8,stuFee9}; //, stuFee13, stuFee14, stuFee15, stuFee16

        // Student_Fee_Payment__c stufeePayUpdated = new Student_Fee_Payment__c();
        // stufeePayUpdated.Amount__c = 1000;
        // stufeePayUpdated.Student_Fee__c = stuFee9.id;
        // stufeePayUpdated.Line_Item_Payment_Status__c = 'Pending';
        // stufeePayUpdated.Student_Payment__c = testPayment.Id;
        // stufeePayUpdated.Cheque_Bank_Name__c = testPayment.Cheque_Bank_Name__c;
        // stufeePayUpdated.Cheque_DD_Date__c = testPayment.ChequeDD_Date__c;
        // stufeePayUpdated.Cheque_DD_Number__c = testPayment.ChequeDD_Number__c;
        // stufeePayUpdated.Cheque_DD_Realisation_Date__c =testPayment.ChequeDD_Realisation_Date__c;
        // stufeePayUpdated.Mode_of_Payment__c = testPayment.Mode_of_Payment__c;
        // stufeePayUpdated.Payment_Date__c =testPayment.Payment_Date__c;
        // stufeePayUpdated.Reference_Number__c =testPayment.Reference_Number__c;
        // stufeePayUpdated.Payment_Mode_Type__c = testPayment.Payment_Mode_Type__c;
        // insert stufeePayUpdated;

        Coupon__c couponCode = new Coupon__c(
            Applicant__c = conObj.Id,
            Coupon_Code__c = enteredCouponCode,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode;
        Set<hed__Application__c> hedLst =new Set<hed__Application__c>();
        hed__Application__c Application = new hed__Application__c(
            hed__Applicant__c = conObj.Id,
            Provisional_Admission_Fee_Paid__c = false,
            hed__Applying_To__c = program.Id,
            Applied_Coupon__c = couponCode.Id,
            Application_Number__C = '98653214713'
        );
        insert Application;
        hedLst.add(Application);
        
        Coupon__c couponCode1 = new Coupon__c(
            Applicant__c = conObj1.Id,
            Coupon_Code__c = enteredCouponCode1,
            Discount_Percent__c = 10,
            Effective_From__c = system.today(),
            Effective_To__c = system.today()+1
        );
        insert couponCode1;
        hed__Application__c Application1 = new hed__Application__c(
            hed__Applicant__c = conObj1.Id,
            Provisional_Admission_Fee_Paid__c = false,
            hed__Applying_To__c = program.Id,
            Applied_Coupon__c = couponCode1.Id,
            Application_Number__C = '98653214712'
        );
        insert Application1;
        hedLst.add(Application1);
        system.debug('lll'+lstStuPay);
    }
    
    
    @isTest
    public static void handlePayments() {
        
        String enteredCouponCode = 'REVA1234';
        List<Contact> conList = [Select id, FirstName, LastName, Email From Contact];
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'jai@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                 Where hed__Applicant__c =:con.Id Limit 1];
        
        
        updateApplication.Applied_Coupon__c = coupn.Id;
        update updateApplication;

        list<student_payment__c> lstStuPay = [select Cheque_Bank_Name__c,ChequeDD_Date__c,ChequeDD_Number__c,ChequeDD_Realisation_Date__c,Mode_of_Payment__c,Payment_Date__c,Reference_Number__c,Payment_Mode_Type__c,  id,Amount__c, Payment_Gateway__c,Transaction_Id__c,Payment_Status__c,Contact__r.Application_fee_paid__c,Contact__r.Application_Number__c,Contact__r.Name,Contact__r.Email,Fee_Type__c from student_payment__c Where (Payment_Gateway__c='Billdesk' or Payment_Gateway__c='RazorPay' or Payment_Gateway__c= 'Paytm' or Payment_Gateway__c= 'Eazypay')];
        
        Map<Id, Student_Payment__c> oldPaymentMap = new Map<Id, Student_Payment__c>();
        for(student_payment__c s : lstStuPay){
            oldPaymentMap.put(s.Id, s);
            if(s.Payment_Status__c == 'Pending'){
                s.Payment_Status__c = 'Success';
            } else {
                s.Payment_Status__c = 'Failed';
            }
        }
        system.debug('vvv'+oldPaymentMap);
        update lstStuPay;
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //Call the handler
        Test.startTest();
        StudentPaymentTriggerHandler.handlePaymentUpdates(lstStuPay,oldPaymentMap);
      //  StudentPaymentTriggerHandler.updateApplicationFeeStatus(lstStuPay);
        StudentPaymentTriggerHandler.updateCouponCount(conList);
        OfflinePaymentIntiated.handleDelete(lstStuPay);
        OfflinePaymentIntiated.HandleUpdate(lstStuPay,oldPaymentMap);
        OfflinePaymentIntiated.createStudentFeePayments(lstStuPay);
        Test.stopTest();
        
        List<student_payment__c> lstStuPayAssert = [select id,Payment_Gateway__c,Transaction_Id__c,Payment_Status__c,Contact__r.Application_fee_paid__c,Contact__r.Application_Number__c,Contact__r.Name,Contact__r.Email,Fee_Type__c from student_payment__c Where Payment_Gateway__c='Razorpay' Limit 1];
        // system.assertEquals('Success', lstStuPayAssert[0].Payment_Status__c);
    }
        
    @isTest
    public static void handlePayments1() {
        
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
        
         hed__Program_Plan__c  objProgPlan =  new hed__Program_Plan__c();
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Name ='LE' ;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            insert objProgPlan;
        

        Contact conObj = new Contact();
        conObj.FirstName = 'John';
        conObj.LastName = 'Doe';
        conObj.Email = 'jai@gmail.com';
        conObj.Application_Fee_Paid__c = false;
        conObj.MobilePhone = '+91-9876543210';
        conObj.Country_Code__c = 'India (+91)';
        conObj.Application_Number__C = '98653214712';
        conObj.RecordTypeId = conRecId;
        conObj.Quota__c = 'Management Quota';
        conObj.Enrollment_Type__c = 'Regular Entry';
        conObj.Admission_Mode__c = 'UQ';
        conObj.Program_Batch__c = objProgPlan.Id;
      insert conObj;
        list<student_payment__c> lstStuPays = new List<student_payment__c>();
        
        student_payment__c lstStuPay = new student_payment__c();
         lstStuPay.Contact__c = conObj.Id;
        lstStuPay.Payment_Gateway__c = 'Paytm';
        lstStuPay.Payment_Status__c = 'Success';
        lstStuPay.Fee_Type__c = 'Application Fee';
        lstStuPay.Mode_of_Payment__c = 'Online';
        lstStuPay.Amount__c = 15;
         insert lstStuPay;
        lstStuPays.add(lstStuPay);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //Call the handler
        Test.startTest();
      
        StudentPaymentTriggerHandler.updateApplicationFeeStatus(lstStuPays);

        Test.stopTest();
        
    }
    
     @isTest
    static void testCalculatePAFPaidAmount() {
        // Create test data for Student_Fee__c
        Contact testContact1 = new Contact(LastName = 'Test', FirstName = 'Student1');
        Contact testContact2 = new Contact(LastName = 'Test', FirstName = 'Student2');
        insert new List<Contact>{testContact1, testContact2};

        Student_Fee__c fee1 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Provisional_Admission_Fee__c = 1000,
            Fee_type__c = 'University Fee'
        );
        Student_Fee__c fee2 = new Student_Fee__c(
            Contact__c = testContact1.Id,
            Provisional_Admission_Fee__c = 2000,
            Fee_type__c = 'University Fee'
        );
        Student_Fee__c fee3 = new Student_Fee__c(
            Contact__c = testContact2.Id,
            Provisional_Admission_Fee__c = 1500,
            Fee_type__c = 'University Fee'
        );
        insert new List<Student_Fee__c>{fee1, fee2, fee3};

        // Create test data for Student_Payment__c
        Student_Payment__c payment1 = new Student_Payment__c(
            Contact__c = testContact1.Id,
            Amount__c = 3000,
            Fee_Type__c = 'University Fee',
            Payment_Status__c = 'Success'
        );
        Student_Payment__c payment2 = new Student_Payment__c(
            Contact__c = testContact2.Id,
            Amount__c = 1500,
            Fee_Type__c = 'University Fee',
            Payment_Status__c = 'Success'
        );
        insert new List<Student_Payment__c>{payment1, payment2};

        // Invoke the method under test
        Set<Id> conIdSet = new Set<Id>{testContact1.Id, testContact2.Id};
        Map<Id, Boolean> result = StudentPaymentTriggerHandler.calculatePAFPaidAmount(conIdSet);

   }

    /************************************************************/
   /* @isTest
    public static void handlebilldeskPayments() {
        
        String enteredCouponCode = 'REVA1234';
        List<Contact> conList = [Select id, FirstName, LastName, Email From Contact WHERE createddate = LAST_WEEK];
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'jun@gmail.com'];
        
        Coupon__c coupn = [Select id From Coupon__c Where Coupon_Code__c = :enteredCouponCode];
        
        hed__Application__c updateApplication = [Select id, Applied_Coupon__c From hed__Application__c 
                                                 Where hed__Applicant__c =:con.Id Limit 1];
        
        
        updateApplication.Applied_Coupon__c = coupn.Id;
        update updateApplication;
        
        
        
        List<student_payment__c> lstStuPay1 = [select Cheque_Bank_Name__c,ChequeDD_Date__c,ChequeDD_Number__c,ChequeDD_Realisation_Date__c,Mode_of_Payment__c,Payment_Date__c,Reference_Number__c,Payment_Mode_Type__c, id,Payment_Gateway__c,Amount__c, Transaction_Id__c,Payment_Status__c,Contact__r.Application_fee_paid__c,Contact__r.Application_Number__c,
                                               Contact__r.Name,Contact__r.Email,Fee_Type__c from student_payment__c Where (Payment_Gateway__c='Billdesk' or Payment_Gateway__c='RazorPay' or Payment_Gateway__c= 'Paytm' or Payment_Gateway__c= 'Eazypay')];
        
        Map<Id, Student_Payment__c> oldPayMap = new Map<Id, Student_Payment__c>();
        for(student_payment__c sp : lstStuPay1){
            oldPayMap.put(sp.Id, sp);
            sp.Payment_Status__c = 'Success';
        }
        update lstStuPay1;
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        //Call the handler
        Test.startTest();
        StudentPaymentTriggerHandler.handlePaymentUpdates(lstStuPay1,oldPayMap);
        // StudentPaymentTriggerHandler.updateApplicationFeeStatus(lstStuPay1);
        StudentPaymentTriggerHandler.updateCouponCount(conList);
        OfflinePaymentIntiated.handleDelete(lstStuPay1);
        OfflinePaymentIntiated.HandleUpdate(lstStuPay1,oldPayMap);
        OfflinePaymentIntiated.createStudentFeePayments(lstStuPay1);
        Test.stopTest();
        
        List<student_payment__c> lstStuPayAssert = [select id,Payment_Gateway__c,Transaction_Id__c,Payment_Status__c,Contact__r.Application_fee_paid__c,Contact__r.Application_Number__c,Contact__r.Name,Contact__r.Email,Fee_Type__c from student_payment__c Where Payment_Gateway__c='Billdesk' Limit 1];
        system.assertEquals('Success', lstStuPayAssert[0].Payment_Status__c);
    } */
    /*********************checkk***************************************/
    
 @isTest
public static void handlebilldeskPAFPayments() {
    // Create test data
    Contact testContact = new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'jun1@gmail.com',
        Application_Number__c = 'APP12345',
        Country_Code__c = 'India (+91)',
        MobilePhone = '+91-9876543210'
    );
    insert testContact;

    List<Contact> conList = [Select id, Application_Number__c, Country_Code__c, FirstName, LastName, Email, Name, MobilePhone, owner.name, OwnerId, Owner.MobilePhone From Contact];
    System.debug('Contacts: ' + conList);

    // Create Student Payment records
    Student_Payment__c payment1 = new Student_Payment__c(
        Contact__c = testContact.Id,
        Amount__c = 10000,
        Payment_Gateway__c = 'Billdesk',
        Payment_Status__c = 'Failed',
        Fee_Type__c = 'Tuition Fee',
        Mode_of_Payment__c = 'Online'
    );
    insert payment1;

    List<student_payment__c> lstStuPay1 = [select Cheque_Bank_Name__c,ChequeDD_Date__c,ChequeDD_Number__c,ChequeDD_Realisation_Date__c,Payment_Date__c,Reference_Number__c,Payment_Mode_Type__c, id,Amount__c, Mode_of_Payment__c,Payment_Gateway__c,Transaction_Id__c,Payment_Status__c,
                                           Contact__r.Application_Number__c,contact__c,Contact__r.Application_fee_paid__c,
                                           Contact__r.Name,Contact__r.Email,Fee_Type__c from student_payment__c 
                                           Where (Payment_Gateway__c='Billdesk' or Payment_Gateway__c='RazorPay' or Payment_Gateway__c= 'Paytm' or Payment_Gateway__c= 'Eazypay')];

    Map<Id, Student_Payment__c> oldPayMap = new Map<Id, Student_Payment__c>();
    Set<Id> stupayset = new Set<Id>();
    for(student_payment__c sp : lstStuPay1){
        oldPayMap.put(sp.Id, sp);
        stupayset.add(sp.Id);
    }

    Test.setMock(HttpCalloutMock.class, new RestMock());

    // Call the handler
    Test.startTest();
    StudentPaymentTriggerHandler.handlePaymentUpdates(lstStuPay1, oldPayMap);
    OfflinePaymentIntiated.handleDelete(lstStuPay1);
    OfflinePaymentIntiated.HandleUpdate(lstStuPay1, oldPayMap);
    OfflinePaymentIntiated.createStudentFeePayments(lstStuPay1);

    // Use specific payment Ids in the set
    Set<Id> specificStuPaySet = new Set<Id>{payment1.Id};
    
    StudentPaymentTriggerHandler.sendApplicationNumber(conList, specificStuPaySet);
    StudentPaymentTriggerHandler.sendSMSAndWhatstapp(conList, specificStuPaySet, 'resetlinknew2', 'Reset_Password_for_Application_Portal');
    StudentPaymentTriggerHandler.sendSMSAndWhatstapp(conList, specificStuPaySet, 'admissionfeeconfirmation', 'Payment_Confirmation');
    StudentPaymentTriggerHandler.sendSMSAndWhatstapp(conList, specificStuPaySet, 'paymentconfirmation1_copy1', 'Partial_Payment_Confirmation');
    try{
      //  StudentPaymentTriggerHandler.sendSMSAndWhatstapp(conList, specificStuPaySet, 'payment_reject_student', 'Payment_Confirmation');        
    }catch(Exception e){
        System.debug('Caught Exception: ' + e.getMessage());
    }
    Test.stopTest();
}

    
    @istest
    public static void HandleUpdate(){
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Admission_Mode__c = 'UQ',
            Fee_Paid_at_University__c = 5000
        );
        insert testContact;
        Student_Payment__c student=new Student_Payment__c();
        student.Contact__c=testContact.id;     
        student.Fee_Type__c='University Fee';
        student.Payment_Status__c='Success';
        insert student;
        Student_Payment__c student2=new Student_Payment__c();
        student2.Contact__c=testContact.id;
        student2.Fee_Type__c='University Fee';
        student2.Payment_Status__c='Failed';
        insert student2;
        Student_Payment__c student1=new Student_Payment__c();
        student1.Contact__c=testContact.id;
        student1.Payment_Status__c='Pending';
        
        List<Student_Payment__c> newPayments=new List<Student_Payment__c>();
        newPayments.add(student);
        
        Student_Fee__c stuFee12 = new Student_Fee__c();
        stuFee12.contact__c = testContact.Id;
        stuFee12.Fee_Year__c = '1st Year';
        stuFee12.Name = 'University Fee 1st year';
        stuFee12.Amount__c = 100;
        stuFee12.Fee_Type__c =  'University Fee';
        stuFee12.Provisional_Admission_Fee__c = 1000;
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

        // Call the method to be tested 
        Test.startTest();
        OfflinePaymentIntiated.handleDelete(new List<Student_Payment__c>{deletedPayment});
        Test.stopTest();

        // Query for the specific hed__Application__c record again
        hed__Application__c updatedApplication = [SELECT Offline_Payment_Initiated__c FROM hed__Application__c WHERE Id = :testApplication.Id LIMIT 1];

        // Verify the results
        System.assertEquals(false, updatedApplication.Offline_Payment_Initiated__c, 'Application should have Offline_Payment_Initiated__c set to true');
    }

    @isTest
    static void handlingtestData() {

        Profile p = [select Id,name from Profile where Name ='Counselor' limit 1];       
        User newUser1 = new User(
             profileId = p.Id,
             username = 'newUsertesting@epeople.com',
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
        // Account program= new Account(
        //     Name = 'Bachelor of Architecture',
        //     // RecordTypeId = academicProgramRT.Id,    
        //     Program_Alias__c = 'Barch',
        //     Program_Type__c = 'UG',
        //     Program_Code__c = 'RA',
        //     Intake__c = 80,
        //     Intake_Per_Section__c = 40
        // );
        // insert program;
        List<Contact> lstCon =new List<Contact>();
        Contact conObj3 = new Contact();
            conObj3.FirstName = 'John1';
            conObj3.LastName = 'Doe1';
            conObj3.Email = 'jun12@gmail.com';
            conObj3.Application_Fee_Paid__c = true;
            conObj3.MobilePhone = '+91-9876543210';
            conObj3.Country_Code__c = 'India (+91)';
            conObj3.Application_Number__C = '98653214712';
            // conObj3.RecordTypeId = conRecId;
            conObj3.OwnerId = newUser1.Id;
            // conObj2.Quota__c = 'Management Quota';
            // conObj2.Enrollment_Type__c = 'Regular Entry';
            // conObj2.Admission_Mode__c = 'UQ';
            // insert conObj2;
            lstCon.add(conObj3);
    
            insert lstCon;
    
            Student_Payment__c stuPayt3 = new Student_Payment__c();
            stuPayt3.Contact__c = conObj3.Id;
            stuPayt3.Payment_Gateway__c = 'RazorPay';
            stuPayt3.Payment_Status__c = 'Pending';
            stuPayt3.Fee_Type__c = 'University Fee, Tuition Fee';
            stuPayt3.Mode_of_Payment__c = 'Online';
            stuPayt3.Amount__c = 10;
            
            Student_Fee__c stuFee13 = new Student_Fee__c();
            stuFee13.contact__c = conObj3.Id;
            stuFee13.Fee_Year__c = '1st Year';
            stuFee13.Name = 'University Fee 1st year';
            stuFee13.Amount__c = 1500;
            stuFee13.Fee_Type__c =  'University Fee';
            stuFee13.Provisional_Admission_Fee__c = 1000;
            //insert stuFee10;

    
            Student_Fee__c stuFee15 = new Student_Fee__c();
            stuFee15.contact__c = conObj3.Id;
            stuFee15.Fee_Year__c = '1st Year';
            stuFee15.Name = 'Tuition Fee 1st year';
            stuFee15.Amount__c = 100;
            stuFee15.Fee_Type__c =  'Tuition Fee';
            stuFee15.Provisional_Admission_Fee__c = 1000;
           // insert stuFee11;
    
            Student_Fee__c stuFee16 = new Student_Fee__c();
            stuFee16.contact__c = conObj3.Id;
            stuFee16.Fee_Year__c = '2nd Year';
            stuFee16.Name = 'University Fee 2nd year';
            stuFee16.Amount__c = 900;
            stuFee16.Fee_Type__c =  'University Fee';
            stuFee16.Provisional_Admission_Fee__c = 1000;

            Student_Fee__c stuFee14 = new Student_Fee__c();
            stuFee14.contact__c = conObj3.Id;
            stuFee14.Fee_Year__c = '1st Year';
            stuFee14.Name = 'University Fee 1st year';
            stuFee14.Amount__c = 100;
            stuFee14.Fee_Type__c =  'University Fee';
            stuFee14.Provisional_Admission_Fee__c = 1000;
           // insert stuFee12;

           Student_Fee_Payment__c stpp=new Student_Fee_Payment__c();
           stpp.Student_Fee__c=stuFee14.id;
           stpp.Student_Payment__c=stuPayt3.Id;
           insert stpp;

            insert new List<Student_Fee__c>{stuFee13, stuFee14, stuFee15, stuFee16};
            List<Contact> conList = [Select id, Application_Number__c, Country_Code__c, FirstName, LastName, Email, Name, MobilePhone, owner.name, OwnerId, Owner.MobilePhone From Contact];
            List<student_payment__c> lstStuPay = [select Cheque_Bank_Name__c,ChequeDD_Date__c,ChequeDD_Number__c,ChequeDD_Realisation_Date__c,Mode_of_Payment__c,Payment_Date__c,Reference_Number__c,Payment_Mode_Type__c, id,Payment_Gateway__c,Amount__c, Transaction_Id__c,Payment_Status__c,Contact__r.Application_fee_paid__c,Contact__r.Application_Number__c,
            Contact__r.Name,Contact__r.Email,Fee_Type__c from student_payment__c Where (Payment_Gateway__c='Billdesk' or Payment_Gateway__c='RazorPay' or Payment_Gateway__c= 'Paytm' or Payment_Gateway__c= 'Eazypay')];

            Map<Id, Student_Payment__c> oldPaymentMap = new Map<Id, Student_Payment__c>();
            for(student_payment__c s : lstStuPay){
                oldPaymentMap.put(s.Id, s);
                if(s.Payment_Status__c == 'Pending'){
                    s.Payment_Status__c = 'Success';
                } else {
                    s.Payment_Status__c = 'Pending';
                }
            }
            system.debug('vvv'+oldPaymentMap);
            update lstStuPay;
            
            
            Test.setMock(HttpCalloutMock.class, new RestMock());
            
            //Call the handler
            Test.startTest();
            StudentPaymentTriggerHandler.handlePaymentUpdates(lstStuPay,oldPaymentMap);
           // StudentPaymentTriggerHandler.updateApplicationFeeStatus(lstStuPay);
            StudentPaymentTriggerHandler.updateCouponCount(conList);
            OfflinePaymentIntiated.handleDelete(lstStuPay);
            OfflinePaymentIntiated.HandleUpdate(lstStuPay,oldPaymentMap);
            OfflinePaymentIntiated.createStudentFeePayments(lstStuPay);
            Test.stopTest();
            
    }
    
    /*************************************/
   // @testSetup
  static void setupTestData() {
        // Set up test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        User testUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'test@example.com',
            MobilePhone = '+91-9876543210',
            OwnerId = testUser.Id,
            Country_Code__c = 'India (+91)',
            Application_Number__c = 'APP12345'
        );
        insert testContact;
        
        Student_payment__c testPayment = new Student_payment__c(
            Contact__c = testContact.Id,
            Amount__c = 1000,
            Payment_Mode_Type__c = 'Online',
            Fee_Type__c = 'Admission Fee',
            payment_status__c = 'Success'
        );
        insert testPayment;
    }

    @isTest
    static void testSendSMSAndWhatsapp() {
        // Retrieve test data
        Contact testContact = [SELECT Id, MobilePhone, Country_Code__c, Application_Number__c, Name, Email, Owner.Name, Owner.MobilePhone FROM Contact LIMIT 1];
        Student_payment__c testPayment = [SELECT Id, Amount__c, Contact__c FROM Student_payment__c WHERE Contact__c = :testContact.Id LIMIT 1];
        
        // Use an existing Domain record
        Domain testDomain = [SELECT Domain FROM Domain WHERE HttpsOption = 'CommunityAlt' LIMIT 1];

        // Set up parameters for the method
        List<Contact> conRecs = new List<Contact>{testContact};
        Set<Id> stuPaySet = new Set<Id>{testPayment.Id};
        String whatsappTemplateName = 'admissionpaymentlink';
       
        String smsType = 'Admission_Payment_Link';

        // Retrieve existing WhatsApp Notification Template Metadata
        List<WhatsApp_Notification_Template__mdt> templateMetadata = [SELECT Template_Field__c , Template_ID__c FROM WhatsApp_Notification_Template__mdt WHERE Template_ID__c = :whatsappTemplateName ];

        // Start test
        Test.startTest();
        
        // Set the mock callout
        RestMock mock = new RestMock();
        Test.setMock(HttpCalloutMock.class, mock);

        // Call the method
        StudentPaymentTriggerHandler.sendSMSAndWhatstapp(conRecs, stuPaySet, whatsappTemplateName, smsType);
       
        Test.stopTest();

        // Assert the results
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assert(!jobs.isEmpty(), 'Queueable job should be enqueued');

        // Add more assertions as needed to verify the method's behavior
    }
    
    /****************************************/
    
   
}