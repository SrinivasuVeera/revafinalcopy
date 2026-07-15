@isTest
public class REVA_AlumniContactDetailsCtrl_Test 
{
    public static testmethod void method()
    {
        User Admin = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() AND IsActive = true LIMIT 1];
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser; 
        
        User objUser = new User();
        Contact objcon = new Contact(); 
        System.runAs(adminUser)
        {
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
            objAccount.RecordtypeId = UniversityRecId;  
            insert objAccount;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            objcon = ALU_TestDataFactory.createContact('test Contact');
            objcon.AccountId = objAccount.id;
            objcon.Professor_Across_Schools__c = true;
            objcon.Application_Number__c = '123'; 
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@gmail.com';
            objcon.MobilePhone ='8963210547';
            objcon.SRN_Number__c='Srn123';
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c = 'Indian';
            objcon.Aadhar_Card_Number__c ='368845632147'; 
            objcon.PAN_Number__c ='HRAPO4561D';
            objcon.ownerid = userinfo.getUserId();
            //objcon.Position_of_Student__c = 'Placed';
            objcon.Placement__c = 'On-Campus';
            objcon.Company__c = 'ttesting';
            objcon.Designation__c = 'ttt';
            objcon.Location__c = 'banglore';
            objcon.Date_of_Joining__c = system.today();
            objcon.Joining_REVA__c = 'yes';
            objcon.Which_Program__c = 'B.tech';
            objcon.University_Name__c = 'college';
            objcon.Date_of_Joining_HS__c = system.today();
            objcon.Country_HS__c = 'india';
            objcon.Location_HS__c = 'pune';
            objcon.Firm_Name__c = 'University';
            objcon.Started__c = 'yes';
            objcon.Designation_SU__c = 'executive';
            objcon.Location_SU__c = 'Karnataka';
            objcon.Type_of_Business__c = 'xxx';
            objcon.Location_B__c = 'yyy';
            objcon.Type_of_Job_Targeting__c = 'business';
            objcon.Coaching_required_from_REVA_University__c = 'yes';
            objcon.Others__c = 'ttesting';
            objcon.Blood_Group__c = 'A+';
            objcon.Marital_Status__c =' Married';
            objcon.hed__Gender__c = 'Female';
            objcon.School_Department__c = 'Branch';
            objcon.Year_Of_Graduation__c = '2023';
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
            
            REVA_AlumniContactDetailsCtrl.wrapperCls wrap = new REVA_AlumniContactDetailsCtrl.wrapperCls();
            wrap.con = objcon;
            
            List<Contact> list_Con = new List<Contact>();
            list_Con.add(objcon);
            
            system.runAs(objUser)
            {
                Test.startTest();
                REVA_AlumniContactDetailsCtrl.fetchContact();
                Test.stopTest();
                system.assertEquals(objcon.Joining_REVA__c,'yes');
            }  
        }
        
    }
    
}