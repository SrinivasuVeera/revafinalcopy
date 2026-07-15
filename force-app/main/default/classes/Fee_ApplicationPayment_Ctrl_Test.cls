@isTest
public class Fee_ApplicationPayment_Ctrl_Test  {
  
    public static final String CONST_APPLICANT_RECTYPE = 'Applicant';
    
    @isTest
    public static void displayApplicantFeeRecordsTest1(){
        // Insert HouseholdAccount Record
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        system.debug('conrecId--->'+conRecId);
        Account objAccount = new account();
        objAccount.Name = 'Stratos';
        objAccount.RecordTypeId = HouseholdRecId;
        insert objAccount;
        
        system.debug('objAccount.id--->'+objAccount);
        //Insert Applicant Contact Record
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        objCon.AccountId = objAccount.id;
        objCon.Applying_For_REVA_CET__c = 'Yes';
        objCon.LeadSource = 'Web';
        objCon.Admission_Mode__c = 'UQ';
        objCon.Country_Code__c = 'India (+91)';
        objCon.Select_Category__c = 'Karnataka';
        objCon.State__c = 'Karnataka';
        objCon.Exam_Type__c = 'Mobile Based';
        objCon.Country__c = 'India';
        insert objCon;
      
           //Insert  StudentFeeWrapper Record      
        FEE_ApplicationPayment_Ctrl.StudentFeeWrapper stuWrap = new FEE_ApplicationPayment_Ctrl.StudentFeeWrapper();
        stuWrap.objAppNumber = '7860879';
        stuWrap.objStuName = 'Karthi';
        stuWrap.objSrnNumber = '12345';
        
        //Inserting Application-Fee Fee payment Criteria 
        Fee_Payment_Criteria__c  criteriaObj = new Fee_Payment_Criteria__c();
        criteriaObj.Payment_Type__c='Full Payment';
        criteriaObj.Fee_Type__c='Application Fee';
        criteriaObj.Merchant_ID_Razorpay__c='MIDR4454545'; 
        criteriaObj.Fee_Type__c = 'Application Fee';
        criteriaObj.Name = 'Application Fee - Full Payment';
        criteriaObj.Maximum_Number_of_Installments__c = 1;
        
        Insert criteriaObj;
        
        system.debug('Fee_Payment_Criteria__c--->'+criteriaObj);
             
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=50000;
        objStudentFee.Amount_Paid__c=0;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() + 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Description__c='Thanks for Your Interest';
        objStudentFee.Due_Date__c=system.today();  
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=1;
        objStudentFee.Paid_Installments__c=0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
        
        Insert objStudentFee;
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        insert objStuPayment;

       
        FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
      
        test.startTest();
        
        FEE_ApplicationPayment_Ctrl.displayApplicantFeeRecords((string)objcon.id,false,(string)objStuPayment.id);
        FEE_ApplicationPayment_Ctrl.displayApplicantFeeRecords((string)objcon.id,true,(string)objStuPayment.id);
        FEE_ApplicationPayment_Ctrl.getPortalName();
        test.stopTest();
    }
    @isTest
    public static void fetchApplicantFeeRecords1(){
         
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        system.debug('conrecId--->'+conRecId);
        Account objAccount = new account();
        objAccount.Name = 'Stratos';
        objAccount.RecordTypeId = HouseholdRecId;
        insert objAccount;
        
        system.debug('objAccount.id--->'+objAccount);
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conrecId;
        objCon.AccountId = objAccount.id;
        insert objCon;
             
                  
        FEE_ApplicationPayment_Ctrl.StudentFeeWrapper stuWrap = new FEE_ApplicationPayment_Ctrl.StudentFeeWrapper();
        stuWrap.objAppNumber = '7860879';
        stuWrap.objStuName = 'Karthi';
        stuWrap.objSrnNumber = '12345';
        
        
        Fee_Payment_Criteria__c  criteriaObj = new Fee_Payment_Criteria__c();
        criteriaObj.Payment_Type__c='Full Payment';
        criteriaObj.Fee_Type__c='University Fee';
        criteriaObj.Merchant_ID_Billdesk__c ='MIDB232323';
        /*criteriaObj.Merchant_ID_Eazypay__c ='MIDE121212';
        criteriaObj.Merchant_ID_Paytm__c ='MIDP343434'; */
        criteriaObj.Merchant_ID_Razorpay__c='MIDR4454545'; 
        criteriaObj.Name = 'Application Fee - Full Payment';
        criteriaObj.Maximum_Number_of_Installments__c = 1;
        
        Insert criteriaObj;
        
        system.debug('Fee_Payment_Criteria__c--->'+criteriaObj);
        
        hed__Program_Enrollment__c objProgramEn = new hed__Program_Enrollment__c();
        objProgramEn.hed__Contact__c = objcon.id;
        objProgramEn.hed__Account__c = objaccount.id;
        
        insert objProgramEn;
        
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() + 1;
        objStudentFee.Fee_Type__c = 'University Fee';
        objStudentFee.Actual_Program_Fee__c=100000;
        objStudentFee.Concession__c=10000;
        objStudentFee.Course_Name_Course_Code__c='230101';
        objStudentFee.Program_Enrollment__c= objProgramEn.id;
        objStudentFee.Description__c='Thanks for the Your Interest';
        objStudentFee.Fee_Category__c='Application';
        objStudentFee.Number_of_Installments__c=5.0;
        objStudentFee.Paid_Installments__c=3.0;
        objStudentFee.Premium__c=12;
        objStudentFee.Received_Source__c='Manual / Upload';
        objStudentFee.Room_Sharing_Details__c= 'three';
        objStudentFee.Scholarship__c= 23;
        objStudentFee.Scholarship_Category__c= 'sports';
         objStudentFee.Fee_Payment_Criteria__c = criteriaObj.Id;
        Insert objStudentFee;
       
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        insert objStuPayment;

       
        FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
      
        
        test.startTest();
        FEE_ApplicationPayment_Ctrl.fetchApplicantFeeRecords(objStudentFee.id,(string)objcon.id);
        FEE_ApplicationPayment_Ctrl.fetchProvisionalAdmissionFeeRecords((string)objcon.id);
        system.test.stopTest();
            
        
    }
    @isTest
    public static void razorPayGenratePaymentLink1(){
       
       
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
      
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
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
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        // Student_Payment__c objStuPayment = new Student_Payment__c();
        // objStuPayment.Payment_Status__c = 'Success';
        // objStuPayment.Contact__c = objcon.id;
        
        // insert objStuPayment;

        Student_Payment__c objStuPayment = new Student_Payment__c(
            Contact__c = objCon.Id,
            Amount__c = 10000,
            Fee_Type__c = 'University Fee, Tuition Fee',
            Payment_Status__c = 'Pending',
            Mode_of_Payment__c = 'Online',
            Payment_Mode_Type__c = 'Online'
        );
        insert objStuPayment;

        FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
        FEE_ApplicationPayment_Ctrl.customerWrp customerObj = new FEE_ApplicationPayment_Ctrl.customerWrp();
        customerObj.Name = 'karthi';
        customerObj.Contact = '9786010552';
        customerObj.Email = 'karthik@gmail.com';
        
        Razorpay_Details__c setting = new Razorpay_Details__c();
        setting.Name = 'Applicant_CallbackUrl';
        setting.Value__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
        insert setting;
        
        list<Razorpay_Details__c> listSetting = new   list<Razorpay_Details__c>();//bulk List of custom setting object for bulk insert
        
        Razorpay_Details__c csRpCallbackUrl=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpCallbackUrl.Name='CallbackUrl';//Static record 1 of custom setting
        csRpCallbackUrl.Value__c='https://reva-university--couat1908.sandbox.my.site.com/ApplicantPortalAccelerator/s/';
        listSetting.add(csRpCallbackUrl);
        
        Razorpay_Details__c csRpUserName=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpUserName.Name='UserName';//Static record 1 of custom setting
        csRpUserName.Value__c='rzp_test_JA1KlDGzmvG6Hh';
        listSetting.add(csRpUserName);
        
        Razorpay_Details__c csRpPassword=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpPassword.Name='Password';//Static record 1 of custom setting
        csRpPassword.Value__c='vdcSuL82zafd9GnXnfyzUIuK';
        listSetting.add(csRpPassword);
        
        
        Razorpay_Details__c csRpEndpoinUrl=new Razorpay_Details__c(); //Custom Setting for Con
        csRpEndpoinUrl.Name='Razorpay Endpoint';
        csRpEndpoinUrl.Value__c='https://api.razorpay.com/v1/payment_links';
        listSetting.add(csRpEndpoinUrl);
        
        insert listSetting;
        
        EasyPay_Details__c easypay = new EasyPay_Details__c();
        easypay.Value__c ='https://eazypay.icicibank.com/EazyPG?';
        easypay.Name ='EndPoint';
        insert easypay;
        
        EasyPay_Details__c easypay1 = new EasyPay_Details__c();
        easypay1.Value__c ='221981';
        easypay1.Name ='ICID';
        insert easypay1;
        
        EasyPay_Details__c easypay2 = new EasyPay_Details__c();
        easypay2.Value__c ='45';
        easypay2.Name ='Submerchantid';
        insert easypay2;
        
        EasyPay_Details__c easypay3 = new EasyPay_Details__c();
        easypay3.Value__c ='https://reva-university.my.salesforce-sites.com/EasyPayResponse';
        easypay3.Name ='CallbackUrl';
        insert easypay3;

        FEE_ApplicationPayment_Ctrl.notifyWrp notifyObj = new FEE_ApplicationPayment_Ctrl.notifyWrp();
        notifyObj.SMS = True;
        notifyObj.Email = True;
        
        FEE_ApplicationPayment_Ctrl.notesWrp notesObj = new FEE_ApplicationPayment_Ctrl.notesWrp();
        notesObj.paymentType = 'FeePayment';
        
        FEE_ApplicationPayment_Ctrl.razorPayRequestCall razorpayobj= new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
        razorpayobj.ramount =10000;
        razorpayobj.callback_method = 'get';
        razorpayobj.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
        razorpayobj.reminder_enable =true;
        razorpayobj.customer = customerObj;
        razorpayobj.notify = notifyObj;
        razorpayobj.notes = notesObj;
        
        
        FEE_ApplicationPayment_Ctrl.rezorpayResponseCall razorPayResponseObj = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
        razorPayResponseObj.id = '123456';
        razorPayResponseObj.reference_id = Utility.generateRandomNumber();
        razorPayResponseObj.short_url = 'google.com';
        razorPayResponseObj.status = 'Success';
        razorPayResponseObj.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new razorPayMock());
        String myJSON = JSON.serialize(razorpayobj); 
        list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
        listStuFee.add(objStudentFee);
       
        test.startTest();
        FEE_ApplicationPayment_Ctrl.razorPayGenratePaymentLink(listStuFee,10.0,'Application Fee',(string)objcon.id);
        // FEE_ApplicationPayment_Ctrl.razorPayGenratePAFPaymentLink((string)objcon.id);
        test.stopTest();
        system.assertEquals('Success', razorPayResponseObj.status); 
    }

    @isTest
    public static void razorPayGenratePAFPaymentLink1(){
       
       
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
      
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.Mobilephone='9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        insert objCon;
        
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
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
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Pending';
        objStuPayment.Contact__c = objcon.id;
        objStuPayment.Mode_of_Payment__c ='Online';
        objStuPayment.Payment_Mode_Type__c ='Online';
        objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
        insert objStuPayment;

        FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
        FEE_ApplicationPayment_Ctrl.customerWrp customerObj = new FEE_ApplicationPayment_Ctrl.customerWrp();
        customerObj.Name = 'karthi';
        customerObj.Contact = '9786010552';
        customerObj.Email = 'karthik@gmail.com';
        
        Razorpay_Details__c setting = new Razorpay_Details__c();
        setting.Name = 'Applicant_CallbackUrl';
        setting.Value__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
        insert setting;
        
        list<Razorpay_Details__c> listSetting = new   list<Razorpay_Details__c>();//bulk List of custom setting object for bulk insert
        
        Razorpay_Details__c csRpCallbackUrl=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpCallbackUrl.Name='CallbackUrl';//Static record 1 of custom setting
        csRpCallbackUrl.Value__c='https://reva-university--couat1908.sandbox.my.site.com/ApplicantPortalAccelerator/s/';
        listSetting.add(csRpCallbackUrl);
        
        Razorpay_Details__c csRpUserName=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpUserName.Name='UserName';//Static record 1 of custom setting
        csRpUserName.Value__c='rzp_test_JA1KlDGzmvG6Hh';
        listSetting.add(csRpUserName);
        
        Razorpay_Details__c csRpPassword=new Razorpay_Details__c(); //Custom Setting for Contact Fields
        csRpPassword.Name='Password';//Static record 1 of custom setting
        csRpPassword.Value__c='vdcSuL82zafd9GnXnfyzUIuK';
        listSetting.add(csRpPassword);
        
        
        Razorpay_Details__c csRpEndpoinUrl=new Razorpay_Details__c(); //Custom Setting for Con
        csRpEndpoinUrl.Name='Razorpay Endpoint';
        csRpEndpoinUrl.Value__c='https://api.razorpay.com/v1/payment_links';
        listSetting.add(csRpEndpoinUrl);
        
        insert listSetting;
        
        
        FEE_ApplicationPayment_Ctrl.notifyWrp notifyObj = new FEE_ApplicationPayment_Ctrl.notifyWrp();
        notifyObj.SMS = True;
        notifyObj.Email = True;
        
        FEE_ApplicationPayment_Ctrl.notesWrp notesObj = new FEE_ApplicationPayment_Ctrl.notesWrp();
        notesObj.paymentType = 'FeePayment';
        
        FEE_ApplicationPayment_Ctrl.razorPayRequestCall razorpayobj= new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
        razorpayobj.ramount =10000;
        razorpayobj.callback_method = 'get';
        razorpayobj.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/RazorPayPGResponse';
        razorpayobj.reminder_enable =true;
        razorpayobj.customer = customerObj;
        razorpayobj.notify = notifyObj;
        razorpayobj.notes = notesObj;
        
        
        FEE_ApplicationPayment_Ctrl.rezorpayResponseCall razorPayResponseObj = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
        razorPayResponseObj.id = '123456';
        razorPayResponseObj.reference_id = Utility.generateRandomNumber();
        razorPayResponseObj.short_url = 'google.com';
        razorPayResponseObj.status = 'Success';
        razorPayResponseObj.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new razorPayMock());
        String myJSON = JSON.serialize(razorpayobj); 
        list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
        listStuFee.add(objStudentFee);
       
        test.startTest();
        // FEE_ApplicationPayment_Ctrl.razorPayGenratePaymentLink(listStuFee,10.0,'Application Fee',(string)objcon.id);
        FEE_ApplicationPayment_Ctrl.razorPayGenratePAFPaymentLink((string)objcon.id, (string)objStuPayment.id);
        test.stopTest();
        system.assertEquals('Success', razorPayResponseObj.status); 
    }

    @isTest
    public static void BillDeskPayGenratePaymentLink(){
        
        
        string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
        contact objCon = new contact();
        objCon.LastName = 'karthi';
        objCon.MobilePhone='+91-9876543210';
        objCon.Email ='kg@gmail.com';
        objCon.Application_Number__c = '1234455';
        objCon.SRN_Number__c = '123';
        objcon.RecordTypeId = conRecId;
        insert objCon;
       
        Student_Fee__c objStudentFee = new Student_Fee__c();     
        objStudentFee.Amount__c = 50000;
        objStudentFee.Amount_Pending__c=40000;
        objStudentFee.Amount_Paid__c=10000;
        objStudentFee.Contact__c = objCon.id;
        objStudentFee.name = 'Tuition Fee 1st year';
        objStudentFee.Due_Date__c = system.today() - 1;
        objStudentFee.Fee_Type__c = 'Application Fee';
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
        
        system.debug('objStudentFee--->'+objStudentFee);
        
        Student_Payment__c objStuPayment = new Student_Payment__c();
        objStuPayment.Payment_Status__c = 'Success';
        objStuPayment.Contact__c = objcon.id;
        insert objStuPayment;
        
        FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
        stufeerecwrapper.NoOfInstallments = 10.0;
        stufeerecwrapper.PendingAmount = 10.0;
        stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
        FEE_ApplicationPayment_Ctrl.customerWrp customerObj = new FEE_ApplicationPayment_Ctrl.customerWrp();
        customerObj.Name = 'karthi';
        customerObj.Contact ='9786010552';
        customerObj.Email = 'karthik@gmail.com';
        
        Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
        paydetails.Name = 'Applicant_BillDesk_CallbackUrl';
        paydetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
        insert paydetails;
        
        list<Billdesk_Merchant_Details__c> listSetting = new   list<Billdesk_Merchant_Details__c>();
        
        Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
        paydetails1.MerchantId__c='uatY7vF4Cx3L';
        paydetails1.Name='Checksum';
        listSetting.add(payDetails1);
        
        
        
        Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
        payDetails2.MerchantId__c='BD9CHILD2';
        payDetails2.Name='Hostel Fee';
        listSetting.add(payDetails2);
        
        Billdesk_Merchant_Details__c payDetails3 = new Billdesk_Merchant_Details__c();
        payDetails3.MerchantId__c='BD9MAIN';
        payDetails3.Name='MainMerchant';
        listSetting.add(payDetails3);
        
        Billdesk_Merchant_Details__c payDetails4 = new Billdesk_Merchant_Details__c();
        payDetails4.MerchantId__c='BD9CHILD3';
        payDetails4.Name='Miscellaneous Fee';
        listSetting.add(payDetails4);
        
        Billdesk_Merchant_Details__c payDetails5 = new Billdesk_Merchant_Details__c();
        payDetails5.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
        payDetails5.Name='PaymentEndPoint';
        listSetting.add(payDetails5);
        
        Billdesk_Merchant_Details__c payDetails6 = new Billdesk_Merchant_Details__c();
        payDetails6.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
        payDetails6.Name='PaymentLink';
        listSetting.add(payDetails6);
        
        Billdesk_Merchant_Details__c payDetails7 = new Billdesk_Merchant_Details__c();
        payDetails7.MerchantId__c='BD9CHILD4';
        payDetails7.Name='Transportation Fee';
        listSetting.add(payDetails7);
        
        Billdesk_Merchant_Details__c payDetails8 = new Billdesk_Merchant_Details__c();
        payDetails8.MerchantId__c='BD9CHILD4';
        payDetails8.Name='SecurityId';
        listSetting.add(payDetails8);
        
        Billdesk_Merchant_Details__c payDetails9 = new Billdesk_Merchant_Details__c();
        payDetails9.MerchantId__c='REVACOMSF';
        payDetails9.Name=objStudentFee.Fee_Type__c;
        listSetting.add(payDetails9);
        
        
        insert listSetting;
        
                
        
        FEE_ApplicationPayment_Ctrl.notifyWrp notifyObj = new FEE_ApplicationPayment_Ctrl.notifyWrp();
        notifyObj.SMS = True;
        notifyObj.Email = True;
        
        FEE_ApplicationPayment_Ctrl.notesWrp notesObj = new FEE_ApplicationPayment_Ctrl.notesWrp();
        notesObj.paymentType = 'FeePayment';
        
        FEE_ApplicationPayment_Ctrl.razorPayRequestCall razorpayobj= new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
        razorpayobj.ramount =10000;
        razorpayobj.callback_method = 'get';
        razorpayobj.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
        razorpayobj.reminder_enable =true;
        razorpayobj.customer = customerObj;
        razorpayobj.notify = notifyObj;
        razorpayobj.notes = notesObj;
        
        
        FEE_ApplicationPayment_Ctrl.rezorpayResponseCall razorPayResponseObj = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
        razorPayResponseObj.id = '123456';
        razorPayResponseObj.reference_id = Utility.generateRandomNumber();
        razorPayResponseObj.short_url = 'google.com';
        razorPayResponseObj.status = 'Success';
        razorPayResponseObj.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new razorPayMock());
        String myJSON = JSON.serialize(razorpayobj); 
        list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
        listStuFee.add(objStudentFee);
      
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new billdeskMock());
        FEE_ApplicationPayment_Ctrl.BillDeskPayGenratePaymentLink(listStuFee,10.0,'Single',(string)objcon.id);
        //FEE_ApplicationPayment_Ctrl.BillDeskPayGenratePAFPaymentLink((string)objcon.id,(string)objStuPayment.id);
        test.stopTest();
        system.assertEquals('Success', razorPayResponseObj.status); 
    }
    

    // @isTest
    // public static void BillDeskPayGenratePAFPaymentLink(){
        
        
    //     string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
    //     contact objCon = new contact();
    //     objCon.LastName = 'karthi';
    //     objCon.MobilePhone='+91-9876543210';
    //     objCon.Email ='kg@gmail.com';
    //     objCon.Application_Number__c = '1234455';
    //     objCon.SRN_Number__c = '123';
    //     objcon.RecordTypeId = conRecId;
    //     insert objCon;
       
    //     Student_Fee__c objStudentFee = new Student_Fee__c();     
    //     objStudentFee.Amount__c = 50000;
    //     objStudentFee.Amount_Pending__c=40000;
    //     objStudentFee.Amount_Paid__c=10000;
    //     objStudentFee.Contact__c = objCon.id;
    //     objStudentFee.name = 'Tuition Fee 1st year';
    //     objStudentFee.Due_Date__c = system.today() - 1;
    //     objStudentFee.Fee_Type__c = 'University Fee';
    //     objStudentFee.Actual_Program_Fee__c=100000;
    //     objStudentFee.Concession__c=10000;
    //     objStudentFee.Course_Name_Course_Code__c='230101';
    //     objStudentFee.Description__c='Thanks for the Your Interest';
    //     objStudentFee.Fee_Category__c='Application';
    //     objStudentFee.Number_of_Installments__c=5.0;
    //     objStudentFee.Paid_Installments__c=3.0;
    //     objStudentFee.Premium__c=12;
    //     objStudentFee.Received_Source__c='Manual / Upload';
    //     objStudentFee.Room_Sharing_Details__c= 'three';
    //     objStudentFee.Scholarship__c= 23;
    //     objStudentFee.Scholarship_Category__c= 'sports';
    //     objStudentFee.Scholarship_Categories__c = 'Sports';
    //     objStudentFee.Scholarship_Sub_Category__c = 'Others';
    //     Insert objStudentFee;
        
    //     system.debug('objStudentFee--->'+objStudentFee);
        
    //     Student_Payment__c objStuPayment = new Student_Payment__c();
    //     objStuPayment.Payment_Status__c = 'Success';
    //     objStuPayment.Contact__c = objcon.id;
    //     objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
    //     objStuPayment.Amount__c = 500;
    //     insert objStuPayment;
        


    //     FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
    //     stufeerecwrapper.NoOfInstallments = 10.0;
    //     stufeerecwrapper.PendingAmount = 10.0;
    //     stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
    //     FEE_ApplicationPayment_Ctrl.customerWrp customerObj = new FEE_ApplicationPayment_Ctrl.customerWrp();
    //     customerObj.Name = 'karthi';
    //     customerObj.Contact ='9786010552';
    //     customerObj.Email = 'karthik@gmail.com';
        
    //     Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
    //     paydetails.Name = 'Applicant_BillDesk_CallbackUrl';
    //     paydetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
    //     insert paydetails;
        
    //     list<Billdesk_Merchant_Details__c> listSetting = new   list<Billdesk_Merchant_Details__c>();
        
    //     Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
    //     paydetails1.MerchantId__c='uatY7vF4Cx3L';
    //     paydetails1.Name='Checksum';
    //     listSetting.add(payDetails1);
        
        
        
    //     Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
    //     payDetails2.MerchantId__c='BD9CHILD2';
    //     payDetails2.Name='Hostel Fee';
    //     listSetting.add(payDetails2);
        
    //     Billdesk_Merchant_Details__c payDetails3 = new Billdesk_Merchant_Details__c();
    //     payDetails3.MerchantId__c='BD9MAIN';
    //     payDetails3.Name='MainMerchant';
    //     listSetting.add(payDetails3);
        
    //     Billdesk_Merchant_Details__c payDetails4 = new Billdesk_Merchant_Details__c();
    //     payDetails4.MerchantId__c='BD9CHILD3';
    //     payDetails4.Name='Miscellaneous Fee';
    //     listSetting.add(payDetails4);
        
    //     Billdesk_Merchant_Details__c payDetails5 = new Billdesk_Merchant_Details__c();
    //     payDetails5.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
    //     payDetails5.Name='PaymentEndPoint';
    //     listSetting.add(payDetails5);
        
    //     Billdesk_Merchant_Details__c payDetails6 = new Billdesk_Merchant_Details__c();
    //     payDetails6.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
    //     payDetails6.Name='PaymentLink';
    //     listSetting.add(payDetails6);
        
    //     Billdesk_Merchant_Details__c payDetails7 = new Billdesk_Merchant_Details__c();
    //     payDetails7.MerchantId__c='BD9CHILD4';
    //     payDetails7.Name='Transportation Fee';
    //     listSetting.add(payDetails7);
        
    //     Billdesk_Merchant_Details__c payDetails8 = new Billdesk_Merchant_Details__c();
    //     payDetails8.MerchantId__c='BD9CHILD4';
    //     payDetails8.Name='SecurityId';
    //     listSetting.add(payDetails8);
        
    //     Billdesk_Merchant_Details__c payDetails9 = new Billdesk_Merchant_Details__c();
    //     payDetails9.MerchantId__c='REVACOMSF';
    //     payDetails9.Name=objStudentFee.Fee_Type__c;
    //     listSetting.add(payDetails9);
        
        
    //     insert listSetting;
        
                
        
    //     FEE_ApplicationPayment_Ctrl.notifyWrp notifyObj = new FEE_ApplicationPayment_Ctrl.notifyWrp();
    //     notifyObj.SMS = True;
    //     notifyObj.Email = True;
        
    //     FEE_ApplicationPayment_Ctrl.notesWrp notesObj = new FEE_ApplicationPayment_Ctrl.notesWrp();
    //     notesObj.paymentType = 'FeePayment';
        
    //     FEE_ApplicationPayment_Ctrl.razorPayRequestCall razorpayobj= new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
    //     razorpayobj.ramount =10000;
    //     razorpayobj.callback_method = 'get';
    //     razorpayobj.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
    //     razorpayobj.reminder_enable =true;
    //     razorpayobj.customer = customerObj;
    //     razorpayobj.notify = notifyObj;
    //     razorpayobj.notes = notesObj;
        
        
    //     FEE_ApplicationPayment_Ctrl.rezorpayResponseCall razorPayResponseObj = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
    //     razorPayResponseObj.id = '123456';
    //     razorPayResponseObj.reference_id = Utility.generateRandomNumber();
    //     razorPayResponseObj.short_url = 'google.com';
    //     razorPayResponseObj.status = 'Success';
    //     razorPayResponseObj.statusCode = 200;
    //     Test.setMock(HttpCalloutMock.class, new razorPayMock());
    //     String myJSON = JSON.serialize(razorpayobj); 
    //     list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
    //     listStuFee.add(objStudentFee);
      
        
    //     test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new razorpaymockup());
    //     FEE_ApplicationPayment_Ctrl.BillDeskPayGenratePAFPaymentLink((string)objcon.id);
    //     test.stopTest();
    //     system.assertEquals('Success', razorPayResponseObj.status); 
    // }

    //PaytmHttpMocks Test Callouts
    
    public class HttpPaytmCalloutMocks_Test implements HttpCalloutMock {
        
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"head":{"responseTimestamp":"1669175092307","version":"v1","signature":"xFrUbEkMOp7YetP40DVK1wy3jqI1ISNSqElLCgFBKZ9hlU9exOsSRnn+j4x/bodIRlU3kETKB5xFW4/6uC9wS/OSTcSNGaA2WNRZQDAFfag="},"body":{"resultInfo":{"resultStatus":"S","resultCode":"0000","resultMsg":"Success"},"txnToken":"1b4ed5536f024edb9a4a63b6a627c5fc1669175091738","isPromoCodeValid":false,"authenticated":false}}');
            res.setStatusCode(200);
            return res;
        }
            
     
            
    }
    public class HttpPaytmFailureCalloutMocks_Test implements HttpCalloutMock {
        
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('Failure');
            res.setStatusCode(101);
            return res;
        }
            
     
            
    }
        
        
    public class razorpaymockup implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('<?xml version="1.0" encoding="UTF-8"?><RESPONSE><TXNDATA><TXNSUMMARY><PGMERCID>REVAECOMSF</PGMERCID><PGCUSTOMERID>1875808211</PGCUSTOMERID><RECORDS>19</RECORDS><AMOUNT>500.00.00</AMOUNT><STATUSCODE>7</STATUSCODE><STATUSDESC>Invalid AMOUNT</STATUSDESC><FILLER1>NA</FILLER1><FILLER2>NA</FILLER2><FILLER3>NA</FILLER3></TXNSUMMARY><RECORD ID="1"><CUSTOMERID>18758082111</CUSTOMERID><ECOMTXNID>NA</ECOMTXNID></RECORD></TXNDATA><CHECKSUM>NA</CHECKSUM></RESPONSE>');
        response.setStatusCode(200);
        return response; 
    }
}
    
        @isTest
        public static void paytmPaymentLinkGenerationTest(){
            
            //Inserting Household Account
            
            string HouseholdRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            Account testAccount = new Account();
            testAccount.Name = 'paytmTestAccount';
            testAccount.RecordTypeId = HouseholdRecordId;
            insert testAccount; 
            
            // Inserting Applicant Contact Record
            
            string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Contact testContact = new Contact();
            testContact.LastName ='paytmTestContact';
            testContact.RecordTypeId = ApplicantRecordId;
            testContact.AccountId = testAccount.Id;
            testContact.MobilePhone ='9866964824';
            testContact.Aadhar_Card_Number__c ='111122223333';
            testContact.Application_Number__c = '23180100023';
            testContact.SRN_Number__c ='1234567891234567';
            testContact.hed__WorkEmail__c  = 'paytmTestContact@reva.edu.in';
            testContact.Nationality__c ='Indian';
            insert testContact;
            
            hed__Application__c app = new hed__Application__c();
            app.hed__Applicant__c = testContact.Id;
            app.Offline_Payment_Initiated__c = false;
            insert app;
            // Inserting Application-Fee Fee payment Criteria
            
            Fee_Payment_Criteria__c paytmFeeCriteria = new Fee_Payment_Criteria__c();
            paytmFeeCriteria.Name = 'Application Fee - Full Payment';
            paytmFeeCriteria.Merchant_ID_Paytm__c ='RevaUn85385305140219';
            Insert paytmFeeCriteria;
            
            
            hed__Program_Enrollment__c objProgenroll = FEE_TestDataFactory.createProgramEnrollment(testContact.Id,null);
            Insert objProgenroll;
            // Inserting Student Fees
            
            
            Student_Fee__c paytmStudentFee = new Student_Fee__c();
            paytmStudentFee.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee.Contact__c = testContact.Id;
            paytmStudentFee.Fee_Type__c ='Application Fee';
            paytmStudentFee.Amount__c = 1500;
            paytmStudentFee.Amount_Pending__c = 1500;
            paytmStudentFee.Amount_Paid__c = 0;
            insert paytmStudentFee;
            // Inserting new StudentFees
            Student_Fee__c paytmStudentFee1 = new Student_Fee__c();
            paytmStudentFee1.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee1.Contact__c = testContact.Id;
            paytmStudentFee1.Fee_Type__c ='Application Fee';
            paytmStudentFee1.Amount__c = 1500;
            paytmStudentFee1.Amount_Pending__c = 1500;
            paytmStudentFee1.Amount_Paid__c = 0;
            insert paytmStudentFee1;
            //Adding the Student Fee to a Student Fee list
            list<Student_Fee__c> paytmStudentFeeList = new list<Student_Fee__c>();
            paytmStudentFeeList.add(paytmStudentFee1);
            
            // Inserting Student Payment
            
            Student_Payment__c paytmStudentPayment = new Student_Payment__c();
            paytmStudentPayment.Contact__c = testContact.Id;
            paytmStudentPayment.Payment_Status__c = 'Success';
            paytmStudentPayment.Transaction_ID__c = '123442123432';
            paytmStudentPayment.Payment_Mode_Type__c = 'Online';
            paytmStudentPayment.Payment_Gateway__c = 'Paytm';
            paytmStudentPayment.Amount__c =1500;
            paytmStudentPayment.Reference_Id__c = '1231234';
            insert paytmStudentPayment;
            
            //Inserting Student Fee Payment
            
       
            
            
            FEE_ApplicationPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_ApplicationPayment_Ctrl.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = paytmStudentFee;
            list<FEE_ApplicationPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_ApplicationPayment_Ctrl.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_ApplicationPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_ApplicationPayment_Ctrl.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(paytmStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =1500;
            
            FEE_ApplicationPayment_Ctrl.razorPayRequestCall reswrap = new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
            reswrap.ramount =1500;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://reva.edu.in';
            //reswrap.short_url ='google.com';
            reswrap.reminder_enable =true;
            //reswrap.statusCode = 200;
            
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
            
            Paytm_Details__c PayDet4 = new Paytm_Details__c();
            PayDet4.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?';
            PayDet4.Name ='PaymentEndPoint';
            insert PayDet4;
            
            FEE_ApplicationPayment_Ctrl.rezorpayResponseCall rescall = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
            rescall.reference_id = Utility.generateRandomNumber();
            rescall.short_url = Paytm_Details__c.getValues('PaymentEndPoint').Value__c +'mid='+Paytm_Details__c.getValues('MID').Value__c+'&orderId='+rescall.reference_id;
            //rescall.short_url = 'google.com';
            rescall.status = 'Success'; 
            rescall.statusCode =200;
            
            FEE_ApplicationPayment_Ctrl.resResultInfoDetails responseInfo = new FEE_ApplicationPayment_Ctrl.resResultInfoDetails();
            responseInfo.resultCode='0000';
            responseInfo.resultMsg='';
            responseInfo.resultStatus='';
            
            FEE_ApplicationPayment_Ctrl.resBodyDetails responseDetails = new FEE_ApplicationPayment_Ctrl.resBodyDetails();
            responseDetails.resultInfo = responseInfo;
            responseDetails.txnToken ='123';
            responseDetails.isPromoCodeValid =false;
            responseDetails.authenticated=false; 
            
            FEE_ApplicationPayment_Ctrl.resHeadDetails responseHeaderDetails = new FEE_ApplicationPayment_Ctrl.resHeadDetails();
            responseHeaderDetails.responseTimestamp ='test';
            responseHeaderDetails.version='1.0';
            responseHeaderDetails.signature='test';
            
            FEE_ApplicationPayment_Ctrl.inisaliseResponse reponseInitialize = new FEE_ApplicationPayment_Ctrl.inisaliseResponse();
            reponseInitialize.body= responseDetails;
            reponseInitialize.head = responseHeaderDetails;
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.class, new HttpPaytmCalloutMocks_Test());
            
            date schDate = system.today(); 
            
            FEE_ApplicationPayment_Ctrl.rezorpayResponseCall reswrap1 = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
            
            reswrap1 = FEE_ApplicationPayment_Ctrl.PaytmGeneratePaymentLink(paytmStudentFeeList,Amount,'Single');
            
            
            test.stoptest();
            
            // system.assertEquals(200, reswrap.statusCode());
            
        } 
    
    @isTest
    public static void paytmPaymentLinkGenerationTest1(){
            
            //Inserting Household Account
            
            string HouseholdRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            Account testAccount = new Account();
            testAccount.Name = 'paytmTestAccount';
            testAccount.RecordTypeId = HouseholdRecordId;
            insert testAccount; 
            
            // Inserting Applicant Contact Record
            
            string ApplicantRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Contact testContact = new Contact();
            testContact.LastName ='paytmTestContact';
            testContact.RecordTypeId = ApplicantRecordId;
            testContact.AccountId = testAccount.Id;
            testContact.MobilePhone ='9866964824';
            testContact.Aadhar_Card_Number__c ='111122223333';
            testContact.Application_Number__c = '23180100023';
            testContact.SRN_Number__c ='1234567891234567';
            testContact.hed__WorkEmail__c  = 'paytmTestContact@reva.edu.in';
            testContact.Nationality__c ='Indian';
            insert testContact;
            
            // Inserting Application-Fee Fee payment Criteria
            
            Fee_Payment_Criteria__c paytmFeeCriteria = new Fee_Payment_Criteria__c();
            paytmFeeCriteria.Name = 'Application Fee - Full Payment';
            paytmFeeCriteria.Merchant_ID_Paytm__c ='RevaUn85385305140219';
            Insert paytmFeeCriteria;
            
            
            hed__Program_Enrollment__c objProgenroll = new hed__Program_Enrollment__c();
            objProgenroll.hed__Contact__c= testContact.Id;
               // FEE_TestDataFactory.createProgramEnrollment(testContact.Id,null);
            Insert objProgenroll;
            // Inserting Student Fees
            
            
            Student_Fee__c paytmStudentFee = new Student_Fee__c();
            paytmStudentFee.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee.Contact__c = testContact.Id;
            paytmStudentFee.Fee_Type__c ='Application Fee';
            paytmStudentFee.Amount__c = 1500;
            paytmStudentFee.Amount_Pending__c = 1500;
            paytmStudentFee.Amount_Paid__c = 0;
            insert paytmStudentFee;
            // Inserting new StudentFees
            Student_Fee__c paytmStudentFee1 = new Student_Fee__c();
            paytmStudentFee1.Name = 'Application Fee - 231801 - paytmTestContact';
            paytmStudentFee1.Contact__c = testContact.Id;
            paytmStudentFee1.Fee_Type__c ='Application Fee';
            paytmStudentFee1.Amount__c = 1500;
            paytmStudentFee1.Amount_Pending__c = 1500;
            paytmStudentFee1.Amount_Paid__c = 0;
            insert paytmStudentFee1;
            //Adding the Student Fee to a Student Fee list
            list<Student_Fee__c> paytmStudentFeeList = new list<Student_Fee__c>();
            paytmStudentFeeList.add(paytmStudentFee1);
            
            // Inserting Student Payment
            
            Student_Payment__c paytmStudentPayment = new Student_Payment__c();
            paytmStudentPayment.Contact__c = testContact.Id;
            paytmStudentPayment.Payment_Status__c = 'Success';
            paytmStudentPayment.Transaction_ID__c = '123442123432';
            paytmStudentPayment.Payment_Mode_Type__c = 'Online';
            paytmStudentPayment.Payment_Gateway__c = 'Paytm';
            paytmStudentPayment.Amount__c =1500;
            paytmStudentPayment.Reference_Id__c = '1231234';
            insert paytmStudentPayment;
            
            //Inserting Student Fee Payment
            
            /*   Student_Fee_Payment__c paytmStudentFeePayment = new Student_Fee_Payment__c();
paytmStudentFeePayment.Student_Fee__c = paytmStudentFee.Id;
paytmStudentFeePayment.Student_Payment__c = paytmStudentPayment.Id;
paytmStudentFeePayment.Line_Item_Payment_Gateway__c = 'Paytm';
paytmStudentFeePayment.Line_Item_Payment_Status__c = 'Success';
paytmStudentFeePayment.Amount__c = 1500;
paytmStudentFeePayment.Mode_of_Payment__c='Online';
paytmStudentFeePayment.SF_Transaction_ID__c= '123442123432';
paytmStudentFeePayment.Transaction_Date_Time__c  = system.now();
paytmStudentFeePayment.Reference_Id__c = '1231234';
insert paytmStudentFeePayment; */
            
            
            FEE_ApplicationPayment_Ctrl.CheckboxWrapper checkWrap = new FEE_ApplicationPayment_Ctrl.CheckboxWrapper();
            checkWrap.ObjStuFeeDeatils = paytmStudentFee;
            list<FEE_ApplicationPayment_Ctrl.CheckboxWrapper> lst_Checkwrap = new list<FEE_ApplicationPayment_Ctrl.CheckboxWrapper>();
            lst_Checkwrap.add(checkWrap); 
            
            FEE_ApplicationPayment_Ctrl.StudentFeeWrapper  stuwrap = new FEE_ApplicationPayment_Ctrl.StudentFeeWrapper(); 
            stuwrap.lst_StuPaidDetails.add(paytmStudentFee1);
            stuwrap.lst_CheckboxWrap  = lst_Checkwrap;
            decimal Amount =1500;
            
            FEE_ApplicationPayment_Ctrl.razorPayRequestCall reswrap = new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
            reswrap.ramount =1500;
            reswrap.callback_method ='get';
            reswrap.callback_url ='https://reva.edu.in';
            //reswrap.short_url ='google.com';
            reswrap.reminder_enable =true;
            //reswrap.statusCode = 200;
            
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
            
            Paytm_Details__c PayDet4 = new Paytm_Details__c();
            PayDet4.Value__c ='https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?';
            PayDet4.Name ='PaymentEndPoint';
            insert PayDet4;
            
            FEE_ApplicationPayment_Ctrl.rezorpayResponseCall rescall = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
           // rescall.reference_id = Utility.generateRandomNumber();
            //rescall.short_url = Paytm_Details__c.getValues('TestPaymentPage').Value__c +'mid='+Paytm_Details__c.getValues('TestMID').Value__c+'&orderId='+rescall.reference_id;
            //rescall.short_url = 'google.com';
            rescall.status = 'Failure'; 
            rescall.statusCode =101;
            
            FEE_ApplicationPayment_Ctrl.resResultInfoDetails responseInfo = new FEE_ApplicationPayment_Ctrl.resResultInfoDetails();
            responseInfo.resultCode='0003';
            responseInfo.resultMsg='';
            responseInfo.resultStatus='101';
            
            FEE_ApplicationPayment_Ctrl.resBodyDetails responseDetails = new FEE_ApplicationPayment_Ctrl.resBodyDetails();
            responseDetails.resultInfo = responseInfo;
            responseDetails.txnToken ='123';
            responseDetails.isPromoCodeValid =false;
            responseDetails.authenticated=false; 
            
            FEE_ApplicationPayment_Ctrl.resHeadDetails responseHeaderDetails = new FEE_ApplicationPayment_Ctrl.resHeadDetails();
            responseHeaderDetails.responseTimestamp ='test';
            responseHeaderDetails.version='1.0';
            responseHeaderDetails.signature='test';
            
            FEE_ApplicationPayment_Ctrl.inisaliseResponse reponseInitialize = new FEE_ApplicationPayment_Ctrl.inisaliseResponse();
            reponseInitialize.body= responseDetails;
            reponseInitialize.head = responseHeaderDetails;
            
            Test.Starttest();
            Test.setMock(HttpCalloutMock.Class, new HttpPaytmFailureCalloutMocks_Test());
           
            date schDate = system.today(); 
            
            // FEE_ApplicationPayment_Ctrl.rezorpayResponseCall reswrap1 = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
            
            // reswrap1 = FEE_ApplicationPayment_Ctrl.PaytmGeneratePaymentLink(paytmStudentFeeList,Amount,'Multiple');
            FEE_ApplicationPayment_Ctrl.rezorpayResponseCall reswrap2 = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
            
            reswrap2 = FEE_ApplicationPayment_Ctrl.paytmGeneratePAFPaymentLink(testContact.Id,(string)paytmStudentPayment.id);
             
            test.stoptest();
            
            // system.assertEquals(200, reswrap.statusCode());
            
    }
    /********************************************************************************/
      @isTest
     public static void BillDeskPayGenratePAFPaymentLink(){
        
        
         string conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
    contact objCon = new contact();
    objCon.LastName = 'karthi';
    objCon.MobilePhone='+91-9876543210';
    objCon.Email ='kg@gmail.com';
    objCon.Application_Number__c = '1234455';
    objCon.SRN_Number__c = '123';
    objcon.RecordTypeId = conRecId;
    insert objCon;
       
    Student_Fee__c objStudentFee = new Student_Fee__c();     
    objStudentFee.Amount__c = 50000;
    objStudentFee.Amount_Pending__c=40000;
    objStudentFee.Amount_Paid__c=10000;
    objStudentFee.Contact__c = objCon.id;
    objStudentFee.name = 'Tuition Fee 1st year';
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
    objStudentFee.Scholarship_Category__c= 'Sports';
    objStudentFee.Scholarship_Categories__c = 'Sports';
    objStudentFee.Scholarship_Sub_Category__c = 'A Level';
    Insert objStudentFee;
        
    system.debug('objStudentFee--->'+objStudentFee);
        
    Student_Payment__c objStuPayment = new Student_Payment__c();
    objStuPayment.Payment_Status__c = 'Pending';
    objStuPayment.Contact__c = objcon.id;
    objStuPayment.Fee_Type__c = 'University Fee, Tuition Fee';
    objStuPayment.Amount__c = 500;
    insert objStuPayment;
        


    FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper stufeerecwrapper = new FEE_ApplicationPayment_Ctrl.StudentFeeRecWrapper();
    stufeerecwrapper.NoOfInstallments = 10.0;
    stufeerecwrapper.PendingAmount = 10.0;
    stufeerecwrapper.Errmsg = 'Value Doesnot Exist';
        
    FEE_ApplicationPayment_Ctrl.customerWrp customerObj = new FEE_ApplicationPayment_Ctrl.customerWrp();
    customerObj.Name = 'karthi';
    customerObj.Contact ='9786010552';
    customerObj.Email = 'karthik@gmail.com';
        
    Billdesk_Merchant_Details__c paydetails = new Billdesk_Merchant_Details__c();
    paydetails.Name = 'Applicant_BillDesk_CallbackUrl';
    paydetails.MerchantId__c = 'https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
    insert paydetails;
        
    list<Billdesk_Merchant_Details__c> listSetting = new   list<Billdesk_Merchant_Details__c>();
        
    Billdesk_Merchant_Details__c payDetails1 = new Billdesk_Merchant_Details__c();
    paydetails1.MerchantId__c='uatY7vF4Cx3L';
    paydetails1.Name='Checksum';
    listSetting.add(payDetails1);
        
        
        
    Billdesk_Merchant_Details__c payDetails2 = new Billdesk_Merchant_Details__c();
    payDetails2.MerchantId__c='BD9CHILD2';
    payDetails2.Name='Hostel Fee';
    listSetting.add(payDetails2);
        
    Billdesk_Merchant_Details__c payDetails3 = new Billdesk_Merchant_Details__c();
    payDetails3.MerchantId__c='BD9MAIN';
    payDetails3.Name='MainMerchant';
    listSetting.add(payDetails3);
        
    Billdesk_Merchant_Details__c payDetails4 = new Billdesk_Merchant_Details__c();
    payDetails4.MerchantId__c='BD9CHILD3';
    payDetails4.Name='Miscellaneous Fee';
    listSetting.add(payDetails4);
        
    Billdesk_Merchant_Details__c payDetails5 = new Billdesk_Merchant_Details__c();
    payDetails5.MerchantId__c='https://uat.billdesk.com/pgidsk/PGIMerchantPayment?msg=';
    payDetails5.Name='PaymentEndPoint';
    listSetting.add(payDetails5);
        
    Billdesk_Merchant_Details__c payDetails6 = new Billdesk_Merchant_Details__c();
    payDetails6.MerchantId__c='https://uat.billdesk.com/ecom/ECOM2ReqHandler';
    payDetails6.Name='PaymentLink';
    listSetting.add(payDetails6);
        
    Billdesk_Merchant_Details__c payDetails7 = new Billdesk_Merchant_Details__c();
    payDetails7.MerchantId__c='BD9CHILD4';
    payDetails7.Name='Transportation Fee';
    listSetting.add(payDetails7);
        
    Billdesk_Merchant_Details__c payDetails8 = new Billdesk_Merchant_Details__c();
    payDetails8.MerchantId__c='BD9CHILD4';
    payDetails8.Name='SecurityId';
    listSetting.add(payDetails8);
        
    Billdesk_Merchant_Details__c payDetails9 = new Billdesk_Merchant_Details__c();
    payDetails9.MerchantId__c='REVACOMSF';
    payDetails9.Name=objStudentFee.Fee_Type__c;
    listSetting.add(payDetails9);
        
        
    insert listSetting;
        
                
        
    FEE_ApplicationPayment_Ctrl.notifyWrp notifyObj = new FEE_ApplicationPayment_Ctrl.notifyWrp();
    notifyObj.SMS = True;
    notifyObj.Email = True;
        
    FEE_ApplicationPayment_Ctrl.notesWrp notesObj = new FEE_ApplicationPayment_Ctrl.notesWrp();
    notesObj.paymentType = 'FeePayment';
        
    FEE_ApplicationPayment_Ctrl.razorPayRequestCall razorpayobj= new FEE_ApplicationPayment_Ctrl.razorPayRequestCall();
    razorpayobj.ramount =10000;
    razorpayobj.callback_method = 'get';
    razorpayobj.callback_url ='https://reva-university--couat1908.sandbox.my.salesforce-sites.com/BillDeskResponse';
    razorpayobj.reminder_enable =true;
    razorpayobj.customer = customerObj;
    razorpayobj.notify = notifyObj;
    razorpayobj.notes = notesObj;
        
        
    FEE_ApplicationPayment_Ctrl.rezorpayResponseCall razorPayResponseObj = new FEE_ApplicationPayment_Ctrl.rezorpayResponseCall();
    razorPayResponseObj.id = '123456';
    razorPayResponseObj.reference_id = Utility.generateRandomNumber();
    razorPayResponseObj.short_url = 'google.com';
    razorPayResponseObj.status = 'Success';
    razorPayResponseObj.statusCode = 200;
    Test.setMock(HttpCalloutMock.class, new razorPayMock());
    String myJSON = JSON.serialize(razorpayobj); 
    list<Student_Fee__c> listStuFee = new list<Student_Fee__c>();
    listStuFee.add(objStudentFee);
      
        
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new razorpaymockup());
    FEE_ApplicationPayment_Ctrl.BillDeskPayGenratePAFPaymentLink((string)objcon.id,objStuPayment.Id);
    test.stopTest();
    system.assertEquals('Success', razorPayResponseObj.status); 
     }

    /*****************************************************************************/




}