@IsTest
public class ContactCheckBox_Handler_Test 
{
    Public Static TestMethod Void ContactCheckBox()
    {
        User otherAdmin = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = ALU_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        objAcc.Recordtypeid = HouseholdRecId;
        Insert objAcc;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
        Account objAccount1 = ALU_TestDataFactory.CreateAccount('Test Account1',AcaRecId );
        objAccount1.RecordTypeid = AcaRecId;
        objAccount1.Parentid = objAcc.id;
        insert objAccount1;
        
        hed__Program_Plan__c  objProgPlan =  ALU_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
        objProgPlan.hed__End_Date__c = system.today().addyears(+1);
        objProgPlan.hed__Account__c = objAccount1.id;
        insert objProgPlan;
        
        string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
        
        Contact objcon = ALU_TestDataFactory.createContact('Test');
        objcon.MobilePhone ='9090909090';
        objcon.Aadhar_Card_Number__c ='098765435612';
        objcon.RecordTypeId = StudentRecId;
        objcon.AccountId = objAcc.Id;
        objcon.School__c = objAcc.id;
        objcon.Application_Number__c = 'test123';
        objcon.SRN_Number__c ='123';
        objcon.Personal_Email__c = 'test@reva.edu.in';
        objcon.hed__Preferred_Email__c = 'Personal Email';
        objcon.Nationality__c ='Indian';
        objcon.Active__c = true;
        objcon.Student_Status__c = 'Pursuing';
        objcon.Program_Batch__c = objProgPlan.id;
        objcon.Primary_Academic_Program__c = objAccount1.id;
        Insert objcon; 
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runAs(thisUser)
        {
            User objUser = new User();
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
            
            List<Contact> lst_update = new List<Contact>();
            lst_update.add(objcon);
            
            objUser.IsActive = false;
            
            Set<Id> Set_conId = new Set<Id>();
            Set_conId.Add(objcon.Id);
            
            Map<Id,Contact> Map_con = new Map<Id,Contact>();
            Map_con.put(objcon.id, objcon);
            
            objcon.Form_Submitted__c = true;
            update objcon;
            
            Test.startTest();
            ContactCheckBox_Handler.Form_Submitted_Contact(lst_update, Map_con);
            ContactCheckBox_Handler.Form_Submitted_User(lst_update);
            ContactCheckBox_Handler.Form_Submitted_Update(lst_update, Map_con);
            ContactCheckBox_Handler.UpdateUser(Set_conId);
            Test.stopTest();
        }
    }
}