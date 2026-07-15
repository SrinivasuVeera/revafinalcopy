@isTest
public class LMS_CreateLeaveRequestAPI_Test
{    
    public static testmethod void LeaveRequestMethod()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
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
            User objUser = new User();
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
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Sections').getRecordTypeId();        
            hed__Term__c obj_Term = ATT_TestDataFactory.createTerm('Test Term',objAccount.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            Insert obj_Term;
            
            hed__Course_Offering__c obj_CourOff =ATT_TestDataFactory.createCourseOffering('Test CourseOffering', obj_Term.Id, obj_Cour.id);
            insert obj_CourOff;
            
            hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
            objcourseSch.hed__Start_Time__c = system.now().time();
            objcourseSch.hed__End_Time__c = system.now().time();
            objcourseSch.Date__c = system.today().adddays(-2);
            objcourseSch.Teaching_Method__c ='ICT';
            objcourseSch.Course_Plan_Completed__c ='Yes';
            objcourseSch.Status__c ='Scheduled';
            insert objcourseSch;
            
            Leave_Request__c objLR = new Leave_Request__c();
            objLR.From_Date__c = system.today();
            objLR.To_Date__c = system.today()+2;
            objLR.Leave_Request_Status__c = 'Submitted';
            objLR.HCM_Leave_Record_ID__c = 'test';
            insert objLr;
            
            LMS_CreateLeaveRequestAPI.FacultyScheduleWrp fmWrpr = new LMS_CreateLeaveRequestAPI.FacultyScheduleWrp();
            fmWrpr.schId = objcourseSch.id;
            fmWrpr.schDate = system.today();
            fmWrpr.CourseId = '1223';
            fmWrpr.sectionId =obj_Term.id;
            fmWrpr.ToDate = system.today() +2;
            fmWrpr.LeaveAppId = 'test';
            fmWrpr.LeaveRes = 'test leave';
            fmWrpr.TypeofLeave = 'test';
            fmWrpr.courseName ='test';
            //fmWrpr.startendtime = String.valueOf(objcourseSch.hed__Start_Time__c).substringAfterLast(':'); 
            fmWrpr.FromDate = system.today();
            fmWrpr.selProfName = objUser.id+'=>'+objcourseSch.id;
            fmWrpr.courseId = 'test 123';
            
            list<LMS_CreateLeaveRequestAPI.FacultyScheduleWrp> lst_fmWrpr = new list<LMS_CreateLeaveRequestAPI.FacultyScheduleWrp>();
            lst_fmWrpr.add(fmWrpr); 
            
            LMS_CreateLeaveRequestAPI.resultWpr resWrpr = new LMS_CreateLeaveRequestAPI.resultWpr();
            resWrpr.empNumber = '12343';
            resWrpr.error='error';
            resWrpr.status = 'success';
            
            LMS_CreateLeaveRequestAPI.ResponseWrp reqwrap = new LMS_CreateLeaveRequestAPI.ResponseWrp();
            reqwrap.schList =  lst_fmWrpr;
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            String jsonBody = Json.serialize(reqwrap);
            req.requestBody = Blob.valueof(jsonBody);
            req.requestURI = '/services/apexrest/CreateLeaveRequestAPI/';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            Test.startTest();               
            LMS_CreateLeaveRequestAPI.GetLeaveRequest();
            LMS_CreateLeaveRequestAPI.CreateLeaveRequest();
            Test.stopTest();
            system.assertEquals(objcourseSch.id, fmWrpr.schId);
        }
    }    
}