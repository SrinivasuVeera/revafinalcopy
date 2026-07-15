@isTest
public class ALU_StudentNOCComp_Ctrl_Test 
{
    public static testmethod void ALU_StudentNOCComp()
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
             objcon.Personal_Email__c = 'test@reva.edu.in';
        objcon.hed__Preferred_Email__c = 'Personal Email';
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
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++)
            {
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ALU_TestDataFactory.CreateCourse( 'cat', objAccount.Id ));
            }
            Insert list_Crs;
            
            hed__Program_Plan__c  objProgPlan =  ALU_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            insert objProgPlan;
            
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
            hed__Term__c objTerm = ALU_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
            objTerm.Program_Batch__c  = objProgPlan.id;
            insert objTerm;
            
            hed__Term__c objTermParent = ALU_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
            objTermParent.hed__Parent_Term__c = objTerm.id;
            insert objTermParent;
            
            hed__Course_Offering__c obj_Cour_Off = ALU_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = objTerm.Id;
            obj_Cour_Off.hed__Term__c = objTermParent.Id;
            insert obj_Cour_Off;
            
            hed__Program_Enrollment__c objProgEnroll = ALU_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
            objProgEnroll.hed__Start_Date__c = system.today()-1;
            objProgEnroll.hed__End_Date__c = system.today();
            objProgEnroll.hed__Program_Plan__c = objProgPlan.id; 
            objProgEnroll.Application_Number__c ='123';
            objProgEnroll.Section__c = objTerm.id;
            insert objProgEnroll; 
            
            Student_Fee__c objStudntFee = ALU_TestDataFactory.createStudentFee(objcon.Id);
            insert objStudntFee;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
            hed__Course_Offering__c Cour_Off = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
            
            hed__Course_Enrollment__c obj_Cour_Enroll = ALU_TestDataFactory.createCourseEnrollment(objcon.id, Cour_Off.Id);
            obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
            obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
            obj_Cour_Enroll.hed__Course_Offering__c = Cour_Off.Id;
            obj_Cour_Enroll.hed__Contact__c = objcon.id;
            Insert obj_Cour_Enroll;
            
            hed__Term_Grade__c objCreateResult = ALU_TestDataFactory.createResults(objcon.Id);
            objCreateResult.hed__Course_Offering__c = Cour_Off.Id;
            objCreateResult.hed__Course_Connection__c = obj_Cour_Enroll.Id;
            Insert objCreateResult;
            
            List<Contact> list_Con = new List<Contact>();
            list_Con.add(objcon);
            
            update objcon;
            
            system.runAs(objUser)
            {
                Test.startTest();
                ALU_StudentNOCComp_Ctrl.getStntResltDetails();
                ALU_StudentNOCComp_Ctrl.getJoiningReva();
                ALU_StudentNOCComp_Ctrl.getPalcementDetails();
                ALU_StudentNOCComp_Ctrl.getCoaching();
                ALU_StudentNOCComp_Ctrl.getStarted(); 
                ALU_StudentNOCComp_Ctrl.getStntResltDetails();
                ALU_StudentNOCComp_Ctrl.getStudentPositionDetails();
                ALU_StudentNOCComp_Ctrl.saveContacts('test', 'hyd', 'xxx', 'hr', 'bang', system.today(), 'test', 'course', 'HR', system.today(), 'india', 'karnataka', 'college', 'test', 'exective', 'pune', 'roll', 'hyd', 'profit', 'ttesting', 'file', 'filename', 'yyy');
                Test.stopTest();
                system.assertEquals(objcon.Joining_REVA__c,'yes');
            }
        } 
    }
}