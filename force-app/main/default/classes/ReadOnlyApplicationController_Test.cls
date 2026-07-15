@isTest
public class ReadOnlyApplicationController_Test {
    public static final String CONST_APPLICANT_RECTYPE = 'Applicant';
    public static final string CONST_ACADEMIC_RECTYPE = 'Academic Program';
    public static final string CONST_HOUSEHOLD_RECTYPE = 'Household Account';
    public static final string CONST_PARENT_RECTYPE = 'Parent';
    public static final String PHOTO_URL_BASE = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=';
    
    @isTest
    public static void ReadOnlyApplicationController_Test() {
        
        String houseHoldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_HOUSEHOLD_RECTYPE).getRecordTypeId();
        Account houseHoldTestAccount = New Account();
        houseHoldTestAccount.Name = 'Test HouseHold Account';
        houseHoldTestAccount.RecordTypeId = houseHoldRecordTypeId;
        insert houseHoldTestAccount;
        
        String applicantContactRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_APPLICANT_RECTYPE).getRecordTypeId();
        Contact applicantContact = New Contact();
        applicantContact.LastName = 'Applicant Contact';
        applicantContact.RecordTypeId = applicantContactRecordId;
        applicantContact.Account = houseHoldTestAccount;
        applicantContact.Email = 'testApplicant@reva.edu.in';
        applicantContact.Birthdate = date.Today();
        applicantContact.Marital_Status__c = 'Single';
        applicantContact.hed__Religion__c = 'Hinduism';
        applicantContact.Caste__c = 'Gowda';
        applicantContact.Aadhar_Card_Number__c = '123456789101';
        applicantContact.Mother_Tongue__c = 'Telugu';
        applicantContact.Whether_it_is_Distance_Education__c = True;
        applicantContact.Hostel_Facility__c = 'Yes';
        applicantContact.MobilePhone = '91-9090909090';
        applicantContact.Select_Category__c = 'Karnataka';
        applicantContact.hed__Gender__c = 'Male';
        applicantContact.PH_Handicapped__c = 'No';
        applicantContact.Caste_Category__c = '2B';
        applicantContact.Nationality__c = 'Indian';
        applicantContact.Blood_Group__c = 'A+';
        applicantContact.Are_You_A_REVA_Student__c = 'No';
        applicantContact.Transportation_Facility__c = 'Yes';
        applicantContact.Passport_Number__c = '123456';
        applicantContact.Passport_Place_Of_Issue__c = 'Hyderabad';
        applicantContact.Passport_Issued_Country__c = 'India';
        applicantContact.Passport_Date_Of_Issue__c = Date.today();
        applicantContact.Passport_Date_Of_Expiry__c = applicantContact.Passport_Date_Of_Issue__c.addDays(90);
        insert applicantContact;
        
        String academicRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CONST_ACADEMIC_RECTYPE).getRecordTypeId();
        Account academicTestAccount = New Account();
        academicTestAccount.Name = 'B.tech in Civil Engineering';
        academicTestAccount.Program_Alias__c = 'BCIVIL';
        academicTestAccount.Program_Code__c = 'CE23';
        academicTestAccount.Intake_Per_Section__c = 60;
        academicTestAccount.Program_Type__c = 'UG';
        academicTestAccount.RecordTypeId = academicRecordTypeId;
        insert academicTestAccount;
        
        
        hed__Application__c testApplication = new hed__Application__c();
        testApplication.hed__Applicant__c = applicantContact.Id;
        testApplication.hed__Applying_To__c = academicTestAccount.Id;
        testApplication.hed__Application_Date__c = Date.today();
        testApplication.Application_Number__c= applicantContact.Application_Number__c;
        insert testApplication;
      
        
        
        String parentContactRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONST_PARENT_RECTYPE).getRecordTypeId();
        contact testFatherContact = new contact();
        testFatherContact.LastName = 'Test Father';
        testFatherContact.ReportsToId = applicantContact.Id;
        testFatherContact.RecordTypeId = parentContactRecordId;
        testFatherContact.Type_of_Relationship__c = 'Father';
        testFatherContact.Email = 'testFather@reva.edu.in';
        testFatherContact.MobilePhone = '9999955555';
        testFatherContact.Occupation__c = 'Software developer';
        testFatherContact.PAN_Number__c = 'ABCDE1234G';
        testFatherContact.Annual_Income__c = 123456111;
        insert testFatherContact;
        
        contact testMotherContact = new contact();
        testMotherContact.LastName = 'Test Mother';
        testMotherContact.ReportsToId = applicantContact.Id;
        testMotherContact.RecordTypeId = parentContactRecordId;
        testMotherContact.Type_of_Relationship__c = 'Mother';
        
        insert testMotherContact;
        
        contact testGaurdianContact = new contact();
        testGaurdianContact.LastName = 'Test Guardian';
        testGaurdianContact.ReportsToId = applicantContact.Id;
        testGaurdianContact.RecordTypeId = parentContactRecordId;
        testGaurdianContact.Type_of_Relationship__c = 'Guardian';
        insert testGaurdianContact;
        
        hed__Education_History__c testTenth = new hed__Education_History__c();
        testTenth.Type_of_Course__c = '10th';
        testTenth.Board__c = 'Telangana State Board of Secondary Education';
        testTenth.hed__Contact__c = applicantContact.Id;
        insert testTenth;
        
        hed__Education_History__c testtwelfth = new hed__Education_History__c();
        testtwelfth.Type_of_Course__c = '12th';
        testtwelfth.Board__c = 'Telangana State Board of Intermediate Education';
        testtwelfth.hed__Contact__c = applicantContact.Id;
        insert testtwelfth;
        
        hed__Education_History__c testUG = new hed__Education_History__c();
        testUG.Type_of_Course__c = 'UG';
        testUG.hed__Contact__c = applicantContact.Id;
        insert testUG;
        
        hed__Education_History__c testPG = new hed__Education_History__c();
        testPG.Type_of_Course__c = 'PG';
        testPG.hed__Contact__c = applicantContact.Id;
        insert testPG;
        
        hed__Address__c testMailingAddress = new hed__Address__c();
        testMailingAddress.hed__Address_Type__c = 'Mailing Address';
        testMailingAddress.hed__Parent_Account__c = houseHoldTestAccount.Id;
        testMailingAddress.hed__Parent_Contact__c = applicantContact.Id;
        insert testMailingAddress;
        
        hed__Address__c testPermanentAddress = new hed__Address__c();
        testPermanentAddress.hed__Address_Type__c = 'Permanent Address';
        testPermanentAddress.hed__Parent_Account__c = houseHoldTestAccount.Id;
        testPermanentAddress.hed__Parent_Contact__c = applicantContact.Id;
        insert testPermanentAddress;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';
        cv.PathOnClient = 'Passport.png';
        cv.VersionData = Blob.valueOf('Passport Photo');
        cv.Description = 'Passport Photo';
        insert cv;
        
        ContentDocument contentDoc = [SELECT Id FROM ContentDocument 
                                      	WHERE LatestPublishedVersionId = : cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDoc.Id;
        cdl.LinkedEntityId = testApplication.Id;
        insert cdl;
     
        PageReference testPage = Page.ReadOnlyApplication;
        testPage.getParameters().put('id',String.valueOf(testApplication.Id));
        Test.setCurrentPage(testPage);
        ReadOnlyApplicationController testController = new ReadOnlyApplicationController();
        testController.applicationNumber = testApplication.Application_Number__c;
        testController.passportPhotoURL = PHOTO_URL_BASE + cdl.ContentDocument.LatestPublishedVersionId;
        ReadOnlyApplicationController.save();
        system.assertEquals(applicantContact.Id, testController.applicant.Id);
        system.assertEquals(testFatherContact.Id, testController.father.Id);
        system.assertEquals(testMotherContact.Id, testController.mother.Id);
        system.assertEquals(testTenth.Id, testController.tenth.Id);
        system.assertEquals(testtwelfth.Id, testController.twelfth.Id);
        system.assertEquals(testUG.Id, testController.ug.Id);
        system.assertEquals(testPG.Id, testController.pg.Id);
        system.assertEquals(testMailingAddress.Id, testController.mailingAddress.Id);
        system.assertEquals(testPermanentAddress.Id, testController.permanentAddress.Id); 
        
        
        
        
    }
}