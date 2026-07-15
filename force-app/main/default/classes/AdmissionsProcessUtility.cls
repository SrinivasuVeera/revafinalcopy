public without sharing class  AdmissionsProcessUtility {
    
    public static final String CONST_EDUCATION_DETAILS = 'Education Details'; 
    public static final String APPLICATION_FEE = 'Application Fee'; 
    public static final String TUITION_FEE = 'Tuition Fee'; 
    public static final String UNIVERSITY_FEE = 'University Fee'; 
    private static final String ENROLMENT_YEAR_CMDT_NAME = 'Enrolment_Year';
    public String paymentStatus { get; set; }
    
    @InvocableMethod(label='Admission Process Utility Invocation')
    public static List<UtilityResponse> decideByInvocation(List<UtilityRequest> uRequests){
        
        UtilityRequest uReq = uRequests[0];
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        Switch on uReq.invocationType{        
            When 'PO_FULLY_SIGNED_DOC_UPLOADED_MAIL'{
                sendPOFullySignedDoc(uReq.applicationId);
            }
            when 'SendLatestPO'{
                sendPOLetterPdf(uReq.applicationId);
            }
            when 'GENERATE_OFFLINE_RECEIPT'{
                generateOfflineReceipt(uReq.stuPayRec,uReq.paymentModeType,'',''); // passing Blank transaction Id and Payment Gateway for Offline Payment
            }
            when 'CONCESSION_APPROVAL'{
                updateMultipleApplApprovals(uReq.applicationIds, uReq.approverAction, uReq.approverComments);
            }
            When 'UNLOCK_APPLICATION_RECORD'{
                UnlockApplicationRecord(uReq.applicationId);
            }
            when 'GENERATE_CHALLAN_NUMBER'{
                uResponses = generateChallanNumber();
            }
            When 'ACCEPT_BULK_OFFLINE_PAYMENT'{
                updateBulkOfflinePayments(uReq.studentPaymentIds, uReq.studentPaymentStatus, uReq.chequeRealizationDate);
            }
            When 'NOT_UQ_Applicant'{
                generateReceiptAdmissionMode(uReq.applicationId);
            }
        }
        return uResponses;
    }
    
    @AuraEnabled(cacheable=true)
    public static void sendPOFullySignedDoc(String applicationId){
        hed__Application__c applicationRecord = [SELECT Id, hed__Applicant__c, hed__Applicant__r.Email, Application_Number__c FROM hed__Application__c Where Id = : applicationId];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = : applicationRecord.hed__Applicant__c 
        ];
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink link : contentDocumentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersions = [
            SELECT Id, ContentDocumentId, Title
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds AND Applicant_Document_Type__c = 'PO Fully Signed' and IsLatest = true ORDER BY CreatedDate DESC
        ];
        
        Id contentVersionId;
        
        if (!contentVersions.isEmpty()) {
            contentVersionId = contentVersions.get(0).Id;
        } 
        
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        email.setOrgWideEmailAddressId(owa.Id);
        email.setToAddresses(new String[] {applicationRecord.hed__Applicant__r.Email});
        email.setTargetObjectId(applicationRecord.hed__Applicant__C);
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Email_to_Applicant_after_submiting_PO_fully_signed_by_applicant_Doc'];
        email.setTemplateID(emailTemplate.Id); 
        email.setEntityAttachments(new List<Id>{contentVersionId});
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
    public static void sendPOLetterPdf(Id applicationId){
        
        hed__Application__c application = [SELECT Id, hed__Applicant__r.FirstName, Application_Number__c
                                           FROM hed__Application__c Where Id=:applicationId];
        PageReference pdfPage = Page.POLetter;
        pdfPage.getParameters().put('id',applicationId);
        
        Blob body;
        try
        {
            if(Test.isRunningTest()){
                body = Blob.valueOf('Test Content');
            }
            else{
                body = pdfPage.getContent();
            }
            
        }
        catch(Exception t)
        {
            body=Blob.valueof('Cannot Create PDF');
            system.debug(t.getMessage());
        }
        
        List<ContentDocumentLink> cdlinks = [select ContentDocumentId, ContentDocument.LatestPublishedVersion.Applicant_Document_Type__c
                                             from ContentDocumentLink
                                             where LinkedEntityId = :applicationId];
        Id contentDocId ;
        List<String> uploadedFileNames = new List<String>();
        
        for(ContentDocumentLink cdl : cdlinks) {
            uploadedFileNames.add(cdl.ContentDocument.LatestPublishedVersion.Applicant_Document_Type__c);
            if(cdl.ContentDocument.LatestPublishedVersion.Applicant_Document_Type__c == 'Provisional Offer Letter')
            {
                contentDocId = cdl.ContentDocumentId;
            }
        }
        
        ContentVersion cVersion = new ContentVersion(); // insert Content Version
        cVersion.ContentLocation = 'S';   // 'S' to locate the document within salesforce
        cVersion.Title = 'Provisional Offer Letter';   //Naming Convention - PO-FirstName-ApplNumber-Date// setting the title of the document
        cversion.PathOnClient = cVersion.Title+'.pdf';  // represents the file type that we are saving 
        cversion.VersionData = body;
        cVersion.Applicant_Document_Type__c = 'Provisional Offer Letter';
        
        if(!uploadedFileNames.contains('Provisional Offer Letter')){
            system.debug('First time creation');
            insert cversion;
            Id ConDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cversion.Id].contentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = ConDocument;
            cDocLink.LinkedEntityId = applicationId;
            cDocLink.Visibility = 'AllUsers'; // specifies whether this file is available to all users, internal users, or shared users
            cDocLink.ShareType = 'V'; // granted the permission to view the file
            insert cDocLink;
        }
        else{
            cVersion.contentDocumentId = contentDocId;
            insert cversion;
        }
        
        ContentVersion versionNumber = [SELECT VersionNumber from ContentVersion WHERE id =: cVersion.Id];
        hed__Application__c applicationRecord = [SELECT Id, hed__Applicant__c, hed__Application_Status__c, Concession_Status__c FROM hed__Application__c Where Id=:applicationId];     
        Contact contactRecord = [SELECT Id, Email, Firstname FROM Contact Where Id = : applicationRecord.hed__Applicant__c];
        list<String> recordIds = new List<String>();
        recordIds.add(applicationRecord.hed__Applicant__c);
        provisionalLetterGenerated((String)contactRecord.Id,(string)cversion.Id,(string)versionNumber.VersionNumber);
    }
    
    public static void updateMultipleApplApprovals(List<Id> applicationIds, String approverAction, String approverComments){
        String APPROVAL_PROCESS_NAME = 'Concession_Approval';
        
        ProcessDefinition procdef = [Select Id, DeveloperName from ProcessDefinition where DeveloperName = : APPROVAL_PROCESS_NAME Limit 1];
        Map<Id,ProcessInstance> procInstances = new Map<Id,ProcessInstance>([Select Id from ProcessInstance 
                                                                             Where ProcessDefinitionId = : procdef.Id and TargetObjectId IN : applicationIds]);
        
        for(ProcessInstanceWorkitem itemOne : [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, ElapsedTimeInHours, 
                                               ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                                               FROM ProcessInstanceWorkitem Where ProcessInstanceId in : procInstances.keyset()]){
                                                   
                                                   Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
                                                   request.setComments(approverComments);
                                                   request.setAction(approverAction);
                                                   List<Id> approverIds = request.getNextApproverIds();
                                                   system.debug('Approver Ids '+approverIds);
                                                   if(approverAction == 'Approve'){
                                                       request.setNextApproverIds(approverIds);
                                                   }
                                                   request.setWorkitemId(itemOne.Id);
                                                   Approval.ProcessResult result2 =  Approval.process(request); 
                                                   
                                                   if(approverAction == 'Approve' && result2.isSuccess()){

     ProcessInstance pi = [
            SELECT Status
            FROM ProcessInstance
            WHERE Id = :itemOne.ProcessInstanceId
            LIMIT 1];
         }
      }
    }
    
     
   @AuraEnabled
public static String submitConcessionForApproval(Id applicationId){

    try{
        System.debug('Current User: ' + UserInfo.getUserId());

        Approval.ProcessSubmitRequest req =
            new Approval.ProcessSubmitRequest();

        req.setObjectId(applicationId);

        Approval.ProcessResult result =
            Approval.process(req);

        System.debug('Success: ' + result.isSuccess());

        return 'SUCCESS';
    }
    catch(Exception e){
        System.debug('ERROR: ' + e.getMessage());
        return e.getMessage();
    }
}
    
    public static Id generateOfflineReceipt(Id stuPayRec , String paymentModeType, String paymentGateway, String transactionId){
        Student_Payment__c studentPaymentRec = [Select Id, Contact__r.Application_Number__c,OwnerId, contact__r.Name,Amount__C,
                                                Payment_Mode_Type__c, Contact__r.Program_Name__c,Transaction_ID__c, Payment_Gateway__c,Mode_of_Payment__c
                                                from Student_Payment__c Where Id =:stuPayRec];
        
        system.debug('studentPaymentRec' +studentPaymentRec);
        PageReference pdfPage = Page.Fee_ProvisionalAdmissionFeeReceipt;
        pdfPage.getParameters().put('id',studentPaymentRec.Id);
        pdfPage.getParameters().put('transactionId',transactionId);
        pdfPage.getParameters().put('paymentGateway',paymentGateway);
        pdfPage.getParameters().put('paymentModeType',paymentModeType);
        
        Blob pdfBlob; 
        if(Test.isRunningTest()){
            pdfBlob = Blob.valueOf('Test Content');
        }
        else{
            pdfBlob = pdfPage.getContent();
        }
        System.debug('Blob value : '+pdfBlob);
        ContentVersion cv = new ContentVersion();
        cv.VersionData = pdfBlob;
        cv.Title = createFileName(studentPaymentRec.Contact__r.Application_Number__c,studentPaymentRec.contact__r.Name);
        cv.PathOnClient = 'TestFile.pdf';
        cv.FirstPublishLocationId=studentPaymentRec.Id;
        insert cv;
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Student_Payment__c stPay = [ SELECT Id, Contact__c, Contact__r.FirstName,Contact__r.Admission_Mode__c,
                                    Contact__r.Application_Number__c, contact__r.Email,
                                    Payment_Gateway__c, Payment_Mode_Type__c,Mode_of_Payment__c,Transaction_ID__c 
                                    FROM Student_Payment__c  
                                    Where Id=:stuPayRec];
        String admissionMode = stPay.Contact__r.Admission_Mode__c;
        
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        email.setOrgWideEmailAddressId(owa.Id);
        email.setToAddresses(new List<String>{stPay.Contact__r.Email});
        email.setTargetObjectId(stPay.Contact__c);//stPay.Contact__c); 
        email.setWhatId(stPay.Id); 
        if(admissionMode == 'UQ'){ 
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Online_and_Offline_PAF_Receipt_Template'];
            email.setTemplateID(emailTemplate.Id);
            } else{
            
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Online_and_Offline_PAF_Receipt_Template_Non_UQ'];
            email.setTemplateID(emailTemplate.Id);             
        } 
        email.setEntityAttachments(new List<Id>{cv.Id});
        
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        return cv.id;
    }
    
    public static void provisionalLetterGenerated(String recId,String docId,String cversionNum){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Contact conRec = [SELECT Id, Email, Name,Application_Number__c,Program_Name__c from Contact where id=:recId];
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        email.setOrgWideEmailAddressId(owa.Id);
        email.setToAddresses(new String[] {conRec.Email});
        email.setTargetObjectId(conRec.Id);
        email.setPlainTextBody('\n Hi '+conRec.Name+','+
                               '\n '+
                               '\nThe Provisional offer letter for the application Number - '+conRec.Application_Number__c+' and the Program - '+conRec.Program_Name__c+' is attached below. Kindly make the signatures and upload on the Applicant Portal.'+
                               '\n '+
                               '\nThank you for applying to REVA University.'+
                               '\n '+
                               '\nREVA University' +
                               '\nRukmini Knowledge Park | Kattingenahalli |' +
                               '\nYelahanka | Bengaluru | Karnataka 560 064');
        email.setSubject(conRec.Name + ' - Provisional Offer Letter - Version '+cversionNum );
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Email_to_Applicant_for_Provisional_Letter_Generated'];
        email.setTemplateID(emailTemplate.Id); 
        email.setEntityAttachments(new List<Id>{docId});
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
    }
    
        // NOT UQ Admission, sending application document to email.
    Public static void generateReceiptAdmissionMode(string ContactId){
        
       
    hed__Application__c applicationRec = [select id, hed__Applicant__r.name,hed__Applicant__r.Admission_Mode__c,hed__Applicant__r.Email, hed__Applicant__c,Application_Number__c from hed__Application__c where hed__Applicant__c =: ContactId];
      String admissionMode= applicationRec.hed__Applicant__r.Admission_Mode__c;
      PageReference pdfPage = Page.ReadOnlyApplicationPdf;
      pdfPage.getParameters().put('id',applicationRec.Id);
      
      
      Blob pdfBlob; 
      if(Test.isRunningTest()){
          pdfBlob = Blob.valueOf('Test Content');
      }
      else{
          pdfBlob = pdfPage.getContent();
      }
      System.debug('Blob value : '+pdfBlob);
      ContentVersion cv = new ContentVersion();
      cv.VersionData = pdfBlob;
      cv.Title = createFileName(applicationRec.Application_Number__c,applicationRec.hed__Applicant__r.Name);
      cv.PathOnClient = 'TestFile.pdf';
      cv.FirstPublishLocationId=applicationRec.Id;
      insert cv;
  		
              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                   
              OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
              email.setOrgWideEmailAddressId(owa.Id);
              email.setToAddresses(new List<String>{applicationRec.hed__Applicant__r.Email});
              email.setTargetObjectId(applicationRec.hed__Applicant__c);//stPay.Contact__c); 
              email.setWhatId(applicationRec.Id); 
              EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Email_to_Applicant'];
              email.setTemplateID(emailTemplate.Id); 
              email.setEntityAttachments(new List<Id>{cv.Id});
              
              Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
      
      
      //return cv.id;
    }
    
    public static String createFileName(String applNo, String contactName){
        String fileName = applNo+'-'+contactName.deleteWhitespace()+'-'+DateTime.now().format('dd-MMM-yyyy');
        return fileName;
    }
    
    @AuraEnabled(cacheable=true)
    public static void UnlockApplicationRecord(Id recordId) {
        for (hed__Application__c recToUnlock : [Select Id, Name From hed__Application__c Where Id = :recordId]){
            Approval.unlock(recToUnlock.Id, false);
        }
    }
    
    @AuraEnabled
public static void updateFeeStructureAndContact(Id applicationId, Id scholarshipId) {

    hed__Application__c app = [
        SELECT Id,
               hed__Applicant__c,
               Fee_Structure_Defined__c
        FROM hed__Application__c
        WHERE Id = :applicationId
        LIMIT 1
    ];

    app.Fee_Structure_Defined__c = true;

    if (scholarshipId != null) {
        app.hed_Scholarship__c = scholarshipId;
    }

    update app;

    if (app.hed__Applicant__c != null) {

        Contact con = new Contact(
            Id = app.hed__Applicant__c,
            Fee_Structure_Defined__c = true
        );

        update con;
    }

    System.debug('Application Updated => ' + app.Id);
    System.debug('Contact Updated => ' + app.hed__Applicant__c);
}

    @AuraEnabled
    public static void writeFeeData(FeeDetailsWrapperClass feeDetails) {
      System.debug(feeDetails);
      if (feeDetails.ApplicationRecord != null) {
        update(feeDetails.ApplicationRecord);
      }
      upsert(feeDetails.ApplicationStudentFeeRecords);
    }

    @AuraEnabled(cacheable=true)
    public static FeeDetailsWrapperClass getApplicationRelatedRecords(String ApplicationRecordId){
        System.debug('ApplicationId'+ApplicationRecordId);
        FeeDetailsWrapperClass ApplicationFeeDetails = new FeeDetailsWrapperClass();
        
        ApplicationFeeDetails.ApplicationRecord = 
                  [SELECT Application_Number__c, 
                          Concession_1st_Year__c, Concession_2nd_Year__c, Concession_3rd_Year__c, 
                          Concession_4th_Year__c, Concession_5th_Year__c, Fee_Structure_Defined__c,
                          hed_Scholarship__c, Additional_Documents__c, hed__Applicant__c, 
                          Concession_Status__c, Provisional_Admission_Fee_Paid__c, Concession_Remarks__c 
                     FROM hed__Application__c 
                    WHERE Id = : ApplicationRecordId];
        
        Id contactRecordId = ApplicationFeeDetails.ApplicationRecord.hed__Applicant__c;
        System.debug('contactRecordId: ' + contactRecordId);
        if(ApplicationFeeDetails.ApplicationRecord.hed_Scholarship__c != null){
            ApplicationFeeDetails.AppliedScholarship = [Select Documents_Required__c from Scholarship_Master__c 
                                                            Where Id = : ApplicationFeeDetails.ApplicationRecord.hed_Scholarship__c ];
        }
        else{
            ApplicationFeeDetails.AppliedScholarship = null;
        }
        
        ApplicationFeeDetails.ApplicationContact = [Select Id, Name, Academic_Program__c, School_Name__c, School__r.Name, Program_Name__c, Select_Category__c,Program_Batch__r.Name, Enrollment_Type__c,Quota__c,Admission_Mode__c, Program_Type__c, Type__c, Email, MobilePhone, Father_Email_ID__c, Father_Mobile_Number__c, Mother_Mobile_Number__c, Mother_Email_ID__c,
                                                    (Select Id, Type_Of_Course__c, Percentage__c, hed__Contact__c from hed__Education_History__r 
                                                     Where (hed__Contact__c = :  contactRecordId and Record_Type_Name__c = : CONST_EDUCATION_DETAILS))
                                                    From Contact Where Id = : contactRecordId] ;
        
        if( ApplicationFeeDetails.ApplicationContact.Select_Category__c == 'Karnataka' || ApplicationFeeDetails.ApplicationContact.Select_Category__c == 'Non-Karnataka'){
            ApplicationFeeDetails.feeCategory ='Indian (SAARC)';
        }else{
            ApplicationFeeDetails.feeCategory = ApplicationFeeDetails.ApplicationContact.Select_Category__c;

        }
        system.debug('ApplicationFeeDetails.ApplicationContact.Program_Name__---->'+ApplicationFeeDetails.ApplicationContact.Program_Name__c);
        system.debug('ApplicationFeeDetails.ApplicationContact.Program_Name__---->'+ApplicationFeeDetails.ApplicationContact.Program_Batch__r.Name);
        ApplicationFeeDetails.ApplicationFeeMasterRecords = [Select Fee_Type__c, Fee_Amount__c, Applicant_Category__c,Premium_Amount__c, Program_Batch__r.Number_of_Years__c, Program_Batch__r.hed__Account__r.Program_Type__c 
                                                             From Fee_Master__c 
                                                             Where (Program_Batch__r.Name = : ApplicationFeeDetails.ApplicationContact.Program_Batch__r.Name and 
                                                                    Applicant_Category__c = : ApplicationFeeDetails.feeCategory and 
                                                                    School_Name__c = :ApplicationFeeDetails.ApplicationContact.School__r.Name and Fee_Type__c != :APPLICATION_FEE and 
                                                                    Quota__c = : ApplicationFeeDetails.ApplicationContact.Admission_Mode__c)];
                System.debug('ApplicationFeeMasterRecords: ' + ApplicationFeeDetails.ApplicationFeeMasterRecords);

                  if (!ApplicationFeeDetails.ApplicationFeeMasterRecords.isEmpty()) {
                     ApplicationFeeDetails.Number_of_Years = ApplicationFeeDetails.ApplicationFeeMasterRecords[0].Program_Batch__r.Number_of_Years__c;
                                                                    }                                        
                                                                    
        ApplicationFeeDetails.ApplicationStudentFeeRecords = [Select Name, Contact__c, Seat_Blocking_Payment_Option__c, Fee_Master__c, Fee_Payment_Criteria__c, 
                                                                      Fee_Type__c, Calculated_Total_Amount__c, Fee_Year__c, 
                                                                      Provisional_Admission_Fee__c, Scholarship__c, Premium__c, Concession__c, 
                                                                      Amount__c, Amount_Pending__c, Amount_Paid__c, Actual_Program_Fee__c
                                                                from Student_Fee__c 
                                                              Where (Contact__c = : contactRecordId and Fee_Type__c != : APPLICATION_FEE) Order by Name];
        
        ApplicationFeeDetails.FeePaymentCriterias = [Select Id, Name, Fee_Type__c, Payment_Type__c From Fee_Payment_Criteria__c 
                                                     Where ((Fee_Type__c = : TUITION_FEE) or (Fee_Type__c = : UNIVERSITY_FEE)) ];
        System.debug('Full details'+ApplicationFeeDetails);
        return ApplicationFeeDetails;
        

    }
   
    @AuraEnabled(cacheable=true)
    public static List<Scholarship_Master__c> getScholarshipMaster(String type, String programType){
        List<Scholarship_Master__c> scholarshipList;
        if (type == 'Non - Engineering' && programType == 'UG') {
            List<Scholarship_Master__c> ugNonEnggScholarshipList = [Select Category__c, Sub_Category__c, Scholarship_Type__c, Is_Active__c, Discount_Percent__c, 
                                                                    Discount_Amount__c, Discount_Amount_2_Year__c,Discount_Amount_3_Year__c,Discount_Amount_4_Year__c,Discount_Amount_5_Year__c,Documents_Required__c, Applicable_for_All_Years__c
                                                                    From Scholarship_Master__c Where Is_Active__c = true 
                                                                    AND (Sub_Category__c != 'UG - Technical' AND Sub_Category__c != 'PG - Technical' 
                                                                         AND Sub_Category__c != 'PG - Others' )];
            scholarshipList = ugNonEnggScholarshipList;
        } 
        if (type == 'Non - Engineering' && programType == 'PG') {
            List<Scholarship_Master__c> pgNonEnggScholarshipList = [Select Category__c, Sub_Category__c, Scholarship_Type__c, Is_Active__c, Discount_Percent__c, 
                                                                    Discount_Amount__c, Discount_Amount_2_Year__c,Discount_Amount_3_Year__c,Discount_Amount_4_Year__c,Discount_Amount_5_Year__c,Documents_Required__c, Applicable_for_All_Years__c 
                                                                    From Scholarship_Master__c Where Is_Active__c = true 
                                                                    AND (Sub_Category__c != 'UG - Technical' AND Sub_Category__c != 'PG - Technical' 
                                                                         AND Sub_Category__c != 'UG - Non Technical' )];
            scholarshipList = pgNonEnggScholarshipList;
        }
        if (type == 'Engineering' && programType == 'UG') {
            List<Scholarship_Master__c> ugEnggScholarshipList = [Select Category__c, Sub_Category__c, Scholarship_Type__c, Is_Active__c, Discount_Percent__c, 
                                                                Discount_Amount__c,Discount_Amount_2_Year__c,Discount_Amount_3_Year__c, Discount_Amount_4_Year__c,Discount_Amount_5_Year__c,Documents_Required__c, Applicable_for_All_Years__c 
                                                                From Scholarship_Master__c Where Is_Active__c = true 
                                                                AND (Sub_Category__c != 'UG - Non Technical' AND Sub_Category__c != 'PG - Technical' 
                                                                      AND Sub_Category__c != 'PG - Others' )];
            scholarshipList = ugEnggScholarshipList;
        }
        if (type == 'Engineering' && programType == 'PG') {
            List<Scholarship_Master__c> pgEnggScholarshipList = [Select Category__c, Sub_Category__c, Scholarship_Type__c, Is_Active__c, Discount_Percent__c, 
                                                                Discount_Amount__c,Discount_Amount_2_Year__c,Discount_Amount_3_Year__c, Discount_Amount_4_Year__c,Discount_Amount_5_Year__c,Documents_Required__c, Applicable_for_All_Years__c 
                                                                From Scholarship_Master__c Where Is_Active__c = true 
                                                                AND (Sub_Category__c != 'UG - Non Technical' AND Sub_Category__c != 'UG - Technical' 
                                                                      AND Sub_Category__c != 'PG - Others' )];
            scholarshipList = pgEnggScholarshipList;
        }
        if (programType == 'Ph.D') {
            List<Scholarship_Master__c> phdScholarshipList = [Select Category__c, Sub_Category__c, Scholarship_Type__c, Is_Active__c, Discount_Percent__c, 
                                                                Discount_Amount__c,Discount_Amount_2_Year__c,Discount_Amount_3_Year__c,Discount_Amount_4_Year__c,Discount_Amount_5_Year__c,Documents_Required__c, Applicable_for_All_Years__c 
                                                                From Scholarship_Master__c Where Is_Active__c = true 
                                                                AND Category__c != 'REVA CET Scholarship' AND Category__c != 'Entrance Exam Based Scholarship' AND (Sub_Category__c != 'UG - Non Technical' AND Sub_Category__c != 'UG - Technical' 
                                                                                                                                                                  AND Sub_Category__c != 'PG - Others' AND Sub_Category__c != 'PG - Technical')];
            scholarshipList = phdScholarshipList;
        }
        return scholarshipList;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Scholarship_Master__c> getSelectedSubCategory(String selectedSubCategory, string selectedCategory){
        List<Scholarship_Master__c> ScholarshipslabList = [Select Category__c, Sub_Category__c, Scholarship_Type__c, Discount_Percent__c, 
                                                           Discount_Amount__c, Discount_Amount_2_Year__c ,Discount_Amount_3_Year__c,Discount_Amount_4_Year__c,Discount_Amount_5_Year__c, Documents_Required__c, Applicable_for_All_Years__c 
                                                           From Scholarship_Master__c 
                                                           Where Sub_Category__c = : selectedSubCategory AND Category__c = : selectedCategory];
        return ScholarshipslabList;
    }
    
    public static List<UtilityResponse> generateChallanNumber(){
        UtilityResponse uR = new UtilityResponse();
        List<UtilityResponse> uResponses = new List<UtilityResponse>();
        String enrollmentYear = getCurrentEnrolmentYear();
        String challanPrefix = 'RU'+ enrollmentYear.right(2);
        String challanNumber =  challanPrefix + RegistrationProcessUtility.generateChallanNoSequence(challanPrefix);
        uR.challanNumber = challanNumber;
        uResponses.add(uR);
        System.debug('inside generateChallanNumber '+uResponses);
        return uResponses;
    }
    
    public static String getCurrentEnrolmentYear() {
        System.debug('getCurrentEnrolmentYear '+[select Text_Value__c from General_Setting__mdt where DeveloperName = :ENROLMENT_YEAR_CMDT_NAME limit 1].Text_Value__c);
        return [select Text_Value__c from General_Setting__mdt where DeveloperName = :ENROLMENT_YEAR_CMDT_NAME limit 1].Text_Value__c;
    }
    
 @AuraEnabled
    public static void updateBulkOfflinePayments(List<Id> recordIds, String paymentStatus, Date chequeRealizationDate){
        
        Set<String> appNoSet = new Set<String>();
        String receiptGeneratedBy = UserInfo.getName();
        List<FeedItem> postsToChatter = new List<FeedItem>();
        System.debug('receiptGeneratedBy '+receiptGeneratedBy);
        System.debug('studentPaymentIds '+recordIds);
        System.debug('paymentStatus '+paymentStatus);
        System.debug('chequeRealizationDate '+chequeRealizationDate);
        
        if(!recordIds.isEmpty()){
            
            List<Student_payment__C> studentPayments = [Select Amount__C, Payment_Status__c, Contact__c, Contact__r.Owner.Name, Application_Number__c, Contact__r.Email, Contact__r.Application_Number__C,
                                                            Contact__r.Name, Mode_of_Payment__c, Payment_Date__c, Fee_Type__C  from Student_payment__C where id in : recordIds];
            List<Id> contactIds = new List<Id>();
            Set<Id> studentPaymentIds = new Set<Id>();
            for(Student_Payment__c sp : studentPayments){
                contactIds.add(sp.Contact__c);
                appNoSet.add(sp.Application_Number__c);
                sp.Payment_Status__c = paymentStatus;
                sp.Payment_Date_Time__c = System.now();
                if(paymentStatus == 'Success'){
                    
                    sp.Receipt_Generated_by__c = receiptGeneratedBy;
                    sp.Receipt_Generated_on__c = System.Today();
                    system.debug('Receipt_Generated_by is'+sp.Receipt_Generated_by__c);

                    FeedItem postToChatter = new FeedItem();
                    postToChatter.ParentId = sp.Contact__r.OwnerId;
                    String ownerName = sp.Contact__r.Owner.Name;
                    String applicationNumber = sp.Application_Number__c;
                    String contactName = sp.Contact__r.Name;
                    System.debug('contactName '+contactName);
                    postToChatter.Body = 'Hi '+ownerName+','+
                        '\n The Applicant - '+applicationNumber+' '+contactName+' has successfully made the payment for Provisional Admission Fee by '+sp.Mode_of_Payment__c+' of Amount Rs.' +sp.Amount__c +' on '+sp.Payment_Date__c+'.';
                    postToChatter.Type = 'TextPost';
                    postsToChatter.add(postToChatter);
                    system.debug('Post TO Chatter '+DateTime.now());
                    studentPaymentIds.add(sp.Id);
                    system.debug('Ids'+studentPaymentIds);
                }
                else if(paymentStatus == 'Failed'){
                    FeedItem postToChatter = new FeedItem();
                    postToChatter.ParentId = sp.Contact__r.OwnerId;
                    String ownerName = sp.Contact__r.Owner.Name;
                    String applicationNumber = sp.Application_Number__c;
                    String contactName = sp.Contact__r.Name;
                    postToChatter.Body = 'Hi '+ownerName+','+
                        '\n The Payment of Applicant - '+applicationNumber+' '+contactName+' has been Rejected.';
                    postToChatter.Type = 'TextPost';
                    postsToChatter.add(postToChatter);

                }
                
            }
            update studentPayments;
            
            List<Student_Fee_Payment__c> studentFeePayments = [Select Amount__C, Line_Item_Payment_Status__c,Transaction_Date_Time__c  
                                                               from Student_Fee_Payment__c where Student_Payment__c in : recordIds];
            
            if(!studentFeePayments.isEmpty()){
                
                for(Student_Fee_Payment__c sfp : studentFeePayments){
                    sfp.Line_Item_Payment_Status__c = paymentStatus;
                    sfp.Transaction_Date_Time__c = System.now();
                    if(chequeRealizationDate != null){
                        sfp.Cheque_DD_Realisation_Date__c = chequeRealizationDate;
                    }
                    
                }
                //=============added on MAY 30 2024=================================
                List<hed__application__c> appList = [SELECT ID, hed__Applicant__c,
                                                 Provisional_Admission_Fee_Paid__c, Application_Number__c
                                               	 FROM hed__application__c
                                                 WHERE Application_Number__c =: appNoSet];
                for(Student_Payment__c sp : studentPayments){
                    for(hed__application__c ap : appList){
                        if(sp.Application_Number__c == ap.Application_Number__c)
                            if(paymentStatus == 'Success'){
                                ap.Provisional_Admission_Fee_Paid__c = true;
                            }
                    }
                }
                update appList;
                //============================================================
                update studentFeePayments;
                
            }

            // if(paymentStatus == 'Success'){
            //     OfflinePAFPaid(contactIds);
                
            // }

            insert postsToChatter;
            
           
            if(paymentStatus == 'Success'){
                
                // system.debug('student'+ studentPayments);
                generateReceipt(studentPaymentIds); //Generates the Provisional Admission Fee Receipt for bulk.
            }
        }
        
    }

    @future(callout=true)
    public static void OfflinePAFPaid(List<Id> contactIds){
        Decimal totalAmount = 0;
        List<hed__Application__c> applications = [Select Id, Provisional_Admission_Fee_Paid__c,Total_Paid_PAF__c,hed__Application_Status__c  from hed__Application__c
                                                                Where hed__Applicant__C In : contactIds];
        List<contact> cons=[select id, admission_mode__c, Fee_Paid_at_University__c from contact where id In: contactIds];
        
        List<Student_payment__C> studentPayments = [Select id, Amount__C,Payment_Status__c,Fee_Type__C,	Contact__c from Student_payment__C where Contact__c In :contactIds
                                             AND Payment_Status__c = 'Success' 
                                             AND Fee_Type__c LIKE '%University fee%'];
        
        List <Student_Fee__c> Studentfee =[select Name, Contact__c, Fee_Type__c, Fee_Year__c, Provisional_Admission_Fee__c,Amount__C
                                                                from Student_Fee__c 
                                                                Where Contact__c = : contactIds AND Fee_Type__c LIKE '%University fee%'];
         
        system.debug('StudentfeeSize'+ Studentfee.size());
        System.debug('studentPaymentsSize: ' + studentPayments.size()); 
        
        for(Student_payment__C sp : studentPayments){
            totalAmount += sp.Amount__c;
                   System.debug('totalAmount: ' + totalAmount);  
            }
       Decimal TotalPAFAmount=0;     
        for(Student_Fee__c sf : Studentfee){
            TotalPAFAmount += sf.Provisional_Admission_Fee__c;
                   System.debug('TotalPAFAmount: ' + TotalPAFAmount);  
            }
        Set<Id> appSet = new Set<id>(); 
        for(hed__Application__c appl : applications){
            System.debug('Total_Paid_PAF__c: ' + appl.Total_Paid_PAF__c);
            System.debug('totalAmount: ' + totalAmount);  
            System.debug('hed__Application__c status is -->'+appl.hed__Application_Status__c);
            
                for(contact con:cons){
                     system.debug('IFBlock'+con.admission_mode__c);
                    If(con.admission_mode__c=='UQ'){
                        system.debug('IFBlock'+TotalPAFAmount);
                       if(TotalPAFAmount <= totalAmount){
                                appl.Provisional_Admission_Fee_Paid__c = True;
                                appSet.add(appl.id);
                        } else {
                        appl.Provisional_Admission_Fee_Paid__c = False;
                        }
                
                    }  else{
                        system.debug('ElseBlock'+con.Fee_Paid_at_University__c);
                          if(con.Fee_Paid_at_University__c <= totalAmount) {
                    
                            
                                appl.Provisional_Admission_Fee_Paid__c = True;
                                appSet.add(appl.id);
                        } else {
                        appl.Provisional_Admission_Fee_Paid__c = False;
                        }
                }
                    
                        
                    }
                
              
        }

        update applications;

        // //30-11-23 Deactivated Provisional admission Flag flow and Replicant of Update is being done here 
        // Set<Id> conSet = new Set<id>(); 
        // List<Contact> conList = new List<Contact>();
        // for(hed__Application__c appl: [SELECT Id, Name, hed__Applicant__c, Provisional_Admission_Fee_Paid__c FROM hed__Application__c where id In : appSet]){
        //     conSet.add(appl.hed__Applicant__c);
        // }
        // for(Contact con: [SELECT Id, LastName, FirstName, Name, Amount_Paid__c FROM Contact where id In : conSet]){
        //     con.Amount_Paid__c = true;
        //     conList.add(con);
        // }
        // if(conList.size() > 0){
        //     update conList;
        // }
   }
   
    
    @future(callout=true)
    public static void generateReceipt(Set<Id> studentPayments){
        List<Student_payment__C> studentPaymentsList = [Select Amount__C, Payment_Status__c, Contact__c, Contact__r.Owner.Name, Application_Number__c, Contact__r.Email, Contact__r.Application_Number__C,
        Contact__r.Name, Mode_of_Payment__c, Payment_Date__c, Fee_Type__C  from Student_payment__C where id in : studentPayments];
        
        List<ContentVersion> receiptContent = new List<ContentVersion>();
        for(Student_Payment__C payment : studentPaymentsList){
            // system.debug(payment.Payment_Status__c);
            
            if(payment.Payment_Status__c == 'Success' &&
               payment.Fee_Type__c != 'Application Fee'){
                   PageReference pdfPage = Page.ApplicantProvisionalAdmissionFeeReceipt;
                   pdfPage.getParameters().put('id',payment.Id);
                   
                   Blob pdfBlob; 
                   if(Test.isRunningTest()){
                       pdfBlob = Blob.valueOf('Test Content');
                   }
                   else{
                       pdfBlob = pdfPage.getContent();
                   }

                   ContentVersion cv = new ContentVersion();
                   cv.VersionData = pdfBlob;
                   cv.Title = payment.Contact__r.Application_Number__c+'-'+payment.contact__r.Name.deleteWhitespace()+'-'+DateTime.now().format('dd-MMM-yyyy');
                   cv.PathOnClient = 'TestFile.pdf';
                   cv.FirstPublishLocationId=payment.Id;
                   receiptContent.add(cv);                           

               }
        }
        
        insert receiptContent;
        
        Map<Id, Id> contentPaymentMap = new Map<Id, Id>();
        Map<Id, String> paymentContactEmailMap = new Map<Id, String>();
        Map<Id, Id> paymentContactIdMap = new Map<Id, Id>();
        for(ContentVersion cv : receiptContent){
            contentPaymentMap.put(cv.Id, cv.FirstPublishLocationId);
        }
        for(Student_payment__C sp : studentPaymentsList){
            paymentContactEmailMap.put(sp.Id, sp.Contact__r.Email);
        }
        for(Student_payment__C sp : studentPaymentsList){
            paymentContactIdMap.put(sp.Id, sp.Contact__c);
        }
        OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress][0];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Online_and_Offline_PAF_Receipt_Template'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(ContentVersion cv : receiptContent){
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owa.Id);
            email.setToAddresses(new List<String>{paymentContactEmailMap.get(contentPaymentMap.get(cv.Id))});
            email.setTargetObjectId(paymentContactIdMap.get(contentPaymentMap.get(cv.Id)));//stPay.Contact__c); 
            email.setWhatId(cv.FirstPublishLocationId); 
            email.setTemplateID(emailTemplate.Id); 
            email.setEntityAttachments(new List<Id>{cv.Id});
            mails.add(email);
        } 
        sendEmailList(mails);
    }

    public static void sendEmailList(List<Messaging.SingleEmailMessage> mails){
        Messaging.SendEmailResult [] results = Messaging.sendEmail(mails);
    }

    @AuraEnabled(cacheable=true)
  public static String getApplicationId() {
    
    User siteUser = [select id, ContactId from user where Id = : UserInfo.getUserId()];
    String ContactId =siteUser.ContactId;
    
    String applicationId = [Select Id  from hed__Application__c where hed__Applicant__c = : ContactId Limit 1].Id;

    return applicationId;
  }

  @AuraEnabled(cacheable=true)
  public static Boolean getApplicationDeclaration(String appId) {
    
    hed__Application__c app = [Select Id, hed__Applicant__c,Declaration__c from hed__Application__c  where id = : appId Limit 1];
    Boolean appDeclaration = app.Declaration__c;
    
    return appDeclaration;
  }

  @AuraEnabled(cacheable=true)
  public static Boolean getPOFullySigned(String appId) {
    
    hed__Application__c app = [Select Id, hed__Applicant__c,PO_Fully_Signed__c from hed__Application__c  where id = : appId Limit 1];
    Boolean appPOFullySigned = app.PO_Fully_Signed__c;
    
    return appPOFullySigned;
  }
    
  @AuraEnabled(cacheable=true)
  public static Boolean getFeeStructureDefined(String appId) {
    
    hed__Application__c app = [Select Id, hed__Applicant__c,Fee_Structure_Defined__c from hed__Application__c  where id = : appId Limit 1];
    Boolean appFeeStructureDefined = app.Fee_Structure_Defined__c;
    
    return appFeeStructureDefined;
  }

  @AuraEnabled(cacheable=true)
  public static hed__Application__c getApplicationStatusInterested(String appId) {
    
    hed__Application__c app = [Select Id, hed__Applicant__c,hed__Application_Status__c, Provisional_Admission_Fee_Paid__c from hed__Application__c  
                                  where id = : appId AND hed__Application_Status__c='Interested' Limit 1];
    
    return app;
  }

  @AuraEnabled(cacheable=true)
        public static Map<ID, String> getRelatedFilesByRecordId(String appId) {
            // Get record file IDs        
            hed__Application__c ApplicationRecord = [SELECT Id, hed__Applicant__c, Application_Number__c FROM hed__Application__c Where Id=:appId];
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink 
                                                                      WHERE LinkedEntityId = :ApplicationRecord.hed__Applicant__c];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Title = 'PO Fully Signed'];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
        }    

        @AuraEnabled(cacheable=true)
        public static hed__Application__c getApplicationCheckListValues(String appId) {
            hed__Application__c applicationRecordValues = [SELECT Id, Additional_Documents_Required__c, Fee_Structure_Defined__c, Provisional_Admission_Fee_Paid__c, 
                                                        Concession_Status__c,hed_Scholarship__c,Offline_Payment_Initiated__c FROM hed__Application__c Where Id=:appId];
            return applicationRecordValues;
        }  

        public class FeeDetailsWrapperClass{
        
            @AuraEnabled public List<Student_Fee__c> ApplicationStudentFeeRecords {get; set;}
            @AuraEnabled public List<Fee_Master__c>  ApplicationFeeMasterRecords {get; set;}
            @AuraEnabled public List<Fee_Payment_Criteria__c> FeePaymentCriterias {get; set;}
            @AuraEnabled public Scholarship_Master__c AppliedScholarship {get; set;}
            @AuraEnabled public Contact ApplicationContact {get; set;}
            @AuraEnabled public hed__Application__c ApplicationRecord {get; set;}
            @AuraEnabled public string feeCategory {get; set;}
            @AuraEnabled public Decimal Number_of_Years { get; set; }
        }
    
    public class UtilityRequest{
        @InvocableVariable(label ='invocation Type')
        public String invocationType;
        
        @InvocableVariable(label ='Application Id')
        public String applicationId;
        
        @InvocableVariable(label ='Notification Type')
        public String notificationType;
        
        @InvocableVariable(label ='generate Receipt StuPayment Id')
        public Id stuPayRec;
        
        @InvocableVariable(label ='offline Payment Mode Type')
        public string paymentModeType;
        
        @InvocableVariable(label = 'multipleApprovalApplIds')
        public List<Id> applicationIds;
        
        @InvocableVariable(label ='Approver Action')
        public String approverAction;
        
        @InvocableVariable(label ='Approver Comments')
        public String approverComments;
        
        @InvocableVariable(label ='Bulk Offline Payment')
        public List<Id> studentPaymentIds;

        @InvocableVariable(label ='Bulk Offline Payment Status')
        public String studentPaymentStatus;

        @InvocableVariable(label ='Bulk Offline Cheque Realisation Date')
        public Date chequeRealizationDate;
    }
    
    public class UtilityResponse{
        @InvocableVariable(label ='Challan Number')
        public String challanNumber;
        
    }

    @AuraEnabled(cacheable=true)
    public static ApplicationContactOwnerWrapper getContactOwnerInfo(String ApplicationRecordId){
        try {
            ApplicationContactOwnerWrapper ap = new ApplicationContactOwnerWrapper();
            hed__Application__c app = [SELECT Id, OwnerId, owner.name, Name, hed__Applicant__c FROM hed__Application__c where id =: applicationRecordId];
            Contact con = [SELECT Id, LastName, FirstName, Name, OwnerId, owner.name FROM Contact where id=: app.hed__Applicant__c];
            //User us = [SELECT Id, Username, LastName, FirstName, Name, ProfileId, profile.name FROM User where id=:con.OwnerId];
            //ap.contactId = con.Id;
            ap.contactOwnerName = con.Owner.Name;
            //ap.contactOwnerProfileName = us.Profile.Name;
            return ap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ApplicationContactOwnerWrapper{
        @AuraEnabled public Id contactId {get; set;}
        @AuraEnabled public string contactOwnerName {get; set;}
        @AuraEnabled public string contactOwnerProfileName {get; set;}
    }
    
 }