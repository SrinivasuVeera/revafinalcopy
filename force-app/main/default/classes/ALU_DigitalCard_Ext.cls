public class ALU_DigitalCard_Ext
{
    public user objUser{get;set;}
    public contact objContact{get;set;}
    public ContentDocumentLink objContDoc{get;set;}
    public boolean docExists{get;set;}
    public string programValue{get;set;}
    public ALU_DigitalCard_Ext()
    {
        string pageId = Apexpages.currentPage().getParameters().get('id');
        objContact  = new Contact();
        objUser = new user();
        objContDoc = new ContentDocumentLink();
        docExists=false;
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        objUser = [SELECT id, Name, ContactId FROM user WHERE id =: UserInfo.getUserId()];
        if(objuser.ContactId != NULL)
        {
            objContact = [SELECT id, Name, Email, SRN_No__c,MobilePhone, Birthdate,RecordTypeId, School_Department__c, Year_Of_Graduation__c, Student_Image__c,
                          File_Passport_Size_Photo__c,Digital_Card_Number__c,Program__c,Program_Name_New__c,
                          (SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId  FROM ContentDocumentLinks
                           where LinkedEntityId =: objUser.ContactId order by ContentDocument.ContentModifiedDate desc limit 1)
                          FROM Contact WHERE id=:objuser.ContactId and  RecordTypeId =: Alumni_Activities_Event_RecType];
            if(!objContact.ContentDocumentLinks.isempty())
                docExists=true;
            if(objContact.Program__c != null)
            {
                programValue = objContact.Program__c;
            }
            else
            {
                programValue = objContact.Program_Name_New__c;
            }
        }
    }
    
    
}