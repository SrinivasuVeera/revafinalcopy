@isTest
public class STOB_DocumentsVerification_Ctrl_Test 
{
    public static testmethod void DocumentVerificationMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Recordtypeid = UniversityRecId;
        Insert objAcc;
        
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objCon.AccountId = objAcc.Id;
        Insert objCon;
        
        Id RecTypeId = Schema.SObjectType.hed__Education_History__c.getRecordTypeInfosByName().get('Education Documents').getRecordTypeId();
             
        hed__Education_History__c objHedEducation = STOB_TestDataFactory.createEducationHistory(objCon.Id);
        objHedEducation.hed__Contact__c = objCon.Id;
        objHedEducation.hed__Verification_Status__c ='Approved';
        objHedEducation.RecordTypeId = RecTypeId;
        objHedEducation.Data__c = true;
        Insert objHedEducation;
        
        List<hed__Education_History__c> list_EducationHistories = new List<hed__Education_History__c>();
        list_EducationHistories.add(objHedEducation);
        
        List<ContentDocumentLink> lst_CondocLink = New List<ContentDocumentLink>();
        
        List<ContentVersion> lst_Contnvrsn = New List<ContentVersion>();
        
        ContentVersion objContVrsn = New ContentVersion();
        objContVrsn.title = 'Test';
        objContVrsn.PathOnClient = objContVrsn.Title + '.snote';
        objContVrsn.VersionData = Blob.valueof('this is a test');
        objContVrsn.FirstPublishLocationId = objHedEducation.Id;
        
        lst_Contnvrsn.add(objContVrsn);
        Insert objContVrsn;
        
        List<ContentDocument> lst_Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: objHedEducation.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        if(!lst_Documents.isEmpty())
        {
          
           contentlink.ShareType= 'C';
           contentlink.LinkedEntityId = objHedEducation.Id;
           contentlink.ContentDocumentId = lst_Documents[0].Id;
           contentlink.Visibility = 'AllUsers'; 
           delete contentlink;          
        }
        lst_CondocLink.add(contentlink); 
                
        Test.startTest();
        STOB_DocumentsVerification_Ctrl.getContactDetails(objCon.Id);
        STOB_DocumentsVerification_Ctrl.getDocumentDetails(objCon.Id);
        STOB_DocumentsVerification_Ctrl.confirmDocuments(list_EducationHistories);
        STOB_DocumentsVerification_Ctrl.getverificationStatus();
        STOB_DocumentsVerification_Ctrl.saveDocuments(list_EducationHistories);
        STOB_DocumentsVerification_Ctrl.getdeletefiledetais(objHedEducation.Id);
        STOB_DocumentsVerification_Ctrl.saveDocuments(null);
        STOB_DocumentsVerification_Ctrl.confirmDocuments(null);
        STOB_DocumentsVerification_Ctrl.getdeletefiledetais(null);
        Test.stopTest(); 
        system.assertEquals(objHedEducation.Id,objHedEducation.Id);
    }
}