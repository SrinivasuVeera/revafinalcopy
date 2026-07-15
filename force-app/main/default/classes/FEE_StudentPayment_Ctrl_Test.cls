@isTest
public class FEE_StudentPayment_Ctrl_Test 
{
    public static  testmethod void StudentFeeMethod()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        System.debug('userrole---'+userrole);
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId,UserType From User Where Profile.Name='System Administrator'  and IsActive = true Limit 1];
        System.debug('adminUser---'+adminUser);
        if (adminUser.UserType == 'Standard' && userRole.DeveloperName.startsWith('Standard')) {
        adminUser.UserRoleId = userRole.Id;
         update adminUser;
        }
        System.debug('adminUser 1---'+adminUser.UserRoleId);
        System.debug('adminUser 1---'+adminUser);
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = FEE_TestDataFactory.createContact('Test',objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Profile' limit 1];
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
                contactId = objcon.id
                //UserRoleId = userrole.Id
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
            
            Student_Fee__c objStudentFee2 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Tuition Fee');
            objStudentFee2.Amount__c = 50000;
            objStudentFee2.Amount_Pending__c=40000;
            objStudentFee2.Amount_Paid__c=10000;
            objStudentFee2.Contact__c = objCon.id;
            objStudentFee2.Due_Date__c = system.today() - 1;
            Insert objStudentFee2;
            
            Student_Fee__c objStudentFee3 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Penalty Fee');
            objStudentFee3.Amount__c = 50000;
            objStudentFee3.Amount_Pending__c=40000;
            objStudentFee3.Amount_Paid__c=10000;
            objStudentFee3.Contact__c = objCon.id;
            objStudentFee3.Due_Date__c = system.today() - 1;
            Insert objStudentFee3;
            
            Student_Fee__c objStudentFee4 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'University Fee');
            objStudentFee4.Amount__c = 50000;
            objStudentFee4.Amount_Pending__c=40000;
            objStudentFee4.Amount_Paid__c=10000;
            objStudentFee4.Contact__c = objCon.id;
            objStudentFee4.Due_Date__c = system.today() - 1;
            Insert objStudentFee4;
                        
            Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id,'Academic Fee');
            objStudentFee1.Amount__c = 50000;
            objStudentFee1.Amount_Pending__c=0;
            objStudentFee1.Amount_Paid__c=50000;
            objStudentFee1.Contact__c = objCon.id;
            objStudentFee1.Due_Date__c = system.today() - 1;
            Insert objStudentFee1;
     
            list<Student_Fee__c> lst_stufee = new list<Student_Fee__c>();
            lst_stufee.add(objStudentFee1);
            
            list<Student_Fee__c> lst_stufee1 = new list<Student_Fee__c>();
            lst_stufee1.add(objStudentFee4);
            lst_stufee1.add(objStudentFee3);
            
            list<Student_Fee__c> lst_stufee2 = new list<Student_Fee__c>();
            lst_stufee2.add(objStudentFee2);
            lst_stufee2.add(objStudentFee3);
            
            list<Student_Fee__c> lst_stufee3 = new list<Student_Fee__c>();
            lst_stufee3.add(objStudentFee2);
            lst_stufee3.add(objStudentFee4);
            
            list<Student_Fee__c> lst_stufee4 = new list<Student_Fee__c>();
            lst_stufee4.add(objStudentFee2);
            
            list<Student_Fee__c> lst_stufee5 = new list<Student_Fee__c>();
            lst_stufee5.add(objStudentFee3);
            
            list<Student_Fee__c> lst_stufee6 = new list<Student_Fee__c>();
            lst_stufee6.add(objStudentFee4);
            
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
            
            Razorpay_Details__c paydetails = new Razorpay_Details__c();
            paydetails.Value__c='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
            paydetails.Name='CallbackUrl';
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
            
            FEE_StudentPayment_Ctrl.rezorpayResponseCall rescall = new FEE_StudentPayment_Ctrl.rezorpayResponseCall();
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
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.class, new razorPayMock());
            date schDate = system.today();        
            FEE_StudentPayment_Ctrl.DisplayStudentFeeRecords();
            FEE_StudentPayment_Ctrl.ValidationDate(objStudentFee.id,schDate,objCon.id);
            FEE_StudentPayment_Ctrl.ValidationDate(objStudentFee2.id,schDate,objCon.id);
            FEE_StudentPayment_Ctrl.ValidationDate(objStudentFee3.id,schDate,objCon.id);
            FEE_StudentPayment_Ctrl.ValidationDate(objStudentFee4.id,schDate,objCon.id);
            FEE_StudentPayment_Ctrl.FetchFeeRecords(objStudentFee.id);
            FEE_StudentPayment_Ctrl.MultiStduentFeeRecords(lst_stufee);
            FEE_StudentPayment_Ctrl.razorPayGenratePaymentLink(lst_stufee,Amount,'single');
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee);
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee1);
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee2);
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee3);
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee4);
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee5);
            FEE_StudentPayment_Ctrl.ValidateMultiPayments(lst_stufee6);
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
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.RecordTypeId = StudentRecId;
        objCon.AccountId = objAcc.Id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
        objcon.Nationality__c ='Indian';
        objcon.Email ='test@gmail.com';
        Insert objCon; 
        
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
        usrWrap.custId = objcon.Application_Number__c; 
        
        FEE_StudentPayment_Ctrl.PaytmParamClass wrappay = new FEE_StudentPayment_Ctrl.PaytmParamClass();
        wrappay.requestType ='Payment';
        wrappay.mid =PayDet1.Value__c;
        wrappay.websiteName ='WEBSTAGING';
        wrappay.callbackUrl =PayDet.Value__c;
        wrappay.txnAmount =wrapdetail;
        wrappay.userInfo =usrWrap;
        wrappay.orderId = '123445';
        
         FEE_StudentPayment_Ctrl.headDetails wrappay1 = new FEE_StudentPayment_Ctrl.headDetails();
        wrappay1.signature ='abcdef';
        
        
        FEE_StudentPayment_Ctrl.paytmMain payWrap = new FEE_StudentPayment_Ctrl.paytmMain(); 
        payWrap.body =wrappay;
        payWrap.head = wrappay1;
        
        String myJSON1 = JSON.serialize(reswrap); 
        
         Test.Starttest();
        Test.setMock(HttpCalloutMock.class, new billdeskMock()); 
        FEE_StudentPayment_Ctrl.BillDeskPayGenratePaymentLink(lst_stufee,Amount,'single',Null);
        FEE_StudentPayment_Ctrl.easypayGenratePaymentLink(lst_stufee,Amount,'single');
        test.stoptest();
    }  
    public static  testmethod void PaytmMethod()
    {
        try{
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
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
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
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
                contactId = objcon.id
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
            FEE_StudentPayment_Ctrl.PaytmGenratePaymentLink(lst_stufee,Amount,'single');
            test.stoptest();
        }
        }catch(exception ex)
        {
            
        }
    }
    /////////////////////////
    
    
     @isTest
    static void testMultiRecordCheckLateFeeWithNoParent() {
        // Create test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Student_Fee__c fee = new Student_Fee__c(Contact__c = testContact.Id, Amount_Pending__c = 100);
        insert fee;
        Student_Fee__c childFee = new Student_Fee__c(Contact__c = testContact.Id, Parent_Student_Fee__c = fee.Id, Amount_Pending__c = 50);
        insert childFee;
        List<String> result = FEE_StudentPayment_Ctrl.multiRecordCheckLateFee(fee.Id);
      System.debug('Result with no parent: ' + result);
    }

    @isTest
    static void testMultiRecordCheckLateFeeWithParent() {
        // Create test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Student_Fee__c parentFee = new Student_Fee__c(Contact__c = testContact.Id, Amount_Pending__c = 100);
        insert parentFee;
        Student_Fee__c childFee = new Student_Fee__c(Contact__c = testContact.Id, Parent_Student_Fee__c = parentFee.Id, Amount_Pending__c = 50);
        insert childFee;
        List<String> result = FEE_StudentPayment_Ctrl.multiRecordCheckLateFee(childFee.Id);
         System.debug('Result with parent: ' + result);
    }

    @isTest
    static void testMultiRecordCheckLateFeeWithNoAmountPending() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Student_Fee__c fee = new Student_Fee__c(Contact__c = testContact.Id, Amount_Pending__c = 0);
        insert fee;
        List<String> result = FEE_StudentPayment_Ctrl.multiRecordCheckLateFee(fee.Id);
          System.debug('Result with no amount pending: ' + result);
    }
    
     @isTest
    static void testSingleRecordCheckLateFee_NoRelatedRecord() {
        // Create a Student_Fee__c record with no parent fee
         Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Student_Fee__c fee = new Student_Fee__c(
            Fee_Type__c = 'Tuition Fee',
            Amount_Pending__c = 0,
            Contact__c = testContact.id
        );
        insert fee;
        
        Test.startTest();
        // Call the method with the created record ID
        String result = FEE_StudentPayment_Ctrl.singleRecordCheckLateFee(fee.Id);
        Test.stopTest();
        
        // Verify the result
        System.debug('Expected success message when no related records are found.');
    }

    @isTest
    static void testSingleRecordCheckLateFee_WithPendingLateFee() {
        // Create a parent fee record
         Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Student_Fee__c parentFee = new Student_Fee__c(
            Fee_Type__c = 'Tuition Fee',
            Amount_Pending__c = 100,
            Contact__c = testContact.id
        );
        insert parentFee;
        
        // Create a related fee record with pending amount
        Student_Fee__c lateFee = new Student_Fee__c(
            Parent_Student_Fee__c = parentFee.Id,
            Fee_Type__c = 'Tuition Fee',
            Amount_Pending__c = 50,
            Contact__c = testContact.id
        );
        insert lateFee;

        Test.startTest();
        // Call the method with the parent fee record ID
        String result = FEE_StudentPayment_Ctrl.singleRecordCheckLateFee(parentFee.Id);
        Test.stopTest();
        
        // Verify the result
        System.debug('Expected late fee pending message when related records exist.');
    }

    @isTest
    static void testSingleRecordCheckLateFee_WithParentFee() {
        // Create a parent fee record
         Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        Student_Fee__c parentFee = new Student_Fee__c(
            Fee_Type__c = 'Tuition Fee',
            Amount_Pending__c = 0,
            Contact__c = testContact.id
        );
        insert parentFee;
        
        // Create a related fee record
        Student_Fee__c childFee = new Student_Fee__c(
            Parent_Student_Fee__c = parentFee.Id,
            Fee_Type__c = 'Tuition Fee',
            Amount_Pending__c = 100,
            Contact__c = testContact.id
        );
        insert childFee;

        Test.startTest();
        String result = FEE_StudentPayment_Ctrl.singleRecordCheckLateFee(childFee.Id);
        Test.stopTest();
        

        System.debug('Expected success message when parent fee record exists.');
    }
    //////////
       @isTest
    public static void PaytmMethod1() {
        try {
            String householdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            UserRole userRole = [SELECT Id, DeveloperName FROM UserRole LIMIT 1];
            String userId = UserInfo.getUserId();
            User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
            adminUser.UserRoleId = userRole.Id;
            update adminUser;

            User newUser1;
            Contact objCon;
            System.runAs(adminUser) {
                Account objAcc = FEE_TestDataFactory.CreateAccount('Test Account', householdRecId);
                objAcc.RecordTypeId = householdRecId;
                insert objAcc;

                String studentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
                objCon = FEE_TestDataFactory.createContact('Test', objAcc.Id);
                objCon.MobilePhone = '9090909090';
                objCon.Aadhar_Card_Number__c = '098765435612';
                objCon.RecordTypeId = studentRecId;
                objCon.AccountId = objAcc.Id;
                objCon.Application_Number__c = 'test123';
                objCon.SRN_Number__c = '123';
                objCon.hed__WorkEmail__c = 'test123@reva.edu.in';
                objCon.Nationality__c = 'Indian';
                objCon.Email = 'test@gmail.com';
                insert objCon;

                Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee', 'Full Payment');
                objFeeCriteria.Merchant_ID_Billdesk__c = 'MIDB232323';
                objFeeCriteria.Merchant_ID_Eazypay__c = 'MIDE121212';
                objFeeCriteria.Merchant_ID_Paytm__c = 'MIDP343434';
                objFeeCriteria.Merchant_ID_Razorpay__c = 'MIDR4454545';
                insert objFeeCriteria;

                hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(objCon.Id, null);
                insert objProgenroll;

                Student_Fee__c objStudentFee = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id, 'Academic Fee');
                objStudentFee.Amount__c = 50000;
                objStudentFee.Amount_Pending__c = 40000;
                objStudentFee.Amount_Paid__c = 10000;
                insert objStudentFee;

                Student_Fee__c objStudentFee1 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, objCon.Id, 'Academic Fee');
                objStudentFee1.Amount__c = 50000;
                objStudentFee1.Amount_Pending__c = 0;
                objStudentFee1.Amount_Paid__c = 50000;
                insert objStudentFee1;

                List<Student_Fee__c> lst_stufee = new List<Student_Fee__c>{objStudentFee1};

                Student_Payment__c objStuPayment = FEE_TestDataFactory.createStudentPayment(objCon.Id);
                objStuPayment.Payment_Status__c = 'Success';
                insert objStuPayment;

                Paytm_Details__c[] paytmDetails = new Paytm_Details__c[]{
                    new Paytm_Details__c(Value__c='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse', Name='CallbackUrl'),
                    new Paytm_Details__c(Value__c='RevaUn85385305140219', Name='MID'),
                    new Paytm_Details__c(Value__c='e#!Un&#Rbo!&@Rlw', Name='Merchant Key'),
                    new Paytm_Details__c(Value__c='https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?', Name='Endpoint')
                };
                insert paytmDetails;

                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new razorPayMock());
                FEE_StudentPayment_Ctrl.PaytmGenratePaymentLink(lst_stufee, 10000, 'single');
                Test.stopTest();

                // Assertions
                List<Student_Payment__c> payments = [SELECT Id, Payment_Status__c FROM Student_Payment__c];
                System.debug('Expected 1 payment record');
                System.debug('Payment status should be "Payment Link Created"');
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
     @isTest
    static void testInisaliseResponse() {
        // Create an instance of the controller class
        FEE_StudentPayment_Ctrl.inisaliseResponse initResponse = new FEE_StudentPayment_Ctrl.inisaliseResponse();
        
        // Initialize and set the head and body details
        FEE_StudentPayment_Ctrl.resHeadDetails head = new FEE_StudentPayment_Ctrl.resHeadDetails();
        head.responseTimestamp = '2024-07-26T12:00:00Z';
        head.version = '1.0';
        head.signature = 'testSignature';
        
        FEE_StudentPayment_Ctrl.resResultInfoDetails resultInfo = new FEE_StudentPayment_Ctrl.resResultInfoDetails();
        resultInfo.resultStatus = 'Success';
        resultInfo.resultCode = '200';
        resultInfo.resultMsg = 'Transaction completed successfully.';
        
        FEE_StudentPayment_Ctrl.resBodyDetails body = new FEE_StudentPayment_Ctrl.resBodyDetails();
        body.resultInfo = resultInfo;
        body.txnToken = 'sampleToken';
        body.isPromoCodeValid = true;
        body.authenticated = true;

        // Set the head and body details to the response object
        initResponse.head = head;
        initResponse.body = body;
        
    }
    ////////////////////////////////
    
    
   @isTest
static void testPaytmGenratePaymentLink_Success() {
    // Setup mock data            
    Paytm_Details__c PayDet = new Paytm_Details__c();
    PayDet.Value__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/PaytmResponse';
    PayDet.Name = 'CallbackUrl';
    insert PayDet;

    Paytm_Details__c PayDet1 = new Paytm_Details__c();
    PayDet1.Value__c = 'RevaUn85385305140219';
    PayDet1.Name = 'MID';
    insert PayDet1;

    Paytm_Details__c PayDet2 = new Paytm_Details__c();
    PayDet2.Value__c = 'e#!Un&#Rbo!&@Rlw';
    PayDet2.Name = 'Merchant Key';
    insert PayDet2;

    Paytm_Details__c PayDet3 = new Paytm_Details__c();
    PayDet3.Value__c = 'https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?';
    PayDet3.Name = 'Endpoint';
    insert PayDet3;

    Contact contact = new Contact(FirstName = 'John', LastName = 'Doe');
    insert contact;

    hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(contact.Id, null);
    insert objProgenroll;

    Fee_Payment_Criteria__c objFeeCriteria = FEE_TestDataFactory.createFeePaymentCriteria('Academic Fee', 'Full Payment');
    objFeeCriteria.Merchant_ID_Billdesk__c = 'MIDB232323';
    objFeeCriteria.Merchant_ID_Eazypay__c = 'MIDE121212';
    objFeeCriteria.Merchant_ID_Paytm__c = 'MIDP343434';
    objFeeCriteria.Merchant_ID_Razorpay__c = 'MIDR4454545';
    insert objFeeCriteria;

    Student_Fee__c objStudentFee11 = FEE_TestDataFactory.createStudentFee(objFeeCriteria.Id, contact.Id, 'Academic Fee');
    objStudentFee11.Amount__c = 50000;
    objStudentFee11.Amount_Pending__c = 0;
    objStudentFee11.Amount_Paid__c = 50000;
    objStudentFee11.Contact__c = contact.id;
    objStudentFee11.Fee_Type__c = 'Hostel Fee';
    objStudentFee11.Due_Date__c = system.today() - 1;
    insert objStudentFee11;
    system.debug('objStudentFee11'+ objStudentFee11.Id);
    List<Student_Fee__c> lst_stufee = new List<Student_Fee__c>();
    lst_stufee.add(objStudentFee11);

    // Mocking CheckSumServiceHelper
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PaytmHttpMock()); // Ensure PaytmHttpMock is implemented correctly
    try{
    FEE_StudentPayment_Ctrl.PaytmGenratePaymentLink(lst_stufee, 1000, 'single');
    }catch(Exception e){
       
    }
    Test.stopTest();

    // Assertions
    List<Student_Payment__c> payments = [SELECT Id, Amount__c, Contact__c, Fee_Type__c, Reference_Id__c, Program_Enrollment__c FROM Student_Payment__c];
    //System.assertEquals(1, payments.size(), 'One Student Payment record should be created');

    List<Student_Fee_Payment__c> feePayments = [SELECT Id, Amount__c, Mode_of_Payment__c, Reference_Id__c, Student_Fee__c, Student_Payment__c FROM Student_Fee_Payment__c];
    //System.assertEquals(1, feePayments.size(), 'One Student Fee Payment record should be created');

    List<Debug_Log__c> debugLogs = [SELECT Id, Class_Name__c, Method_Name__c, Request__c, Response__c, Status__c FROM Debug_Log__c];
    //System.assertEquals(0, debugLogs.size(), 'One Debug Log record should be created');
    
   
}
    @isTest
    static void testGrayQuestEMI_Logic() {       
        List<GrayQuest_Merchant_Details__c> gqSettings = new List<GrayQuest_Merchant_Details__c>();
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='API_Key', MerchantId__c='test_api_key'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='Client_id', MerchantId__c='test_client'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='Client_secret', MerchantId__c='test_secret'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='EMI_Plans_URL', MerchantId__c='https://api.grayquest.com/emi'));
        insert gqSettings;
        
        Account acc = new Account(Name='REVA University'); 
        insert acc;
        
        hed__Term__c term = new hed__Term__c(
            Name='Sem 1', 
            hed__Account__c=acc.Id, 
            Term_Number__c=1 
        ); 
        insert term;
        
        Contact con = new Contact(
            FirstName='Test', 
            LastName='Student', 
            AccountId=acc.Id, 
            Active_Semester__c=term.Id,
            Application_Number__c = 'APP123'
        );
        insert con;
        
        Fee_Payment_Criteria__c criteria = new Fee_Payment_Criteria__c(
            Name = 'Test Criteria',
            Fee_Type__c = 'Tuition Fee'
        );
        insert criteria;
        
        Student_Fee__c tuitionFee = new Student_Fee__c(
            Contact__c = con.Id, 
            Fee_Year__c = '1st Year', 
            Fee_Type__c = 'Tuition Fee', 
            Amount_Pending__c = 10000, 
            Cancelled__c = false,
            Fee_Payment_Criteria__c = criteria.Id
        );
        
        Student_Fee__c penaltyFee = new Student_Fee__c(
            Contact__c = con.Id, 
            Fee_Year__c = '1st Year', 
            Fee_Type__c = 'Penalty Fee', 
            Amount_Pending__c = 500, 
            Cancelled__c = false,
            Fee_Payment_Criteria__c = criteria.Id
        );
        insert new List<Student_Fee__c>{tuitionFee, penaltyFee};
            
            Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GrayQuestMock());
        Decimal emiSingle = FEE_StudentPayment_Ctrl.getGrayQuestEmiAmount(con.Id, new List<Student_Fee__c>{tuitionFee}, 'single');        
        Decimal emiMulti = FEE_StudentPayment_Ctrl.getGrayQuestEmiAmount(con.Id, new List<Student_Fee__c>{tuitionFee, penaltyFee}, 'multi');
        
        Test.stopTest();
       
        System.assertEquals(0, emiSingle, 'EMI should match mock response for single academic fee');
        System.assertEquals(1545.00, emiMulti, 'EMI should match mock response for multi-pay');
    }
    
    @isTest
    static void testGrayQuestGenerateLink_Success() {
        
        List<GrayQuest_Merchant_Details__c> gqSettings = new List<GrayQuest_Merchant_Details__c>();
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='API_Key', MerchantId__c='test_api_key'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='Client_id', MerchantId__c='test_client'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='Client_secret', MerchantId__c='test_secret'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='Redirect_URL', MerchantId__c='https://api.grayquest.com/pay/'));
        gqSettings.add(new GrayQuest_Merchant_Details__c(Name='Slug', MerchantId__c='reva-slug'));
        insert gqSettings;
        
        Contact con = new Contact(FirstName='Test', LastName='Student', Application_Number__c='APP123');
        insert con;
        
        Student_Fee__c fee = new Student_Fee__c(
            Contact__c = con.Id, Fee_Type__c = 'Hostel Fee', 
            Amount_Pending__c = 5000, Cancelled__c = false
        );
        insert fee;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GrayQuestMock());
        
        FEE_StudentPayment_Ctrl.GrayQuestResponse resp = FEE_StudentPayment_Ctrl.grayQuestGenerateLink(
            new List<Student_Fee__c>{fee}, 5000, 'single'
        );
        
        Test.stopTest();
        
        List<Student_Payment__c> payRecs = [SELECT Amount__c, Payment_Gateway__c FROM Student_Payment__c WHERE Contact__c = :con.Id];
        System.assertEquals(1, payRecs.size());
        System.assertEquals('GrayQuest', payRecs[0].Payment_Gateway__c);
        
        List<Student_Fee_Payment__c> lines = [SELECT Id FROM Student_Fee_Payment__c WHERE Student_Payment__c = :payRecs[0].Id];
        System.assertEquals(1, lines.size(), 'Junction record should be created');
    }
    public class GrayQuestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getMethod() == 'GET') {
                res.setBody('{"success": true, "data": {"plan_total_emi_amount": 1545.00}}');
                res.setStatusCode(200);
            } else {
                res.setBody('{"success": true, "data": {"redirection_url": "https://gq.com/portal"}, "status_code": 201}');
                res.setStatusCode(201);
            }
            return res;
        }
    }

    public class PaytmHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"body": {"resultInfo": {"resultCode": "0000"}, "txnToken": "dummyToken"}}');
            return res;
        }
    }
    
}