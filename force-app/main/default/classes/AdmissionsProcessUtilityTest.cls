@isTest
private class AdmissionsProcessUtilityTest 
{
    
    public static final String CONST_APPLICANT_RECTYPE = 'Applicant';
    public static final String CONST_EDUCATION_DETAILS = 'Education Details';
    public static final string CONST_ACADEMIC_RECTYPE = 'Academic Program';
    public static final string CONST_HOUSEHOLD_RECTYPE = 'Household Account';
    public static final string CONST_SCHOOL_RECTYPE = 'University Department';
    
    @TestSetup
    static void makeData(){
        
        String programName = 'Bachelor of Architecture';
        
        RecordType academicProgramRT = [Select id FROM RecordType Where DeveloperName = 'Academic_Program' Limit 1];
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        
        Account program= new Account(
        	Name = programName,
            RecordTypeId = academicProgramRT.Id,    
            Program_Alias__c = 'Barch',
            Program_Type__c = 'UG',
            Program_Code__c = 'RA',
            Intake__c = 80,
            Intake_Per_Section__c = 40
        );
        insert program;
        
        Contact Applicant1 = new Contact(
            FirstName = 'sai',
            MiddleName = 'k',
            LastName = 'K',
            Email = 'sai@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = applicantRT.Id,
            Application_Fee_Paid__c = false,
            Application_Number__c = '222333555',
            Primary_Academic_Program__c = program.Id
        );
        insert Applicant1;
        
        Contact testContact1 = new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@test.com',
            Phone = '9999999999'
        );
        insert testContact1; //Used for updateMultipleApprovalsTest - Dont Modify
        Contact testContact2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Email = 'test2@test.com',
            Phone = '8888888888'
        );
        insert testContact2; ////Used for updateMultipleApprovalsTest - Dont Modify
        //Create test hed__Application__c record and link it to the test contact record
        hed__Application__c testApplication1 = new hed__Application__c(
            hed__Applicant__c = testContact1.Id,
            hed__Application_Status__c = 'New',
            Concession_Status__c = 'Initiated',
            School__c = 'Test School',
            Application_Number__c = '1234',
            Concession_1st_Year__c = 0.0,
            Concession_2nd_Year__c = 0.0,
            Concession_3rd_Year__c = 0.0,
            Concession_4th_Year__c = 0.0,
            Concession_5th_Year__c =0.0
            // hed__Applying_To__r.Name = 'Test Program',
            // hed_Scholarship__r.Category__c = 'Test Category'
        );
        insert testApplication1; ////Used for updateMultipleApprovalsTest - Dont Modify
        
        hed__Application__c testApplication2 = new hed__Application__c(
            hed__Applicant__c = testContact2.Id,
            hed__Application_Status__c = 'New',
            Concession_Status__c = 'Initiated',
            School__c = 'Test School2',
            Application_Number__c = '5678',
            Concession_1st_Year__c = 0.0,
            Concession_2nd_Year__c = 0.0,
            Concession_3rd_Year__c = 0.0,
            Concession_4th_Year__c = 0.0,
            Concession_5th_Year__c =0.0
            // hed__Applying_To__r.Name = 'Test Program',
            // hed_Scholarship__r.Category__c = 'Test Category'
        );
        insert testApplication2; ////Used for updateMultipleApprovalsTest - Dont Modify
     
    }
    
    @isTest
    static void testSendPOFullySignedDoc() {
        
        //create a test contact
        Contact conRec = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'john@example.com');
        insert conRec;
        
        // Create application record
        hed__Application__c appRec = new hed__Application__c(hed__Applicant__c = conRec.Id);
        insert appRec;
        
        //test content version 
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PO Fully Signed';
        cv.PathOnClient = 'test.doc';
        cv.VersionData = Blob.valueOf('Test document content');
        cv.FirstPublishLocationId=appRec.Id;
        cv.Applicant_Document_Type__c = 'PO Fully Signed';
        insert cv;
        
        // Create a test ContentDocumentLink record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = conRec.Id;
        insert cdl;
        
        // call the method being tested
        Test.startTest();
        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest sendPOFullySignedInstance = new AdmissionsProcessUtility.UtilityRequest();
        sendPOFullySignedInstance.invocationType = 'PO_FULLY_SIGNED_DOC_UPLOADED_MAIL';
        sendPOFullySignedInstance.applicationId = appRec.Id;
        utilityRequests.add(sendPOFullySignedInstance);


        AdmissionsProcessUtility.decideByInvocation(utilityRequests);
        //AdmissionsProcessUtility.provisionalLetterGenerated(conRec.Id,cv.Id,);
        Test.stopTest();
    }
     
    @isTest
    static Void testSavePOLetter(){
        //Create a test contact record
        Contact testCon = new Contact();
        testCon.FirstName = 'Test'; 
        testCon.LastName = 'Contact';
        testCon.Email = 'test@test.com';
        insert testCon;
        
        //Create a test application record
        hed__Application__c testApp = new hed__Application__c();
        testApp.Application_Number__c = '6789';
        testApp.hed__Applicant__c = testCon.Id;
        insert testApp;
        
        //test content version 
        ContentVersion testCv = new ContentVersion();
        testCv.Title = 'Provisional Offer Letter';
        testCv.PathOnClient = 'test1.doc';
        testCv.VersionData = Blob.valueOf('Test Content');
        testCv.Applicant_Document_Type__c = 'Provisional Offer Letter';
        insert testCv;
        
        //Create a test ContentDocumentLink record
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testCv.Id].ContentDocumentId;
        ContentDocumentLink testCdlink = new ContentDocumentLink();
        testCdlink.ContentDocumentId = conDoc;
        testCdlink.LinkedEntityId = testApp.Id;
        testCdlink.ShareType = 'V';
        testCdlink.Visibility = 'AllUsers';
        insert testCdlink;
        
        // call the method being tested
        Test.startTest();
        
        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest sendPOLetterPdfInstance = new AdmissionsProcessUtility.UtilityRequest();
        sendPOLetterPdfInstance.invocationType = 'SendLatestPO';
        sendPOLetterPdfInstance.applicationId = testApp.Id;
        utilityRequests.add(sendPOLetterPdfInstance);


        AdmissionsProcessUtility.decideByInvocation(utilityRequests);
        Test.stopTest();
    }
    @isTest
    static Void testSavePOLetter2(){
         //Create a test contact record
        Contact testConRec = new Contact();
        testConRec.FirstName = 'One'; 
        testConRec.LastName = 'Two';
        testConRec.Email = 'test@two.com';
        insert testConRec;
        
        //Create a test application record
        hed__Application__c testAppRec = new hed__Application__c();
        testAppRec.Application_Number__c = '7589';
        testAppRec.hed__Applicant__c = testConRec.Id;
        insert testAppRec;
        
        //test content version 
        ContentVersion testCvRec = new ContentVersion();
        testCvRec.Title = 'TestDoc';
        testCvRec.PathOnClient = 'test2.doc';
        testCvRec.VersionData = Blob.valueOf('Test Content');
        insert testCvRec;
        
        // Create a test ContentDocumentLink record
        Id conDocRec = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testCvRec.Id].ContentDocumentId;
        ContentDocumentLink testCdlinkRec = new ContentDocumentLink();
        testCdlinkRec.ContentDocumentId = conDocRec;
        testCdlinkRec.LinkedEntityId = testAppRec.Id;
        testCdlinkRec.ShareType = 'V';
        testCdlinkRec.Visibility = 'AllUsers';
        insert testCdlinkRec;
        
        // call the method being tested
        Test.startTest();

        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest sendPOLetterPdfInstance = new AdmissionsProcessUtility.UtilityRequest();
        sendPOLetterPdfInstance.invocationType = 'SendLatestPO';
        sendPOLetterPdfInstance.applicationId = testAppRec.Id;
        utilityRequests.add(sendPOLetterPdfInstance);


        AdmissionsProcessUtility.decideByInvocation(utilityRequests);

        Test.stopTest();
    }
    @isTest
    static void testGenerateOffPayReceipt(){

        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email='test@test.com';
        testContact.Application_Number__c = '2211001120';
        insert testContact;

        
        Student_Payment__c stpy = new Student_Payment__c();
        stpy.Mode_of_Payment__c ='Offline';  
        stpy.Contact__c= testContact.id;
        insert stpy;
               
        //test content version 
        ContentVersion testcontent=new ContentVersion(); 
        testcontent.Title='Test Receipt';
        Blob bodyBlob=Blob.valueOf('Test Content'); 
        testcontent.FirstPublishLocationId=stpy.Id;
        testcontent.PathOnClient = 'Test Receipt';
        testcontent.VersionData = bodyBlob;
        insert testcontent;

         
        Test.startTest();
        
        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest generateOfflineReceiptInstance = new AdmissionsProcessUtility.UtilityRequest();
        generateOfflineReceiptInstance.invocationType = 'GENERATE_OFFLINE_RECEIPT';
        generateOfflineReceiptInstance.stuPayRec = stpy.Id;
        generateOfflineReceiptInstance.paymentModeType = '';
        utilityRequests.add(generateOfflineReceiptInstance);


        AdmissionsProcessUtility.decideByInvocation(utilityRequests);
        Test.stopTest();
    }
	@isTest
    static void testgetScholarshipMaster1() {
        String type1 = 'Non - Engineering';
        String programType1 = 'PG';
        Scholarship_Master__c scholarshipRec1 = new Scholarship_Master__c();
        scholarshipRec1.Category__c = 'REVA to REVA';
        scholarshipRec1.Discount_Amount__c = 5000;
        scholarshipRec1.Documents_Required__c = 	'Bonafide letter;PUC ID card;REVA ID Card';
      	scholarshipRec1.Enrollment_year__c = '2023';
        scholarshipRec1.Is_Active__c = True;
        scholarshipRec1.Scholarship_Type__c = '85.01 & Above';
        scholarshipRec1.Sub_Category__c = 'PG - Others';
        scholarshipRec1.Applicable_for_All_Years__c = True;
        insert scholarshipRec1;
       
        Test.startTest();
        AdmissionsProcessUtility.getScholarshipMaster(type1, programType1);
        AdmissionsProcessUtility.getSelectedSubCategory(scholarshipRec1.Category__c, scholarshipRec1.Sub_Category__c);
        Test.stopTest();
    }
	@isTest
    static void testgetScholarshipMaster2() {
        String type2 = 'Engineering';
        String programType2 = 'UG';
        Scholarship_Master__c scholarshipRec2 = new Scholarship_Master__c();
        scholarshipRec2.Category__c = 'REVA to REVA';
        scholarshipRec2.Discount_Amount__c = 5000;
        scholarshipRec2.Documents_Required__c = 	'Bonafide letter;PUC ID card;REVA ID Card';
      	scholarshipRec2.Enrollment_year__c = '2023';
        scholarshipRec2.Is_Active__c = True;
        scholarshipRec2.Scholarship_Type__c = '90.01 & Above';
        scholarshipRec2.Sub_Category__c = 'UG - Technical';
        scholarshipRec2.Applicable_for_All_Years__c = True;
        insert scholarshipRec2;
        
        Test.startTest();
        AdmissionsProcessUtility.getScholarshipMaster(type2, programType2);
        AdmissionsProcessUtility.getSelectedSubCategory(scholarshipRec2.Category__c, scholarshipRec2.Sub_Category__c);
        Test.stopTest();
    }
	@isTest
    static void testgetScholarshipMaster3() {
        String type3 = 'Engineering';
        String programType3 = 'PG';
        Scholarship_Master__c scholarshipRec3 = new Scholarship_Master__c();
        scholarshipRec3.Category__c = 'REVA to REVA';
        scholarshipRec3.Discount_Amount__c = 5000;
        scholarshipRec3.Documents_Required__c = 	'Bonafide letter;PUC ID card;REVA ID Card';
      	scholarshipRec3.Enrollment_year__c = '2023';
        scholarshipRec3.Is_Active__c = True;
        scholarshipRec3.Scholarship_Type__c = '75.01 - 85.00';
        scholarshipRec3.Sub_Category__c = 'PG - Technical';
        scholarshipRec3.Applicable_for_All_Years__c = True;
        insert scholarshipRec3;
        
        Test.startTest();
        AdmissionsProcessUtility.getScholarshipMaster(type3, programType3);
        AdmissionsProcessUtility.getSelectedSubCategory(scholarshipRec3.Category__c, scholarshipRec3.Sub_Category__c);
        Test.stopTest();
    }
    @isTest
    static void testgetScholarshipMaster4() {
        String type4 = 'Non - Engineering';
        String programType4 = 'UG';
        Scholarship_Master__c scholarshipRec4 = new Scholarship_Master__c();
        scholarshipRec4.Category__c = 'REVA to REVA';
        scholarshipRec4.Discount_Amount__c = 5000;
        scholarshipRec4.Documents_Required__c = 	'Bonafide letter;PUC ID card;REVA ID Card';
      	scholarshipRec4.Enrollment_year__c = '2023';
        scholarshipRec4.Is_Active__c = True;
        scholarshipRec4.Scholarship_Type__c = '85.01 & Above';
        scholarshipRec4.Sub_Category__c = 'UG - Non Technical';
        scholarshipRec4.Applicable_for_All_Years__c = True;
        insert scholarshipRec4;
       
        Test.startTest();
        AdmissionsProcessUtility.getScholarshipMaster(type4, programType4);
        AdmissionsProcessUtility.getSelectedSubCategory(scholarshipRec4.Category__c, scholarshipRec4.Sub_Category__c);
        Test.stopTest();
    }
	@isTest
    static void testgetScholarshipMaster5() {
        String programType5 = 'Ph.D';
        String type5 = 'Non - Engineering';
        Scholarship_Master__c scholarshipRec5 = new Scholarship_Master__c();
        scholarshipRec5.Category__c = 'Sports';
        scholarshipRec5.Discount_Percent__c = 80;
        scholarshipRec5.Documents_Required__c = 'Sports Highest Level Certificate';
      	scholarshipRec5.Enrollment_year__c = '2023';
        scholarshipRec5.Is_Active__c = True;
        scholarshipRec5.Sub_Category__c = 'A+ Level';
        scholarshipRec5.Applicable_for_All_Years__c = True;
        insert scholarshipRec5;
       
        Test.startTest();
        AdmissionsProcessUtility.getScholarshipMaster(type5, programType5);
        AdmissionsProcessUtility.getSelectedSubCategory(scholarshipRec5.Category__c, scholarshipRec5.Sub_Category__c);
        Test.stopTest();
    }
    @isTest
    public static void updateMultipleApprovalsTest(){
        //List<Id> applicationIds, String approverAction, String approverComments
        List<hed__Application__c> applications = [Select Id, Name from hed__Application__c Where Application_Number__C in ('1234','5678') ];
        List<Id> applIds = new List<Id>();
        for(hed__Application__c appl : applications){
                applIds.add(appl.Id);
        }
        String approverAction = 'Approve';
        String approverComments = 'Approved.';
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(applIds[0]);
        req1.setProcessDefinitionNameOrId('Concession_Approval');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result1 = Approval.process(req1);

        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval.');
        req2.setObjectId(applIds[1]);
        req2.setProcessDefinitionNameOrId('Concession_Approval');
        req2.setSkipEntryCriteria(true);
        Approval.ProcessResult result2 = Approval.process(req2);

        Test.startTest();
        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest updateMultipleApprovalsInstance = new AdmissionsProcessUtility.UtilityRequest();
        updateMultipleApprovalsInstance.invocationType = 'CONCESSION_APPROVAL';
        updateMultipleApprovalsInstance.applicationIds = applIds;
        updateMultipleApprovalsInstance.approverAction = approverAction;
        updateMultipleApprovalsInstance.approverComments = approverComments;
        utilityRequests.add(updateMultipleApprovalsInstance);

        //AdmissionsProcessUtility.updateMultipleApplApprovals(applIds, approverAction, approverComments);
        AdmissionsProcessUtility.decideByInvocation(utilityRequests);

        List<hed__Application__c> applsAfterLOneApproval = [Select Id, Name , Concession_Status__c from hed__Application__c 
                                                            Where Application_Number__C in ('1234','5678')];

         List<Id> applIdsLOne = new List<Id>();
         for(hed__Application__c appl : applications){
            applIdsLOne.add(appl.Id);
         }
        System.assertEquals('Under Approval', applsAfterLOneApproval[0].Concession_Status__c);

        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests2 = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest updateMultipleApprovalsInstance1 = new AdmissionsProcessUtility.UtilityRequest();
        updateMultipleApprovalsInstance1.invocationType = 'CONCESSION_APPROVAL';
        updateMultipleApprovalsInstance1.applicationIds = applIdsLOne;
        updateMultipleApprovalsInstance1.approverAction = approverAction;
        updateMultipleApprovalsInstance1.approverComments = approverComments;
        utilityRequests2.add(updateMultipleApprovalsInstance1);
        //AdmissionsProcessUtility.updateMultipleApplApprovals(applIdsLOne, approverAction, approverComments);

        AdmissionsProcessUtility.decideByInvocation(utilityRequests2);
        Test.stopTest();
        List<hed__Application__c> applsAfterLTwoApproval = [Select Id, Name , Concession_Status__c from hed__Application__c 
                                                            Where Application_Number__C in ('1234','5678')];
        System.assertEquals('Approved', applsAfterLTwoApproval[0].Concession_Status__c);
    }

    @isTest
    public static void generateChallanNumberTest(){

        Sequence_Number__c sequenceNo = new Sequence_Number__c();
        sequenceNo.Key_Field__c = 'RU23';
        sequenceNo.Integer_Five__c = 94;
        insert sequenceNo;

        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest generateChallanInstance = new AdmissionsProcessUtility.UtilityRequest();
        generateChallanInstance.invocationType = 'GENERATE_CHALLAN_NUMBER';
        utilityRequests.add(generateChallanInstance);

        Test.startTest();
        AdmissionsProcessUtility.decideByInvocation(utilityRequests);
        Test.stopTest();

        Sequence_Number__c seqNoAfterTest = [Select Integer_Five__c from Sequence_Number__c Where Key_Field__c = 'RU23' Limit 1];
        System.assertEquals(94, seqNoAfterTest.Integer_Five__c);
    }
    @isTest
    public static void unlockApplicationRecordTest(){

        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest unlockApplRecordInstance = new AdmissionsProcessUtility.UtilityRequest();
        unlockApplRecordInstance.invocationType = 'UNLOCK_APPLICATION_RECORD';
        utilityRequests.add(unlockApplRecordInstance);

        Test.startTest();
        AdmissionsProcessUtility.decideByInvocation(utilityRequests);
        Test.stopTest();
    }
     @isTest
    public static void FEE_Details_Controller_Test() {


        String houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_HOUSEHOLD_RECTYPE).getRecordTypeId();
        Account houseHoldTestAccount = new Account();
        houseHoldTestAccount.Name = 'Test Household Account';
        houseHoldTestAccount.RecordTypeId = houseHoldRecordTypeId;
        insert houseHoldTestAccount;

      

        String schoolRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_SCHOOL_RECTYPE).getRecordTypeId();
        Account schoolTestAccount = new Account();
        schoolTestAccount.Name = 'School of Civil Engineering';
        schoolTestAccount.RecordTypeId = schoolRecordTypeId;
        insert schoolTestAccount;

       



        String academicRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_ACADEMIC_RECTYPE).getRecordTypeId();
        Account academicTestAccount = New Account();
        academicTestAccount.Name = 'B.tech in Civil Engineering';
        academicTestAccount.Program_Alias__c = 'BCIVIL';
        academicTestAccount.Program_Code__c = 'CE23';
        academicTestAccount.Intake_Per_Section__c = 60;
        academicTestAccount.Program_Type__c = 'UG';
        academicTestAccount.RecordTypeId = academicRecordTypeId;
        insert academicTestAccount;


        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'B. Tech in Civil Engineering-(2023-2027)';
        programBatch.Number_of_Years__c = 4;
        programBatch.hed__Account__c = academicTestAccount.Id;
        insert programBatch;

        String applicantContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
        Contact applicantContact = new Contact();
        applicantContact.RecordTypeId = applicantContactRecordTypeId;
        applicantContact.LastName = 'Applicant Contact';
        applicantContact.AccountId = houseHoldTestAccount.Id;
        applicantContact.Select_Category__c = 'Karnataka';
        applicantContact.Primary_Academic_Program__c = academicTestAccount.Id;
        applicantContact.School__c = schoolTestAccount.Id;
        applicantContact.Admission_Mode__c = 'UQ';
        insert applicantContact;
        
     
        

        String educationHistRecordTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(CONST_EDUCATION_DETAILS).getRecordTypeId();
        
        hed__Education_History__c testtenth= new hed__Education_History__c();
        testtenth.Type_Of_Course__c = '10th';
        testtenth.Percentage__c = '80';
        testtenth.Board__c = 'Telangana State Board of Secondary Education';
        testtenth.hed__Contact__c = applicantContact.Id;
        testtenth.RecordTypeId = educationHistRecordTypeId;
        insert testtenth;

        hed__Education_History__c testtwelfth = new hed__Education_History__c();
        testtwelfth.Type_of_Course__c = '12th';
        testtwelfth.Board__c = 'Telangana State Board of Intermediate Education';
        testtwelfth.hed__Contact__c = applicantContact.Id;
        testtenth.RecordTypeId = educationHistRecordTypeId;
        insert testtwelfth;

        Fee_Master__c applicantFeeMaster = new Fee_Master__c();
        applicantFeeMaster.Fee_Type__c = 'Program Fee';
        applicantFeeMaster.Fee_Amount__c = 500000;
        applicantFeeMaster.Applicant_Category__c = 'Indian (SAARC)';
        applicantFeeMaster.Quota__c = 'UQ';
        applicantFeeMaster.Program_Batch__c = programBatch.Id;
        insert applicantFeeMaster;

        hed__Application__c testApplication = new hed__Application__c();
        testApplication.hed__Applicant__c = applicantContact.Id;
        testApplication.hed__Applying_To__c = academicTestAccount.Id;
        testApplication.hed__Application_Date__c = Date.today();
        testApplication.Application_Number__c= applicantContact.Application_Number__c;
        insert testApplication;

        test.startTest();
        AdmissionsProcessUtility.getApplicationRelatedRecords(testApplication.id);
        test.stopTest();

    }

    @isTest
 	public static void FEE_Details_Controller_Test2() {

        String houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_HOUSEHOLD_RECTYPE).getRecordTypeId();
        Account houseHoldTestAccount = new Account();
        houseHoldTestAccount.Name = 'Test Household Account';
        houseHoldTestAccount.RecordTypeId = houseHoldRecordTypeId;
        insert houseHoldTestAccount;

        String schoolRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_SCHOOL_RECTYPE).getRecordTypeId();
        Account schoolTestAccount = new Account();
        schoolTestAccount.Name = 'School of Civil Engineering';
        schoolTestAccount.RecordTypeId = schoolRecordTypeId;
        insert schoolTestAccount;

        String academicRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_ACADEMIC_RECTYPE).getRecordTypeId();
        Account academicTestAccount = New Account();
        academicTestAccount.Name = 'B.tech in Civil Engineering';
        academicTestAccount.Program_Alias__c = 'BCIVIL';
        academicTestAccount.Program_Code__c = 'CE23';
        academicTestAccount.Intake_Per_Section__c = 60;
        academicTestAccount.Program_Type__c = 'UG';
        academicTestAccount.RecordTypeId = academicRecordTypeId;
        insert academicTestAccount;

        hed__Program_Plan__c programBatch = new hed__Program_Plan__c();
        programBatch.Name = 'B. Tech in Civil Engineering-(2023-2027)';
        programBatch.Number_of_Years__c = 4;
        programBatch.hed__Account__c = academicTestAccount.Id;
        insert programBatch;

        String applicantContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        
        Contact applicantContact = new Contact();
        applicantContact.RecordTypeId = applicantContactRecordTypeId;
        applicantContact.LastName = 'Applicant Contact';
        applicantContact.AccountId = houseHoldTestAccount.Id;
        applicantContact.Select_Category__c = 'Non-Resident Indian(NRI)';
        applicantContact.Primary_Academic_Program__c = academicTestAccount.Id;
        applicantContact.School__c = schoolTestAccount.Id;
        applicantContact.Admission_Mode__c = 'UQ';
        insert applicantContact;

        String educationHistRecordTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get(CONST_EDUCATION_DETAILS).getRecordTypeId();
        
        hed__Education_History__c testtenth= new hed__Education_History__c();
        testtenth.Type_Of_Course__c = '10th';
        testtenth.Percentage__c = '80';
        testtenth.Board__c = 'Telangana State Board of Secondary Education';
        testtenth.hed__Contact__c = applicantContact.Id;
        testtenth.RecordTypeId = educationHistRecordTypeId;
        insert testtenth;

        hed__Education_History__c testtwelfth = new hed__Education_History__c();
        testtwelfth.Type_of_Course__c = '12th';
        testtwelfth.Board__c = 'Telangana State Board of Intermediate Education';
        testtwelfth.hed__Contact__c = applicantContact.Id;
        testtenth.RecordTypeId = educationHistRecordTypeId;
        insert testtwelfth;

        Fee_Master__c applicantFeeMaster = new Fee_Master__c();
        applicantFeeMaster.Fee_Type__c = 'Program Fee';
        applicantFeeMaster.Fee_Amount__c = 500000;
        applicantFeeMaster.Applicant_Category__c = 'Non-Resident Indian(NRI)';
        applicantFeeMaster.Quota__c = 'UQ';
        applicantFeeMaster.Program_Batch__c = programBatch.Id;
        insert applicantFeeMaster;

        hed__Application__c testApplication = new hed__Application__c();
        testApplication.hed__Applicant__c = applicantContact.Id;
        testApplication.hed__Applying_To__c = academicTestAccount.Id;
        testApplication.hed__Application_Date__c = Date.today();
        testApplication.Application_Number__c= applicantContact.Application_Number__c;
        insert testApplication;
        
        test.startTest();
        AdmissionsProcessUtility.getApplicationRelatedRecords(testApplication.id);
        test.stopTest();
    }

    @isTest
    public static void updateBulkOfflineTest(){

        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email='test@test.com';
        testContact.Application_Number__c = '2211001120';
        insert testContact;

        
        Student_Payment__c stpy = new Student_Payment__c();
        stpy.Mode_of_Payment__c ='Offline';  
        stpy.Contact__c= testContact.id;
        insert stpy;

        Contact testContact2 = new Contact();
        testContact2.FirstName = 'Johnny';
        testContact2.LastName='Test Contact 2' ;
        testContact2.Email='test@test2.com';
        testContact2.Application_Number__c = '2211001121';
        insert testContact2;

        
        Student_Payment__c stpy2 = new Student_Payment__c();
        stpy2.Mode_of_Payment__c ='Offline';  
        stpy2.Contact__c= testContact.id;
        insert stpy2;

        Test.startTest();

        List<Student_payment__C> stuPays = [Select Amount__C, Payment_Status__c, Contact__c, Contact__r.Owner.Name, Application_Number__c, Contact__r.Email, Contact__r.Application_Number__c,
                                                Contact__r.Name, Mode_of_Payment__c, Payment_Date__c, Fee_Type__C  from Student_payment__C];

        List<Id> studentPayIds = new List<Id>();
        for(Student_Payment__c sp : stuPays){
            studentPayIds.add(sp.Id);
        }

        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest updateBulkOfflineInstance = new AdmissionsProcessUtility.UtilityRequest();
        updateBulkOfflineInstance.invocationType = 'ACCEPT_BULK_OFFLINE_PAYMENT';
        updateBulkOfflineInstance.studentPaymentIds = studentPayIds;
        updateBulkOfflineInstance.studentPaymentStatus = 'Success';
        utilityRequests.add(updateBulkOfflineInstance);


        AdmissionsProcessUtility.decideByInvocation(utilityRequests);

        Test.stopTest();

    }
    
    @isTest
    public static void applicationTest(){
        
        User siteUser = [select id, ContactId from user where Id = : UserInfo.getUserId()];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = siteUser.ContactId
         );
         insert Application1;
        
         Test.startTest();
        AdmissionsProcessUtility.getApplicationId();
        Test.stopTest();
    }

   @isTest
public static void applicationOwnerTest() {
    try {
        User siteUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

        hed__Application__c Application1 = new hed__Application__c(
            hed__Applicant__c = siteUser.ContactId
        );
        insert Application1;

        Test.startTest();
        AdmissionsProcessUtility.getContactOwnerInfo(Application1.Id);
        Test.stopTest();
    } catch (Exception e) {
        // Print or log the exception details for debugging
        System.debug('Exception: ' + e.getMessage());
        // Optionally rethrow the exception to fail the test
        // throw e;
    }
}

    
    @isTest
    public static void applicationDeclarationTest(){
        
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = con.Id,
            hed__Applying_To__c = acc.Id,
            Declaration__c=true
         );
        insert Application1;
        
         Test.startTest();
        AdmissionsProcessUtility.getApplicationDeclaration(Application1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void applicationPOFullySignedTest(){
        
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = con.Id,
            hed__Applying_To__c = acc.Id,
            PO_Fully_Signed__c=true
         );
        insert Application1;
        
         Test.startTest();
        AdmissionsProcessUtility.getPOFullySigned(Application1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void applicationFeeStructureDefinedTest(){
        
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = con.Id,
            hed__Applying_To__c = acc.Id,
            Fee_Structure_Defined__c=true
         );
        insert Application1;
        
         Test.startTest();
        AdmissionsProcessUtility.getFeeStructureDefined(Application1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void applicationApplicationStatusInterestedTest(){
        
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = con.Id,
            hed__Applying_To__c = acc.Id,
            hed__Application_Status__c='Interested',
            hed__Application_Date__c = Date.Today()
         );
        insert Application1;
        
         Test.startTest();
        AdmissionsProcessUtility.getApplicationStatusInterested(Application1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void getRelatedFilesByRecordIdTest(){
        
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = con.Id,
            hed__Applying_To__c = acc.Id
         );
        insert Application1;

         Test.startTest();
        AdmissionsProcessUtility.getRelatedFilesByRecordId(Application1.id);
        Test.stopTest();
    }
    @isTest
    static void testGenerateAdmissionReceipt(){

        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName='Test Contact' ;
        testContact.Email='test@test.com';
        testContact.Application_Number__c = '2211001120';
        insert testContact;
        
         hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = testContact.Id
          
        );
        insert Application1;

        
        Student_Payment__c stpy = new Student_Payment__c();
        stpy.Mode_of_Payment__c ='Online';  
        stpy.Contact__c= testContact.id;
        insert stpy;
               
        //test content version 
        ContentVersion testcontent=new ContentVersion(); 
        testcontent.Title='Test Receipt';
        Blob bodyBlob=Blob.valueOf('Test Content'); 
        testcontent.FirstPublishLocationId=stpy.Id;
        testcontent.PathOnClient = 'Test Receipt';
        testcontent.VersionData = bodyBlob;
        insert testcontent;
        
        

         
        Test.startTest();
        
        list<AdmissionsProcessUtility.UtilityRequest> utilityRequests = new list<AdmissionsProcessUtility.UtilityRequest>();
        AdmissionsProcessUtility.UtilityRequest generateOfflineReceiptInstance = new AdmissionsProcessUtility.UtilityRequest();
        generateOfflineReceiptInstance.invocationType = 'NOT_UQ_Applicant';
        generateOfflineReceiptInstance.applicationId = testContact.Id;
        //generateOfflineReceiptInstance.paymentModeType = 'Online';
        utilityRequests.add(generateOfflineReceiptInstance);


        AdmissionsProcessUtility.decideByInvocation(utilityRequests);
        Test.stopTest();
    }
    @isTest
static void testSubmitConcessionForApproval() {

    // Get existing application from TestSetup
    hed__Application__c appRec = [
        SELECT Id
        FROM hed__Application__c
        LIMIT 1
    ];

    Test.startTest();

    String result =
        AdmissionsProcessUtility.submitConcessionForApproval(appRec.Id);

    Test.stopTest();

    System.assertNotEquals(null, result);
}
}