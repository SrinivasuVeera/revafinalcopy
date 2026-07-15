@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    
    @isTest
    public static void UpdateVisibilityTest(){
        
        List<ContentDocumentLink> contDocumentLinkList = new List<ContentDocumentLink>();
        
        RecordType applicantRT = [Select id FROM RecordType Where DeveloperName = 'Applicant' Limit 1];
        
        Contact Applicant1 = new Contact(
            FirstName = 'sai',
            MiddleName = 'k',
            LastName = 'K',
            Email = 'sai@gmail.com',
            MobilePhone = '9999999999',
            RecordTypeId = applicantRT.Id,
            Application_Fee_Paid__c = false,
            Application_Number__c = '222333555'
        );
        insert Applicant1;
        
        ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
        
        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId=Applicant1.Id;
        cdl.ContentDocumentId=contentDocId;
        cdl.shareType = 'V';
        insert cdl;
        
        cdl.Visibility='AllUsers';
        update cdl;
        
        contDocumentLinkList.add(cdl);
        
        Test.startTest();
        ContentDocumentLinkTriggerHandler.UpdateVisibility(contDocumentLinkList);
        Test.stopTest();
    }

}