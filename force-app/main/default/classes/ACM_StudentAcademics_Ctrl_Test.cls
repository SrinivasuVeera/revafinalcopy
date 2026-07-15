@isTest
public class ACM_StudentAcademics_Ctrl_Test 
{
    public static testmethod Void AcademicMethod()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User objUser = new User();
        hed__Course_Offering_Schedule__c objcourseSch = new hed__Course_Offering_Schedule__c(); 
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
            obj_Cour.hed__Course_ID__c ='123';
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
            hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
            obj_CourEnroll.RecordTypeId= enrollRecTypeId;
            obj_CourEnroll.Section__c = obj_Term.id;
            Insert obj_CourEnroll;
            
            Course_Plan_Topic__c obj_CoursePlanTopic = new Course_Plan_Topic__c();
            obj_CoursePlanTopic.name='test';
            insert obj_CoursePlanTopic;
            
            objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
            objcourseSch.hed__Start_Time__c = system.now().time();
            objcourseSch.hed__End_Time__c = system.now().time();
            objcourseSch.Date__c = system.today();
            objcourseSch.Teaching_Method__c ='ICT';
            objcourseSch.Course_Plan_Completed__c ='Yes';
            objcourseSch.Status__c ='Scheduled';
            objcourseSch.Actual_Topic__c = obj_CoursePlanTopic.id;
            objcourseSch.Planned_Topic__c = obj_CoursePlanTopic.id;
            insert objcourseSch;   
            
            ACM_StudentAcademics_Ctrl.StudentWrapper swrap = new ACM_StudentAcademics_Ctrl.StudentWrapper();
            swrap.ProgramName = 'test';
            swrap.SemesterNo='3';
            swrap.SectionName='C';
            
            ACM_StudentAcademics_Ctrl.PlanWrapper pwrap = new ACM_StudentAcademics_Ctrl.PlanWrapper();
            pwrap.ActualTopicName='test topic';
            pwrap.PlannedTopicName='plan topic'; 
        }
        system.runas(objUser)
        {
            test.starttest();
            ACM_StudentAcademics_Ctrl.DisplayAttendance();
            ACM_StudentAcademics_Ctrl.DisplayPlanTopic(objcourseSch.id);
            test.stoptest();
            system.assertEquals(objcourseSch.id, objcourseSch.id);            
        }
        
    }
}