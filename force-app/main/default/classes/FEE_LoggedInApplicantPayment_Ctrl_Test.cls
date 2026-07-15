@isTest
public class FEE_LoggedInApplicantPayment_Ctrl_Test {
    
    public static final String CONST_APPLICANT_RECTYPE = 'Applicant';
    
    
    @isTest
    public static void StudentFeeMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
        adminUser.UserRoleId = userRole.Id;
        //update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            Id ApplicantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = ApplicantRecId;
            objCon.AccountId = objAcc.Id;
            objCon.Application_Number__c = 'test123';
            objCon.SRN_Number__c ='123';
            objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objCon.Nationality__c ='Indian';
            objCon.Admission_Mode__c='DCET';
            Insert objCon; 
            System.debug('objCon'+objCon);
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objCon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            Fee_Payment_Criteria__c refPay = FEE_TestDataFactory.createFeePaymentCriteria('University Fee','Full Payment');
            refPay.Merchant_ID_Billdesk__c ='MIDB232323';
            refPay.Merchant_ID_Eazypay__c ='MIDE121212';
            refPay.Merchant_ID_Paytm__c ='MIDP343434';
            refPay.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert refPay;
            
            hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
            Insert objProgenroll;
            
            Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee.Amount__c = 50000;
            objStudentFee.Amount_Pending__c=50000;
            objStudentFee.Amount_Paid__c=0;
            objStudentFee.Contact__c = objCon.id;
            objStudentFee.Fee_Year__c = '1st Year';
            objStudentFee.Fee_Type__c = 'University Fee';
            objStudentFee.Provisional_Admission_Fee__c = 15000;
            objStudentFee.Due_Date__c = system.today() - 1;
            objStudentFee.Fee_Payment_Criteria__c = refPay.Id;
            Insert objStudentFee;
            
            Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee1.Amount__c = 50000;
            objStudentFee1.Amount_Pending__c=50000;
            objStudentFee1.Amount_Paid__c=0;
            objStudentFee1.Contact__c = objCon.id;
            objStudentFee1.Fee_Year__c = '1st Year';
            objStudentFee1.Fee_Type__c = 'Tuition Fee';
            objStudentFee1.Provisional_Admission_Fee__c = 15000;
            objStudentFee1.Number_of_Installments__c = 4;
            objStudentFee1.Due_Date__c = system.today() - 1;
            Insert objStudentFee1;
            
            Student_Fee__c objStudentFee3 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee3.Amount__c = 50000;
            objStudentFee3.Amount_Pending__c= 0;
            objStudentFee3.Amount_Paid__c=50000;
            objStudentFee3.Contact__c = objCon.id;
            objStudentFee3.Fee_Year__c = '1st Year';
            objStudentFee3.Fee_Type__c = 'University Fee';
            objStudentFee3.Provisional_Admission_Fee__c = 15000;
            objStudentFee3.Due_Date__c = system.today() - 1;
            objStudentFee3.Number_of_Installments__c = 3;
            objStudentFee3.Paid_Installments__c = 1;
            Insert objStudentFee3;
            
            list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
            lst_stufee.add(objStudentFee1);
            
            //Student_Fee__c objStudentFee2 = [Select Id, Amount_Pending__c, Amount_Paid__c from Student_Fee__c Where Id = : objStudentFee.Id];
            //objStudentFee2.Amount_Paid__c = 50000;
            //objStudentFee2.Amount_Pending__c = 0;
            //Update objStudentFee2;
            
            Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment.Payment_Status__c ='Pending';
            objStuPayment.Mode_of_Payment__c ='Online';
            objStuPayment.Payment_Mode_Type__c ='Online';
            insert objStuPayment;
            
            Student_Payment__c objStuPayment1 = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment1.Payment_Status__c ='Success';
            insert objStuPayment1;
            
            // Create a test Student_Fee_Payment__c record associated with the test Student_Payment__c record
            Student_Fee_Payment__c testFeePayment = new Student_Fee_Payment__c();
            testFeePayment.Amount__c=6000;
            testFeePayment.Student_Payment__c=objStuPayment.Id;
            testFeePayment.Student_Fee__c = objStudentFee1.Id;
            testFeePayment.Line_Item_Payment_Status__c = 'Pending';
            insert testFeePayment;
            
            Student_Fee_Payment__c testFeePayment1 = new Student_Fee_Payment__c();
            testFeePayment1.Amount__c=6000;
            testFeePayment1.Student_Payment__c=objStuPayment.Id;
            testFeePayment1.Student_Fee__c = objStudentFee1.Id;
            testFeePayment1.Line_Item_Payment_Status__c = 'Success';
            insert testFeePayment1;

            list<Student_Fee_Payment__c> lst_stufeePay = new list<Student_Fee_Payment__c>();
            lst_stufeePay.add(testFeePayment);
            lst_stufeePay.add(testFeePayment1);
            
            
            FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = objStudentFee;
            list<FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_LoggedInApplicantPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_LoggedInApplicantPayment_Ctrl.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(objStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =10000;
            
            FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper checkWrap1 = new FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper();
            checkWrap1.ObjStuFeeDeatils = objStudentFee3;
            list<FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper> lst_Checkwrap1 = new list<FEE_LoggedInApplicantPayment_Ctrl.CheckboxWrapper>();
            lst_Checkwrap1.add(checkWrap1);
            
            FEE_LoggedInApplicantPayment_Ctrl.razorPayRequestCall reswrap = new FEE_LoggedInApplicantPayment_Ctrl.razorPayRequestCall();
            reswrap.ramount =10000;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
            reswrap.reminder_enable =true;
            
            String myJSON = JSON.serialize(reswrap); 
            
            Razorpay_Details__c paydetails = new Razorpay_Details__c();
            paydetails.Value__c='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
            paydetails.Name='Applicant_CallbackUrl';
            insert paydetails;
            
            Razorpay_Details__c paydetails1 = new Razorpay_Details__c();
            paydetails1.Value__c='vdcSuL82zafd9GnXnfyzUIuK';
            paydetails1.Name='Password';
            insert paydetails1;
            
            Razorpay_Details__c paydetails2 = new Razorpay_Details__c();
            paydetails2.Value__c='https://api.razorpay.com/v1/payment_links';
            paydetails2.Name='Razorpay Endpoint';
            insert paydetails2;
            
            Razorpay_Details__c paydetails3 = new Razorpay_Details__c();
            paydetails3.Value__c='rzp_test_JA1KlDGzmvG6Hh';
            paydetails3.Name='UserName';
            insert paydetails3;
            
            FEE_LoggedInApplicantPayment_Ctrl.razorpayResponseCall rescall = new FEE_LoggedInApplicantPayment_Ctrl.razorpayResponseCall();
            rescall.reference_id = Utility.generateRandomNumber();
            rescall.short_url ='ep';
            rescall.status = 'Success'; 
            rescall.statusCode =200;
            
            Paytm_Details__c PayDet = new Paytm_Details__c();
            PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
            PayDet.Name ='CallbackUrl';
            insert PayDet;
            
            Paytm_Details__c PayDet1 = new Paytm_Details__c();
            PayDet1.Value__c ='RevaUn85385305140219';
            PayDet1.Name ='MID';
            insert PayDet1;
            
            Paytm_Details__c PayDet2 = new Paytm_Details__c();
            PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
            PayDet2.Name ='Merchant Key';
            insert PayDet2;
            
            Paytm_Details__c PayDet3 = new Paytm_Details__c();
            PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
            PayDet3.Name ='Endpoint';
            insert PayDet3;
            hed__Application__c hedapp=new hed__Application__c();
            hedapp.hed__Applicant__c=objCon.id;
            insert hedapp;
                        
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.class, new razorPayMock());
            date schDate = system.today();        
            FEE_LoggedInApplicantPayment_Ctrl.displayApplicantFeeRecords();
            FEE_LoggedInApplicantPayment_Ctrl.fetchApplicationFeeRecords(objStudentFee.id);
            FEE_LoggedInApplicantPayment_Ctrl.MultiStduentFeeRecords(lst_stufee);
            FEE_LoggedInApplicantPayment_Ctrl.razorpayGeneratePaymentLink(lst_stufee,Amount,'single');
            FEE_LoggedInApplicantPayment_Ctrl.ValidateMultiPayments(lst_stufee);
            FEE_LoggedInApplicantPayment_Ctrl.displayUpdatedApplicantFeeRecords();
            FEE_LoggedInApplicantPayment_Ctrl.ValidateUpdatedMultiPayments(lst_stufeePay);
            FEE_LoggedInApplicantPayment_Ctrl.MultiUpdatedStduentFeePayRecords(lst_stufeePay);
            test.stoptest();
            
        }
    }
    
    
    public static  testmethod void StudentFeeMethod1()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Number__c = 'test123';
        objCon.SRN_Number__c ='123';
        objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objCon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        list<Contact> lst_Con = new list<Contact>();
        lst_Con.add(objCon);
        
        Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
        User testUser = new User(
            profileId = p.Id,
            username = 'newUser@epeople.com',
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lal Baburao',
            contactId = objCon.id
            
        );
        insert testUser;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        insert objStuPayment;
        
        
        
        FEE_StudentPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_StudentPayment_Ctrl.CheckboxWrapper();
        checkWrap.ObjStuFeeDeatils = objStudentFee;
        list<FEE_StudentPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_StudentPayment_Ctrl.CheckboxWrapper>();
        lst_Checkwrap.add(checkWrap); 
        
        FEE_StudentPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_StudentPayment_Ctrl.StudentFeeWrapper(); 
        stuwrap.lst_StuPaidDetails.add(objStudentFee1);
        stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
        decimal Amount =10000;
        
        FEE_StudentPayment_Ctrl.razorPayRequestCall reswrap = new FEE_StudentPayment_Ctrl.razorPayRequestCall();
        reswrap.ramount =10000;
        reswrap.callback_method ='get';
        reswrap.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
        reswrap.reminder_enable =true;
        
        String myJSON = JSON.serialize(reswrap); 
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='BD9CHILD1';
        paydetails.Name='Academic Fee';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetails1 = new Billdesk_Merchant_Details__c();
        paydetails1.MerchantId__c='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
        paydetails1.Name='CallbackUrl';
        insert paydetails1;
        
        Billdesk_Merchant_Details__c applicantCallbackUrl = new Billdesk_Merchant_Details__c();
        applicantCallbackUrl.Name = 'Applicant_BillDesk_CallbackUrl';
        applicantCallbackUrl.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
        insert applicantCallbackUrl;
        
        Billdesk_Merchant_Details__c paydetails2 = new Billdesk_Merchant_Details__c();
        paydetails2.MerchantId__c='uatY7vF4Cx3L';
        paydetails2.Name='Checksum';
        insert paydetails2;
        
        Billdesk_Merchant_Details__c paydetails3 = new Billdesk_Merchant_Details__c();
        paydetails3.MerchantId__c='BD9CHILD2';
        paydetails3.Name='Hostel Fee';
        insert paydetails3;
        
        Billdesk_Merchant_Details__c paydetails4 = new Billdesk_Merchant_Details__c();
        paydetails4.MerchantId__c='BD9MAIN';
        paydetails4.Name='MainMerchant';
        insert paydetails4;
        
        Billdesk_Merchant_Details__c paydetails5 = new Billdesk_Merchant_Details__c();
        paydetails5.MerchantId__c='BD9CHILD3';
        paydetails5.Name='Miscellaneous Fee';
        insert paydetails5;
        
        Billdesk_Merchant_Details__c paydetails6 = new Billdesk_Merchant_Details__c();
        paydetails6.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
        paydetails6.Name='PaymentEndPoint';
        insert paydetails6;
        
        Billdesk_Merchant_Details__c paydetails7 = new Billdesk_Merchant_Details__c();
        paydetails7.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
        paydetails7.Name='PaymentLink';
        insert paydetails7;
        
        Billdesk_Merchant_Details__c paydetails8 = new Billdesk_Merchant_Details__c();
        paydetails8.MerchantId__c='BD9CHILD4';
        paydetails8.Name='Transportation Fee';
        insert paydetails8;
        
        Billdesk_Merchant_Details__c paydetails9 = new Billdesk_Merchant_Details__c();
        paydetails9.MerchantId__c='BD9CHILD4';
        paydetails9.Name='SecurityId';
        insert paydetails9;
        
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='https://eazypayuat.icicibank.com/EazyPG?';
        easypaydetails.name ='EndPoint';
        insert easypaydetails;
        
        EasyPay_Details__c EDetails = new EasyPay_Details__c();
        EDetails.Value__c ='45?';
        EDetails.name ='Submerchantid';
        insert EDetails;
        
        EasyPay_Details__c EpDetails = new EasyPay_Details__c();
        EpDetails.Value__c ='131966';
        EpDetails.name ='ICID';
        insert EpDetails;
        
        EasyPay_Details__c EAeDetails = new EasyPay_Details__c();
        EAeDetails.Value__c ='1311140119601518';
        EAeDetails.name ='AES key';
        insert EAeDetails;
        
        EasyPay_Details__c EDetailsUrl = new EasyPay_Details__c();
        EDetailsUrl.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/EasyPayResponse';
        EDetailsUrl.name ='CallbackUrl';
        insert EDetailsUrl;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
        insert PayDet;
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
        PayDet3.Name ='Endpoint';
        insert PayDet3;
        
        FEE_StudentPayment_Ctrl.paymentDetails wrapdetail = new FEE_StudentPayment_Ctrl.paymentDetails();
        wrapdetail.value =string.valueof(Amount);
        wrapdetail.ccurrency ='INR';
        
        FEE_StudentPayment_Ctrl.UserDetails usrWrap = new FEE_StudentPayment_Ctrl.UserDetails();
        usrWrap.custId = objCon.Application_Number__c; 
        
        FEE_StudentPayment_Ctrl.PaytmParamClass wrappay = new FEE_StudentPayment_Ctrl.PaytmParamClass();
        wrappay.requestType ='Payment';
        wrappay.mid =PayDet1.Value__c;
        wrappay.websiteName ='WEBSTAGING';
        wrappay.callbackUrl =PayDet.Value__c;
        wrappay.txnAmount =wrapdetail;
        wrappay.userInfo =usrWrap;
        
        FEE_StudentPayment_Ctrl.paytmMain payWrap = new FEE_StudentPayment_Ctrl.paytmMain(); 
        payWrap.body =wrappay;
        
        String myJSON1 = JSON.serialize(reswrap); 
        
        /* FEE_LoggedInApplicantPayment_Ctrl.calculateAes CalSum=new FEE_LoggedInApplicantPayment_Ctrl.calculateAes();
CalSum.Key = EAeDetails.Value__c;
CalSum.decode='Decode';*/
        
        Test.Starttest();
        Test.setMock(HttpCalloutMock.class, new billdeskMock()); 
        FEE_LoggedInApplicantPayment_Ctrl.BillDeskPayGenratePaymentLink(lst_stufee,Amount,'single');
        //FEE_LoggedInApplicantPayment_Ctrl.easypayGenratePaymentLink(lst_stufee,Amount,'single');
        test.stoptest();
    }  
    @isTest
    public static void PaytmMethod()
    {
        try{
            string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            UserRole userrole = [Select Id,Name, DeveloperName From UserRole where Name='Admin Role' Limit 1];
            string userId = userinfo.getUserId();
            User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
            adminUser.UserRoleId = userRole.Id;
            update adminUser;
            
            User newUser1 = new user();
            contact objCon = new contact();
            
            system.runAs(adminUser){    
                Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
                objAcc.Recordtypeid = HouseholdRecId;
                Insert objAcc;
                
                string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
                objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
                objCon.FirstName='test';
                objCon.LastName='testing';
                objCon.MobilePhone ='9090909090';
                objCon.Aadhar_Card_Number__c ='098765435612';
                objCon.RecordTypeId = StudentRecId;
                objCon.AccountId = objAcc.Id;
                objCon.Application_Number__c = 'test123';
                objCon.SRN_Number__c ='123';
                objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
                objCon.Nationality__c ='Indian';
                Insert objCon; 
                
                Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
                system.debug('p '+p);
                newUser1 = new User(
                    profileId = p.Id,
                    username = 'newUser@epeople.com',
                    email = 'pb@f.com',
                    emailencodingkey = 'UTF-8',
                    localesidkey = 'en_US',
                    languagelocalekey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    alias='nuser',
                    lastname='lastname',
                    contactId = objCon.id
                    //   UserRoleId = userrole.Id
                );
                insert newUser1;
            }
            system.runAs(newUser1){        
                Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
                objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
                objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
                objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
                objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
                Insert objFeeCriteria;
                
                hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
                Insert objProgenroll;
                
                Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
                objStudentFee.Amount__c = 50000;
                objStudentFee.Amount_Pending__c=40000;
                objStudentFee.Amount_Paid__c=10000;
                objStudentFee.Contact__c = objCon.id;
                objStudentFee.Due_Date__c = system.today() - 1;
                Insert objStudentFee;
                
                Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
                objStudentFee1.Amount__c = 50000;
                objStudentFee1.Amount_Pending__c=0;
                objStudentFee1.Amount_Paid__c=50000;
                objStudentFee1.Contact__c = objCon.id;
                objStudentFee1.Due_Date__c = system.today() - 1;
                Insert objStudentFee1;
                
                list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
                lst_stufee.add(objStudentFee1);
                
                Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
                objStuPayment.Payment_Status__c ='Success';
                objStuPayment.Reference_Id__c='123';
                insert objStuPayment;
                
                
                FEE_StudentPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_StudentPayment_Ctrl.CheckboxWrapper();
                checkWrap.ObjStuFeeDeatils = objStudentFee;
                list<FEE_StudentPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_StudentPayment_Ctrl.CheckboxWrapper>();
                lst_Checkwrap.add(checkWrap); 
                
                FEE_StudentPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_StudentPayment_Ctrl.StudentFeeWrapper(); 
                stuwrap.lst_StuPaidDetails.add(objStudentFee1);
                stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
                decimal Amount =10000;
                
                FEE_StudentPayment_Ctrl.razorPayRequestCall reswrap = new FEE_StudentPayment_Ctrl.razorPayRequestCall();
                reswrap.ramount =10000;
                reswrap.callback_method ='get';
                reswrap.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
                reswrap.reminder_enable =true;
                
                String myJSON = JSON.serialize(reswrap); 
                
                Paytm_Details__c PayDet = new Paytm_Details__c();
                PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
                PayDet.Name ='Applicant_Paytm_CallbackUrl';
                insert PayDet;
                
                Paytm_Details__c PayDet1 = new Paytm_Details__c();
                PayDet1.Value__c ='RevaUn85385305140219';
                PayDet1.Name ='MID';
                insert PayDet1;
                
                Paytm_Details__c PayDet2 = new Paytm_Details__c();
                PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
                PayDet2.Name ='Merchant Key';
                insert PayDet2;
                
                Paytm_Details__c PayDet3 = new Paytm_Details__c();
                PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
                PayDet3.Name ='Endpoint';
                insert PayDet3;
                
                Paytm_Details__c Pd1 = new Paytm_Details__c();
                Pd1.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse/apex/ApplicationFeePaytmResponse';
                Pd1.Name ='Applicant_Paytm_CallbackUrl';
                insert Pd1;
                
                FEE_StudentPayment_Ctrl.resResultInfoDetails rsInfo = new FEE_StudentPayment_Ctrl.resResultInfoDetails();
                rsInfo.resultCode='0002';
                rsInfo.resultMsg='';
                rsInfo.resultStatus='';
                
                FEE_StudentPayment_Ctrl.resBodyDetails resDet = new FEE_StudentPayment_Ctrl.resBodyDetails();
                resDet.resultInfo = rsInfo;
                resDet.txnToken ='123';
                resDet.isPromoCodeValid =false;
                resDet.authenticated=false; 
                
                FEE_StudentPayment_Ctrl.resHeadDetails headres = new FEE_StudentPayment_Ctrl.resHeadDetails();
                headres.responseTimestamp ='test';
                headres.version='1.0';
                headres.signature='test';
                
                FEE_StudentPayment_Ctrl.inisaliseResponse resin = new FEE_StudentPayment_Ctrl.inisaliseResponse();
                resin.body= resDet;
                resin.head = headres;
                
                Test.Starttest();
                Test.setMock(HttpCalloutMock.class, new razorPayMock());
                date schDate = system.today(); 
                FEE_LoggedInApplicantPayment_Ctrl.PaytmGeneratePaymentLink(lst_stufee,Amount,'single');
                test.stoptest();
            }
        }catch(exception ex)
        {
           system.debug('Error==>'+ex.getMessage()+' at line ==>'+ ex.getLinenumber());
        }
    }
    @isTest
    static void PaytmUpdatedGeneratePaymentLinktest() {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        decimal amount=5000.00;
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Number__c = 'test123';
        objCon.SRN_Number__c ='123';
        objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objCon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        list<Contact> lst_Con = new list<Contact>();
        lst_Con.add(objCon);
        
        Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
        User testUser = new User(
            profileId = p.Id,
            username = 'newUser@epeople.com',
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lal Baburao',
            contactId = objCon.id
            
        );
        insert testUser;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Pending';
        objStuPayment.Mode_of_Payment__c ='Online';
        objStuPayment.Contact__c=objCon.id;
        
        insert objStuPayment;
        
        Paytm_Details__c PayDet = new Paytm_Details__c();
        PayDet.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet.Name ='CallbackUrl';
        insert PayDet;
        
        Paytm_Details__c PayDet1 = new Paytm_Details__c();
        PayDet1.Value__c ='RevaUn85385305140219';
        PayDet1.Name ='MID';
        insert PayDet1;
        
        Paytm_Details__c PayDet2 = new Paytm_Details__c();
        PayDet2.Value__c ='e#!Un&#Rbo!&@Rlw';
        PayDet2.Name ='Merchant Key';
        insert PayDet2;
        
        Paytm_Details__c PayDet3 = new Paytm_Details__c();
        PayDet3.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
        PayDet3.Name ='Endpoint';
        insert PayDet3;
        
        Paytm_Details__c PayDet11 = new Paytm_Details__c();
        PayDet11.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
        PayDet11.Name ='Applicant_Paytm_CallbackUrl';
        insert PayDet11;
        Billdesk_Merchant_Details__c paydetails6 = new Billdesk_Merchant_Details__c();
        paydetails6.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
        paydetails6.Name='PaymentEndPoint';
        insert paydetails6;
        
        Paytm_Details__c PayDet122 = new Paytm_Details__c();
        PayDet122.Value__c ='RevaUn85385305140219';
        PayDet122.Name ='MID';
        insert PayDet122;
        
        FEE_StudentPayment_Ctrl.paymentDetails wrapdetail = new FEE_StudentPayment_Ctrl.paymentDetails();
        wrapdetail.value =string.valueof(Amount);
        wrapdetail.ccurrency ='INR';
        
        FEE_StudentPayment_Ctrl.UserDetails usrWrap = new FEE_StudentPayment_Ctrl.UserDetails();
        usrWrap.custId = objCon.Application_Number__c; 
        
        FEE_StudentPayment_Ctrl.PaytmParamClass wrappay = new FEE_StudentPayment_Ctrl.PaytmParamClass();
        wrappay.requestType ='Payment';
        wrappay.mid =PayDet1.Value__c;
        wrappay.websiteName ='WEBSTAGING';
        wrappay.callbackUrl =PayDet.Value__c;
        wrappay.txnAmount =wrapdetail;
        wrappay.userInfo =usrWrap;
        
        FEE_StudentPayment_Ctrl.paytmMain payWrap = new FEE_StudentPayment_Ctrl.paytmMain(); 
        payWrap.body =wrappay;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new razorPayMock());
        FEE_LoggedInApplicantPayment_Ctrl.razorpayResponseCall result= FEE_LoggedInApplicantPayment_Ctrl.PaytmUpdatedGeneratePaymentLink(objCon.Id, 10000, 'single');           
        Test.stopTest();
        
        
    }
    @isTest
    static void testEasypayUpdatedGenratePaymentLink() {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Number__c = 'test123';
        objCon.SRN_Number__c ='123';
        objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objCon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        list<Contact> lst_Con = new list<Contact>();
        lst_Con.add(objCon);
        
        Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
        User testUser = new User(
            profileId = p.Id,
            username = 'newUser@epeople.com',
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lal Baburao',
            contactId = objCon.id
            
        );
        insert testUser;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Fee_Payment_Criteria__c=objFeeCriteria.Id;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        Student_Fee__c objStudentFee2 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        
        insert objStuPayment;
        
        
        EasyPay_Details__c EpDetails = new EasyPay_Details__c();
        EpDetails.Value__c ='131966';
        EpDetails.name ='ICID';
        insert EpDetails;
        
        
        EasyPay_Details__c easypaydetails = new EasyPay_Details__c();
        easypaydetails.Value__c ='https://eazypayuat.icicibank.com/EazyPG?';
        easypaydetails.name ='EndPoint';
        insert easypaydetails;
        EasyPay_Details__c EDetailsUrl = new EasyPay_Details__c();
        EDetailsUrl.Value__c ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/EasyPayResponse';
        EDetailsUrl.name ='CallbackUrl';
        insert EDetailsUrl;
        
        EasyPay_Details__c EDetails = new EasyPay_Details__c();
        EDetails.Value__c ='45?';
        EDetails.name ='Submerchantid';
        insert EDetails;
        try{
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new billdeskMock());
            //FEE_LoggedInApplicantPayment_Ctrl.rezorpayResponseCall result = FEE_LoggedInApplicantPayment_Ctrl.easypayUpdatedGenratePaymentLink(objCon.Id,100.00,'ApplicationFee');
            Test.stopTest();
        }catch(exception e){
            
        }
    }
    @isTest
    static void testBillDeskUpdatedPayGenratePaymentLink() {
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Number__c = 'test123';
        objCon.SRN_Number__c ='123';
        objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objCon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        list<Contact> lst_Con = new list<Contact>();
        lst_Con.add(objCon);
        
        Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
        User testUser = new User(
            profileId = p.Id,
            username = 'newUser@epeople.com',
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lal Baburao',
            contactId = objCon.id
            
        );
        insert testUser;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        objStuPayment.Fee_Type__c = 'University Fee';
        objStuPayment.Mode_of_Payment__c = 'Online';
        objStuPayment.Payment_Status__c = 'Pending';
        insert objStuPayment;
        List<Student_Payment__c> stupayLst = new List<Student_Payment__c>();
        stupayLst.add(objStuPayment);
        
        Billdesk_Merchant_Details__c paydetails4 = new Billdesk_Merchant_Details__c();
        paydetails4.MerchantId__c='BD9MAIN';
        paydetails4.Name='MainMerchant';
        insert paydetails4;
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.MerchantId__c='BD9CHILD1';
        paydetails.Name='Academic Fee';
        insert paydetails;
        
        Billdesk_Merchant_Details__c paydetail12 = new Billdesk_Merchant_Details__c();
        paydetail12.MerchantId__c='UATV1E07C1';
        paydetail12.Name='University Fee';
        insert paydetail12;
        
        
        try{
            FEE_LoggedInApplicantPayment_Ctrl.razorpayResponseCall result = FEE_LoggedInApplicantPayment_Ctrl.BillDeskUpdatedPayGenratePaymentLink(objCon.Id,100.00,'ApplicationFee',stupayLst);
            FEE_LoggedInApplicantPayment_Ctrl.razorpayResponseCall result1 = FEE_LoggedInApplicantPayment_Ctrl.BillDeskPayGenratePaymentLink(lst_stufee,100.00,'ApplicationFee');
        }catch(exception e){
            
        }
    }
    @isTest
    static void testrazorpayUpdatedGeneratePaymentLink() {
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        Contact objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
        objCon.FirstName = 'Test';
        objCon.LastName = 'Contact';
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objCon.Application_Number__c = 'test123';
        objCon.SRN_Number__c ='123';
        objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objCon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        list<Contact> lst_Con = new list<Contact>();
        lst_Con.add(objCon);
        
        Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
        User testUser = new User(
            profileId = p.Id,
            username = 'newUser@epeople.com',
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lal Baburao',
            contactId = objCon.id
            
        );
        insert testUser;
        
        Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
        objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
        objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
        objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
        objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
        Insert objFeeCriteria;
        
        hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
        Insert objProgenroll;
        
        Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        Insert objStudentFee;
        
        Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
        objStudentFee1.Amount__c = 50000;
        objStudentFee1.Amount_Pending__c=0;
        objStudentFee1.Amount_Paid__c=50000;
        Insert objStudentFee1;
        
        list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
        lst_stufee.add(objStudentFee1);
        
        Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment.Payment_Status__c ='Success';
        insert objStuPayment;
        
        Student_Payment__c objStuPayment1 = FEE_TestDataFactory.createStudentPayment(objCon.Id);
        objStuPayment1.Payment_Status__c ='Pending';
        insert objStuPayment1;

         List<Student_Payment__c> stupayLst = new List<Student_Payment__c>();
        stupayLst.add(objStuPayment1);
        
        Razorpay_Details__c pkk=new Razorpay_Details__c();
        pkk.Value__c='https://reva-university.my.salesforce-sites.com/RazorPayPGResponse/apex/ApplicationFeeResponse';
        pkk.Name='Applicant_CallbackUrl';
        insert pkk;
        
        Razorpay_Details__c pkk2=new Razorpay_Details__c();
        pkk2.Value__c='https://api.razorpay.com/v1/payment_links';
        pkk2.Name='Razorpay Endpoint';
        insert pkk2;
        
        Razorpay_Details__c pkk3=new Razorpay_Details__c();
        pkk3.Value__c='rzp_live_ez9dBbTyQABJKH';
        pkk3.Name='UserName';
        insert pkk3;
        
        Razorpay_Details__c pkk4=new Razorpay_Details__c();
        pkk4.Value__c='685AJH26ZKO7EBN3zGWoPXBG';
        pkk4.Name='Password';
        insert pkk4;  
        
        try{
            FEE_LoggedInApplicantPayment_Ctrl.razorpayResponseCall result = FEE_LoggedInApplicantPayment_Ctrl.razorpayUpdatedGeneratePaymentLink(objCon.Id,100.00,'ApplicationFee',stupayLst);
            System.debug('result --Test class::'+result);
            
        }catch(exception e){
            
        }
    }
    @isTest
    static void testWrapApexClass() {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
        adminUser.UserRoleId = userRole.Id;
        //update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            Id ApplicantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = ApplicantRecId;
            objCon.AccountId = objAcc.Id;
            objCon.Application_Number__c = 'test123';
            objCon.SRN_Number__c ='123';
            objCon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objCon.Nationality__c ='Indian';
            objCon.Admission_Mode__c='DCET';
            Insert objCon; 
            System.debug('objCon'+objCon);
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser',
                lastname='lastname',
                contactId = objCon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee','Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id,null);
            Insert objProgenroll;
            
            Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee.Amount__c = 50000;
            objStudentFee.Amount_Pending__c=50000;
            objStudentFee.Amount_Paid__c=0;
            objStudentFee.Contact__c = objCon.id;
            objStudentFee.Fee_Year__c = '1st Year';
            objStudentFee.Fee_Type__c = 'University Fee';
            objStudentFee.Provisional_Admission_Fee__c = 15000;
            objStudentFee.Due_Date__c = system.today() - 1;
            Insert objStudentFee;
            
            Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee1.Amount__c = 50000;
            objStudentFee1.Amount_Pending__c=50000;
            objStudentFee1.Amount_Paid__c=0;
            objStudentFee1.Contact__c = objCon.id;
            objStudentFee1.Fee_Year__c = '1st Year';
            objStudentFee1.Fee_Type__c = 'Tuition Fee';
            objStudentFee1.Provisional_Admission_Fee__c = 15000;
            objStudentFee1.Number_of_Installments__c = 4;
            objStudentFee1.Due_Date__c = system.today() - 1;
            Insert objStudentFee1;
            
            Student_Fee__c objStudentFee3 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee3.Amount__c = 50000;
            objStudentFee3.Amount_Pending__c= 0;
            objStudentFee3.Amount_Paid__c=50000;
            objStudentFee3.Contact__c = objCon.id;
            objStudentFee3.Fee_Year__c = '1st Year';
            objStudentFee3.Fee_Type__c = 'University Fee';
            objStudentFee3.Provisional_Admission_Fee__c = 15000;
            objStudentFee3.Due_Date__c = system.today() - 1;
            objStudentFee3.Number_of_Installments__c = 3;
            objStudentFee3.Paid_Installments__c = 1;
            Insert objStudentFee3;
            
            list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
            lst_stufee.add(objStudentFee1);
            
            //Student_Fee__c objStudentFee2 = [Select Id, Amount_Pending__c, Amount_Paid__c from Student_Fee__c Where Id = : objStudentFee.Id];
            //objStudentFee2.Amount_Paid__c = 50000;
            //objStudentFee2.Amount_Pending__c = 0;
            //Update objStudentFee2;
            
            Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
            objStuPayment.Payment_Status__c ='Success';
            insert objStuPayment;
            
            
            // Create a test Student_Fee_Payment__c record associated with the test Student_Payment__c record
            Student_Fee_Payment__c testFeePayment = new Student_Fee_Payment__c();
            testFeePayment.Amount__c=6000;
            testFeePayment.Student_Payment__c=objStuPayment.Id;
            insert testFeePayment;
            
            list<Student_Fee_Payment__c> lst_stufeePay = new list<Student_Fee_Payment__c>();
            lst_stufeePay.add(testFeePayment);
            
            List<Student_Payment__c> testPayments = new List<Student_Payment__c>();
            for (Integer i = 0; i < 5; i++) {
                testPayments.add(new Student_Payment__c(
                    Amount__c = 100.00,
                    Contact__c = objCon.Id,
                    Mode_of_Payment__c = 'Online',
                    Payment_Status__c =  'Pending' 
                ));
            }
            insert testPayments;
            
            // Create test Student_Fee_Payment__c records
            Student_Fee_Payment__c testFeePayments = new Student_Fee_Payment__c();
            testFeePayments.Amount__c = 50.00;
            testFeePayments.Line_Item_Payment_Status__c = 'Pending';
            testFeePayments.Mode_of_Payment__c = 'Online';
            
            insert testFeePayments;
            
            // Create an instance of StuFeePayWrapper
            FEE_LoggedInApplicantPayment_Ctrl.StuFeePayWrapper wrapper = new FEE_LoggedInApplicantPayment_Ctrl.StuFeePayWrapper();
            wrapper.ObjStuFeePayDetails = testFeePayments;
            wrapper.isChecked = true; // Set to true for coverage YourApexClass.inisaliseResponse initResponse = new YourApexClass.inisaliseResponse();
            FEE_LoggedInApplicantPayment_Ctrl.inisaliseResponse initResponse = new FEE_LoggedInApplicantPayment_Ctrl.inisaliseResponse();
            initResponse.body = new FEE_LoggedInApplicantPayment_Ctrl.resBodyDetails();
            initResponse.head = new FEE_LoggedInApplicantPayment_Ctrl.resHeadDetails();
            
            FEE_LoggedInApplicantPayment_Ctrl.rezorpayResponseCall responseCall = new FEE_LoggedInApplicantPayment_Ctrl.rezorpayResponseCall();
            responseCall.id = 'testId';
            responseCall.reference_id = 'testRefId';
            responseCall.short_url = 'testShortUrl';
            responseCall.status = 'testStatus';
            responseCall.statusCode = 200;
            
            FEE_LoggedInApplicantPayment_Ctrl.resResultInfoDetails resultInfoDetails = new FEE_LoggedInApplicantPayment_Ctrl.resResultInfoDetails();
            resultInfoDetails.resultStatus = 'Success';
            resultInfoDetails.resultCode = '200';
            resultInfoDetails.resultMsg = 'Operation successful';
            
            // Create an instance of resBodyDetails
            FEE_LoggedInApplicantPayment_Ctrl.resBodyDetails bodyDetails = new FEE_LoggedInApplicantPayment_Ctrl.resBodyDetails();
            bodyDetails.resultInfo = resultInfoDetails;
            bodyDetails.txnToken = 'testToken';
            bodyDetails.isPromoCodeValid = true;
            bodyDetails.authenticated = false;
            
            FEE_LoggedInApplicantPayment_Ctrl.resHeadDetails headDetails = new FEE_LoggedInApplicantPayment_Ctrl.resHeadDetails();
            headDetails.responseTimestamp = '2024-01-19T12:00:00Z';
            headDetails.version='1.0';
            headDetails.signature='test';
            
            FEE_LoggedInApplicantPayment_Ctrl.StudentFeeWrapper StuFeeWrp= new  FEE_LoggedInApplicantPayment_Ctrl.StudentFeeWrapper();
            StuFeeWrp.objStuname='Testing';
            StuFeeWrp.objAppNumber='3456789';
            StuFeeWrp.objSrnNumber='9876543';
            StuFeeWrp.objConcessionStatus='Pending';
            StuFeeWrp.ProvisionalAdmissionFee=100.00;
            
            FEE_LoggedInApplicantPayment_Ctrl.ErrorWrapper ErrWrp= new  FEE_LoggedInApplicantPayment_Ctrl.ErrorWrapper();
            ErrWrp.DateError='Warning';
            
            FEE_LoggedInApplicantPayment_Ctrl.StudentFeeRecWrapper StuFeeRecWrap= new  FEE_LoggedInApplicantPayment_Ctrl.StudentFeeRecWrapper();
            StuFeeRecWrap.StuFeeType='Tuition fee';
            StuFeeRecWrap.NoOfInstallments = 4.00;
            StuFeeRecWrap.conId = objCon.Id;
            StuFeeRecWrap.PendingAmount=5000.00;
            
            
        }
    }
   private class GrayQuestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if(req.getEndpoint().contains('emi-plans')) {
                res.setStatusCode(200);
                res.setBody('{"data":{"plan_total_emi_amount":2500}}');
            } else {
                // Default redirection mock
                res.setStatusCode(201);
                res.setBody('{"success": true, "status_code": 201, "data": {"redirection_url": "https://grayquest.test/payment"}}');
            }
            return res;
        }
    }

     @isTest
    static void testGrayQuestGenerateLink() {
        // Setup Basic Data
        Account acc = new Account(Name = 'GrayQuest Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Application_Number__c = 'APP123');
        insert con;
        Student_Payment__c sp = new Student_Payment__c(Contact__c = con.Id, Amount__c = 1000, Payment_Status__c = 'Pending');
        insert sp;

        // INSERT SETTINGS (Exact casing matching your Production screenshots)
        List<GrayQuest_Merchant_Details__c> gqSettings = new List<GrayQuest_Merchant_Details__c>();
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'Slug', MerchantId__c = 'reva-prod'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'API_Key', MerchantId__c = 'key123'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'Client_id', MerchantId__c = 'id123')); 
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'Client_secret', MerchantId__c = 'secret123'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'Redirect_URL', MerchantId__c = 'https://api.test.com/'));
        insert gqSettings;
        
        // 2. CRITICAL FIX: Robust parameter preparation mimicking LWC/Aura serialization
        List<Object> paymentList = new List<Object>();
        Map<String,Object> payMap = new Map<String,Object>();
        payMap.put('Id', (String)sp.Id);
        payMap.put('Amount__c', '1000'); // Passed as string to ensure String.valueOf in controller works
        payMap.put('Contact__c', (String)con.Id);
        payMap.put('Program_Enrollment__c', null); 
        
        // Relationship structure the loop looks for
        Map<String,Object> conMap = new Map<String,Object>();
        conMap.put('Application_Number__c', 'APP123');
        payMap.put('Contact__r', conMap);
        
        paymentList.add(payMap);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GrayQuestMock());
        
        // Calling the controller method
        FEE_LoggedInApplicantPayment_Ctrl.GrayQuestResponse result = 
            FEE_LoggedInApplicantPayment_Ctrl.grayQuestGenerateLink(paymentList, 1000, 'Multi');
        
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'GrayQuest result should not be null');
    }

    @isTest
    static void testGetGrayQuestEmiAmount() {
        // Setup settings needed for EMI logic
        List<GrayQuest_Merchant_Details__c> gqSettings = new List<GrayQuest_Merchant_Details__c>();
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'API_Key', MerchantId__c = 'apikey'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'Client_id', MerchantId__c = 'clientid'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'Client_secret', MerchantId__c = 'secret'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name = 'EMI_Plans_URL', MerchantId__c = 'https://api.graydev.tech/emi-plans'));
        insert gqSettings;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GrayQuestMock());
        
        Decimal emiAmount = FEE_LoggedInApplicantPayment_Ctrl.getGrayQuestEmiAmount(10000);
        
        Test.stopTest();
        
        System.assertEquals(2500, emiAmount, 'EMI Amount calculation mismatch');
    }  
    
}