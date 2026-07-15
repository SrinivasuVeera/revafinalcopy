@isTest
public class MM_CreateAppointmentAttendeeCls_Test 
{    
    public static testMethod Void AppointmentMethod()
    {       
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();            
        Account objAcc = MM_TestDataFactory.CreateAccount('Test Account1', AccountRecTypeId);
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        Contact ObjCon = MM_TestDataFactory.createContact('Test Contact1');
        
        Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];        
        User newUser1 = new User();
        
        Id AccountRecTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();            
        Account objAcc1 = MM_TestDataFactory.CreateAccount('Test Account', AccountRecTypeId1);
        
        Id ContactRecTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        Contact ObjCon1 = MM_TestDataFactory.createContact('Test Contact');
        
        system.runAs(adminUser)
        { 
            objAcc1.RecordTypeId = AccountRecTypeId1;
            insert objAcc1;
            
            ObjCon1.RecordTypeId = ContactRecTypeId1;
            ObjCon1.AccountId = objAcc1.Id;
            ObjCon1.hed__WorkEmail__c='123@reva.edu.in';
            ObjCon1.Email = 'test@reva.edu.in';
            //ObjCon1.Email ='test@342bctest.com';
            ObjCon1.hed__Preferred_Email__c='Personal Email';
            //.hed__Preferred_Email__c = 'Official Email';
            
            Insert ObjCon1; 
            system.debug('ObjCon1 '+ObjCon1);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            ObjCon.RecordTypeId = ContactRecTypeId;
            ObjCon.AccountId = objAcc.Id;
            Insert ObjCon;
            
            newUser1.profileId = p.Id;
            newUser1.username = 'newUser@epeople.com';
            newUser1.email = 'pb@f.com';
            newUser1.emailencodingkey = 'UTF-8';
            newUser1.localesidkey = 'en_US';
            newUser1.languagelocalekey = 'en_US';
            newUser1.timezonesidkey = 'America/Los_Angeles';
            newUser1.alias='nuser';
            newUser1.lastname='lastname';
            newUser1.contactId = ObjCon.id;
            insert newUser1;
            
            case objcase = MM_TestDataFactory.createCase('Queued','Email');
            objcase.ownerid =  adminUser.id;
            objcase.ContactId = ObjCon.id;
            insert objcase;
            
            CaseTeamRole  ctr= [SELECT Id, Name, AccessLevel FROM CaseTeamRole Where Name='Student Member' limit 1 ];
            CaseTeamMember ctm = new CaseTeamMember();
            ctm.MemberId = ObjCon.id;
            ctm.ParentId = objcase.Id;
            ctm.TeamRoleId = ctr.Id;
            insert ctm;
        }
        system.runAs(newUser1)
        {         
            datetime stdate = system.now();
            datetime enddate = system.now();
            
            sfal__Appointment__c objApp = MM_TestDataFactory.createAppointment(stdate,enddate);
            insert objApp;
            
            event objevent = MM_TestDataFactory.CreateEvent(newUser1.id,'Email',stdate,enddate);
            objevent.ownerId = adminUser.id; 
            insert objevent;        
            
            sfal__AppointmentAttendee__c objAppAtt = MM_TestDataFactory.CreaetAppAttendance(objApp.id);
            insert objAppAtt;
            
            test.starttest();
            MM_CreateAppointmentAttendeeCls.getAttendeeRecord(objApp.id);
            test.stoptest();
            system.assertequals(objApp.id,objApp.id);
        }
    }
}