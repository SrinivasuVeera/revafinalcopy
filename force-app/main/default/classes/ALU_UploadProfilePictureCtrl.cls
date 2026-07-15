public class ALU_UploadProfilePictureCtrl 
{
    @AuraEnabled
    public static wrapperCon getProfilePicture() 
    {
        Contact objContact  = new Contact();
        user objUser = new user();
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        objUser = [SELECT id, Name, ContactId FROM user WHERE id =: UserInfo.getUserId()];
        if(objuser.ContactId != NULL)
        {
            objContact = [SELECT id, Name,RecordTypeId, 
                          Student_Image__c, File_Passport_Size_Photo__c,Digital_Card_Number__c,
                          (SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks)
                          FROM Contact 
                          WHERE id=:objUser.ContactId and  RecordTypeId =: Alumni_Activities_Event_RecType];
            // Att=[SELECT ContentDocumentId, ContentDocument.Title,  LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =: objUser.ContactId];
            
        }
        wrapperCon wrp=new wrapperCon();
        wrp.ConId=objuser.ContactId;
        
        return wrp;
        /*
// Attachment permissions are set in parent object (Contact)
if (objuser.ContactId == NULL) 
{
throw new System.NoAccessException();
//return null;
}
return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
WHERE parentid=:ParentId 
ORDER BY LastModifiedDate DESC LIMIT 1];
*/
    }
    
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data) 
    { 
           ContentVersion contentVersionRec = new ContentVersion();
        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable())
        {
            throw new System.NoAccessException();
            // return null;
        }
        try
        {
            contentVersionRec.Title = fileName;  
            contentVersionRec.PathOnClient = '/' + fileName;  
            contentVersionRec.FirstPublishLocationId = parentId;
            contentVersionRec.VersionData = EncodingUtil.base64Decode(base64Data);
            contentVersionRec.NetworkId = Network.getNetworkId();
            contentVersionRec.IsMajorVersion = true;  
            Insert contentVersionRec;
            system.debug('==='+parentId);
            update new Contact(id =parentId, Upload_Image__c=false);
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
             system.debug('==='+parentId);
        }
        return contentVersionRec.id;
    }
    public class wrapperCon
    {
        @AuraEnabled public string ConId{get;set;}
        @AuraEnabled public string AttId{get;set;}
        @AuraEnabled public contact VersId{get;set;}
    }
}