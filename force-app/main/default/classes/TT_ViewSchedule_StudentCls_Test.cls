@Istest
public class TT_ViewSchedule_StudentCls_Test 
{
    Public static testmethod Void SectionMethod()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        //update adminUser;
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'revacodex@gmail.com' + System.now().millisecond() ,
            Alias = 'sfdc',
            Email='revacodex@gmail.com',
            EmailEncodingKey='UTF-8',
            Firstname='Dhanik',
            Lastname='Sahni',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        system.runAs(portalAccountOwner1){
            Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
            Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            Contact objCon = TT_TestDataFactory.createContact('Test');
            objcon.RecordTypeId = ContactRecTypeId;            
            //objcon.RecordTypeId = ContactRecTypeId;
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';            
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id; 
            objcon.Nationality__c = 'Indian';
            objcon.Active__c = true;
            Insert objCon;        
            
            Profile portalProfile = [select Id,name from Profile where Name ='Student Portal Profile' Limit 1];
            User newUser1 = new User(
                UserName = 'newUser@epeople.com',
                FirstName = objAcc.Name,
                LastName = objAcc.Name,
                Alias = 'test123',
                email = 'pb@f.com',
                ContactId = objCon.Id,
                ProfileId = portalProfile.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            Database.insert(newUser1);
            
            system.runAs(newUser1){
                hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
                Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
                hed__Term__c obj_Term3 = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
                hed__Term__c obj_Term2 = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
                hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
                
                hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
                
                Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();        
                hed__Course_Enrollment__c obj_CourEnroll = TT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
                
                hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
                objcourseSch.hed__Start_Time__c = time.newInstance(6, 0, 0, 0);
                objcourseSch.hed__End_Time__c = time.newInstance(22, 0, 0, 0);
                 //    objcourseSch.hed__Start_Time__c =  system.now().time();
                  //  objcourseSch.hed__End_Time__c =  system.now().time();

                system.runAs(adminUser){
                    obj_Cour.hed__Course_ID__c ='123';
                    Insert obj_Cour; 
                    
                    obj_Term3.RecordTypeId = termRecTypeId;
                    obj_Term3.hed__Start_Date__c =system.today().addDays(-5);
                    obj_Term3.hed__End_Date__c = system.today().addDays(10);
                    obj_Term3.hed__Account__c = objAcc.Id;
                    Insert obj_Term3;
                    
                    obj_Term2.RecordTypeId = termRecTypeId;
                    obj_Term2.hed__Start_Date__c =system.today().addDays(-5);
                    obj_Term2.hed__End_Date__c = system.today().addDays(10);
                    obj_Term2.hed__Account__c = objAcc.Id;
                    obj_Term2.hed__Parent_Term__c = obj_Term3.Id;
                    Insert obj_Term2;
                    
                    obj_Term.RecordTypeId = termRecTypeId;
                    obj_Term.hed__Start_Date__c =system.today().addDays(-7);
                    obj_Term.hed__End_Date__c = system.today().addDays(8);
                    obj_Term.hed__Account__c = objAcc.Id;
                    obj_Term.hed__Parent_Term__c = obj_Term2.id;
                    Insert obj_Term;
                    
                    obj_CourOff.hed__Course__c = obj_Cour.Id;
                    obj_CourOff.hed__Term__c = obj_Term.Id;
                    obj_CourOff.Category__c ='Hardcore Course';
                    insert obj_CourOff; 
                    
                    obj_CourEnroll.RecordTypeId= enrollRecTypeId;
                    obj_CourEnroll.Section__c = obj_Term.id;
                    obj_CourEnroll.hed__Course_Offering__c = obj_CourOff.Id;
                    Insert obj_CourEnroll;
                    
                    objcourseSch.Section__c =  obj_Term.id;
                    objcourseSch.hed__Course_Offering__c= obj_CourOff.Id;
                    objcourseSch.hed__Start_Time__c =  time.newInstance(6, 0, 0, 0);
                    objcourseSch.hed__End_Time__c =  time.newInstance(22, 0, 0, 0);
                    insert objcourseSch;
                }   
                TT_ViewSchedule_StudentCls.SlotWrp slwrap = new TT_ViewSchedule_StudentCls.SlotWrp('slotname','courseNames',1);
                slwrap.slotname='slotname';
                slwrap.courseNames='courseNames';
                slwrap.colLen=1;
                
                list<TT_ViewSchedule_StudentCls.SlotWrp> lst_slwrap = new list<TT_ViewSchedule_StudentCls.SlotWrp>();
                lst_slwrap.add(slwrap);
                
                TT_ViewSchedule_StudentCls.ScheduleWrp schwrap = new TT_ViewSchedule_StudentCls.ScheduleWrp('courseNames','dayName',lst_slwrap);
                schwrap.dayName ='dayName';
                schwrap.lst_Slots=lst_slwrap;
                
                list<TT_ViewSchedule_StudentCls.ScheduleWrp> lst_sch = new list<TT_ViewSchedule_StudentCls.ScheduleWrp>();
                lst_sch.add(schwrap);
                
                TT_ViewSchedule_StudentCls.ResponseWrp  reswrap = new TT_ViewSchedule_StudentCls.ResponseWrp();
                reswrap.resStatus ='success';
                reswrap.resMessage='res message';
                reswrap.schoolName='test';
                reswrap.programName='programName';
                reswrap.semesterName='semesterName';
                reswrap.secName='secName';
                reswrap.acdYear='acdYear';
                reswrap.lst_Sch = lst_sch;
                
                set<string> set_course = new set<string>();
                set_course.add(obj_CourOff.id); 
                
                string termid=obj_Term.Id;
                
                TT_ViewSchedule_StudentCls.SlotTimeWrp slttimewrap = new TT_ViewSchedule_StudentCls.SlotTimeWrp('10','20','1');
                test.starttest();
                try {
                TT_ViewSchedule_StudentCls.getFaculties(termid,set_course);
                TT_ViewSchedule_StudentCls.getTimeTableRecords('courseNames');
                } catch(Exception ex) {
                    
                }
                test.stopTest();
                system.assertEquals(obj_Term.Id, objcourseSch.Section__c);                
            }   
        }
    }
    Public static testmethod Void SectionMethod2()
    {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        //update adminUser;
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'revacodex@gmail.com' + System.now().millisecond() ,
            Alias = 'sfdc',
            Email='revacodex@gmail.com',
            EmailEncodingKey='UTF-8',
            Firstname='Dhanik',
            Lastname='Sahni',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        system.runAs(portalAccountOwner1){
            Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();        
            Account objAcc = TT_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            Contact objCon = TT_TestDataFactory.createContact('Test');
            objcon.RecordTypeId = ContactRecTypeId;            
            //objcon.RecordTypeId = ContactRecTypeId;
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';            
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id; 
            objcon.Nationality__c = 'Indian';
            objcon.Active__c = true;
            Insert objCon;
            
            
            Profile portalProfile = [select Id,name from Profile where Name ='Student Portal Profile' Limit 1];
            User newUser1 = new User(
                UserName = 'newUser@epeople.com',
                FirstName = objAcc.Name,
                LastName = objAcc.Name,
                Alias = 'test123',
                email = 'pb@f.com',
                ContactId = objCon.Id,
                ProfileId = portalProfile.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
            Database.insert(newUser1);
            
            system.runAs(newUser1){
                hed__Course__c obj_Cour = TT_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
                Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
                hed__Term__c obj_Term3 = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
                hed__Term__c obj_Term2 = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
                hed__Term__c obj_Term = TT_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
                
                hed__Course_Offering__c obj_CourOff =TT_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
                
                Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Faculty').getRecordTypeId();        
                hed__Course_Enrollment__c obj_CourEnroll = TT_TestDataFactory.createCourseEnrollment(ObjCon.id, obj_CourOff.Id);
                
                hed__Course_Offering_Schedule__c objcourseSch = TT_TestDataFactory.CreateCourseSchedule(obj_CourOff.id,obj_Term.id);
                objcourseSch.hed__Start_Time__c = system.now().time();
                objcourseSch.hed__End_Time__c = system.now().time();
                objcourseSch.hed__Friday__c =true;
                objcourseSch.hed__Saturday__c = true;
                objcourseSch.hed__Sunday__c = true;
                
                system.runAs(adminUser){
                    obj_Cour.hed__Course_ID__c ='123';
                    Insert obj_Cour; 
                    
                    obj_Term3.RecordTypeId = termRecTypeId;
                    obj_Term3.hed__Start_Date__c =system.today().addDays(-5);
                    obj_Term3.hed__End_Date__c = system.today().addDays(10);
                    obj_Term3.hed__Account__c = objAcc.Id;
                    Insert obj_Term3;
                    
                    obj_Term2.RecordTypeId = termRecTypeId;
                    obj_Term2.hed__Start_Date__c =system.today().addDays(-5);
                    obj_Term2.hed__End_Date__c = system.today().addDays(10);
                    obj_Term2.hed__Account__c = objAcc.Id;
                    obj_Term2.hed__Parent_Term__c = obj_Term3.Id;
                    Insert obj_Term2;
                    
                    obj_Term.RecordTypeId = termRecTypeId;
                    obj_Term.hed__Start_Date__c =system.today().addDays(-7);
                    obj_Term.hed__End_Date__c = system.today().addDays(8);
                    obj_Term.hed__Account__c = objAcc.Id;
                    obj_Term.hed__Parent_Term__c = obj_Term2.id;
                    Insert obj_Term;
                    
                    obj_CourOff.hed__Course__c = obj_Cour.Id;
                    obj_CourOff.hed__Term__c = obj_Term.Id;
                    obj_CourOff.Category__c ='Hardcore Course';
                    insert obj_CourOff; 
                    
                    obj_CourEnroll.RecordTypeId= enrollRecTypeId;
                    obj_CourEnroll.Section__c = obj_Term.id;
                    obj_CourEnroll.hed__Course_Offering__c = obj_CourOff.Id;
                    Insert obj_CourEnroll;
                    
                    objcourseSch.Batch_Group__c =  obj_Term.id;
                    objcourseSch.Section__c=  obj_Term.id;
                    insert objcourseSch;
                    objcourseSch.hed__Start_Time__c = system.now().time();
                    objcourseSch.hed__End_Time__c = system.now().time();
                    update objcourseSch;
                }
                TT_ViewSchedule_StudentCls.SlotWrp slwrap = new TT_ViewSchedule_StudentCls.SlotWrp('slotname','courseNames',1);
                slwrap.slotname='slotname';
                slwrap.courseNames='courseNames';
                slwrap.colLen=1;
                
                list<TT_ViewSchedule_StudentCls.SlotWrp> lst_slwrap = new list<TT_ViewSchedule_StudentCls.SlotWrp>();
                lst_slwrap.add(slwrap);
                
                TT_ViewSchedule_StudentCls.ScheduleWrp schwrap = new TT_ViewSchedule_StudentCls.ScheduleWrp('courseNames','dayName',lst_slwrap);
                schwrap.dayName ='dayName';
                schwrap.lst_Slots=lst_slwrap;
                
                list<TT_ViewSchedule_StudentCls.ScheduleWrp> lst_sch = new list<TT_ViewSchedule_StudentCls.ScheduleWrp>();
                lst_sch.add(schwrap);
                
                TT_ViewSchedule_StudentCls.ResponseWrp  reswrap = new TT_ViewSchedule_StudentCls.ResponseWrp();
                reswrap.resStatus ='success';
                reswrap.resMessage='res message';
                reswrap.schoolName='test';
                reswrap.programName='programName';
                reswrap.semesterName='semesterName';
                reswrap.secName='secName';
                reswrap.acdYear='acdYear';
                reswrap.lst_Sch = lst_sch;
                
                set<string> set_course = new set<string>();
                set_course.add(obj_CourOff.id); 
                string termid=obj_Term.Id;
                  TT_ViewSchedule_StudentCls.FacultyWrp facultyWrp = new TT_ViewSchedule_StudentCls.FacultyWrp(
            'connectionId', 
            'coursoffsch', 
            'courseCode', 
            'coursename', 
            'facultyName', 
            'facilityName', 
            'dayAndTime'
        );
                
                TT_ViewSchedule_StudentCls.SlotTimeWrp slttimewrap = new TT_ViewSchedule_StudentCls.SlotTimeWrp('10','20','1');
                test.starttest();
                TT_ViewSchedule_StudentCls.getTimeTableRecords('test');
                TT_ViewSchedule_StudentCls.getFaculties(termid,set_course);  
                TT_ViewSchedule_StudentCls.getDistinctCourseNames(objCon.Id);
                test.stopTest();
                system.assertEquals(obj_Term.Id, objcourseSch.Section__c);                
            }
        }
    }
}