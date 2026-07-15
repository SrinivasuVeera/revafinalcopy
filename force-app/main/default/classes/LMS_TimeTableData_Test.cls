@isTest
public class LMS_TimeTableData_Test
{    
    public static testmethod void GetDataMethod()
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
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
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
            objcon.Employee_Number__c ='001';
            
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
            obj_CourOff.Category__c ='Hardcore Course'; 
            insert obj_CourOff;
            
            hed__Course_Offering__c obj_CourOff1 =ATT_TestDataFactory.createCourseOffering('Mandatory Course', obj_Term.Id, obj_Cour.id);
            obj_CourOff1.Category__c ='Mandatory Course'; 
            insert obj_CourOff1;
            
            hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
            objcourseSch.hed__Start_Time__c = system.now().time();
            objcourseSch.hed__End_Time__c = system.now().time();
            objcourseSch.Date__c = system.today();
            objcourseSch.Teaching_Method__c ='ICT';
            objcourseSch.Course_Plan_Completed__c ='Yes';
            objcourseSch.Status__c ='Scheduled';
            objcourseSch.Professor__c =objcon.ownerid;
            objcourseSch.Batch_Group__c = obj_Term.id;
            insert objcourseSch;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
            obj_CourEnroll.RecordTypeId= enrollRecTypeId;
            obj_CourEnroll.Section__c = obj_Term.id;
            Insert obj_CourEnroll;
            
            LMS_TimeTableData.ProfDetWrp prfwrap = new LMS_TimeTableData.ProfDetWrp(objUser.id,'test professor1','red',objcourseSch.id,'');
            prfwrap.colorCode ='red';
            prfwrap.profId = objUser.id;
            prfwrap.ProfName='test user';
            prfwrap.ReqSchId = objcourseSch.id; 
            
            list<LMS_TimeTableData.ProfDetWrp> lst_prof = new list<LMS_TimeTableData.ProfDetWrp>();
            lst_prof.add(prfwrap);
            
            LMS_TimeTableData.FacultyScheduleWrp fmWrpr = new LMS_TimeTableData.FacultyScheduleWrp(objcourseSch.id,
                                                                                                   system.today(),
                                                                                                   2,
                                                                                                   '11:00-12:00',
                                                                                                   'test',
                                                                                                   'Course Name',
                                                                                                   obj_Term.id,
                                                                                                   obj_Term.id,
                                                                                                   'cp123');
            fmWrpr.schId = objcourseSch.id;
            fmWrpr.schDate = system.today();
            fmWrpr.CourseId = '1223';
            fmWrpr.sectionId =obj_Term.id;
            fmWrpr.isChecked = true;
            fmWrpr.courseName ='test';
            fmWrpr.courseId = 'test 123';
            fmWrpr.profDetails = lst_prof;
            
            list<LMS_TimeTableData.FacultyScheduleWrp> lst_fmWrpr = new list<LMS_TimeTableData.FacultyScheduleWrp>();
            lst_fmWrpr.add(fmWrpr);
            
            LMS_TimeTableData.ResponseWrp reqwarp = new LMS_TimeTableData.ResponseWrp();            
            reqwarp.schList = lst_fmWrpr;
            
            LMS_TimeTableData.EmployeeData empwrap = new LMS_TimeTableData.EmployeeData();
            empwrap.Emp_EmployeeNumber = '001';
            empwrap.Emp_Reason='test';
            empwrap.Emp_LeaveType='First';
            empwrap.Emp_FromDate = string.valueof(system.today());
            empwrap.Emp_ToDate =string.valueof(system.today());
            empwrap.Emp_SessionType = 'First';
            
            list<LMS_TimeTableData.EmployeeData> lst_empwrap = new list<LMS_TimeTableData.EmployeeData>();
            lst_empwrap.add(empwrap);
            
            LMS_TimeTableData.RequestWrapper reqwrap = new LMS_TimeTableData.RequestWrapper();
            reqwrap.EmployeeData = lst_empwrap;
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            String jsonBody = Json.serialize(reqwrap);
            req.requestBody = Blob.valueof(jsonBody);
            req.requestURI = '/services/apexrest/professorTTDetails/';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            test.startTest();
            LMS_TimeTableData.getSLCMProfessorDetails();
            test.stopTest();            
        }
    }
      public static testmethod void GetDataMethod3()
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
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
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
            objcon.Employee_Number__c ='001';
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
            obj_CourOff.Category__c ='Hardcore Course'; 
            insert obj_CourOff;
            
            hed__Course_Offering__c obj_CourOff1 =ATT_TestDataFactory.createCourseOffering('Mandatory Course', obj_Term.Id, obj_Cour.id);
            obj_CourOff1.Category__c ='Mandatory Course'; 
            insert obj_CourOff1;
            
            hed__Course_Offering__c obj_CourOff2 =ATT_TestDataFactory.createCourseOffering('Open Elective', obj_Term.Id, obj_Cour.id);
            obj_CourOff2.Category__c ='Open Elective'; 
            insert obj_CourOff2;
            
            
            hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
            objcourseSch.hed__Start_Time__c = system.now().time();
            objcourseSch.hed__End_Time__c = system.now().time();
            objcourseSch.Date__c = system.today();
            objcourseSch.Teaching_Method__c ='ICT';
            objcourseSch.Course_Plan_Completed__c ='Yes';
            objcourseSch.Status__c ='Scheduled';
            objcourseSch.Professor__c =objcon.ownerid;
            objcourseSch.Batch_Group__c = obj_Term.id;
            insert objcourseSch;
            
            hed__Course_Offering_Schedule__c objcourseSch1 = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff2.id,obj_Term.id);
            objcourseSch1.hed__Start_Time__c = system.now().time();
            objcourseSch1.hed__End_Time__c = system.now().time();
            objcourseSch1.Date__c = system.today();
            objcourseSch1.Teaching_Method__c ='ICT';
            objcourseSch1.Course_Plan_Completed__c ='Yes';
            objcourseSch1.Status__c ='Scheduled';
            objcourseSch1.Professor__c =objcon.ownerid;
            objcourseSch1.Batch_Group__c = obj_Term.id;
            insert objcourseSch1;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
            obj_CourEnroll.RecordTypeId= enrollRecTypeId;
            obj_CourEnroll.Section__c = obj_Term.id;
            Insert obj_CourEnroll;
            
            LMS_TimeTableData.ProfDetWrp prfwrap = new LMS_TimeTableData.ProfDetWrp(objUser.id,'test professor1','red',objcourseSch.id,'');
            prfwrap.colorCode ='red';
            prfwrap.profId = objUser.id;
            prfwrap.ProfName='test user';
            prfwrap.ReqSchId = objcourseSch.id; 
            
            list<LMS_TimeTableData.ProfDetWrp> lst_prof = new list<LMS_TimeTableData.ProfDetWrp>();
            lst_prof.add(prfwrap);
            
            LMS_TimeTableData.FacultyScheduleWrp fmWrpr = new LMS_TimeTableData.FacultyScheduleWrp(objcourseSch.id,
                                                                                                   system.today(),
                                                                                                   2,
                                                                                                   '11:00-12:00',
                                                                                                   'test',
                                                                                                   'Course Name',
                                                                                                   obj_Term.id,
                                                                                                   obj_Term.id,
                                                                                                   'cp123');
            fmWrpr.schId = objcourseSch.id;
            fmWrpr.schDate = system.today();
            fmWrpr.CourseId = '1223';
            fmWrpr.sectionId =obj_Term.id;
            fmWrpr.isChecked = true;
            fmWrpr.courseName ='test';
            fmWrpr.courseId = 'test 123';
            fmWrpr.profDetails = lst_prof;
            
            list<LMS_TimeTableData.FacultyScheduleWrp> lst_fmWrpr = new list<LMS_TimeTableData.FacultyScheduleWrp>();
            lst_fmWrpr.add(fmWrpr);
            
            LMS_TimeTableData.ResponseWrp reqwarp = new LMS_TimeTableData.ResponseWrp();            
            reqwarp.schList = lst_fmWrpr;
            
            LMS_TimeTableData.EmployeeData empwrap = new LMS_TimeTableData.EmployeeData();
            empwrap.Emp_EmployeeNumber = '001';
            empwrap.Emp_Reason='test';
            empwrap.Emp_LeaveType='Whole';
            empwrap.Emp_FromDate = string.valueof(system.today());
            empwrap.Emp_ToDate =string.valueof(system.today());
            empwrap.Emp_SessionType = 'Whole';
            
            list<LMS_TimeTableData.EmployeeData> lst_empwrap = new list<LMS_TimeTableData.EmployeeData>();
            lst_empwrap.add(empwrap);
            
            LMS_TimeTableData.RequestWrapper reqwrap = new LMS_TimeTableData.RequestWrapper();
            reqwrap.EmployeeData = lst_empwrap;
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            String jsonBody = Json.serialize(reqwrap);
            req.requestBody = Blob.valueof(jsonBody);
            req.requestURI = '/services/apexrest/professorTTDetails/';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            test.startTest();
            LMS_TimeTableData.getSLCMProfessorDetails();
            test.stopTest();            
        }
    }
    public static testmethod void GetDataMethod1()
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
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Professor').getRecordTypeId();
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
            objcon.Employee_Number__c ='001';
            objcon.FirstName = 'Test';
            objcon.MiddleName = 'M';
            objcon.LastName = 'T';
            objcon.Active__c = true;
            insert objcon;
            
            Contact objcon1 = ATT_TestDataFactory.createContact('test Contact1');
            objcon1.AccountId = objAccount.id;
            objcon1.Professor_Across_Schools__c = true;
            objcon1.Application_Number__c = '1232';
            objcon1.hed__WorkEmail__c='1232@reva.edu.in';
            objcon1.Email = 'test2@gmail.com';
            objcon1.MobilePhone ='8963220547';
            objcon1.SRN_Number__c='Srn1223';
            //objcon1.RecordTypeId = ContactRecTypeId;
            objcon1.ownerid = userinfo.getUserId();
            objcon1.Nationality__c = 'Indian';
            objcon1.Aadhar_Card_Number__c ='368845632147'; 
            objcon1.PAN_Number__c ='HRAPO4561D';
            objcon1.Employee_Number__c ='001';
            ObjCon1.Active__c=true;
            ObjCon1.FirstName = 'Test';
            ObjCon1.MiddleName = 'M';
            ObjCon1.LastName = 'T';             
            insert objcon1;
            
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
            obj_CourOff.Category__c ='Hardcore Course'; 
            insert obj_CourOff;
            
            hed__Course_Offering_Schedule__c objcourseSch = ATT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
            objcourseSch.hed__Start_Time__c = system.now().time();
            objcourseSch.hed__End_Time__c = system.now().time();
            objcourseSch.Date__c = system.today();
            objcourseSch.Teaching_Method__c ='ICT';
            objcourseSch.Course_Plan_Completed__c ='Yes';
            objcourseSch.Status__c ='Scheduled';
            //objcourseSch.Professor__c =objcon1.ownerid;
            insert objcourseSch;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
            obj_CourEnroll.RecordTypeId= enrollRecTypeId;
            obj_CourEnroll.Section__c = obj_Term.id;
            Insert obj_CourEnroll;
            
            string FacultyRecId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Faculty_RecType).getRecordTypeId();
            
            hed__Course_Enrollment__c obj_CourEnrol = ATT_TestDataFactory.createCourseEnrollment(ObjCon1.id, obj_CourOff.Id);
            obj_CourEnrol.RecordTypeId= FacultyRecId;
            obj_CourEnrol.Section__c = obj_Term.id;
            Insert obj_CourEnrol;
            
            LMS_TimeTableData.ProfDetWrp prfwrap = new LMS_TimeTableData.ProfDetWrp(objUser.id,'test professor1','red',objcourseSch.id,'test');
            prfwrap.colorCode ='red';
            prfwrap.profId = objUser.id;
            prfwrap.ProfName='test user';
            prfwrap.ReqSchId = objcourseSch.id;
            
            list<LMS_TimeTableData.ProfDetWrp> lst_prof = new list<LMS_TimeTableData.ProfDetWrp>();
            lst_prof.add(prfwrap);
            
            LMS_TimeTableData.FacultyScheduleWrp fmWrpr = new LMS_TimeTableData.FacultyScheduleWrp(objcourseSch.id,system.today(),decimal.valueof(10),'11:00-12:00','test','test',obj_Term.id,obj_Term.id,'cp123');
            fmWrpr.schId = objcourseSch.id;
            fmWrpr.schDate = system.today();
            fmWrpr.CourseId = '1223';
            fmWrpr.sectionId =obj_Term.id;
            fmWrpr.isChecked = true;
            fmWrpr.courseName ='test';
            fmWrpr.courseId = 'test 123';
            fmWrpr.profDetails = lst_prof;
            
            list<LMS_TimeTableData.FacultyScheduleWrp> lst_fmWrpr = new list<LMS_TimeTableData.FacultyScheduleWrp>();
            lst_fmWrpr.add(fmWrpr);
            
            LMS_TimeTableData.ResponseWrp reqwarp = new LMS_TimeTableData.ResponseWrp();            
            reqwarp.schList = lst_fmWrpr;
            
            LMS_TimeTableData.EmployeeData empwrap = new LMS_TimeTableData.EmployeeData();
            empwrap.Emp_EmployeeNumber = '001';
            empwrap.Emp_Reason='test';
            empwrap.Emp_LeaveType='cl';
            empwrap.Emp_FromDate = string.valueof(system.today());
            empwrap.Emp_ToDate =string.valueof(system.today());
            empwrap.Emp_SessionType = 'first';
            
            list<LMS_TimeTableData.EmployeeData> lst_empwrap = new list<LMS_TimeTableData.EmployeeData>();
            lst_empwrap.add(empwrap);
            
            LMS_TimeTableData.RequestWrapper reqwrap = new LMS_TimeTableData.RequestWrapper();
            reqwrap.EmployeeData = lst_empwrap;
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            
            String jsonBody = Json.serialize(reqwrap);
            req.requestBody = Blob.valueof(jsonBody);
            req.requestURI = '/services/apexrest/professorTTDetails/';
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response= res;
            
            test.startTest();
            LMS_TimeTableData.getSLCMProfessorDetails();
            test.stopTest();            
        }
    }
}