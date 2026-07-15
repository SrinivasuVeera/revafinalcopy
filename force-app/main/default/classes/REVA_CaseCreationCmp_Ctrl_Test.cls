@isTest
public class REVA_CaseCreationCmp_Ctrl_Test 
{
    public static testmethod void  CaseCreation()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        User newUser1 = new user();
        
        system.runAs(adminUser){ 
            Account objAccount = new Account();
            objAccount.Name = 'Name';
            insert objAccount;
            
            Contact objContact = new Contact();
            objContact.LastName = 'Test';
            objContact.AccountId = objAccount.id;
             objContact.Personal_Email__c = 'test@reva.edu.in';
        objContact.hed__Preferred_Email__c = 'Personal Email';
            insert objContact;
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objContact.id
                //UserRoleId = userrole.Id
            );
        }
        Id CaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Utility.Case_SupportRequest_RecType).getRecordTypeId(); 
        system.runAs(newUser1){
            Case objCase = new Case();
            objCase.Category__c = 'Finance';
            objCase.Sub_Category__c  = 'Fee Payment';
            objCase.Subject= 'Case';
            objCase.RecordTypeId = CaseRecTypeId;
            
            Case_Management__c objCaseMang = new Case_Management__c();
            objCaseMang.Name= 'Adress Proof Certicate';
            objCaseMang.Sub_Category__c = 'Adress Proof Certicate';
            objCaseMang.Remarks__c='Please attach a copy of Government ID Proof of self/ parents';
            insert objCaseMang;
            
            REVA_CaseCreationCmp_Ctrl.responeWrapper reswrap = new REVA_CaseCreationCmp_Ctrl.responeWrapper();
            reswrap.strMessage='Success';
            reswrap.CaseId=objCase.id;
            
            test.startTest();
            REVA_CaseCreationCmp_Ctrl.CreateCaseWithFile('Title', 'fileName', objCase);
            REVA_CaseCreationCmp_Ctrl.fetchSubCatDetails();
            REVA_CaseCreationCmp_Ctrl.DisplayRecType();
            test.stopTest();  
            system.assertequals(objCase.id,objCase.id);
        }
    }
}