@isTest
public class ALU_UploadProfilePictureCtrl_Test 
{
   public static testMethod void UploadProfile()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
        Contact objcon = ALU_TestDataFactory.createContact('test Contact');
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123'; 
        objcon.Personal_Email__c = 'test@reva.edu.in';
        objcon.hed__Preferred_Email__c = 'Personal Email';
        objcon.MobilePhone ='8963210547';
        objcon.SRN_No__c='Srn123';
        objcon.FirstName  = 'Test Con';
        objcon.LastName  ='LastCon';
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c = 'Indian';
        objcon.Aadhar_Card_Number__c ='368845632147'; 
        objcon.PAN_Number__c ='HRAPO4561D';
        insert objcon;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Alumni Portal Profile'];
        
        User objUser = new User(
            LastName = 'Te',
            FirstName ='testing',
            alias = 'tes'+'tes',
            Email = 'test@unitingambitionn.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            ContactId = objcon.Id,
            UserName='test@unitingambitions.com',
            EmployeeNumber ='EP134'
        );
        insert objUser;
        
        List<ContentDocumentLink> lst_CondocLink = New List<ContentDocumentLink>();
        
        List<ContentVersion> lst_Contnvrsn = New List<ContentVersion>();
        
        ContentVersion objContVrsn = New ContentVersion();
        objContVrsn.title = 'Test';
        objContVrsn.PathOnClient = objContVrsn.Title + '.snote';
        objContVrsn.VersionData = Blob.valueof('this is a test');
         objContVrsn.FirstPublishLocationId = objcon.Id;
        objContVrsn.NetworkId = Network.getNetworkId();
        lst_Contnvrsn.add(objContVrsn);
        Insert objContVrsn;
        
        List<ContentDocument> lst_Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: objcon.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        if(!lst_Documents.isEmpty())
        {
            
            contentlink.ShareType= 'C';
            contentlink.LinkedEntityId = objcon.Id;
            contentlink.ContentDocumentId = lst_Documents[0].Id;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;          
        }
        lst_CondocLink.add(contentlink); 
        system.runAs(objUser)
        {
            
            Test.startTest();
            ALU_UploadProfilePictureCtrl.getProfilePicture();
            ALU_UploadProfilePictureCtrl.saveAttachment(objcon.id, 'FileNameTest', 'Testbase');
            Test.stopTest();
            // system.assertEquals(objcon.Joining_REVA__c,'yes');
        }
    }
    
   /* public static testMethod void UploadProfile1()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, ContactId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.ContactId = userRole.Id;
        update adminUser;
        //User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        User objUser = new User();
        System.runAs(adminUser)
        {
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Alumni').getRecordTypeId();
            Contact objcon = ALU_TestDataFactory.createContact('test Contact');
            objcon.Professor_Across_Schools__c = true;
            objcon.Application_Number__c = '123'; 
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@gmail.com';
            objcon.MobilePhone ='8963210547';
            objcon.SRN_No__c='Srn123';
            objcon.FirstName  = 'Test Con';
            objcon.LastName  ='LastCon';
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c = 'Indian';
            objcon.Aadhar_Card_Number__c ='368845632147'; 
            objcon.PAN_Number__c ='HRAPO4561D';
            insert objcon;
            
            Profile objProfile = [SELECT Id FROM Profile WHERE Name='Student Portal Profile'];
            
            objUser.LastName = 'Test User';
            objUser.Alias = 'standt';
            objUser.email='TestUserCityHead@testorg.com';
            objUser.EmailEncodingKey='UTF-8';
            objUser.LanguageLocaleKey='en_US';
            objUser.LocaleSidKey='en_US';
            objUser.TimeZoneSidKey='America/Los_Angeles';
            objUser.username='TestUserCityHead@testorg.com';
            objUser.ProfileId = objProfile.Id;
            objUser.ContactId=objcon.id;                        
            insert objUser;      
            
            List<ContentDocumentLink> lst_CondocLink = New List<ContentDocumentLink>();
            
            List<ContentVersion> lst_Contnvrsn = New List<ContentVersion>();
            
            ContentVersion objContVrsn = New ContentVersion();
            objContVrsn.title = 'Test';
            objContVrsn.PathOnClient = objContVrsn.Title + '.snote';
            objContVrsn.VersionData = Blob.valueof('this is a test');
            objContVrsn.FirstPublishLocationId = objcon.Id;
            lst_Contnvrsn.add(objContVrsn);
            Insert objContVrsn;
            
            List<ContentDocument> lst_Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: objcon.Id];
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            if(!lst_Documents.isEmpty())
            {
                
                contentlink.ShareType= 'C';
                contentlink.LinkedEntityId = objcon.Id;
                contentlink.ContentDocumentId = lst_Documents[0].Id;
                contentlink.Visibility = 'AllUsers'; 
                insert contentlink;          
            }
            lst_CondocLink.add(contentlink);
        }
        system.runAs(objUser)
        {
            
            Test.startTest();
            ALU_UploadProfilePictureCtrl.saveAttachment(objcon.id, 'FileNameTest', 'Testbase');
            Test.stopTest();
            // system.assertEquals(objcon.Joining_REVA__c,'yes');
        }
    }*/
}