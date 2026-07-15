@isTest
public class ApplicantDocumentUploadTest {
    
    @testSetup
    public static void createData(){
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
    }
    
    @isTest
    public static void applicantTest(){
        String programName = 'Bachelor of Architecture';
        
        Account acc =[Select id,Name From Account Where Name  = : programName];
        
        Contact con = [Select id, FirstName, LastName, Email From Contact Where Email = 'sai@gmail.com'];
        
        hed__Application__c Application1 = new hed__Application__c(
	        hed__Applicant__c = con.Id,
            hed__Applying_To__c = acc.Id
         );
         insert Application1;
        
        Test.startTest();
        ApplicantDocumentUpload.getApplicantId(Application1.id);
        ApplicantDocumentUpload.getProgramType(Application1.id);
        Test.stopTest();
    }

    @isTest
    public static void uploadFiles_Test(){
        ApplicantDocumentUpload.FileInfo fileinfo = new ApplicantDocumentUpload.FileInfo();
        // ApplicantDocumentUpload.SavedFileInfo sf = new ApplicantDocumentUpload.SavedFileInfo ();
        // ApplicantDocumentUpload.EducationHistory Ehh = new ApplicantDocumentUpload.EducationHistory();
        // ApplicantDocumentUpload.EducationHistory Ehh = ApplicantDocumentUpload.EducationHistory.create();
        List<ApplicantDocumentUpload.FileInfo> fileinfos = new List<ApplicantDocumentUpload.FileInfo>();
        fileinfo.base64 = 'base64';
        fileinfo.filename = 'test';
        contact con = new contact();
        con.LastName='Mayur';
        insert con;
        fileinfo.recordIds=new List<string>{con.Id, fileinfo.fileType, fileinfo.fileType};
            fileinfo.filesize=2500;
        fileinfos.add(fileinfo);
        contentVersion cv = new contentVersion();
        cv.title ='Test';
        cv.PathOnClient = 'PathTest';
        cv.VersionData = Blob.valueof('this is a test');
        cv.Applicant_Document_Type__c ='Passport Photo';
        insert cv;
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDoc.Id;
        cdl.LinkedEntityId = con.Id;
        fileinfo.contentDocumentId = contentDoc.Id;
        fileinfo.fileType = 'Passport Photo';
        List<String> cvIds = new List<String>();
        cvIds.add(cv.Id);
        
        // sf.contentDocumentId =  contentDoc.Id;
        // sf.fileType = 'Passport Photo'; 
        contentVersion cv2 = new contentVersion();
        cv2.PathOnClient = 'PathTest';
        cv2.VersionData = Blob.valueof('this is a test');
        cv2.Applicant_Document_Type__c ='Passport Photo';
        insert cv2;
        ContentDocument contentDoc2 = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = contentDoc.Id;
        cdl2.LinkedEntityId = con.Id;
        fileinfo.contentDocumentId = contentDoc.Id;
        fileinfo.fileType = 'Passport Photo';
    
        cvIds.add(cv2.Id);
        String eduHistId = fileinfo.recordIds[1]; 
        String useLocation = 'primaryApplication';
        String useLocation1 = 'Additional Documents';
        hed__Education_History__c educationHistory = new hed__Education_History__c();
        educationHistory.Type_Of_Course__c = 'UG';
        educationHistory.hed__Contact__c = con.Id;
        insert educationHistory;
         hed__Education_History__c educationHistory2 = new hed__Education_History__c();
        educationHistory2.Type_Of_Course__c = 'PG';
        educationHistory2.hed__Contact__c = con.Id;
        insert educationHistory2;
    
        List<String> str = ApplicantDocumentUpload.uploadFiles(fileinfos);
        List<ApplicantDocumentUpload.SavedFileInfo> SFI = ApplicantDocumentUpload.getCurrentFiles(con.Id);
        List<ApplicantDocumentUpload.EducationHistory> EH = ApplicantDocumentUpload.getEducationHistories(con.Id);
        ApplicantDocumentUpload.getFileTypes(con.Id,useLocation);
        ApplicantDocumentUpload.getFileTypes(con.Id,useLocation1);
        List<String> cetDocs = ApplicantDocumentUpload.getFileTypes(con.Id,'CET');
        List<String> uqDocs =  ApplicantDocumentUpload.getFileTypes(con.Id,'UQ');
        System.assertEquals(2, cetDocs.size());
        System.assertEquals('Passport Photo', cetDocs[0]);
        System.assertEquals('CET Allotment Letter', cetDocs[1]);      
    }
    
    @isTest
    public static void uploadFiles_Test1(){
        ApplicantDocumentUpload.FileInfo fileinfo = new ApplicantDocumentUpload.FileInfo();
        List<ApplicantDocumentUpload.FileInfo> fileinfos = new List<ApplicantDocumentUpload.FileInfo>();
        fileinfo.base64 = 'base64';
        fileinfo.filename = 'test';
        contact con = new contact();
        con.LastName='Mayur';
        insert con;
        fileinfo.recordIds=new List<string>{con.Id, fileinfo.fileType, fileinfo.fileType};
            fileinfo.filesize=2500;
        fileinfos.add(fileinfo);
        contentVersion cv = new contentVersion();
        cv.title ='Test';
        cv.PathOnClient = 'PathTest';
        cv.VersionData = Blob.valueof('this is a test');
        cv.Applicant_Document_Type__c ='Passport Photo';
            fileinfo.ContentDocumentId= cv.Id;
        insert cv;
   
       
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDoc.Id;
        cdl.LinkedEntityId = con.Id;
        fileinfo.fileType = 'Passport Photo';
        List<String> cvIds = new List<String>();
        cvIds.add(cv.Id);
        String eduHistId = fileinfo.recordIds[1]; 
        String useLocation = 'primaryApplication';
        hed__Education_History__c educationHistory = new hed__Education_History__c();
        educationHistory.Type_Of_Course__c = 'UG';
        educationHistory.hed__Contact__c = con.Id;
        insert educationHistory;
        List<String> str = ApplicantDocumentUpload.uploadFiles(fileinfos);
        List<ApplicantDocumentUpload.SavedFileInfo> SFI = ApplicantDocumentUpload.getCurrentFiles(con.Id);
        List<ApplicantDocumentUpload.EducationHistory> EH = ApplicantDocumentUpload.getEducationHistories(con.Id);
        
        ApplicantDocumentUpload.getFileTypes(con.Id,useLocation);
        ApplicantDocumentUpload.updateFileName(cv.Id,cv.title,'Passport Photo');
    }
}