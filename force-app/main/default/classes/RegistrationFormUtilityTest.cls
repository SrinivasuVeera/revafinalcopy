@isTest
public class RegistrationFormUtilityTest {
    @isTest
    public static void  updateLeadPriorConversionmethod(){
        
        Lead leadCreation = new Lead();
        leadCreation.LastName = 'John';
        leadCreation.Company = 'NewIdea';
        leadCreation.Email = 'john@gmail.com';
        leadCreation.School__c = 'School of Civil Engineering';
        leadCreation.Program_Name_Display__c = 'B.Tech. - Civil Engineering';
        leadCreation.Category__c = 'Non-Resident Indian(NRI)';
        leadCreation.MobilePhone = '+91-9876543212';
        
        insert leadCreation;
        string leadId = leadCreation.Id;
        
        
        lead testLead = [select id, email,school__c from lead where id=:leadId];
        system.assert(testLead!=null,'Lead should not be empty');
        system.assertEquals('john@gmail.com', testLead.Email, 'Email is Not Correct');
        
        //Account Creation 
        Account createAccount = new Account();
        createAccount.name = 'School of Civil Engineering';
        insert createAccount;
        system.debug('Account id:'+createAccount.Id);
        system.debug('Account Name: '+createAccount.name);
        
        
        //program Batch record creation
        hed__Program_Plan__c programBatchRec = new hed__Program_Plan__c();
        programBatchRec.name =  'School of Civil Engineering';
        programBatchRec.hed__Account__c = createAccount.id;
        insert programBatchRec;
        system.debug('Program Batch Account Id:' +programBatchRec.hed__Account__c);
        system.debug('Program Batch Account Name:' +programBatchRec.hed__account__r.name);
        
        // Fee Master Record Creation
        Fee_Master__c feeMasterCreation = new Fee_Master__c();
        feeMasterCreation.Program_Batch__c  = programBatchRec.id;
        feeMasterCreation.Fee_Type__c = 'Application Fee';
        feeMasterCreation.Program_Name_Display__c = 'B.Tech. - Civil Engineering';
        feeMasterCreation.Applicant_Category__c = 'Non-Resident Indian(NRI)';
        feeMasterCreation.Application_Number_Prefix__c = '230401';
        insert feeMasterCreation;
        string feeMasterId= feeMasterCreation.Id;
        system.debug('Fee Master Program Batch:'+ feeMasterCreation.Program_Batch__c);
        
        Fee_Master__c feeMasterInfo = [select id,Program_Batch__c,Program_Name_Display__c,Application_Number_Prefix__c from Fee_Master__c where id=:feeMasterId];
        system.assertEquals('230401', feeMasterInfo.Application_Number_Prefix__c, 'Application Number Prefix is Not Correct');
        
        // Fee Payment Criteria
        Fee_payment_Criteria__c fee_Criteria = new Fee_payment_Criteria__c();
        fee_Criteria.Name = 'Application Fee - Full Payment';
        insert fee_Criteria;
        
        // Generate OTP method
        list<RegistrationFormUtility.UtilityRequest> otpList = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest otpInstance = new RegistrationFormUtility.UtilityRequest();
        otpInstance.invocationType = 'GENERATE_OTP';
        OTP_Config__mdt otpConfig = OTP_Config__mdt.getInstance('Applicant_Registration_OTP');
        
        system.assertEquals(otpConfig.OTP_Length__c, 4, 'OTP Length should be 4');
        otpList.add(otpInstance);
        
        // LEAD_UPDATION_PRIOR_CONVERSION Request
        
        list<RegistrationFormUtility.UtilityRequest> leadPriorUpdate = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest leadPriorInstance = new RegistrationFormUtility.UtilityRequest();
        leadPriorInstance.leadId = leadId;
        leadPriorInstance.generatedOTP = '3452';
        leadPriorInstance.invocationType = 'LEAD_UPDATION_PRIOR_CONVERSION';
        leadPriorUpdate.add(leadPriorInstance);
        
        //Lead Conversion Request*/
        
        list<RegistrationFormUtility.UtilityRequest> leadConversion = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest leadConversionInstance = new RegistrationFormUtility.UtilityRequest();
        leadConversionInstance.feeMasterId = feeMasterId;
        leadConversionInstance.leadId = leadId;
        leadConversionInstance.invocationType = 'LEAD_CONVERSION';
        leadConversion.add(leadConversionInstance);
        
        // Email Validate - xyz@domain.com
        list<RegistrationFormUtility.UtilityRequest> leadEmailValidate = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest leadEmailInstance = new RegistrationFormUtility.UtilityRequest();
        leadEmailInstance.email = 'george@gmail.com';
        leadEmailInstance.invocationType = 'EMAIL_VERIFICATION';
        leadEmailValidate.add(leadEmailInstance);
        
        // Email Validate - xyz@domain.edu.com
        list<RegistrationFormUtility.UtilityRequest> leadEmailValidates = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest leadEmailInstances = new RegistrationFormUtility.UtilityRequest();
        leadEmailInstances.email = 'george@domain.edu.com';
        leadEmailInstances.invocationType = 'EMAIL_VERIFICATION';
        leadEmailValidates.add(leadEmailInstances);
        
        //UNLOCK_CONTACT_RECORD
        list<RegistrationFormUtility.UtilityRequest> unlockContactRecord = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest unlockContactRecordInstances = new RegistrationFormUtility.UtilityRequest();
        unlockContactRecordInstances.invocationType = 'UNLOCK_CONTACT_RECORD';
        unlockContactRecord.add(unlockContactRecordInstances);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorRegistration());
        RegistrationFormUtility.decideByInvocation(otpList);
        RegistrationFormUtility.getSchoolPrograms('ApplicationFee');
        RegistrationFormUtility.getSchoolPrograms('CET');
        RegistrationFormUtility.getChangeSchoolPrograms('PG', 'Master of Architecture');
        RegistrationFormUtility.decideByInvocation(leadPriorUpdate);
        RegistrationFormUtility.decideByInvocation(leadConversion);
        RegistrationFormUtility.getSiteURL();
        RegistrationFormUtility.decideByInvocation(leadEmailValidate);
        RegistrationFormUtility.decideByInvocation(leadEmailValidates);
        RegistrationFormUtility.sendEmailRevisitOtpLead(leadCreation.Id);
        RegistrationFormUtility.decideByInvocation(unlockContactRecord);
        
        Test.stopTest();
    }
    
    @isTest
    public static void  generateReceiptMethod(){
        Id conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Id eduRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Id schoolRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id programRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        String conEmail= 'john@gmail.com';
        
        Account acc = new Account();  // Household Account
        acc.Name = 'test1';
        acc.RecordTypeId = accRecId;
        insert acc;
        
        Account eduAccount = new Account(); // Educational Institution Account - No Parent Account
        eduAccount.Name = 'REVA University';
        eduAccount.RecordTypeId = eduRecId;
        insert eduAccount;
        
        Account eduInsAccount = new Account(); // Educational Institution Account - REVA University Parent Account
        eduInsAccount.Name = 'Faculty of Engineering and Technology';
        eduInsAccount.RecordTypeId = eduRecId;
        eduInsAccount.ParentId = eduAccount.Id;
        insert eduInsAccount;
        
        Account schoolacc = new Account();  // University Department Account - Parent Educational account
        schoolacc.Name = 'School of Civil Engineering';
        schoolacc.RecordTypeId = schoolRecId;
        schoolacc.ParentId = eduInsAccount.Id;
        insert schoolacc;
        
        Account programacc = new Account();  // Academic Program Account - Parent - Unviersity Account
        programacc.Name = 'B. Tech in Civil Engineering';
        programacc.RecordTypeId = programRecId;
        programacc.ParentId = schoolacc.Id;
        insert programacc;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email=conEmail;
        testContact.Application_Number__c = '2211001120';
        testContact.AccountId = acc.Id;
        testContact.School__c = schoolacc.Id;
        testContact.Primary_Academic_Program__c = programacc.Id;
        testContact.RecordTypeId = conRecId;
        testContact.Quota__c = 'Management Quota';
        testContact.Enrollment_Type__c = 'Regular Entry';
        testContact.Admission_Mode__c = 'UQ';
        insert testContact;
        
        
        Student_Payment__c stpy = new Student_Payment__c();
        stpy.Transaction_ID__c='8284723HB';
        //stpy.Payment_Date__c= system.today();
        stpy.Payment_Gateway__c ='BillDesk';
        stpy.Mode_of_Payment__c ='online';  
        
        stpy.Contact__c= testContact.id;
        insert stpy;
        
        //test content version 
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1';
        content.ContentUrl ='www.google.com';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.FirstPublishLocationId=stpy.Id;
        insert content;
        
        
        Student_Payment__c stp = new Student_Payment__c();
        stp.Payment_Gateway__c ='Razorpay';
        stp.Payment_Mode_Type__c = 'online';
        stp.Transaction_ID__c ='1123njs23';
        stp.Contact__c =testContact.Id;
        insert stp;
        
        Student_Fee__c studentFeeRec = new Student_Fee__c();
        studentFeeRec.Amount_Paid__c = 1000;
        studentFeeRec.Description__c = 'No Fee. 100% waived OFF';
        studentFeeRec.Amount_Pending__c = 1000;
        studentFeeRec.Amount__c = 1000;
        studentFeeRec.Contact__c = testContact.Id;
        studentFeeRec.Fee_Type__c = 'Application Fee';
        insert studentFeeRec;
        
        // PUC Drive 
        list<RegistrationFormUtility.UtilityRequest> PUCValidate = new list<RegistrationFormUtility.UtilityRequest>();
        RegistrationFormUtility.UtilityRequest PUCInstance = new RegistrationFormUtility.UtilityRequest();
        PUCInstance.email = 'george@gmail.com';
        PUCInstance.invocationType = 'PUC_DRIVE';
        PUCInstance.contactId =  testContact.Id;
        PUCValidate.add(PUCInstance);
        
        
        Test.startTest();
        
        RegistrationFormUtility.generateReceipt(stpy.id,stp.Transaction_ID__c, stp.Payment_Gateway__c);
        RegistrationFormUtility.sendReceipt(stp.Id,content.id);
        RegistrationFormUtility.getPortalContactId();
        RegistrationFormUtility.sendEmailRevisitOtpContact(testContact.Id);
        RegistrationFormUtility.UnlockContactRecord(testContact.Id);
        RegistrationFormUtility.getChangeSchoolPrograms(testContact.Program_Type__c, testContact.School_Name__c);
        RegistrationFormUtility.decideByInvocation(PUCValidate);
        RegistrationFormUtility.isSandboxOrg();
        Test.stopTest();
    }
    
    @isTest
    public static void studentcont(){
        
        
        Id conRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        Id schoolRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        Id programRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        String conEmail= 'john@gmail.com';
        
        Account acc = new Account();
        acc.Name = 'test1';
        acc.RecordTypeId = accRecId;
        insert acc;
        
        Account schoolacc = new Account();
        schoolacc.Name = 'School of Civil Engineering';
        schoolacc.RecordTypeId = schoolRecId;
        insert schoolacc;
        
        Account programacc = new Account();
        programacc.Name = 'B. Tech in Civil Engineering';
        programacc.RecordTypeId = programRecId;
        programacc.ParentId = schoolacc.Id;
        insert programacc;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email=conEmail;
        testContact.Application_Number__c = '2211001120';
        testContact.Account = acc;
        testContact.School__c = schoolacc.Id;
        testContact.Primary_Academic_Program__c = programacc.Id;
        testContact.RecordTypeId = conRecId;
        insert testContact;
        
        Student_Payment__c stp = new Student_Payment__c();
        stp.Payment_Gateway__c ='Razorpay';
        stp.Payment_Mode_Type__c = 'Online';
        stp.Transaction_ID__c ='1123njs23';
        stp.Contact__c =testContact.Id;
        insert stp;
        ApexPages.CurrentPage().getparameters().put('id',stp.id);
        ApexPages.CurrentPage().getparameters().put('transactionId','1123njs23');
        
        StudentPaymentController studCont = new StudentPaymentController();
        studCont.studentPayment = stp;
        studCont.transactionId ='1123njs23';
        
        Test.startTest();
        studCont.processPayment();
        
        Test.stopTest(); 
        
        
    }
    
    public class MockHttpResponseGeneratorRegistration implements HttpCalloutMock{
    
    public HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"transactionId":25025729248,"state":"SUBMIT_ACCEPTED",'+
                    '"description":"Message submitted successfully","pdu":1,"corelationId":null}');
        res.setStatusCode(200);
        return res;
    }

}
}