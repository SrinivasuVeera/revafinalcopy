@isTest
public class ContentDocumentVisiblTriggerHandlr_Test 
{
    public static testMethod  void ContentDocMethod()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
        objAccount.RecordtypeId = UniversityRecId;  
        insert objAccount;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
         objcon.Personal_Email__c = 'test@reva.edu.in';
        objcon.hed__Preferred_Email__c = 'Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_Number__c='Srn123';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        objcon.ownerid = userinfo.getUserId();
        insert objcon;
        
        Id Alumni_Activities_Event_RecType = Schema.SObjectType.Alumni_Activities__c.getRecordTypeInfosByName().get('Events').getRecordTypeId();
        Alumni_Activities__c objAluminActivities= ALU_TestDataFactory.createAlumniActivities(objcon.id);
        objAluminActivities.Date__c = system.today()+1;
        objAluminActivities.Contact__c = objcon.id;
        objAluminActivities.RecordTypeId = Alumni_Activities_Event_RecType;
        insert objAluminActivities;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=objAluminActivities.id;
        contentlink.ShareType= 'I';
        contentlink.LinkedEntityId = objAluminActivities.Id; 
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink; 
        
        List<ContentDocumentLink> lst_contDocLink = New List<ContentDocumentLink>();
        lst_contDocLink.add(contentlink);
        
        test.starttest();
        ContentDocumentVisiblity_Trigger_Handlr.ContentDocumentVisiblity(lst_contDocLink);
        test.stoptest();
    }
}