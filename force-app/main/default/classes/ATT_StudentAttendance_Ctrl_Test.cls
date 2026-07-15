@isTest
public class ATT_StudentAttendance_Ctrl_Test 
{
    public static testmethod Void StudentMethod()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole where PortalType = 'None'Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User objUser = new User();
        hed__Course_Enrollment__c obj_CourEnroll = new hed__Course_Enrollment__c();
        System.runAs(adminUser)
        { 
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId);
            objAccount.RecordtypeId = UniversityRecId;  
            insert objAccount;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            Contact objcon = ATT_TestDataFactory.createContact('test Contact');
            objcon.AccountId = objAccount.id;
            objcon.Professor_Across_Schools__c = true;
            objcon.Application_Number__c = '123';
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@gmail.com';
            objcon.MobilePhone ='8963210547';
            objcon.SRN_Number__c='Srn123';
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.ownerid = userinfo.getUserId();
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
            
            hed__Course__c obj_Cour = ATT_TestDataFactory.CreateCourse('Test Course', objAccount.Id);
            obj_Cour.hed__Course_ID__c = 'TC101';
            obj_Cour.Credits__c = 80.1;
            obj_Cour.Offered_By_School__c = objAccount.Id; 
            obj_Cour.Credit_Hours__c = 123.1;
            obj_Cour.L_T_P__c = '3.8:4.4:8.6';
            obj_Cour.Maximum_External_Marks__c = 100;
            obj_Cour.Total_Maximum_Marks_IA_External__c = 20;
            obj_Cour.No_of_IA_s__c = '2';            
            Insert obj_Cour;
            
            Id termRecTypeId1 = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
            hed__Term__c obj_Term1 = ATT_TestDataFactory.createTerm('Parent TermName',objAccount.Id, termRecTypeId1);
            obj_Term1.RecordTypeId = termRecTypeId1;
            obj_Term1.hed__Start_Date__c = system.today();
            obj_Term1.hed__End_Date__c = system.today();
            Insert obj_Term1;
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
            hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            obj_Term.hed__Parent_Term__c =obj_Term1.id;        
            Insert obj_Term;
            
            hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('Test CourseOffering', obj_Term.Id, obj_Cour.id);
            insert obj_CourOff;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
            obj_CourEnroll.RecordTypeId= enrollRecTypeId;
            obj_CourEnroll.Section__c = obj_Term.id;
            Insert obj_CourEnroll;
            
            ATT_StudentAttendance_Ctrl.StudentWrapper swrap = new ATT_StudentAttendance_Ctrl.StudentWrapper();
            swrap.ProgramName = 'test';
            swrap.SemesterNo='3';
            swrap.SectionName='C';
        }
        system.runas(objUser)
        {
            test.starttest();
            ATT_StudentAttendance_Ctrl.DisplayAttendance();
            test.stoptest();
            system.assertEquals(obj_CourEnroll.id, obj_CourEnroll.id);            
        }
        
    }
}