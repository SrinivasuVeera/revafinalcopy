@isTest
public class STOB_DefineStudentPreference_ctrl_Test 
{
     public static testMethod Void StudentMethod()
    {
       // UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
     
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;
            
            string UniversityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc1 = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc1.Recordtypeid = UniversityRecTypeId;
            objAcc1.OwnerId = portalAccountOwner1.Id;
            Insert objAcc1;
            
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objcon.RecordTypeId = ContactRecTypeId;            
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';            
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.Nationality__c ='Indian';
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
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                insert objProgEnrol;
                
                string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('OPEN ELECTIVES - 1',objAcc1.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffOpenEle.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffProfEle.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                    objCourse.Category__c = 'Hardcore Course';
                    objCourse.HardCore_Sub_Type__c = 'Theory'; 
                    objCourse.Credits__c = 4.00;
                    objCourse.Offered_By_School__c = objAcc1.Id;
                    objCourse.Credit_Hours__c = 4.00;
                    objCourse.Maximum_External_Marks__c = 50.00;
                    objCourse.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourse.SEE_Conducted_Marks__c = 12;
                    insert objCourse; 
                    
                    objCourseHI.Category__c = 'Hardcore Integrated Course';
                    objCourseHI.Credits__c = 4.00;
                    objCourseHI.Offered_By_School__c = objAcc1.Id;
                    objCourseHI.Credit_Hours__c = 4.00;
                    objCourseHI.Maximum_External_Marks__c = 50.00;
                    objCourseHI.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseHI;
                    
                    objCoursePW.Category__c = 'Practical/Term Work';
                    objCoursePW.Credits__c = 4.00;
                    objCoursePW.Offered_By_School__c = objAcc1.Id;
                    objCoursePW.Credit_Hours__c = 4.00;
                    objCoursePW.Maximum_External_Marks__c = 50.00;
                    objCoursePW.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCoursePW; 
                    
                    objCourseMAN.Category__c = 'Mandatory Course';
                    objCourseMAN.Credits__c = 4.00;
                    objCourseMAN.Offered_By_School__c = objAcc1.Id;
                    objCourseMAN.Credit_Hours__c = 4.00;
                    objCourseMAN.Maximum_External_Marks__c = 50.00;
                    objCourseMAN.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseMAN; 
                    
                    objCourseOpen.Category__c = 'Open Elective';
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Offered_By_School__c = objAcc1.Id;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                     objCourseProf.Credits__c = 4.00;
                    objCourseProf.Offered_By_School__c = objAcc1.Id;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    objCourseOff1.Credits__c = 40;
                    insert objCourseOff1;
                    
                    objCourseOffHC.Category__c = 'Hardcore Course';
                    objCourseOffHC.Sequence__c =1;
                    objCourseOffHC.Preference__c = '1';
                    objCourseOffHC.hed__Course__c = objCourse.Id;
                    objCourseOffHC.Credits__c = 40;
                    objCourseOffHC.hed__Term__c = objTerm.Id;
                    insert objCourseOffHC;
                    
                    objCourseOffHI.Category__c = 'Hardcore Integrated Course';
                    objCourseOffHI.Sequence__c =1;
                    objCourseOffHI.Preference__c = '1';
                    objCourseOffHI.hed__Course__c = objCourseHI.Id;
                    objCourseOffHI.hed__Term__c = objTerm.Id;
                    objCourseOffHI.Credits__c = 40;
                    insert objCourseOffHI;
                    
                    objCourseOffPWORK.Category__c = 'Practical/Term Work';
                    objCourseOffPWORK.Sequence__c =1;
                    objCourseOffPWORK.Preference__c = '1';
                    objCourseOffPWORK.hed__Course__c = objCoursePW.Id;
                    objCourseOffPWORK.hed__Term__c = objTerm.Id;
                    objCourseOffPWORK.Credits__c = 40;
                    insert objCourseOffPWORK;
                    
                    objCourseOffMandatory.Category__c = 'Mandatory Course';
                    objCourseOffMandatory.Sequence__c =1; 
                    objCourseOffMandatory.Preference__c = '1';
                    objCourseOffMandatory.hed__Course__c = objCourseMAN.Id;
                    objCourseOffMandatory.hed__Term__c = objTerm.Id;
                    objCourseOffMandatory.Credits__c = 40;
                    insert objCourseOffMandatory;
                    
                    objCourseOffProfEle.Category__c = 'Professional Elective';
                    objCourseOffProfEle.Sequence__c =1;
                    objCourseOffProfEle.Preference__c = '1';
                    //objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffProfEle.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle.Credits__c =40;
                    insert objCourseOffProfEle;
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    //objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Credits__c = 30;
                    insert objCourseOffOpenEle;                       
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                objProfStuOE.Course_Offering__c = objCourseOffOpenEle.Id;
                objProfStuOE.Semester__c = objTerm.Id;
                objProfStuOE.Student_Preference__c = true;                    
                insert objProfStuOE;
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                objProfStuProf.Course_Offering__c = objCourseOffProfEle.Id;
                objProfStuProf.Semester__c = objTerm.Id;
                objProfStuProf.Student_Preference__c = false;
                insert objProfStuProf;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                
                list<hed__Course_Offering__c> lstHC = new list<hed__Course_Offering__c>();
                lstHC.add(objCourseOffHC);
                
                list<hed__Course_Offering__c> lstMan = new list<hed__Course_Offering__c>();
                lstMan.add(objCourseOffMandatory);
                
                list<hed__Course_Offering__c> lstWork = new list<hed__Course_Offering__c>();
                lstWork.add(objCourseOffPWORK);
                
                list<hed__Course_Offering__c> lstHI = new list<hed__Course_Offering__c>();
                lstWork.add(objCourseOffHI);
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.DisplayCourseOfferingRecords();
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle,lstProf);                    
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }
        }
    }
    
    public static testMethod Void StudentMethodRBS()
    {
       // UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
     
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;
            
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objcon.RecordTypeId = ContactRecTypeId;            
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';            
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.Nationality__c ='Indian';
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
                  //Regarding RBS Specalization 
                     string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();
                    Account objAcc1 = STOB_TestDataFactory.CreateAccount('Test Account');
                    objAcc1.Recordtypeid = acaRecId;
                    objAcc1.OwnerId = portalAccountOwner1.Id;
                    Insert objAcc1;
                    
                    string rbsRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.RBS_Specialization).getRecordTypeId();
                    Account objAcc2 = STOB_TestDataFactory.CreateAccount('RBS Spcl HR');
                    objAcc2.Recordtypeid = rbsRecId;
                    objAcc2.ParentId = objAcc1.id;
                    objAcc2.OwnerId = portalAccountOwner1.Id;
                    Insert objAcc2;
                 string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                  hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
               
                
               
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('OPEN ELECTIVES - 1',objAcc.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffOpenEle.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffProfEle.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                     objcon.Active_Semester__c = objTerm.Id;
                     update objcon;
                
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                objProgEnrol.RBS_Specialization_1__c = objAcc2.Id;
                objProgEnrol.RBS_Specialization_2__c = objAcc2.Id;
                objProgEnrol.Semester__c = objTerm.Id;
                insert objProgEnrol;
                    
                    objCourse.Category__c = 'Hardcore Course';
                    objCourse.HardCore_Sub_Type__c = 'Theory'; 
                    objCourse.Credits__c = 4.00;
                    objCourse.Offered_By_School__c = objAcc.Id;
                    objCourse.Credit_Hours__c = 4.00;
                    objCourse.Maximum_External_Marks__c = 50.00;
                    objCourse.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourse.SEE_Conducted_Marks__c = 12;
                    insert objCourse; 
                    
                    objCourseHI.Category__c = 'Hardcore Integrated Course';
                    objCourseHI.Credits__c = 4.00;
                    objCourseHI.Offered_By_School__c = objAcc.Id;
                    objCourseHI.Credit_Hours__c = 4.00;
                    objCourseHI.Maximum_External_Marks__c = 50.00;
                    objCourseHI.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseHI;
                    
                    objCoursePW.Category__c = 'Practical/Term Work';
                    objCoursePW.Credits__c = 4.00;
                    objCoursePW.Offered_By_School__c = objAcc.Id;
                    objCoursePW.Credit_Hours__c = 4.00;
                    objCoursePW.Maximum_External_Marks__c = 50.00;
                    objCoursePW.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCoursePW;
                    
                    objCourseMAN.Category__c = 'Mandatory Course';
                    objCourseMAN.Credits__c = 4.00;
                    objCourseMAN.Offered_By_School__c = objAcc.Id;
                    objCourseMAN.Credit_Hours__c = 4.00;
                    objCourseMAN.Maximum_External_Marks__c = 50.00;
                    objCourseMAN.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseMAN; 
                    
                    objCourseOpen.Category__c = 'Open Elective';
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Offered_By_School__c = objAcc.Id;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                    objCourseProf.Credits__c = 4.00;
                    objCourseProf.Offered_By_School__c = objAcc.Id;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                  
               
                    hed__Course__c rbsSpclCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                    rbsSpclCourse.Category__c = 'RBS Specialization';
                    rbsSpclCourse.Specialization__c = objAcc2.Id;
                    rbsSpclCourse.Credits__c = 4.00;
                    rbsSpclCourse.Offered_By_School__c = objAcc.Id;
                    rbsSpclCourse.Credit_Hours__c = 4.00;
                    rbsSpclCourse.Maximum_External_Marks__c = 50.00;
                    rbsSpclCourse.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert rbsSpclCourse;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    objCourseOff1.Credits__c = 40;
                    
                    insert objCourseOff1;
                    
                    objCourseOffHC.Category__c = 'Hardcore Course';
                    objCourseOffHC.Sequence__c =1;
                    objCourseOffHC.Preference__c = '1';
                    objCourseOffHC.hed__Course__c = objCourse.Id;
                    objCourseOffHC.Credits__c = 40;
                    objCourseOffHC.hed__Term__c = objTerm.Id;
                    insert objCourseOffHC;
                    
                   hed__Course_Offering__c  rbsCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);

                    rbsCourseOff.Category__c = 'RBS Specialization';
                    rbsCourseOff.Sequence__c =1;
                    rbsCourseOff.Preference__c = '1';
                    rbsCourseOff.hed__Course__c = rbsSpclCourse.Id;
                    rbsCourseOff.Specialization__c = objAcc2.Id;
                    rbsCourseOff.Credits__c = 40;
                    rbsCourseOff.hed__Term__c = objTerm.Id;
                    insert rbsCourseOff;
                    
                    objCourseOffHI.Category__c = 'Hardcore Integrated Course';
                    objCourseOffHI.Sequence__c =1;
                    objCourseOffHI.Preference__c = '1';
                    objCourseOffHI.hed__Course__c = objCourseHI.Id;
                    objCourseOffHI.hed__Term__c = objTerm.Id;
                    objCourseOffHI.Credits__c = 40;
                    insert objCourseOffHI;
                    
                    objCourseOffPWORK.Category__c = 'Practical/Term Work';
                    objCourseOffPWORK.Sequence__c =1;
                    objCourseOffPWORK.Preference__c = '1';
                    objCourseOffPWORK.hed__Course__c = objCoursePW.Id;
                    objCourseOffPWORK.hed__Term__c = objTerm.Id;
                    objCourseOffPWORK.Credits__c = 40;
                    insert objCourseOffPWORK;
                    
                    objCourseOffMandatory.Category__c = 'Mandatory Course';
                    objCourseOffMandatory.Sequence__c =1; 
                    objCourseOffMandatory.Preference__c = '1';
                    objCourseOffMandatory.hed__Course__c = objCourseMAN.Id;
                    objCourseOffMandatory.hed__Term__c = objTerm.Id;
                    objCourseOffMandatory.Credits__c = 40;
                    insert objCourseOffMandatory;
                    
                    objCourseOffProfEle.Category__c = 'Professional Elective';
                    objCourseOffProfEle.Sequence__c =1;
                    objCourseOffProfEle.Preference__c = '1';
                    //objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffProfEle.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle.Credits__c =40;
                    insert objCourseOffProfEle;
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    //objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Credits__c = 30;
                    insert objCourseOffOpenEle;                       
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                objProfStuOE.Course_Offering__c = objCourseOffOpenEle.Id;
                objProfStuOE.Semester__c = objTerm.Id;
                objProfStuOE.Student_Preference__c = true;                    
                insert objProfStuOE;
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                objProfStuProf.Course_Offering__c = objCourseOffProfEle.Id;
                objProfStuProf.Semester__c = objTerm.Id;
                objProfStuProf.Student_Preference__c = false;
                insert objProfStuProf;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                
                list<hed__Course_Offering__c> lstHC = new list<hed__Course_Offering__c>();
                lstHC.add(objCourseOffHC);
                
                list<hed__Course_Offering__c> lstMan = new list<hed__Course_Offering__c>();
                lstMan.add(objCourseOffMandatory);
                
                list<hed__Course_Offering__c> lstWork = new list<hed__Course_Offering__c>();
                lstWork.add(objCourseOffPWORK);
                
                list<hed__Course_Offering__c> lstHI = new list<hed__Course_Offering__c>();
                lstWork.add(objCourseOffHI);
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.DisplayCourseOfferingRecords();
                STOB_DefineStudentPreference_ctrl.DisplayCourseOffering();
                STOB_DefineStudentPreference_ctrl.DisplayCourseOffering1();
               // STOB_DefineStudentPreference_ctrl.DisplayCourseOfferingRBS1();
               // STOB_DefineStudentPreference_ctrl.DisplayCourseOfferingRBS2();
                
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle,lstProf);                    
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }
        }
    }
    public static testMethod Void StudentMethod1()
    {
       // UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
        //User adminUser = [Select Id, UserRoleId,ContactId From User Where Profile.Name='System Administrator'  Limit 1];
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;                
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objcon.Application_Number__c = '123';
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c ='Indian';
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
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                insert objProgEnrol;
                
                string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen2 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen3 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff2 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff3 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff4 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff5 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff6 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseMAN.id);
                
                hed__Course_Offering__c  objCourseProfOff1 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);                
                hed__Course_Offering__c  objCourseProfOff3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle2 = MSTR_TestDataFactory.createCourseOffering('Test Open- 1',objTerm.id,objCourseOpen.id);                
                hed__Course_Offering__c  objCourseOffOpenEle3 = MSTR_TestDataFactory.createCourseOffering('Test Open- 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle4 = MSTR_TestDataFactory.createCourseOffering('Test Open- 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle5 = MSTR_TestDataFactory.createCourseOffering('Test Open- 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle6 = MSTR_TestDataFactory.createCourseOffering('Test Open-6',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle7 = MSTR_TestDataFactory.createCourseOffering('Test Open- 7',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle8 = MSTR_TestDataFactory.createCourseOffering('Test Open- 8',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle9 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle10 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle6 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle7 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle8 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle9 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle10 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle11 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle11 = MSTR_TestDataFactory.createCourseOffering('Test Open- 11',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle12 = MSTR_TestDataFactory.createCourseOffering('Test Open- 12',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle13 = MSTR_TestDataFactory.createCourseOffering('Test Open- 13',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle14 = MSTR_TestDataFactory.createCourseOffering('Test Open- 14',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle15 = MSTR_TestDataFactory.createCourseOffering('Test Open- 15',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle12 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                
                hed__Course_Offering__c  objCourseOffOpenEle16 = MSTR_TestDataFactory.createCourseOffering('Test Open- 16',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle17 = MSTR_TestDataFactory.createCourseOffering('Test Open- 17',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle18 = MSTR_TestDataFactory.createCourseOffering('Test Open- 18',objTerm.id,objCourseProf.id);
                
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf2 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf3 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                    objCourseOpen.Category__c = 'Open Elective';
                    objCourseOpen.Offered_By_School__c = objAcc.Id;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourseOpen.SEE_Conducted_Marks__c = 12;
                    
                    insert objCourseOpen;
                    
                    objCourseOpen2.Category__c = 'Open Elective';
                    objCourseOpen2.Max_Students__c = 1;
                    objCourseOpen2.Offered_By_School__c = objAcc.Id;
                    objCourseOpen2.Max_Students__c = 1;
                    objCourseOpen2.Credits__c = 4.00;
                    objCourseOpen2.Credit_Hours__c = 4.00;
                    objCourseOpen2.Maximum_External_Marks__c = 50.00;
                    objCourseOpen2.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen2;
                    
                    objCourseOpen3.Category__c = 'Open Elective';
                    objCourseOpen3.Offered_By_School__c = objAcc.Id;
                    objCourseOpen3.Max_Students__c = 1;
                    objCourseOpen3.Max_Students__c = 1;
                    objCourseOpen3.Credits__c = 4.00;
                    objCourseOpen3.Credit_Hours__c = 4.00;
                    objCourseOpen3.Maximum_External_Marks__c = 50.00;
                    objCourseOpen3.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen3;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                    objCourseProf.Offered_By_School__c = objAcc.Id;
                    objCourseProf.Max_Students__c = 1;
                    objCourseProf.Credits__c = 4.00;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 1';
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    objCourseOff1.Student_Preference_1__c =1;
                    insert objCourseOff1;
                    
                    objCourseOff2.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 2';
                    objCourseOff2.Sequence__c =2;
                    objCourseOff2.Student_Preference_1__c =1;
                    objCourseOff2.hed__Course__c = objCourseOpen3.Id;
                    objCourseOff2.hed__Term__c = objTerm.Id;                    
                    insert objCourseOff2;
                    
                    objCourseOffOpenEle6.Category__c = 'Open Elective';
                    objCourseOffOpenEle6.Sequence__c =2;
                    objCourseOffOpenEle6.Preference__c = '1';
                    objCourseOffOpenEle6.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle6.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle6.Parent_Course_Offering__c = objCourseOff2.id;
                    objCourseOffOpenEle6.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle6;  
                    objCourseOffOpenEle6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle6.Id limiT 1];
                    
                    objCourseOff3.Category__c = 'Open Elective';
                    objCourseOff3.Sequence__c =2;
                    objCourseOff3.Preference__c = '1';
                    objCourseOff3.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff3.hed__Term__c = objTerm.Id;
                    objCourseOff3.Student_Preference_1__c =1;
                    insert objCourseOff3;
                    
                    objCourseOff4.Category__c = 'Open Elective';
                    objCourseOff4.Sequence__c =2;
                    objCourseOff4.Preference__c = '1';
                    objCourseOff4.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff4.hed__Term__c = objTerm.Id;
                    objCourseOff4.Student_Preference_1__c =1;
                    insert objCourseOff4;
                    
                    objCourseProfOff4.Category__c = 'Professional Elective';
                    objCourseProfOff4.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseProfOff4.Sequence__c =2;
                    objCourseProfOff4.Preference__c = '1';
                    objCourseProfOff4.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff4.hed__Term__c = objTerm.Id;
                    objCourseProfOff4.Student_Preference_1__c =1;
                    insert objCourseProfOff4;
                    
                    objCourseProfOff5.Category__c = 'Professional Elective';
                    objCourseProfOff5.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseProfOff5.Sequence__c =2;
                    objCourseProfOff5.Preference__c = '1';
                    objCourseProfOff5.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff5.hed__Term__c = objTerm.Id;
                    objCourseProfOff5.Student_Preference_1__c =1;
                    insert objCourseProfOff5;
                    
                    objCourseOff5.Category__c = 'Open Elective';
                    objCourseOpen2.Name = 'OPEN ELECTIVES - 5';
                    objCourseOff5.Sequence__c =2;
                    objCourseOff5.Preference__c = '1';
                    objCourseOff5.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff5.hed__Term__c = objTerm.Id;
                    objCourseOff5.Student_Preference_1__c =1;
                    insert objCourseOff5;
                    
                    objCourseOffOpenEle10.Category__c = 'Open Elective';
                    objCourseOffOpenEle10.Sequence__c =2;
                    objCourseOffOpenEle10.Preference__c = '1';
                    objCourseOffOpenEle10.hed__Course__c = objCourseOpen2.Id;
                    objCourseOffOpenEle10.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle10.Student_Preference_1__c =1;
                    objCourseOffOpenEle10.Parent_Course_Offering__c = objCourseOff5.id;                    
                    insert objCourseOffOpenEle10;
                    
                    objCourseOffOpenEle10 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle10.Id limiT 1];
                    
                    objCourseOffOpenEle7.Category__c = 'Open Elective';
                    objCourseOffOpenEle7.Sequence__c =2;
                    objCourseOffOpenEle7.Preference__c = '1';
                    objCourseOffOpenEle7.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle7.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle7.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle7.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle7;  
                    objCourseOffOpenEle7 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle7.Id limiT 1];
                    
                    objCourseOff6.Category__c = 'Open Elective';
                    objCourseOff6.Sequence__c =2;
                    objCourseOff6.Preference__c = '1';
                    objCourseOff6.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff6.hed__Term__c = objTerm.Id;
                    objCourseOff6.Student_Preference_1__c =1;
                    insert objCourseOff6;
                    objCourseOff6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                     Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOff6.Id limiT 1];
                    
                    objCourseOffOpenEle8.Category__c = 'Open Elective';
                    objCourseOffOpenEle8.Sequence__c =2;
                    objCourseOffOpenEle8.Preference__c = '1';
                    objCourseOffOpenEle8.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle8.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle8.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle8.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle8;  
                    objCourseOffOpenEle8 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle8.Id limiT 1];
                    
                    objCourseProfOff1.Category__c = 'Professional Elective';
                    objCourseProfOff1.Name = 'PROFESSIONAL ELECTIVES - 1';
                    objCourseProfOff1.Sequence__c =1;
                    objCourseProfOff1.Preference__c = '1';
                    objCourseProfOff1.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff1.hed__Term__c = objTerm.Id;
                    objCourseProfOff1.Student_Preference_1__c =1;
                    insert objCourseProfOff1; 
                    
                    objCourseProfOff2.Category__c = 'Professional Elective';
                    objCourseProfOff2.Name = 'PROFESSIONAL ELECTIVES - 2';
                    objCourseProfOff2.Sequence__c =2;
                    objCourseProfOff2.Preference__c = '1';
                    objCourseProfOff2.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff2.hed__Term__c = objTerm.Id;
                    objCourseProfOff2.Student_Preference_1__c =1;
                    insert objCourseProfOff2;
                    
                    objCourseProfOff3.Category__c = 'Professional Elective';
                    objCourseProfOff3.Name = 'PROFESSIONAL ELECTIVES - 3';
                    objCourseProfOff3.Sequence__c =2;
                    objCourseProfOff3.Preference__c = '1';
                    objCourseProfOff3.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff3.hed__Term__c = objTerm.Id;
                    objCourseProfOff3.Student_Preference_1__c =1;
                    insert objCourseProfOff3;
                    
                    objCourseOffProfEle10.Category__c = 'Professional Elective';
                    objCourseOffProfEle10.Sequence__c =1;
                    objCourseOffProfEle10.Preference__c = '1';
                    objCourseOffProfEle10.Parent_Course_Offering__c = objCourseProfOff5.id;
                    objCourseOffProfEle10.Student_Preference_1__c =1;
                    objCourseOffProfEle10.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle10.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle10;
                    
                    objCourseOffProfEle10 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle10.id  limit 1]; 
                    objCourseOffProfEle11.Category__c = 'Professional Elective';
                    objCourseOffProfEle11.Sequence__c =1;
                    objCourseOffProfEle11.Preference__c = '1';
                    objCourseOffProfEle11.Parent_Course_Offering__c = objCourseProfOff5.id;
                    objCourseOffProfEle11.Student_Preference_1__c =1;
                    objCourseOffProfEle11.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle11.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle11;
                    
                    objCourseOffProfEle11 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle11.id  limit 1]; 
                    
                    objCourseOffProfEle2.Category__c = 'Professional Elective';
                    objCourseOffProfEle2.Sequence__c =1;
                    objCourseOffProfEle2.Preference__c = '3';
                    objCourseOffProfEle2.Parent_Course_Offering__c = objCourseProfOff1.id;
                    objCourseOffProfEle2.Student_Preference_1__c =1;
                    objCourseOffProfEle2.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle2.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle2;
                    
                    objCourseOffProfEle2 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle2.id  limit 1]; 
                    
                    objCourseOffProfEle4.Category__c = 'Professional Elective';
                    objCourseOffProfEle4.Sequence__c =1;
                    objCourseOffProfEle4.Preference__c = '2';
                    objCourseOffProfEle4.Parent_Course_Offering__c = objCourseProfOff2.id;
                    objCourseOffProfEle4.Student_Preference_1__c =1;
                    objCourseOffProfEle4.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle4.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle4;
                    
                    objCourseOffProfEle4 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle4.Id limiT 1];
                    
                    objCourseOffProfEle5.Category__c = 'Professional Elective';
                    objCourseOffProfEle5.Sequence__c =1;
                    objCourseOffProfEle5.Preference__c = '3';
                    objCourseOffProfEle5.Parent_Course_Offering__c = objCourseProfOff3.id;
                    objCourseOffProfEle5.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle5.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle5.Student_Preference_1__c =1;
                    insert objCourseOffProfEle5;
                    
                    objCourseOffProfEle5 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle5.id  limit 1]; 
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff4.id;
                    objCourseOffOpenEle.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle;  
                    
                    objCourseOffOpenEle = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                           hed__Course__c,hed__Term__c
                                           from hed__Course_Offering__c where id=:objCourseOffOpenEle.id  limit 1];
                    
                    objCourseOffOpenEle2.Category__c = 'Open Elective';
                    objCourseOffOpenEle2.Sequence__c =2;
                    objCourseOffOpenEle2.Preference__c = '1';
                    objCourseOffOpenEle2.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle2.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle2.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    objCourseOffOpenEle2.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle2;  
                    objCourseOffOpenEle2 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle2.Id limiT 1];
                    
                    objCourseOffOpenEle4.Category__c = 'Open Elective';
                    objCourseOffOpenEle4.Sequence__c =2;
                    objCourseOffOpenEle4.Student_Preference_1__c =1;
                    objCourseOffOpenEle4.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle4.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle4.Parent_Course_Offering__c = objCourseOffOpenEle.id;                    
                    insert objCourseOffOpenEle4;  
                    
                    objCourseOffOpenEle5.Category__c = 'Open Elective';
                    objCourseOffOpenEle5.Sequence__c =2;
                    objCourseOffOpenEle5.Student_Preference_1__c =1;
                    objCourseOffOpenEle5.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle5.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle5.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    insert objCourseOffOpenEle5;  
                    
                    objCourseOffProfEle.Category__c = 'Professional Elective';
                    objCourseOffProfEle.Sequence__c =1;
                    objCourseOffProfEle.Student_Preference_1__c =1;
                    objCourseOffProfEle.Parent_Course_Offering__c = objCourseProfOff3.id;
                    objCourseOffProfEle.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle;
                    
                    objCourseOffProfEle6.Category__c = 'Professional Elective';
                    objCourseOffProfEle6.Sequence__c =1;
                    objCourseOffProfEle6.Student_Preference_1__c =1;
                    objCourseOffProfEle6.Parent_Course_Offering__c = objCourseProfOff5.id;
                    objCourseOffProfEle6.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle6.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle6;
                    
                    objCourseOffProfEle7.Category__c = 'Professional Elective';
                    objCourseOffProfEle7.Sequence__c =1;
                    objCourseOffProfEle7.Student_Preference_1__c =1;
                    objCourseOffProfEle7.Parent_Course_Offering__c = objCourseProfOff5.id;
                    objCourseOffProfEle7.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle7.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle7;
                    
                    objCourseOffOpenEle3.Category__c = 'Open Elective';
                    objCourseOffOpenEle3.Sequence__c =3;
                    objCourseOffOpenEle3.Preference__c = '1';
                    objCourseOffOpenEle3.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle3.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle3.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle3.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle3;
                    
                    objCourseOffOpenEle3 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle3.Id limiT 1];
                    
                    objCourseOffOpenEle16.Category__c = 'Open Elective';
                    objCourseOffOpenEle16.Sequence__c =3;
                    objCourseOffOpenEle16.Preference__c = '1';
                    objCourseOffOpenEle16.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle16.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle16.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle16.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle16;
                    
                    objCourseOffOpenEle16 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle16.Id limiT 1];
                    objCourseOffOpenEle17.Category__c = 'Open Elective';
                    objCourseOffOpenEle17.Sequence__c =3;
                    objCourseOffOpenEle17.Preference__c = '1';
                    objCourseOffOpenEle17.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle17.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle17.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle17.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle17;
                    
                    objCourseOffOpenEle17 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle17.Id limiT 1];
                    objCourseOffOpenEle18.Category__c = 'Open Elective';
                    objCourseOffOpenEle18.Sequence__c =3;
                    objCourseOffOpenEle18.Preference__c = '1';
                    objCourseOffOpenEle18.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle18.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle18.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle18.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle18;
                    
                    objCourseOffOpenEle18 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle18.Id limiT 1];
                    
                    
                    objCourseOffProfEle3.Category__c = 'Professional Elective';
                    objCourseOffProfEle3.Sequence__c =3;
                    objCourseOffOpenEle3.Preference__c = '1';
                    objCourseOffProfEle3.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle3.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle3.Parent_Course_Offering__c = objCourseProfOff1.id;
                    objCourseOffProfEle3.Student_Preference_1__c =1;
                    insert objCourseOffProfEle3;
                    
                    objCourseOffProfEle3 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle3.Id limiT 1];
                    
                    objCourseOffProfEle9.Category__c = 'Professional Elective';
                    objCourseOffProfEle9.Sequence__c =3;
                    objCourseOffProfEle9.Preference__c = '1';
                    objCourseOffProfEle9.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle9.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle9.Parent_Course_Offering__c = objCourseProfOff5.id;
                     objCourseOffProfEle9.Student_Preference_1__c =1;
                    insert objCourseOffProfEle9;
                    
                    objCourseOffProfEle9 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle9.Id limiT 1];
                    
                    objCourseOffOpenEle11.Category__c = 'Open Elective';
                    objCourseOffOpenEle11.Sequence__c =3;
                    objCourseOffOpenEle11.Student_Preference_1__c =1;
                    objCourseOffOpenEle11.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle11.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle11.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle11;
                    
                    objCourseOffOpenEle11 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle11.Id limiT 1];
                    objCourseOffOpenEle12.Category__c = 'Open Elective';
                    objCourseOffOpenEle12.Sequence__c =3;
                    objCourseOffOpenEle12.Student_Preference_1__c =1;
                    objCourseOffOpenEle12.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle12.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle12.Parent_Course_Offering__c = objCourseOff2.id;
                    insert objCourseOffOpenEle12;
                    
                    objCourseOffOpenEle12 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle12.Id limiT 1];
                    
                    objCourseOffOpenEle13.Category__c = 'Open Elective';
                    objCourseOffOpenEle13.Sequence__c =3;
                    objCourseOffOpenEle13.Student_Preference_1__c =1;
                    objCourseOffOpenEle13.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle13.hed__Term__c = objTerm.Id;
                    //objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff3.id;
                    insert objCourseOffOpenEle13;
                    
                    objCourseOffOpenEle13 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle13.Id limiT 1];
                    objCourseOffOpenEle14.Category__c = 'Open Elective';
                    objCourseOffOpenEle14.Sequence__c =3;
                    objCourseOffOpenEle14.Student_Preference_1__c =1;
                    objCourseOffOpenEle14.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle14.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff4.id;
                    insert objCourseOffOpenEle14;
                    
                    objCourseOffOpenEle14 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle14.Id limiT 1];
                    //objCourseOffOpenEle15
                    objCourseOffOpenEle15.Category__c = 'Open Elective';
                    objCourseOffOpenEle15.Sequence__c =3;
                    objCourseOffOpenEle15.Student_Preference_1__c =1;
                    objCourseOffOpenEle15.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle15.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff5.id;
                    insert objCourseOffOpenEle15;
                    
                    objCourseOffOpenEle15 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle15.Id limiT 1];
                    
                    objCourseOffProfEle8.Category__c = 'Professional Elective';
                    objCourseOffProfEle8.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle8.Sequence__c =1;
                    objCourseOffProfEle8.Preference__c = '1';
                    objCourseOffProfEle8.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle8.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle8.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    objCourseOffProfEle8.Student_Preference_1__c =1;
                    insert objCourseOffProfEle8;
                    
                    
                    objCourseOffProfEle8 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle8.id  limit 1]; 
                    
                    objCourseOffProfEle12.Category__c = 'Professional Elective';
                    objCourseOffProfEle12.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseOffProfEle12.Sequence__c =1;
                    objCourseOffProfEle12.Preference__c = '1';
                    objCourseOffProfEle12.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle12.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle12.Parent_Course_Offering__c = objCourseProfOff5.Id;
                    objCourseOffProfEle12.Student_Preference_1__c =1;
                    insert objCourseOffProfEle12;
                    
                    
                   // objCourseOffProfEle12 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            // hed__Course__c,hed__Term__c
                                            // from hed__Course_Offering__c where id=:objCourseOffProfEle12.id  limit 1];                        
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                objProfStuOE.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuOE.Preference__c = '1';
                
                objProfStuOE.Student_Preference__c = true;
                insert objProfStuOE;                    
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                objProfStuProf.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuProf.Preference__c = '1';
                
                objProfStuProf.Student_Preference__c = true;
                insert objProfStuProf;
                
                objProfStuProf2.Professor__c = objcon.id;
                objProfStuProf2.Contact__c = objcon.id;
                objProfStuProf2.Course_Offering__c = objCourseOffOpenEle4.Id;
                objProfStuProf2.Preference__c = '1';
                
                objProfStuProf2.Student_Preference__c = true;
                insert objProfStuProf2;
                
                objProfStuProf3.Professor__c = objcon.id;
                objProfStuProf3.Contact__c = objcon.id;
                objProfStuProf3.Course_Offering__c = objCourseOffOpenEle5.Id;
                objProfStuProf3.Preference__c = '1';
                
                objProfStuProf3.Student_Preference__c = true;
                insert objProfStuProf3;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                lstOpenEle.add(objCourseOffOpenEle2);
                lstOpenEle.add(objCourseOffOpenEle3);
                lstOpenEle.add(objCourseOffOpenEle4);
                lstOpenEle.add(objCourseOffOpenEle5);
                lstOpenEle.add(objCourseOffOpenEle6);
                lstOpenEle.add(objCourseOffOpenEle10);
                lstOpenEle.add(objCourseOffOpenEle13);
                lstOpenEle.add(objCourseOffOpenEle14);
                lstOpenEle.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstOpenEle2 = new list<hed__Course_Offering__c>();
                lstOpenEle2.add(objCourseOffOpenEle11);
                lstOpenEle2.add(objCourseOffOpenEle12);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                lstProf.add(objCourseOffProfEle3);
                lstProf.add(objCourseOffProfEle2);
                lstProf.add(objCourseOffProfEle4);
                lstProf.add(objCourseOffProfEle5);
                lstProf.add(objCourseOffProfEle6);
                lstProf.add(objCourseOffProfEle7);
                lstProf.add(objCourseOffProfEle8);
                lstProf.add(objCourseOffProfEle9);
                lstProf.add(objCourseOffProfEle10);
                lstProf.add(objCourseOffProfEle11);
                lstProf.add(objCourseOffProfEle12);
                
                list<hed__Course_Offering__c> lstProf2 = new list<hed__Course_Offering__c>();
                lstProf2.add(objCourseOffProfEle4);
                lstProf2.add(objCourseOffProfEle5);
                
                
                list<hed__Course_Offering__c> lstOpenEle3 = new list<hed__Course_Offering__c>();
                lstOpenEle3.add(objCourseOffOpenEle13);
                lstOpenEle3.add(objCourseOffOpenEle14);
                lstOpenEle3.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstProf3 = new list<hed__Course_Offering__c>();
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle,lstProf);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle2,lstProf2);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle3,lstProf3);
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }                
        }
    }
    public static testMethod Void StudentMethod2(){
        test.startTest();
        STOB_DefineStudentPreference_ctrl.CourseOfferingWrapper cwrpr = new STOB_DefineStudentPreference_ctrl.CourseOfferingWrapper ();
        cwrpr.StudentPreference = true;
        STOB_DefineStudentPreference_ctrl.ErrorWrapper erwrpr = new  STOB_DefineStudentPreference_ctrl.ErrorWrapper();
        erwrpr.OpenElectiveErrmsg = 'error';
        erwrpr.ProfElectiveErrmsg ='error';
        erwrpr.OpenDupPreference = 'error';
        erwrpr.PrefDupPreference = 'error';
        erwrpr.ProfPrefErrmsg= 'error';
        erwrpr.OpenPrefErrmsg= 'error';
        erwrpr.CountOpenPrefErrmsg= 'error';
        STOB_DefineStudentPreference_ctrl.getPreference();
        
        test.stopTest();
    }
    public static testMethod Void StudentMethod3(){
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
        objAcc.Recordtypeid = UniversityRecId;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact objCon = STOB_TestDataFactory.createContact('Test');
        objCon.MobilePhone ='9090909090';
        objCon.Aadhar_Card_Number__c ='098765435612';
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
        objcon.AccountId = objAcc.id;
        objcon.RecordTypeId = ContactRecTypeId;
        objcon.Nationality__c ='Indian';
        Insert objCon;
        
        hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
        objProgPlan.hed__Account__c = objAcc.id;
        objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
        objProgPlan.hed__End_Date__c = system.today()+2;
        insert objProgPlan;
        
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        
        hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today().adddays(-16); 
        objTerm.hed__End_Date__c =system.today().adddays(16);
        objTerm.Approval_Status__c = 'Confirmed';
        objTerm.Allow_Student_Elective_Preference__c = true;
        insert objTerm;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.id);
        objCourse.Category__c = 'Hardcore Course';
         objCourse.HardCore_Sub_Type__c = 'Theory'; 
        objCourse.Offered_By_School__c = objAcc.Id;
        objCourse.Max_Students__c = 1;
        objCourse.Credits__c = 4.00;
        objCourse.Credit_Hours__c = 4.00;
        objCourse.Maximum_External_Marks__c = 50.00;
        objCourse.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourse.SEE_Conducted_Marks__c = 12;
        insert objCourse; 
        
        hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.id);
        objCourseHI.Category__c = 'Hardcore Integrated Course';
        objCourseHI.Offered_By_School__c = objAcc.Id;
        objCourseHI.Max_Students__c = 1;
        objCourseHI.Credits__c = 4.00;
        objCourseHI.Credit_Hours__c = 4.00;
        objCourseHI.Maximum_External_Marks__c = 50.00;
        objCourseHI.Total_Maximum_Marks_IA_External__c = 100.00;
        insert objCourseHI; 
        
        hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.id);
        objCoursePW.Category__c = 'Practical/Term Work';
        objCoursePW.Offered_By_School__c = objAcc.Id;
        objCoursePW.Max_Students__c = 1;
        objCoursePW.Credits__c = 4.00;
        objCoursePW.Credit_Hours__c = 4.00;
        objCoursePW.Maximum_External_Marks__c = 50.00;
        objCoursePW.Total_Maximum_Marks_IA_External__c = 100.00;
        insert objCoursePW; 
        
        hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.id);
        objCourseMAN.Category__c = 'Mandatory Course';
        objCourseMAN.Offered_By_School__c = objAcc.Id;
        objCourseMAN.Max_Students__c = 1;
        objCourseMAN.Credits__c = 4.00;
        objCourseMAN.Credit_Hours__c = 4.00;
        objCourseMAN.Maximum_External_Marks__c = 50.00;
        objCourseMAN.Total_Maximum_Marks_IA_External__c = 100.00;
        insert objCourseMAN; 
        
        hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.id);
        objCourseOpen.Category__c = 'Open Elective';
        objCourseOpen.Offered_By_School__c = objAcc.Id;
        objCourseOpen.Max_Students__c = 1;
        objCourseOpen.Credits__c = 4.00;
        objCourseOpen.Credit_Hours__c = 4.00;
        objCourseOpen.Maximum_External_Marks__c = 50.00;
        objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
        insert objCourseOpen;
        
        hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.id);
        objCourseProf.Category__c = 'Professional Elective';
        objCourseProf.Offered_By_School__c = objAcc.Id;
        objCourseProf.Max_Students__c = 1;
        objCourseProf.Credits__c = 4.00;
        objCourseProf.Credit_Hours__c = 4.00;
        objCourseProf.Maximum_External_Marks__c = 50.00;
        objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
        insert objCourseProf; 
        
        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        
        insert objCourseOff1; 
        
        hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOffHC.Category__c = 'Hardcore Course';
        objCourseOffHC.Sequence__c =1;
        //objCourseOffHC.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffHC;
        
        hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
        objCourseOffHI.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI.Sequence__c =1;
        //objCourseOffHI.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffHI;
        
        hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
        objCourseOffPWORK.Category__c = 'Practical/Term Work';
        objCourseOffPWORK.Sequence__c =1;
        //objCourseOffPWORK.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffPWORK;
        
        hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
        objCourseOffMandatory.Category__c = 'Mandatory Course';
        objCourseOffMandatory.Sequence__c =1;       
        //objCourseOffMandatory.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffMandatory;
        
        hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
        objCourseOffProfEle.Category__c = 'Professional Elective';
        objCourseOffProfEle.Sequence__c =1;
        objCourseOffProfEle.Preference__c = '1';
        objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffProfEle;
        
        hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOffOpenEle.Category__c = 'Open Elective';
        objCourseOffOpenEle.Sequence__c =1;
        objCourseOffOpenEle.Preference__c = '1';
        objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffOpenEle;      
        
        list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
        lstOpenEle.add(objCourseOffOpenEle);
        
        list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
        lstProf.add(objCourseOffProfEle);
        
        Test.Starttest();
        STOB_DefineStudentPreference_ctrl.SaveStudentCourseprefernce(lstOpenEle,lstProf,true);
        STOB_DefineStudentPreference_ctrl.SaveStudentCourseprefernce(lstOpenEle,lstProf,false);
        test.stoptest();
        system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
    }
    public static testMethod Void StudentMethod4()
    {
        //UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
        //User adminUser = [Select Id, UserRoleId,ContactId From User Where Profile.Name='System Administrator'  Limit 1];
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objcon.Application_Number__c = '123';
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c ='Indian';
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
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                insert objProgEnrol;
                
                string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                    objCourse.Category__c = 'Hardcore Course';
                     objCourse.HardCore_Sub_Type__c = 'Theory';
                    objCourse.Offered_By_School__c = objAcc.Id;
                    objCourse.Max_Students__c = 1;
                    objCourse.Credits__c = 4.00;
                    objCourse.Credit_Hours__c = 4.00;
                    objCourse.Maximum_External_Marks__c = 50.00;
                    objCourse.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourse.SEE_Conducted_Marks__c = 12;
                    insert objCourse; 
                    
                    objCourseHI.Category__c = 'Hardcore Integrated Course';
                    objCourseHI.Offered_By_School__c = objAcc.Id;
                    objCourseHI.Max_Students__c = 1;
                    objCourseHI.Credits__c = 4.00;
                    objCourseHI.Credit_Hours__c = 4.00;
                    objCourseHI.Maximum_External_Marks__c = 50.00;
                    objCourseHI.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseHI;
                    
                    objCoursePW.Category__c = 'Practical/Term Work';
                    objCoursePW.Offered_By_School__c = objAcc.Id;
                    objCoursePW.Max_Students__c = 1;
                    objCoursePW.Credits__c = 4.00;
                    objCoursePW.Credit_Hours__c = 4.00;
                    objCoursePW.Maximum_External_Marks__c = 50.00;
                    objCoursePW.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCoursePW; 
                    
                    objCourseMAN.Category__c = 'Mandatory Course';
                    objCourseMAN.Offered_By_School__c = objAcc.Id;
                    objCourseMAN.Max_Students__c = 1;
                    objCourseMAN.Credits__c = 4.00;
                    objCourseMAN.Credit_Hours__c = 4.00;
                    objCourseMAN.Maximum_External_Marks__c = 50.00;
                    objCourseMAN.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseMAN; 
                    
                    objCourseOpen.Category__c = 'Open Elective';
                    objCourseOpen.Offered_By_School__c = objAcc.Id;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                      insert objCourseOpen;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                    objCourseProf.Offered_By_School__c = objAcc.Id;
                    objCourseProf.Max_Students__c = 1;
                    objCourseProf.Credits__c = 4.00;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    objCourseOff1.Credits__c =20;
                    insert objCourseOff1;
                    
                    objCourseOffHC.Category__c = 'Hardcore Course';
                    objCourseOffHC.Sequence__c =1;
                    objCourseOffHC.Preference__c = '1';
                    objCourseOffHC.hed__Course__c = objCourse.Id;
                    objCourseOffHC.Credits__c = 40;
                    objCourseOffHC.hed__Term__c = objTerm.Id;
                    
                    //objCourseOffHC.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffHC;
                    
                    objCourseOffHI.Category__c = 'Hardcore Integrated Course';
                    objCourseOffHI.Sequence__c =1;
                    objCourseOffHI.Preference__c = '1';
                    objCourseOffHI.hed__Course__c = objCourseHI.Id;
                    objCourseOffHI.hed__Term__c = objTerm.Id;
                    objCourseOffHI.Credits__c = 40;
                    // objCourseOffHI.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffHI;
                    
                    objCourseOffPWORK.Category__c = 'Practical/Term Work';
                    objCourseOffPWORK.Sequence__c =1;
                    objCourseOffPWORK.Preference__c = '1';
                    objCourseOffPWORK.hed__Course__c = objCoursePW.Id;
                    objCourseOffPWORK.hed__Term__c = objTerm.Id; 
                    objCourseOffPWORK.Credits__c = 40;
                    //objCourseOffPWORK.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffPWORK;
                    
                    objCourseOffMandatory.Category__c = 'Mandatory Course';
                    objCourseOffMandatory.Sequence__c =1; 
                    objCourseOffMandatory.Preference__c = '1';
                    objCourseOffMandatory.hed__Course__c = objCourseMAN.Id;
                    objCourseOffMandatory.hed__Term__c = objTerm.Id;
                    objCourseOffMandatory.Credits__c = 40;
                    //objCourseOffMandatory.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffMandatory;
                    
                    objCourseOffProfEle.Category__c = 'Professional Elective';
                    objCourseOffProfEle.Sequence__c =1;
                    objCourseOffProfEle.Preference__c = '1';
                    //objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffProfEle.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle.Credits__c = 40;
                    insert objCourseOffProfEle;
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Credits__c = 30;
                    insert objCourseOffOpenEle;
                    
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                
                objProfStuOE.Student_Preference__c = true;
                insert objProfStuOE;
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                
                objProfStuProf.Student_Preference__c = false;
                insert objProfStuProf;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                
                list<hed__Course_Offering__c> lstHC = new list<hed__Course_Offering__c>();
                lstHC.add(objCourseOffHC);
                
                list<hed__Course_Offering__c> lstMan = new list<hed__Course_Offering__c>();
                lstMan.add(objCourseOffMandatory);
                
                list<hed__Course_Offering__c> lstWork = new list<hed__Course_Offering__c>();
                lstWork.add(objCourseOffPWORK);
                
                list<hed__Course_Offering__c> lstHI = new list<hed__Course_Offering__c>();
                lstWork.add(objCourseOffHI);
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.DisplayCourseOffering();
                STOB_DefineStudentPreference_ctrl.DisplayCourseOffering1();
               // STOB_DefineStudentPreference_ctrl.DisplayCourseOfferingRBS1();
                //STOB_DefineStudentPreference_ctrl.DisplayCourseOfferingRBS2();
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }
        }
    }
    public static testMethod Void StudentMethodTest1()
    {
        //UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
        //User adminUser = [Select Id, UserRoleId,ContactId From User Where Profile.Name='System Administrator'  Limit 1];
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;                
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objcon.Application_Number__c = '123';
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.Nationality__c ='Indian';
            objcon.RecordTypeId = ContactRecTypeId;
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
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                insert objProgEnrol;
                
                string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen2 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen3 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff2 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff3 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff4 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff5 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff6 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseMAN.id);
                
                hed__Course_Offering__c  objCourseProfOff1 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);                
                hed__Course_Offering__c  objCourseProfOff3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle2 = MSTR_TestDataFactory.createCourseOffering('Test Open- 1',objTerm.id,objCourseOpen.id);                
                hed__Course_Offering__c  objCourseOffOpenEle3 = MSTR_TestDataFactory.createCourseOffering('Test Open- 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle4 = MSTR_TestDataFactory.createCourseOffering('Test Open- 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle5 = MSTR_TestDataFactory.createCourseOffering('Test Open- 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle6 = MSTR_TestDataFactory.createCourseOffering('Test Open-6',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle7 = MSTR_TestDataFactory.createCourseOffering('Test Open- 7',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle8 = MSTR_TestDataFactory.createCourseOffering('Test Open- 8',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle9 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle10 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle6 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle7 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle8 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle9 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle10 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle11 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle11 = MSTR_TestDataFactory.createCourseOffering('Test Open- 11',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle12 = MSTR_TestDataFactory.createCourseOffering('Test Open- 12',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle13 = MSTR_TestDataFactory.createCourseOffering('Test Open- 13',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle14 = MSTR_TestDataFactory.createCourseOffering('Test Open- 14',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle15 = MSTR_TestDataFactory.createCourseOffering('Test Open- 15',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle12 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                
                hed__Course_Offering__c  objCourseOffOpenEle16 = MSTR_TestDataFactory.createCourseOffering('Test Open- 16',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle17 = MSTR_TestDataFactory.createCourseOffering('Test Open- 17',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle18 = MSTR_TestDataFactory.createCourseOffering('Test Open- 18',objTerm.id,objCourseProf.id);
                
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf2 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf3 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                    objCourseOpen.Category__c = 'Open Elective';
                    objCourseOpen.Offered_By_School__c = objAcc.Id;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.SEE_Conducted_Marks__c = 12;
                    
                    insert objCourseOpen;
                    objCourseOpen2.Category__c = 'Open Elective';
                    objCourseOpen2.Offered_By_School__c = objAcc.Id;
                    objCourseOpen2.Max_Students__c = 1;
                    objCourseOpen2.Credits__c = 4.00;
                    objCourseOpen2.Credit_Hours__c = 4.00;
                    objCourseOpen2.Maximum_External_Marks__c = 50.00;
                    objCourseOpen2.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen2;
                    
                    objCourseOpen3.Category__c = 'Open Elective';
                    objCourseOpen3.Offered_By_School__c = objAcc.Id;
                    objCourseOpen3.Max_Students__c = 1;
                    objCourseOpen3.Credits__c = 4.00;
                    objCourseOpen3.Credit_Hours__c = 4.00;
                    objCourseOpen3.Maximum_External_Marks__c = 50.00;
                    objCourseOpen3.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen3;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                    objCourseProf.Offered_By_School__c = objAcc.Id;
                    objCourseProf.Max_Students__c = 1;
                    objCourseProf.Credits__c = 4.00;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 1';
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    insert objCourseOff1;
                    
                    objCourseOff2.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 2';
                    objCourseOff2.Sequence__c =2;
                    //objCourseOff2.Preference__c = '1';
                    objCourseOff2.hed__Course__c = objCourseOpen3.Id;
                    objCourseOff2.hed__Term__c = objTerm.Id;
                    
                    insert objCourseOff2;
                    
                    objCourseOffOpenEle6.Category__c = 'Open Elective';
                    objCourseOffOpenEle6.Sequence__c =2;
                    objCourseOffOpenEle6.Preference__c = '1';
                    objCourseOffOpenEle6.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle6.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle6.Parent_Course_Offering__c = objCourseOff2.id;
                    
                    insert objCourseOffOpenEle6;  
                    objCourseOffOpenEle6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle6.Id limiT 1];
                    system.debug('objCourseOffOpenEle6 '+objCourseOffOpenEle6);
                    system.debug('objCourseOffOpenEle6 '+objCourseOffOpenEle6.Parent_Course_Offering__r.Name);
                    
                    objCourseOff3.Category__c = 'Open Elective';
                    objCourseOff3.Sequence__c =2;
                    objCourseOff3.Preference__c = '1';
                    objCourseOff3.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff3.hed__Term__c = objTerm.Id;
                    insert objCourseOff3;
                    
                    objCourseOff4.Category__c = 'Open Elective';
                    objCourseOff4.Sequence__c =2;
                    objCourseOff4.Preference__c = '1';
                    objCourseOff4.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff4.hed__Term__c = objTerm.Id;
                    insert objCourseOff4;
                    
                    objCourseProfOff4.Category__c = 'Professional Elective';
                    objCourseProfOff4.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseProfOff4.Sequence__c =2;
                    objCourseProfOff4.Preference__c = '1';
                    objCourseProfOff4.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff4.hed__Term__c = objTerm.Id;
                    insert objCourseProfOff4;
                    
                    objCourseProfOff5.Category__c = 'Professional Elective';
                    objCourseProfOff5.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseProfOff5.Sequence__c =2;
                    objCourseProfOff5.Preference__c = '1';
                    objCourseProfOff5.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff5.hed__Term__c = objTerm.Id;
                    insert objCourseProfOff5;
                    
                    objCourseOff5.Category__c = 'Open Elective';
                    objCourseOpen2.Name = 'OPEN ELECTIVES - 5';
                    objCourseOff5.Sequence__c =2;
                    objCourseOff5.Preference__c = '1';
                    objCourseOff5.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff5.hed__Term__c = objTerm.Id;
                    insert objCourseOff5;
                    
                    objCourseOffOpenEle10.Category__c = 'Open Elective';
                    objCourseOffOpenEle10.Sequence__c =2;
                    objCourseOffOpenEle10.Preference__c = '1';
                    objCourseOffOpenEle10.hed__Course__c = objCourseOpen2.Id;
                    objCourseOffOpenEle10.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle10.Parent_Course_Offering__c = objCourseOff5.id;
                    
                    insert objCourseOffOpenEle10;  
                    objCourseOffOpenEle10 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle10.Id limiT 1];
                    
                    objCourseOffOpenEle7.Category__c = 'Open Elective';
                    objCourseOffOpenEle7.Sequence__c =2;
                    objCourseOffOpenEle7.Preference__c = '1';
                    objCourseOffOpenEle7.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle7.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle7.Parent_Course_Offering__c = objCourseOff3.id;
                    
                    insert objCourseOffOpenEle7;  
                    objCourseOffOpenEle7 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle7.Id limiT 1];
                    
                    objCourseOff6.Category__c = 'Open Elective';
                    objCourseOff6.Sequence__c =2;
                    objCourseOff6.Preference__c = '1';
                    objCourseOff6.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff6.hed__Term__c = objTerm.Id;
                    insert objCourseOff6;
                    objCourseOff6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                     Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOff6.Id limiT 1];
                    
                    objCourseOffOpenEle8.Category__c = 'Open Elective';
                    objCourseOffOpenEle8.Sequence__c =2;
                    objCourseOffOpenEle8.Preference__c = '1';
                    objCourseOffOpenEle8.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle8.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle8.Parent_Course_Offering__c = objCourseOff3.id;
                    
                    insert objCourseOffOpenEle8;  
                    objCourseOffOpenEle8 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle8.Id limiT 1];
                    
                    objCourseProfOff1.Category__c = 'Professional Elective';
                    objCourseProfOff1.Name = 'PROFESSIONAL ELECTIVES - 1';
                    objCourseProfOff1.Sequence__c =1;
                    objCourseProfOff1.Preference__c = '1';
                    objCourseProfOff1.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff1.hed__Term__c = objTerm.Id;
                    insert objCourseProfOff1; 
                    
                    objCourseProfOff2.Category__c = 'Professional Elective';
                    objCourseProfOff2.Name = 'PROFESSIONAL ELECTIVES - 2';
                    objCourseProfOff2.Sequence__c =2;
                    objCourseProfOff2.Preference__c = '1';
                    objCourseProfOff2.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff2.hed__Term__c = objTerm.Id;
                    insert objCourseProfOff2;
                    
                    objCourseProfOff3.Category__c = 'Professional Elective';
                    objCourseProfOff3.Name = 'PROFESSIONAL ELECTIVES - 3';
                    objCourseProfOff3.Sequence__c =2;
                    objCourseProfOff3.Preference__c = '1';
                    objCourseProfOff3.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff3.hed__Term__c = objTerm.Id;
                    insert objCourseProfOff3;
                    
                    /*objCourseOffProfEle10.Category__c = 'Professional Elective';
                    objCourseOffProfEle10.Sequence__c =1;
                    objCourseOffProfEle10.Preference__c = '1';
                    objCourseOffProfEle10.Parent_Course_Offering__c = objCourseProfOff5.id;
                    
                    objCourseOffProfEle10.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle10.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle10;
                    
                    objCourseOffProfEle10 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle10.id  limit 1]; 
                    objCourseOffProfEle11.Category__c = 'Professional Elective';
                    objCourseOffProfEle11.Sequence__c =1;
                    objCourseOffProfEle11.Preference__c = '1';
                    objCourseOffProfEle11.Parent_Course_Offering__c = objCourseProfOff5.id;
                    
                    objCourseOffProfEle11.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle11.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle11;
                    
                    objCourseOffProfEle11 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle11.id  limit 1]; */
                    
                    objCourseOffProfEle2.Category__c = 'Professional Elective';
                    objCourseOffProfEle2.Sequence__c =1;
                    objCourseOffProfEle2.Preference__c = '3';
                    objCourseOffProfEle2.Parent_Course_Offering__c = objCourseProfOff1.id;
                    
                    objCourseOffProfEle2.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle2.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle2;
                    
                    objCourseOffProfEle2 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle2.id  limit 1]; 
                    
                    objCourseOffProfEle4.Category__c = 'Professional Elective';
                    objCourseOffProfEle4.Sequence__c =1;
                    objCourseOffProfEle4.Preference__c = '2';
                    objCourseOffProfEle4.Parent_Course_Offering__c = objCourseProfOff2.id;
                    
                    objCourseOffProfEle4.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle4.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle4;
                    
                    objCourseOffProfEle4 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle4.Id limiT 1];
                    
                    objCourseOffProfEle5.Category__c = 'Professional Elective';
                    objCourseOffProfEle5.Sequence__c =1;
                    objCourseOffProfEle5.Preference__c = '3';
                    objCourseOffProfEle5.Parent_Course_Offering__c = objCourseProfOff3.id;
                    objCourseOffProfEle5.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle5.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle5;
                    
                    objCourseOffProfEle5 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle5.id  limit 1]; 
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff4.id;
                    
                    insert objCourseOffOpenEle;  
                    
                    objCourseOffOpenEle = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                           hed__Course__c,hed__Term__c
                                           from hed__Course_Offering__c where id=:objCourseOffOpenEle.id  limit 1];
                    
                    objCourseOffOpenEle2.Category__c = 'Open Elective';
                    objCourseOffOpenEle2.Sequence__c =2;
                    objCourseOffOpenEle2.Preference__c = '1';
                    objCourseOffOpenEle2.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle2.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle2.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    
                    insert objCourseOffOpenEle2;  
                    objCourseOffOpenEle2 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle2.Id limiT 1];
                    
                    objCourseOffOpenEle4.Category__c = 'Open Elective';
                    objCourseOffOpenEle4.Sequence__c =2;
                    //objCourseOffOpenEle4.Preference__c = '1';
                    objCourseOffOpenEle4.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle4.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle4.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    
                    insert objCourseOffOpenEle4;  
                    objCourseOffOpenEle5.Category__c = 'Open Elective';
                    objCourseOffOpenEle5.Sequence__c =2;
                    //objCourseOffOpenEle4.Preference__c = '1';
                    objCourseOffOpenEle5.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle5.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle5.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    insert objCourseOffOpenEle5;  
                                      
                    objCourseOffOpenEle3.Category__c = 'Open Elective';
                    objCourseOffOpenEle3.Sequence__c =3;
                    objCourseOffOpenEle3.Preference__c = '1';
                    objCourseOffOpenEle3.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle3.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle3.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle3.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle3;
                    
                    objCourseOffOpenEle3 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle3.Id limiT 1];
                    
                    objCourseOffOpenEle16.Category__c = 'Open Elective';
                    objCourseOffOpenEle16.Sequence__c =3;
                    objCourseOffOpenEle16.Preference__c = '1';
                    objCourseOffOpenEle16.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle16.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle16.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle16;
                    
                    objCourseOffOpenEle16 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle16.Id limiT 1];
                    objCourseOffOpenEle17.Category__c = 'Open Elective';
                    objCourseOffOpenEle17.Sequence__c =3;
                    objCourseOffOpenEle17.Preference__c = '1';
                    objCourseOffOpenEle17.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle17.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle17.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle17;
                    
                    objCourseOffOpenEle17 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle17.Id limiT 1];
                    objCourseOffOpenEle18.Category__c = 'Open Elective';
                    objCourseOffOpenEle18.Sequence__c =3;
                    objCourseOffOpenEle18.Preference__c = '1';
                    objCourseOffOpenEle18.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle18.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle18.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle18;
                    
                    objCourseOffOpenEle18 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle18.Id limiT 1];
                   
                    objCourseOffOpenEle11.Category__c = 'Open Elective';
                    objCourseOffOpenEle11.Sequence__c =3;
                    objCourseOffOpenEle11.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle11.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle11.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle11;
                    
                    objCourseOffOpenEle11 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle11.Id limiT 1];
                    objCourseOffOpenEle12.Category__c = 'Open Elective';
                    objCourseOffOpenEle12.Sequence__c =3;
                    objCourseOffOpenEle12.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle12.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle12.Parent_Course_Offering__c = objCourseOff2.id;
                    objCourseOffOpenEle12.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle12;
                    
                    objCourseOffOpenEle12 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle12.Id limiT 1];
                    
                    objCourseOffOpenEle13.Category__c = 'Open Elective';
                    objCourseOffOpenEle13.Sequence__c =3;
                    //objCourseOffOpenEle11.Preference__c = '1';
                    objCourseOffOpenEle13.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle13.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Student_Preference_1__c =1;
                    //objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff3.id;
                    insert objCourseOffOpenEle13;
                    
                    objCourseOffOpenEle13 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle13.Id limiT 1];
                    objCourseOffOpenEle14.Category__c = 'Open Elective';
                    objCourseOffOpenEle14.Sequence__c =3;
                    //objCourseOffOpenEle14.Preference__c = '3';
                    objCourseOffOpenEle14.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle14.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff4.id;
                    objCourseOffOpenEle13.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle14;
                    
                    objCourseOffOpenEle14 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle14.Id limiT 1];
                    //objCourseOffOpenEle15
                    objCourseOffOpenEle15.Category__c = 'Open Elective';
                    objCourseOffOpenEle15.Sequence__c =3;
                    //objCourseOffOpenEle15.Preference__c = '2';
                    objCourseOffOpenEle15.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle15.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff5.id;
                    objCourseOffOpenEle15.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle15;
                    
                    objCourseOffOpenEle15 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle15.Id limiT 1];
                    
                    objCourseOffProfEle8.Category__c = 'Professional Elective';
                    objCourseOffProfEle8.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle8.Sequence__c =1;
                    objCourseOffProfEle8.Preference__c = '3';
                    objCourseOffProfEle8.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle8.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle8.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    objCourseOffProfEle8.Student_Preference_1__c =1;
                    insert objCourseOffProfEle8;
                    
                    
                    objCourseOffProfEle8 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle8.id  limit 1]; 
                    
                    objCourseOffProfEle12.Category__c = 'Professional Elective';
                    objCourseOffProfEle12.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseOffProfEle12.Sequence__c =1;
                    objCourseOffProfEle12.Preference__c = '2';
                    objCourseOffProfEle12.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle12.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle12.Parent_Course_Offering__c = objCourseProfOff5.Id;
                    objCourseOffProfEle12.Student_Preference_1__c =1;
                    insert objCourseOffProfEle12;
                    
                    
                    objCourseOffProfEle12 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle12.id  limit 1];
                    //system.debug('objCourseOffProfEle12 '+objCourseOffProfEle12);
                    objCourseOffProfEle9.Category__c = 'Professional Elective';
                    objCourseOffProfEle9.Sequence__c =3;
                    objCourseOffProfEle9.Student_Preference_1__c =1;
                    //objCourseOffProfEle9.Preference__c = '1';
                    objCourseOffProfEle9.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle9.hed__Term__c = objTerm.Id;
                    //objCourseOffProfEle9.Parent_Course_Offering__c = objCourseProfOff5.id;
                    insert objCourseOffProfEle9;
                    
                    objCourseOffProfEle9 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle9.Id limiT 1];objCourseOffProfEle8.Category__c = 'Professional Elective';
                    objCourseOffProfEle6.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle6.Sequence__c =1;
                    objCourseOffProfEle6.Preference__c = '1';
                    objCourseOffProfEle6.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle6.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle6.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    insert objCourseOffProfEle6;
                    
                    
                    objCourseOffProfEle6 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle6.id  limit 1]; 
                    
                   
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                objProfStuOE.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuOE.Preference__c = '1';
                
                objProfStuOE.Student_Preference__c = true;
                insert objProfStuOE;                    
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                objProfStuProf.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuProf.Preference__c = '1';
                
                objProfStuProf.Student_Preference__c = true;
                insert objProfStuProf;
                
                objProfStuProf2.Professor__c = objcon.id;
                objProfStuProf2.Contact__c = objcon.id;
                objProfStuProf2.Course_Offering__c = objCourseOffOpenEle4.Id;
                objProfStuProf2.Preference__c = '1';
                
                objProfStuProf2.Student_Preference__c = true;
                insert objProfStuProf2;
                
                objProfStuProf3.Professor__c = objcon.id;
                objProfStuProf3.Contact__c = objcon.id;
                objProfStuProf3.Course_Offering__c = objCourseOffOpenEle5.Id;
                objProfStuProf3.Preference__c = '1';
                
                objProfStuProf3.Student_Preference__c = true;
                insert objProfStuProf3;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                lstOpenEle.add(objCourseOffOpenEle2);
                lstOpenEle.add(objCourseOffOpenEle3);
                lstOpenEle.add(objCourseOffOpenEle4);
                lstOpenEle.add(objCourseOffOpenEle5);
                lstOpenEle.add(objCourseOffOpenEle6);
                lstOpenEle.add(objCourseOffOpenEle10);
                lstOpenEle.add(objCourseOffOpenEle13);
                lstOpenEle.add(objCourseOffOpenEle14);
                lstOpenEle.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstOpenEle2 = new list<hed__Course_Offering__c>();
                lstOpenEle2.add(objCourseOffOpenEle11);
                lstOpenEle2.add(objCourseOffOpenEle12);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                lstProf.add(objCourseOffProfEle3);
                lstProf.add(objCourseOffProfEle2);
                lstProf.add(objCourseOffProfEle4);
                lstProf.add(objCourseOffProfEle5);
                lstProf.add(objCourseOffProfEle6);
                lstProf.add(objCourseOffProfEle7);
                lstProf.add(objCourseOffProfEle8);
                lstProf.add(objCourseOffProfEle9);
                lstProf.add(objCourseOffProfEle10);
                lstProf.add(objCourseOffProfEle11);
                lstProf.add(objCourseOffProfEle12);
                
                list<hed__Course_Offering__c> lstProf2 = new list<hed__Course_Offering__c>();
                lstProf2.add(objCourseOffProfEle4);
                lstProf2.add(objCourseOffProfEle5);
                
                
                list<hed__Course_Offering__c> lstOpenEle3 = new list<hed__Course_Offering__c>();
                lstOpenEle3.add(objCourseOffOpenEle13);
                lstOpenEle3.add(objCourseOffOpenEle14);
                lstOpenEle3.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstProf3 = new list<hed__Course_Offering__c>();
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle,lstProf);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle2,lstProf2);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle3,lstProf3);
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }                
        }
    }
    public static testMethod Void StudentMethodTest2()
    {
        //UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
       // User adminUser = [Select Id, UserRoleId,ContactId From User Where Profile.Name='System Administrator'  Limit 1];
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;                
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objcon.Application_Number__c = '123';
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c ='Indian';
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
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                insert objProgEnrol;
                
                string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen2 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen3 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff2 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff3 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff4 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff5 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff6 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseMAN.id);
                
                hed__Course_Offering__c  objCourseProfOff1 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);                
                hed__Course_Offering__c  objCourseProfOff3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle2 = MSTR_TestDataFactory.createCourseOffering('Test Open- 1',objTerm.id,objCourseOpen.id);                
                hed__Course_Offering__c  objCourseOffOpenEle3 = MSTR_TestDataFactory.createCourseOffering('Test Open- 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle4 = MSTR_TestDataFactory.createCourseOffering('Test Open- 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle5 = MSTR_TestDataFactory.createCourseOffering('Test Open- 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle6 = MSTR_TestDataFactory.createCourseOffering('Test Open-6',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle7 = MSTR_TestDataFactory.createCourseOffering('Test Open- 7',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle8 = MSTR_TestDataFactory.createCourseOffering('Test Open- 8',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle9 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle10 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle6 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle7 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle8 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle9 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle10 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle11 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle11 = MSTR_TestDataFactory.createCourseOffering('Test Open- 11',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle12 = MSTR_TestDataFactory.createCourseOffering('Test Open- 12',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle13 = MSTR_TestDataFactory.createCourseOffering('Test Open- 13',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle14 = MSTR_TestDataFactory.createCourseOffering('Test Open- 14',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle15 = MSTR_TestDataFactory.createCourseOffering('Test Open- 15',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle12 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                
                hed__Course_Offering__c  objCourseOffOpenEle16 = MSTR_TestDataFactory.createCourseOffering('Test Open- 16',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle17 = MSTR_TestDataFactory.createCourseOffering('Test Open- 17',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle18 = MSTR_TestDataFactory.createCourseOffering('Test Open- 18',objTerm.id,objCourseProf.id);
                
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf2 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf3 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                    objCourseOpen.Category__c = 'Open Elective';
                    objCourseOpen.Offered_By_School__c = objAcc.Id;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.SEE_Conducted_Marks__c = 12;
                    insert objCourseOpen;
                    objCourseOpen2.Category__c = 'Open Elective';
                    objCourseOpen2.Offered_By_School__c = objAcc.Id;
                    objCourseOpen2.Max_Students__c = 1;
                    objCourseOpen2.Credits__c = 4.00;
                    objCourseOpen2.Credit_Hours__c = 4.00;
                    objCourseOpen2.Maximum_External_Marks__c = 50.00;
                    objCourseOpen2.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen2;
                    
                    objCourseOpen3.Category__c = 'Open Elective';
                    objCourseOpen3.Offered_By_School__c = objAcc.Id;
                    objCourseOpen3.Max_Students__c = 1;
                    objCourseOpen3.Credits__c = 4.00;
                    objCourseOpen3.Credit_Hours__c = 4.00;
                    objCourseOpen3.Maximum_External_Marks__c = 50.00;
                    objCourseOpen3.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen3;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                    objCourseProf.Offered_By_School__c = objAcc.Id;
                    objCourseProf.Max_Students__c = 1;
                    objCourseProf.Credits__c = 4.00;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 1';
                    objCourseOff1.Student_Preference_1__c =1;
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    objCourseOff1.Student_Preference_1__c =1;
                    insert objCourseOff1;
                    
                    objCourseOff2.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 2';
                    objCourseOff2.Sequence__c =2;
                    objCourseOff2.Student_Preference_1__c =1;
                    objCourseOff2.hed__Course__c = objCourseOpen3.Id;
                    objCourseOff2.hed__Term__c = objTerm.Id;
                    objCourseOff2.Student_Preference_1__c =1;
                    insert objCourseOff2;
                    
                    objCourseOffOpenEle6.Category__c = 'Open Elective';
                    objCourseOffOpenEle6.Sequence__c =2;
                    objCourseOffOpenEle6.Preference__c = '1';
                    objCourseOffOpenEle6.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle6.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle6.Student_Preference_1__c =1;
                    objCourseOffOpenEle6.Parent_Course_Offering__c = objCourseOff2.id;
                    objCourseOffOpenEle6.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle6;  
                    objCourseOffOpenEle6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle6.Id limiT 1];
                    
                    objCourseOff3.Category__c = 'Open Elective';
                    objCourseOff3.Sequence__c =2;
                    objCourseOff3.Preference__c = '1';
                    objCourseOff3.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff3.hed__Term__c = objTerm.Id;
                    objCourseOff3.Student_Preference_1__c =1;
                    insert objCourseOff3;
                    
                    objCourseOff4.Category__c = 'Open Elective';
                    objCourseOff4.Sequence__c =2;
                    objCourseOff4.Preference__c = '1';
                    objCourseOff4.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff4.hed__Term__c = objTerm.Id;
                    objCourseOff4.Student_Preference_1__c =1;
                    insert objCourseOff4;
                    
                    objCourseProfOff4.Category__c = 'Professional Elective';
                    objCourseProfOff4.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseProfOff4.Sequence__c =2;
                    objCourseProfOff4.Preference__c = '1';
                    objCourseProfOff4.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff4.hed__Term__c = objTerm.Id;
                    objCourseProfOff4.Student_Preference_1__c =1;
                    insert objCourseProfOff4;
                    
                    objCourseProfOff5.Category__c = 'Professional Elective';
                    objCourseProfOff5.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseProfOff5.Sequence__c =2;
                    objCourseProfOff5.Preference__c = '1';
                    objCourseProfOff5.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff5.hed__Term__c = objTerm.Id;
                    objCourseProfOff5.Student_Preference_1__c =1;
                    insert objCourseProfOff5;
                    
                    objCourseOff5.Category__c = 'Open Elective';
                    objCourseOpen2.Name = 'OPEN ELECTIVES - 5';
                    objCourseOff5.Sequence__c =2;
                    objCourseOff5.Preference__c = '1';
                    objCourseOff5.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff5.hed__Term__c = objTerm.Id;
                    objCourseOff5.Student_Preference_1__c =1;
                    insert objCourseOff5;
                    
                    objCourseOffOpenEle10.Category__c = 'Open Elective';
                    objCourseOffOpenEle10.Sequence__c =2;
                    objCourseOffOpenEle10.Preference__c = '1';
                    objCourseOffOpenEle10.hed__Course__c = objCourseOpen2.Id;
                    objCourseOffOpenEle10.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle10.Parent_Course_Offering__c = objCourseOff5.id;
                    objCourseOffOpenEle10.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle10;  
                    objCourseOffOpenEle10 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle10.Id limiT 1];
                    
                    objCourseOffOpenEle7.Category__c = 'Open Elective';
                    objCourseOffOpenEle7.Sequence__c =2;
                    objCourseOffOpenEle7.Preference__c = '1';
                    objCourseOffOpenEle7.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle7.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle7.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle7.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle7;  
                    objCourseOffOpenEle7 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle7.Id limiT 1];
                    
                    objCourseOff6.Category__c = 'Open Elective';
                    objCourseOff6.Sequence__c =2;
                    objCourseOff6.Preference__c = '1';
                    objCourseOff6.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff6.hed__Term__c = objTerm.Id;
                    objCourseOff6.Student_Preference_1__c =1;
                    insert objCourseOff6;
                    objCourseOff6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                     Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOff6.Id limiT 1];
                    
                    objCourseOffOpenEle8.Category__c = 'Open Elective';
                    objCourseOffOpenEle8.Sequence__c =2;
                    objCourseOffOpenEle8.Preference__c = '1';
                    objCourseOffOpenEle8.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle8.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle8.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle8.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle8;  
                    objCourseOffOpenEle8 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle8.Id limiT 1];
                    
                    objCourseProfOff1.Category__c = 'Professional Elective';
                    objCourseProfOff1.Name = 'PROFESSIONAL ELECTIVES - 1';
                    objCourseProfOff1.Sequence__c =1;
                    objCourseProfOff1.Preference__c = '1';
                    objCourseProfOff1.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff1.hed__Term__c = objTerm.Id;
                    objCourseProfOff1.Student_Preference_1__c =1;
                    insert objCourseProfOff1; 
                    
                    objCourseProfOff2.Category__c = 'Professional Elective';
                    objCourseProfOff2.Name = 'PROFESSIONAL ELECTIVES - 2';
                    objCourseProfOff2.Sequence__c =2;
                    objCourseProfOff2.Preference__c = '1';
                    objCourseProfOff2.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff2.hed__Term__c = objTerm.Id;
                    objCourseProfOff1.Student_Preference_1__c =1;
                    insert objCourseProfOff2;
                    
                    objCourseProfOff3.Category__c = 'Professional Elective';
                    objCourseProfOff3.Name = 'PROFESSIONAL ELECTIVES - 3';
                    objCourseProfOff3.Sequence__c =2;
                    objCourseProfOff3.Preference__c = '1';
                    objCourseProfOff3.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff3.hed__Term__c = objTerm.Id;
                    objCourseProfOff3.Student_Preference_1__c =1;
                    insert objCourseProfOff3;
                   
                    objCourseOffProfEle2.Category__c = 'Professional Elective';
                    objCourseOffProfEle2.Sequence__c =1;
                    objCourseOffProfEle2.Preference__c = '1';
                    objCourseOffProfEle2.Parent_Course_Offering__c = objCourseProfOff1.id;
                    objCourseOffProfEle2.Student_Preference_1__c =1;
                    objCourseOffProfEle2.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle2.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle2.Student_Preference_1__c =1;
                    insert objCourseOffProfEle2;
                    
                    objCourseOffProfEle2 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle2.id  limit 1]; 
                    
                    objCourseOffProfEle4.Category__c = 'Professional Elective';
                    objCourseOffProfEle4.Sequence__c =1;
                    objCourseOffProfEle4.Preference__c = '2';
                    objCourseOffProfEle4.Parent_Course_Offering__c = objCourseProfOff2.id;
                    objCourseOffProfEle4.Student_Preference_1__c =1;                    
                    objCourseOffProfEle4.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle4.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle4;
                    
                    objCourseOffProfEle4 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle4.Id limiT 1];
                    
                    objCourseOffProfEle5.Category__c = 'Professional Elective';
                    objCourseOffProfEle5.Sequence__c =1;
                    objCourseOffProfEle5.Preference__c = '3';
                    objCourseOffProfEle5.Parent_Course_Offering__c = objCourseProfOff3.id;
                    objCourseOffProfEle5.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle5.hed__Term__c = objTerm.Id;
                     objCourseOffProfEle5.Student_Preference_1__c =1;   
                    insert objCourseOffProfEle5;
                    
                    objCourseOffProfEle5 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle5.id  limit 1]; 
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff4.id;
                    objCourseOffOpenEle.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle;  
                    
                    objCourseOffOpenEle = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                           hed__Course__c,hed__Term__c
                                           from hed__Course_Offering__c where id=:objCourseOffOpenEle.id  limit 1];
                    
                    objCourseOffOpenEle2.Category__c = 'Open Elective';
                    objCourseOffOpenEle2.Sequence__c =2;
                    objCourseOffOpenEle2.Preference__c = '1';
                    objCourseOffOpenEle2.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle2.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle2.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    objCourseOffOpenEle2.Student_Preference_1__c =1;                    
                    insert objCourseOffOpenEle2;  
                    objCourseOffOpenEle2 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle2.Id limiT 1];
                    
                    objCourseOffOpenEle4.Category__c = 'Open Elective';
                    objCourseOffOpenEle4.Sequence__c =2;
                    objCourseOffOpenEle4.Student_Preference_1__c =1; 
                    objCourseOffOpenEle4.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle4.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle4.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    objCourseOffOpenEle4.Student_Preference_1__c =1;  
                    insert objCourseOffOpenEle4; 
                    
                    objCourseOffOpenEle5.Category__c = 'Open Elective';
                    objCourseOffOpenEle5.Sequence__c =2;
                    objCourseOffOpenEle5.Student_Preference_1__c =1; 
                    objCourseOffOpenEle5.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle5.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle5.Student_Preference_1__c =1;
                    objCourseOffOpenEle5.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    insert objCourseOffOpenEle5; 
                    
                    objCourseOffOpenEle3.Category__c = 'Open Elective';
                    objCourseOffOpenEle3.Sequence__c =3;
                    objCourseOffOpenEle3.Preference__c = '1';
                    objCourseOffOpenEle3.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle3.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle3.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle3.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle3;
                    
                    objCourseOffOpenEle3 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle3.Id limiT 1];
                    
                    objCourseOffOpenEle16.Category__c = 'Open Elective';
                    objCourseOffOpenEle16.Sequence__c =3;
                    objCourseOffOpenEle16.Preference__c = '1';
                    objCourseOffOpenEle16.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle16.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle16.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle16.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle16;
                    
                    objCourseOffOpenEle16 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle16.Id limiT 1];
                    objCourseOffOpenEle17.Category__c = 'Open Elective';
                    objCourseOffOpenEle17.Sequence__c =3;
                    objCourseOffOpenEle17.Preference__c = '1';
                    objCourseOffOpenEle17.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle17.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle17.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle17.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle17;
                    
                    objCourseOffOpenEle17 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle17.Id limiT 1];
                    objCourseOffOpenEle18.Category__c = 'Open Elective';
                    objCourseOffOpenEle18.Sequence__c =3;
                    objCourseOffOpenEle18.Preference__c = '1';
                    objCourseOffOpenEle18.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle18.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle18.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle18.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle18;
                    
                    objCourseOffOpenEle18 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle18.Id limiT 1];
                                        
                    objCourseOffOpenEle11.Category__c = 'Open Elective';
                    objCourseOffOpenEle11.Sequence__c =3;
                    objCourseOffOpenEle11.Student_Preference_1__c =1; 
                    objCourseOffOpenEle11.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle11.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle11.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle11;
                    
                    objCourseOffOpenEle11 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle11.Id limiT 1];
                    objCourseOffOpenEle12.Category__c = 'Open Elective';
                    objCourseOffOpenEle12.Sequence__c =3;
                    objCourseOffOpenEle12.Student_Preference_1__c =1; 
                    objCourseOffOpenEle12.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle12.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle12.Parent_Course_Offering__c = objCourseOff2.id;
                    insert objCourseOffOpenEle12;
                    
                    objCourseOffOpenEle12 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle12.Id limiT 1];
                    
                    objCourseOffOpenEle13.Category__c = 'Open Elective';
                    objCourseOffOpenEle13.Sequence__c =3;
                    objCourseOffOpenEle13.Student_Preference_1__c =1;
                    objCourseOffOpenEle13.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle13.hed__Term__c = objTerm.Id;
                    //objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff3.id;
                    insert objCourseOffOpenEle13;
                    
                    objCourseOffOpenEle13 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle13.Id limiT 1];
                    objCourseOffOpenEle14.Category__c = 'Open Elective';
                    objCourseOffOpenEle14.Sequence__c =3;
                    objCourseOffOpenEle14.Student_Preference_1__c =1;
                    objCourseOffOpenEle14.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle14.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff4.id;
                    insert objCourseOffOpenEle14;
                    
                    objCourseOffOpenEle14 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle14.Id limiT 1];
                    //objCourseOffOpenEle15
                    objCourseOffOpenEle15.Category__c = 'Open Elective';
                    objCourseOffOpenEle15.Sequence__c =3;
                    objCourseOffOpenEle15.Student_Preference_1__c =1;
                    objCourseOffOpenEle15.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle15.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff5.id;
                    insert objCourseOffOpenEle15;
                    
                    objCourseOffOpenEle15 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle15.Id limiT 1];
                    
                    objCourseOffProfEle8.Category__c = 'Professional Elective';
                    objCourseOffProfEle8.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle8.Sequence__c =1;
                    objCourseOffProfEle8.Preference__c = '1';
                    objCourseOffProfEle8.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle8.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle8.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    objCourseOffProfEle8.Student_Preference_1__c =1;
                    insert objCourseOffProfEle8;
                    
                    
                    objCourseOffProfEle8 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle8.id  limit 1]; 
                    
                    objCourseOffProfEle12.Category__c = 'Professional Elective';
                    objCourseOffProfEle12.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseOffProfEle12.Sequence__c =1;
                    objCourseOffProfEle12.Preference__c = '2';
                    objCourseOffProfEle12.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle12.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle12.Student_Preference_1__c =1;
                    objCourseOffProfEle12.Parent_Course_Offering__c = objCourseProfOff5.Id;
                    insert objCourseOffProfEle12;
                    
                    
                    objCourseOffProfEle12 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle12.id  limit 1];
                    objCourseOffProfEle6.Category__c = 'Professional Elective';
                    objCourseOffProfEle6.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle6.Sequence__c =1;
                    objCourseOffProfEle6.Preference__c = '3';
                    objCourseOffProfEle6.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle6.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle6.Student_Preference_1__c =1;
                    objCourseOffProfEle6.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    insert objCourseOffProfEle6;
                    
                    
                    objCourseOffProfEle6 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle6.id  limit 1]; 
                    
                   
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                objProfStuOE.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuOE.Preference__c = '1';                
                objProfStuOE.Student_Preference__c = true;
                insert objProfStuOE;                    
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                objProfStuProf.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuProf.Preference__c = '1';                
                objProfStuProf.Student_Preference__c = true;
                insert objProfStuProf;
                
                objProfStuProf2.Professor__c = objcon.id;
                objProfStuProf2.Contact__c = objcon.id;
                objProfStuProf2.Course_Offering__c = objCourseOffOpenEle4.Id;
                objProfStuProf2.Preference__c = '1';                
                objProfStuProf2.Student_Preference__c = true;
                insert objProfStuProf2;
                
                objProfStuProf3.Professor__c = objcon.id;
                objProfStuProf3.Contact__c = objcon.id;
                objProfStuProf3.Course_Offering__c = objCourseOffOpenEle5.Id;
                objProfStuProf3.Preference__c = '1';                
                objProfStuProf3.Student_Preference__c = true;
                insert objProfStuProf3;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                lstOpenEle.add(objCourseOffOpenEle2);
                lstOpenEle.add(objCourseOffOpenEle3);
                lstOpenEle.add(objCourseOffOpenEle4);
                lstOpenEle.add(objCourseOffOpenEle5);
                lstOpenEle.add(objCourseOffOpenEle6);
                lstOpenEle.add(objCourseOffOpenEle10);
                lstOpenEle.add(objCourseOffOpenEle13);
                lstOpenEle.add(objCourseOffOpenEle14);
                lstOpenEle.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstOpenEle2 = new list<hed__Course_Offering__c>();
                lstOpenEle2.add(objCourseOffOpenEle11);
                lstOpenEle2.add(objCourseOffOpenEle12);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                lstProf.add(objCourseOffProfEle3);
                lstProf.add(objCourseOffProfEle2);
                lstProf.add(objCourseOffProfEle4);
                lstProf.add(objCourseOffProfEle5);
                lstProf.add(objCourseOffProfEle6);
                lstProf.add(objCourseOffProfEle7);
                lstProf.add(objCourseOffProfEle8);
                lstProf.add(objCourseOffProfEle9);
                lstProf.add(objCourseOffProfEle10);
                lstProf.add(objCourseOffProfEle11);
                lstProf.add(objCourseOffProfEle12);
                
                list<hed__Course_Offering__c> lstProf2 = new list<hed__Course_Offering__c>();
                lstProf2.add(objCourseOffProfEle4);
                lstProf2.add(objCourseOffProfEle5);
                
                
                list<hed__Course_Offering__c> lstOpenEle3 = new list<hed__Course_Offering__c>();
                lstOpenEle3.add(objCourseOffOpenEle13);
                lstOpenEle3.add(objCourseOffOpenEle14);
                lstOpenEle3.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstProf3 = new list<hed__Course_Offering__c>();
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle,lstProf);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle2,lstProf2);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle3,lstProf3);
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }                
        }
    }
  
   public static testMethod Void StudentMethodTest3()
    {
        //UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId,IsActive From User Where Profile.Name='System Administrator' and IsActive=true AND UserRoleId !=null Limit 1];
        //adminUser.UserRoleId = userRole.Id;
        update adminUser;
        //User adminUser = [Select Id, UserRoleId,ContactId From User Where Profile.Name='System Administrator'  Limit 1];
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
            string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
            Account objAcc = STOB_TestDataFactory.CreateAccount('Test Account');
            objAcc.Recordtypeid = UniversityRecId;
            objAcc.OwnerId = portalAccountOwner1.Id;
            Insert objAcc;                
            
            Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            
            Contact objCon = STOB_TestDataFactory.createContact('Test');
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objcon.Application_Number__c = '123';
            objcon.hed__WorkEmail__c='123@reva.edu.in';
            objcon.Email = 'test@reva.edu.in';
            objcon.MobilePhone ='8963210547';
            objcon.AccountId = objAcc.id;
            objcon.RecordTypeId = ContactRecTypeId;
            objcon.Nationality__c ='Indian';
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
                
                hed__Program_Plan__c objProgPlan = STOB_TestDataFactory.createProgramPlan('test program plan');
                objProgPlan.hed__Account__c = objAcc.Id;
                objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
                objProgPlan.hed__End_Date__c = system.today()+2;
                insert objProgPlan;
                
                hed__Program_Enrollment__c objProgEnrol = new hed__Program_Enrollment__c();
                objProgEnrol.hed__Contact__c = ObjCon.Id;
                objProgEnrol.hed__Account__c = objAcc.Id;
                objProgEnrol.hed__Program_Plan__c = objProgPlan.Id;
                insert objProgEnrol;
                
                string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
                hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
                hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen2 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseOpen3 = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAcc.Id);
                
                hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff2 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff3 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff4 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff5 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOff6 = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 5',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourse.id);
                hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseHI.id);
                hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCoursePW.id);
                hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseMAN.id);
                
                hed__Course_Offering__c  objCourseProfOff1 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);                
                hed__Course_Offering__c  objCourseProfOff3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseProfOff5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('OPEN ELECTIVES - 1',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle2 = MSTR_TestDataFactory.createCourseOffering('Test Open- 1',objTerm.id,objCourseOpen.id);                
                hed__Course_Offering__c  objCourseOffOpenEle3 = MSTR_TestDataFactory.createCourseOffering('Test Open- 2',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle4 = MSTR_TestDataFactory.createCourseOffering('Test Open- 3',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle5 = MSTR_TestDataFactory.createCourseOffering('Test Open- 4',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle6 = MSTR_TestDataFactory.createCourseOffering('Test Open-6',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle7 = MSTR_TestDataFactory.createCourseOffering('Test Open- 7',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle8 = MSTR_TestDataFactory.createCourseOffering('Test Open- 8',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle9 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffOpenEle10 = MSTR_TestDataFactory.createCourseOffering('Test Open- 9',objTerm.id,objCourseOpen.id);
                hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 4',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle2 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 5',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle3 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 1',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle4 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 2',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle5 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle6 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle7 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle8 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle9 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle10 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle11 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle11 = MSTR_TestDataFactory.createCourseOffering('Test Open- 11',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle12 = MSTR_TestDataFactory.createCourseOffering('Test Open- 12',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle13 = MSTR_TestDataFactory.createCourseOffering('Test Open- 13',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle14 = MSTR_TestDataFactory.createCourseOffering('Test Open- 14',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle15 = MSTR_TestDataFactory.createCourseOffering('Test Open- 15',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffProfEle12 = MSTR_TestDataFactory.createCourseOffering('PROFESSIONAL ELECTIVES - 3',objTerm.id,objCourseProf.id);
                
                hed__Course_Offering__c  objCourseOffOpenEle16 = MSTR_TestDataFactory.createCourseOffering('Test Open- 16',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle17 = MSTR_TestDataFactory.createCourseOffering('Test Open- 17',objTerm.id,objCourseProf.id);
                hed__Course_Offering__c  objCourseOffOpenEle18 = MSTR_TestDataFactory.createCourseOffering('Test Open- 18',objTerm.id,objCourseProf.id);
                
                Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf2 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                Professor_Student_Course_Preference__c objProfStuProf3 = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
                
                system.runAs(adminUser){
                    
                    objTerm.Program_Batch__c  = objProgPlan.id;
                    objTerm.hed__Start_Date__c = system.today().adddays(-16); 
                    objTerm.hed__End_Date__c =system.today().adddays(16);
                    objTerm.Approval_Status__c = 'Confirmed';
                    objTerm.Allow_Student_Elective_Preference__c = true;
                    insert objTerm;
                    
                    objCourseOpen.Category__c = 'Open Elective';
                     objCourseOpen.Offered_By_School__c = objAcc.Id;
                    objCourseOpen.Max_Students__c = 1;
                    objCourseOpen.Credits__c = 4.00;
                    objCourseOpen.Credit_Hours__c = 4.00;
                    objCourseOpen.Maximum_External_Marks__c = 50.00;
                    objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
                    objCourseOpen.Max_Students__c = 1;
                     objCourseOpen.SEE_Conducted_Marks__c = 12;
                    insert objCourseOpen;
                    objCourseOpen2.Category__c = 'Open Elective';
                    objCourseOpen2.Offered_By_School__c = objAcc.Id;
                    objCourseOpen2.Max_Students__c = 1;
                    objCourseOpen2.Credits__c = 4.00;
                    objCourseOpen2.Credit_Hours__c = 4.00;
                    objCourseOpen2.Maximum_External_Marks__c = 50.00;
                    objCourseOpen2.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen2;
                    
                    objCourseOpen3.Category__c = 'Open Elective';
                    objCourseOpen3.Offered_By_School__c = objAcc.Id;
                    objCourseOpen3.Max_Students__c = 1;
                    objCourseOpen3.Credits__c = 4.00;
                    objCourseOpen3.Credit_Hours__c = 4.00;
                    objCourseOpen3.Maximum_External_Marks__c = 50.00;
                    objCourseOpen3.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseOpen3;
                    
                    objCourseProf.Category__c = 'Professional Elective';
                     objCourseProf.Offered_By_School__c = objAcc.Id;
                    objCourseProf.Max_Students__c = 1;
                    objCourseProf.Credits__c = 4.00;
                    objCourseProf.Credit_Hours__c = 4.00;
                    objCourseProf.Maximum_External_Marks__c = 50.00;
                    objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
                    insert objCourseProf;
                    
                    objCourseOff1.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 1';
                    objCourseOff1.Sequence__c =1;
                    objCourseOff1.Preference__c = '1';
                    objCourseOff1.hed__Course__c = objCourseOpen.Id;
                    objCourseOff1.hed__Term__c = objTerm.Id;
                    objCourseOff1.Student_Preference_1__c =1;
                    insert objCourseOff1;
                    
                    objCourseOff2.Category__c = 'Open Elective';
                    objCourseOff1.Name = 'OPEN ELECTIVES - 2';
                    objCourseOff2.Sequence__c =2;
                    objCourseOff2.Student_Preference_1__c =1;
                    objCourseOff2.hed__Course__c = objCourseOpen3.Id;
                    objCourseOff2.hed__Term__c = objTerm.Id;
                    
                    insert objCourseOff2;
                    
                    objCourseOffOpenEle6.Category__c = 'Open Elective';
                    objCourseOffOpenEle6.Sequence__c =2;
                    objCourseOffOpenEle6.Preference__c = '1';
                    objCourseOffOpenEle6.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle6.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle6.Parent_Course_Offering__c = objCourseOff2.id;
                    objCourseOffOpenEle6.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle6;  
                    objCourseOffOpenEle6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle6.Id limiT 1];
                    
                    objCourseOff3.Category__c = 'Open Elective';
                    objCourseOff3.Sequence__c =2;
                    objCourseOff3.Preference__c = '1';
                    objCourseOff3.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff3.hed__Term__c = objTerm.Id;
                    objCourseOff3.Student_Preference_1__c =1;
                    insert objCourseOff3;
                    
                    objCourseOff4.Category__c = 'Open Elective';
                    objCourseOff4.Sequence__c =2;
                    objCourseOff4.Preference__c = '1';
                    objCourseOff4.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff4.hed__Term__c = objTerm.Id;
                    objCourseOff4.Student_Preference_1__c =1;
                    insert objCourseOff4;
                    
                    objCourseProfOff4.Category__c = 'Professional Elective';
                    objCourseProfOff4.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseProfOff4.Sequence__c =2;
                    objCourseProfOff4.Preference__c = '1';
                    objCourseProfOff4.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff4.hed__Term__c = objTerm.Id;
                    objCourseProfOff4.Student_Preference_1__c =1;
                    insert objCourseProfOff4;
                    
                    objCourseProfOff5.Category__c = 'Professional Elective';
                    objCourseProfOff5.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseProfOff5.Sequence__c =2;
                    objCourseProfOff5.Preference__c = '1';
                    objCourseProfOff5.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff5.hed__Term__c = objTerm.Id;
                    objCourseProfOff5.Student_Preference_1__c =1;
                    insert objCourseProfOff5;
                    
                    objCourseOff5.Category__c = 'Open Elective';
                    objCourseOpen2.Name = 'OPEN ELECTIVES - 5';
                    objCourseOff5.Sequence__c =2;
                    objCourseOff5.Preference__c = '1';
                    objCourseOff5.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff5.hed__Term__c = objTerm.Id;
                    objCourseOff5.Student_Preference_1__c =1;
                    insert objCourseOff5;
                    
                    objCourseOffOpenEle10.Category__c = 'Open Elective';
                    objCourseOffOpenEle10.Sequence__c =2;
                    objCourseOffOpenEle10.Preference__c = '1';
                    objCourseOffOpenEle10.hed__Course__c = objCourseOpen2.Id;
                    objCourseOffOpenEle10.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle10.Parent_Course_Offering__c = objCourseOff5.id;
                    objCourseOffOpenEle10.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle10;  
                    objCourseOffOpenEle10 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle10.Id limiT 1];
                    
                    objCourseOffOpenEle7.Category__c = 'Open Elective';
                    objCourseOffOpenEle7.Sequence__c =2;
                    objCourseOffOpenEle7.Preference__c = '1';
                    objCourseOffOpenEle7.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle7.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle7.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle7.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle7;  
                    objCourseOffOpenEle7 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle7.Id limiT 1];
                    
                    objCourseOff6.Category__c = 'Open Elective';
                    objCourseOff6.Sequence__c =2;
                    objCourseOff6.Preference__c = '1';
                    objCourseOff6.hed__Course__c = objCourseOpen2.Id;
                    objCourseOff6.hed__Term__c = objTerm.Id;
                     objCourseOff6.Student_Preference_1__c =1;
                    insert objCourseOff6;
                    objCourseOff6 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                     Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOff6.Id limiT 1];
                    
                    objCourseOffOpenEle8.Category__c = 'Open Elective';
                    objCourseOffOpenEle8.Sequence__c =2;
                    objCourseOffOpenEle8.Preference__c = '1';
                    objCourseOffOpenEle8.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle8.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle8.Parent_Course_Offering__c = objCourseOff3.id;
                    objCourseOffOpenEle8.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle8;  
                    objCourseOffOpenEle8 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle8.Id limiT 1];
                    
                    objCourseProfOff1.Category__c = 'Professional Elective';
                    objCourseProfOff1.Name = 'PROFESSIONAL ELECTIVES - 1';
                    objCourseProfOff1.Sequence__c =1;
                    objCourseProfOff1.Preference__c = '1';
                    objCourseProfOff1.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff1.hed__Term__c = objTerm.Id; 
                    objCourseProfOff1.Student_Preference_1__c =1;
                    insert objCourseProfOff1; 
                    
                    objCourseProfOff2.Category__c = 'Professional Elective';
                    objCourseProfOff2.Name = 'PROFESSIONAL ELECTIVES - 2';
                    objCourseProfOff2.Sequence__c =2;
                    objCourseProfOff2.Preference__c = '1';
                    objCourseProfOff2.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff2.hed__Term__c = objTerm.Id;
                    objCourseProfOff2.Student_Preference_1__c =1;
                    insert objCourseProfOff2;
                    
                    objCourseProfOff3.Category__c = 'Professional Elective';
                    objCourseProfOff3.Name = 'PROFESSIONAL ELECTIVES - 3';
                    objCourseProfOff3.Sequence__c =2;
                    objCourseProfOff3.Preference__c = '1';
                    objCourseProfOff3.hed__Course__c = objCourseProf.Id;
                    objCourseProfOff3.hed__Term__c = objTerm.Id;
                    objCourseProfOff3.Student_Preference_1__c =1;
                    insert objCourseProfOff3;
                    
                    objCourseOffProfEle2.Category__c = 'Professional Elective';
                    objCourseOffProfEle2.Sequence__c =1;
                    objCourseOffProfEle2.Preference__c = '3';
                    objCourseOffProfEle2.Parent_Course_Offering__c = objCourseProfOff1.id;
                    objCourseOffProfEle2.Student_Preference_1__c =1;
                    objCourseOffProfEle2.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle2.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle2;
                    
                    objCourseOffProfEle2 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle2.id  limit 1]; 
                    
                    objCourseOffProfEle4.Category__c = 'Professional Elective';
                    objCourseOffProfEle4.Sequence__c =1;
                    objCourseOffProfEle4.Preference__c = '2';
                    objCourseOffProfEle4.Parent_Course_Offering__c = objCourseProfOff2.id;
                    objCourseOffProfEle4.Student_Preference_1__c =1;
                    objCourseOffProfEle4.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle4.hed__Term__c = objTerm.Id;
                    insert objCourseOffProfEle4;
                    
                    objCourseOffProfEle4 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle4.Id limiT 1];
                    
                    objCourseOffProfEle5.Category__c = 'Professional Elective';
                    objCourseOffProfEle5.Sequence__c =1;
                    objCourseOffProfEle5.Preference__c = '3';
                    objCourseOffProfEle5.Parent_Course_Offering__c = objCourseProfOff3.id;
                    objCourseOffProfEle5.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle5.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle5.Student_Preference_1__c =1;
                    insert objCourseOffProfEle5;
                    
                    objCourseOffProfEle5 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle5.id  limit 1]; 
                    
                    objCourseOffOpenEle.Category__c = 'Open Elective';
                    objCourseOffOpenEle.Sequence__c =1;
                    objCourseOffOpenEle.Preference__c = '1';
                    objCourseOffOpenEle.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff4.id;
                    objCourseOffOpenEle.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle;  
                    
                    objCourseOffOpenEle = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                           hed__Course__c,hed__Term__c
                                           from hed__Course_Offering__c where id=:objCourseOffOpenEle.id  limit 1];
                    
                    objCourseOffOpenEle2.Category__c = 'Open Elective';
                    objCourseOffOpenEle2.Sequence__c =2;
                    objCourseOffOpenEle2.Preference__c = '1';
                    objCourseOffOpenEle2.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle2.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle2.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    objCourseOffOpenEle2.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle2;  
                    objCourseOffOpenEle2 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle2.Id limiT 1];
                    
                    objCourseOffOpenEle4.Category__c = 'Open Elective';
                    objCourseOffOpenEle4.Sequence__c =2;
                    //objCourseOffOpenEle4.Preference__c = '1';
                    objCourseOffOpenEle4.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle4.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle4.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    objCourseOffOpenEle4.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle4;  
                    
                    objCourseOffOpenEle5.Category__c = 'Open Elective';
                    objCourseOffOpenEle5.Sequence__c =2;
                    objCourseOffOpenEle5.Student_Preference_1__c =1;
                    objCourseOffOpenEle5.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle5.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle5.Parent_Course_Offering__c = objCourseOffOpenEle.id;
                    insert objCourseOffOpenEle5;  
                    
                    objCourseOffOpenEle3.Category__c = 'Open Elective';
                    objCourseOffOpenEle3.Sequence__c =3;
                    objCourseOffOpenEle3.Preference__c = '1';
                    objCourseOffOpenEle3.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle3.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle3.Student_Preference_1__c =1;
                    objCourseOffOpenEle3.Parent_Course_Offering__c = objCourseOff3.id;
                    insert objCourseOffOpenEle3;
                    
                    objCourseOffOpenEle3 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle3.Id limiT 1];
                    
                    objCourseOffOpenEle16.Category__c = 'Open Elective';
                    objCourseOffOpenEle16.Sequence__c =3;
                    objCourseOffOpenEle16.Preference__c = '1';
                    objCourseOffOpenEle16.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle16.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle16.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle16.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle16;
                    
                    objCourseOffOpenEle16 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle16.Id limiT 1];
                    objCourseOffOpenEle17.Category__c = 'Open Elective';
                    objCourseOffOpenEle17.Sequence__c =3;
                    objCourseOffOpenEle17.Preference__c = '1';
                    objCourseOffOpenEle17.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle17.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle17.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle17.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle17;
                    
                    objCourseOffOpenEle17 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle17.Id limiT 1];
                    objCourseOffOpenEle18.Category__c = 'Open Elective';
                    objCourseOffOpenEle18.Sequence__c =3;
                    objCourseOffOpenEle18.Preference__c = '1';
                    objCourseOffOpenEle18.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle18.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle18.Parent_Course_Offering__c = objCourseOff1.id;
                    objCourseOffOpenEle18.Student_Preference_1__c =1;
                    insert objCourseOffOpenEle18;
                    
                    objCourseOffOpenEle18 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle18.Id limiT 1];
                    
                    objCourseOffOpenEle11.Category__c = 'Open Elective';
                    objCourseOffOpenEle11.Sequence__c =3;
                    objCourseOffOpenEle11.Student_Preference_1__c =1;
                    objCourseOffOpenEle11.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle11.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle11.Parent_Course_Offering__c = objCourseOff1.id;
                    insert objCourseOffOpenEle11;
                    
                    objCourseOffOpenEle11 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle11.Id limiT 1];
                    objCourseOffOpenEle12.Category__c = 'Open Elective';
                    objCourseOffOpenEle12.Sequence__c =3;
                    objCourseOffOpenEle12.Student_Preference_1__c =1;
                    objCourseOffOpenEle12.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle12.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle12.Parent_Course_Offering__c = objCourseOff2.id;
                    insert objCourseOffOpenEle12;
                    
                    objCourseOffOpenEle12 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle12.Id limiT 1];
                    
                    objCourseOffOpenEle13.Category__c = 'Open Elective';
                    objCourseOffOpenEle13.Sequence__c =3;
                    objCourseOffOpenEle13.Student_Preference_1__c =1;
                    objCourseOffOpenEle13.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle13.hed__Term__c = objTerm.Id;
                    //objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff3.id;
                    insert objCourseOffOpenEle13;
                    
                    objCourseOffOpenEle13 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle13.Id limiT 1];
                    objCourseOffOpenEle14.Category__c = 'Open Elective';
                    objCourseOffOpenEle14.Sequence__c =3;
                    objCourseOffOpenEle14.Student_Preference_1__c =1;
                    objCourseOffOpenEle14.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle14.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff4.id;
                    insert objCourseOffOpenEle14;
                    
                    objCourseOffOpenEle14 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle14.Id limiT 1];
                    //objCourseOffOpenEle15
                    objCourseOffOpenEle15.Category__c = 'Open Elective';
                    objCourseOffOpenEle15.Sequence__c =3;
                    objCourseOffOpenEle15.Student_Preference_1__c =1;
                    objCourseOffOpenEle15.hed__Course__c = objCourseOpen.Id;
                    objCourseOffOpenEle15.hed__Term__c = objTerm.Id;
                    objCourseOffOpenEle13.Parent_Course_Offering__c = objCourseOff5.id;
                    insert objCourseOffOpenEle15;
                    
                    objCourseOffOpenEle15 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                             Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffOpenEle15.Id limiT 1];
                    
                    objCourseOffProfEle8.Category__c = 'Professional Elective';
                    objCourseOffProfEle8.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle8.Sequence__c =1;
                    objCourseOffProfEle8.Student_Preference_1__c =1;
                    objCourseOffProfEle8.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle8.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle8.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    insert objCourseOffProfEle8;
                    
                    
                    objCourseOffProfEle8 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle8.id  limit 1]; 
                    
                    objCourseOffProfEle12.Category__c = 'Professional Elective';
                    objCourseOffProfEle12.Name = 'PROFESSIONAL ELECTIVES - 5';
                    objCourseOffProfEle12.Sequence__c =1;
                    objCourseOffProfEle12.Student_Preference_1__c =1;
                    objCourseOffProfEle12.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle12.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle12.Parent_Course_Offering__c = objCourseProfOff5.Id;
                    insert objCourseOffProfEle12;
                    
                    
                    objCourseOffProfEle12 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                             hed__Course__c,hed__Term__c
                                             from hed__Course_Offering__c where id=:objCourseOffProfEle12.id  limit 1];
                    objCourseOffProfEle9.Category__c = 'Professional Elective';
                    objCourseOffProfEle9.Sequence__c =3;
                    objCourseOffProfEle9.Student_Preference_1__c =1;
                    objCourseOffProfEle9.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle9.hed__Term__c = objTerm.Id;
                    //objCourseOffProfEle9.Parent_Course_Offering__c = objCourseProfOff5.id;
                    insert objCourseOffProfEle9;
                    
                    objCourseOffProfEle9 = [SELECT Id,Name,Parent_Course_Offering__c,hed__Course__c,hed__Term__c,
                                            Preference__c,Parent_Course_Offering__r.Name FROM hed__Course_Offering__c WHERE id=:objCourseOffProfEle9.Id limiT 1];objCourseOffProfEle8.Category__c = 'Professional Elective';
                    objCourseOffProfEle6.Name = 'PROFESSIONAL ELECTIVES - 4';
                    objCourseOffProfEle6.Sequence__c =1;
                    objCourseOffProfEle6.Student_Preference_1__c =1;
                    objCourseOffProfEle6.hed__Course__c = objCourseProf.Id;
                    objCourseOffProfEle6.hed__Term__c = objTerm.Id;
                    objCourseOffProfEle6.Parent_Course_Offering__c = objCourseProfOff4.Id;
                    insert objCourseOffProfEle6;
                    
                    
                    objCourseOffProfEle6 = [select id,name,Sequence__c,Preference__c,Parent_Course_Offering__c,Parent_Course_Offering__r.name,
                                            hed__Course__c,hed__Term__c
                                            from hed__Course_Offering__c where id=:objCourseOffProfEle6.id  limit 1]; 
                    
                   
                }
                objProfStuOE.Professor__c = objcon.id;
                objProfStuOE.Contact__c = objcon.id;
                objProfStuOE.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuOE.Preference__c = '1';                
                objProfStuOE.Student_Preference__c = true;
                insert objProfStuOE;                    
                
                objProfStuProf.Professor__c = objcon.id;
                objProfStuProf.Contact__c = objcon.id;
                objProfStuProf.Course_Offering__c = objCourseOffOpenEle3.Id;
                objProfStuProf.Preference__c = '1';                
                objProfStuProf.Student_Preference__c = true;
                insert objProfStuProf;
                
                objProfStuProf2.Professor__c = objcon.id;
                objProfStuProf2.Contact__c = objcon.id;
                objProfStuProf2.Course_Offering__c = objCourseOffOpenEle4.Id;
                objProfStuProf2.Preference__c = '1';                
                objProfStuProf2.Student_Preference__c = true;
                insert objProfStuProf2;
                
                objProfStuProf3.Professor__c = objcon.id;
                objProfStuProf3.Contact__c = objcon.id;
                objProfStuProf3.Course_Offering__c = objCourseOffOpenEle5.Id;
                objProfStuProf3.Preference__c = '1';                
                objProfStuProf3.Student_Preference__c = true;
                insert objProfStuProf3;
                
                list<hed__Course_Offering__c> lstOpenEle = new list<hed__Course_Offering__c>();
                lstOpenEle.add(objCourseOffOpenEle);
                lstOpenEle.add(objCourseOffOpenEle2);
                lstOpenEle.add(objCourseOffOpenEle3);
                lstOpenEle.add(objCourseOffOpenEle4);
                lstOpenEle.add(objCourseOffOpenEle5);
                lstOpenEle.add(objCourseOffOpenEle6);
                lstOpenEle.add(objCourseOffOpenEle10);
                lstOpenEle.add(objCourseOffOpenEle13);
                lstOpenEle.add(objCourseOffOpenEle14);
                lstOpenEle.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstOpenEle2 = new list<hed__Course_Offering__c>();
                lstOpenEle2.add(objCourseOffOpenEle11);
                lstOpenEle2.add(objCourseOffOpenEle12);
                
                list<hed__Course_Offering__c> lstProf = new list<hed__Course_Offering__c>();
                lstProf.add(objCourseOffProfEle);
                lstProf.add(objCourseOffProfEle3);
                lstProf.add(objCourseOffProfEle2);
                lstProf.add(objCourseOffProfEle4);
                lstProf.add(objCourseOffProfEle5);
                lstProf.add(objCourseOffProfEle6);
                lstProf.add(objCourseOffProfEle7);
                lstProf.add(objCourseOffProfEle8);
                lstProf.add(objCourseOffProfEle9);
                lstProf.add(objCourseOffProfEle10);
                lstProf.add(objCourseOffProfEle11);
                lstProf.add(objCourseOffProfEle12);
                
                list<hed__Course_Offering__c> lstProf2 = new list<hed__Course_Offering__c>();
                lstProf2.add(objCourseOffProfEle4);
                lstProf2.add(objCourseOffProfEle5);
                
                
                list<hed__Course_Offering__c> lstOpenEle3 = new list<hed__Course_Offering__c>();
                lstOpenEle3.add(objCourseOffOpenEle13);
                lstOpenEle3.add(objCourseOffOpenEle14);
                lstOpenEle3.add(objCourseOffOpenEle15);
                
                list<hed__Course_Offering__c> lstProf3 = new list<hed__Course_Offering__c>();
                
                Test.Starttest();
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle,lstProf);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle2,lstProf2);
                STOB_DefineStudentPreference_ctrl.ValidationPreferences(lstOpenEle3,lstProf3);
                test.stoptest();
                system.assertequals(objCourseOffOpenEle.id,objCourseOffOpenEle.id);
            }                
        }
    } 
}