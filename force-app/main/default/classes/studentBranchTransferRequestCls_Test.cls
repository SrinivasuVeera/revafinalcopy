@isTest
public class studentBranchTransferRequestCls_Test {
    @isTest
    public static void stdntBranchMethodTermNotMatch(){
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User objUser = new User();
        
        System.runAs(adminUser)
        {
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); 
            Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            Id accRecTypeId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(); 
            
            Account Acc2P=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology');
            Acc2P.RecordTypeId=accRecTypeId;
            Acc2P.Program_Type__c = 'UG';
            Acc2P.UG_Start_date__c = system.today();
            Acc2P.UG_End_Date__c = system.today() +7;
            insert Acc2P;
            
            
            Account Acc2=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 3');
            Acc2.RecordTypeId=accRecTypeId;
            Acc2.ParentId = Acc2P.Id;
            Acc2.UG_Start_date__c = system.today();
            Acc2.UG_End_Date__c = system.today();
            insert Acc2;
            
            Account Acc5=STOB_TestDataFactory.CreateAccount('University Dep');
            Acc5.RecordTypeId=accRecTypeId2;
            Acc5.UG_Start_date__c = system.today();
            Acc5.UG_End_Date__c = system.today();
            insert Acc5;
            
            //Faculty of Engineering & Technology
            Account Acc1=STOB_TestDataFactory.CreateAccount('REVA Engineering College');
            Acc1.RecordTypeId=accRecTypeId;
            Acc1.Intake__c=1;
            Acc1.Intake_Per_Section__c=8;
            Acc1.Number_of_Batches__c=2;
            Acc1.Number_of_Semesters__c=2;
            Acc1.Program_Alias__c='1234AVC';
            Acc1.Program_Alias__c='AVCFD';
            Acc1.Program_Type__c='UG';
            Acc1.ParentId = Acc2.Id;
            Acc1.UG_Start_date__c = system.today();
            Acc1.UG_End_Date__c = system.today();
            insert Acc1;
            
            Account Acc3=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 2');
            Acc3.RecordTypeId=accRecTypeId;
            Acc3.ParentId = Acc2.Id;
            insert Acc3;
            
             Account Acc6=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 5');
            Acc6.RecordTypeId=accRecTypeId;
            Acc6.ParentId = Acc2P.Id;
            insert Acc6;
            
            
            
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
            
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',Acc1.id,termRtId);
            objTerm.Term_Number__c = 1;
            objTerm.hed__Start_Date__c = system.today()-10;
            objterm.IA_1_Start_date__c = system.today()+11;
            objterm.hed__End_Date__c =  system.today()+12;
            insert objTerm;
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++){
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, Acc1.Id, cat));
            }
            Insert list_Crs;
            
            date dt = system.today();
            
            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objterm.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = objTerm.Id;
            
            insert obj_Cour_Off;
            
            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            objProgPlan.hed__Account__c = Acc1.Id;
            objProgPlan.hed__Start_Date__c = system.today();
            objProgPlan.hed__End_Date__c = system.today();
            insert objProgPlan;
            
            SYSTEM.debug('objProgPlan IN TEST '+objProgPlan);
            //hed__Program_Plan__c
            
            Id accRecTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            contact con=new Contact();
            con.Lastname='Test';
            con.Enrollment_Type__c='Regular Entry';
            con.hed__Gender__c='Male';
            con.Application_Number__c='123';
            con.MobilePhone='9393949785';            
            con.AccountId =Acc1.id;
            con.School__c=Acc2.id;
            con.Nationality__c='Austrian';
            con.RecordTypeId=accRecTypeId1;
            con.hed__WorkEmail__c='123@reva.edu.in';
            //con.AccountId=Acc2.id;
            con.Passport_Number__c='436646654656';
            con.Active_Semester__c =objTerm.id;
            con.Primary_Academic_Program__c = objProgPlan.hed__Account__c;
            con.Program_Batch__c = objProgPlan.Id;

            insert con; 
            
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
            
            hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',acc1.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            obj_Term.Term_Number__c = 1;
            Insert obj_Term;
            
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
            objUser.ContactId=con.id;                        
            insert objUser;
            
            hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                    Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                    hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                    Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
            system.debug('objProgen '+objProgen);
            objProgen.Requested_Program__c =  acc2.id;
            objProgen.Requested_School__c =acc5.Id;
            //objProgen.Program_Type__c = 'UG';
            //objProgen.Semester__c = obj_Term.Id;
            objProgen.SRN_Number__c = 'Srn1234';

            update  objProgen;             
        }
        system.runAs(objUser)
        {
            
            Test.startTest();
            system.runAs(adminUser){
                Account ac = [select id from account where name='Faculty of Engineering & Technology'  limit 1];
                contact con = [select id,school__c from contAct limit 1];
                //University Dep
                Account ac2 = [select id from account where name='University Dep'  limit 1];
                
                
                hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                        Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                        hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                        Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
                system.debug('objProgen '+objProgen);
                objProgen.Requested_Program__c =  ac.id;
                objProgen.Requested_School__c =ac2.Id;
                objProgen.Program_Type__c = 'UG';
                //update  objProgen; 
                
                Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
                hed__Course_Offering__c courseOff = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
                
                hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(Con.id, courseOff.Id);
                obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
                obj_Cour_Enroll.hed__Program_Enrollment__c = objProgen.id;
                obj_Cour_Enroll.hed__Course_Offering__c = courseOff.Id;
                obj_Cour_Enroll.hed__Contact__c=Con.id;
                Insert obj_Cour_Enroll;
                
                hed__Term__c  objTerm = [SELECT Id FROM hed__Term__c LIMIT 1 ];
                hed__Term_Grade__c resSmry = ASM_TestDataFactory.createResSummary(Con.id,objTerm.Id,courseOff.Id);
                Insert resSmry;
                
                hed__Term_Grade__c result = ASM_TestDataFactory.createResult(Con.id,objTerm.Id,obj_Cour_Enroll.Id,courseOff.Id);
                result.Result_Summary__c = resSmry.Id;
                result.hed__Result__c = 'Audit';
                
                insert result;
                studentBranchTransferRequestCls.WrapperClass wrpr = studentBranchTransferRequestCls.getBranchDetail(con.School__c, 'UG');
                
            }
                        
            studentBranchTransferRequestCls.WrapperClass wrpr = studentBranchTransferRequestCls.getRecordDetail();

            Test.stopTest();
        }
        
        
        
    }
     @isTest
    public static void stdntBranchMethodUGPG(){
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User objUser = new User();
        
        System.runAs(adminUser)
        {
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); 
            Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            Id accRecTypeId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(); 
            
            Account Acc2P=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology');
            Acc2P.RecordTypeId=accRecTypeId;
            Acc2P.Program_Type__c = 'PG';
            Acc2P.PG_Start_Date__c = system.today();
            Acc2P.PG_End_Date__c = system.today() +7;
            insert Acc2P;
            
            
            Account Acc2=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 3');
            Acc2.RecordTypeId=accRecTypeId;
            Acc2.ParentId = Acc2P.Id;
            Acc2.PG_Start_Date__c = system.today();
            Acc2.PG_End_Date__c = system.today();
            insert Acc2;
            
            Account Acc5=STOB_TestDataFactory.CreateAccount('University Dep');
            Acc5.RecordTypeId=accRecTypeId2;
            Acc5.UG_Start_date__c = system.today();
            Acc5.UG_End_Date__c = system.today();
            insert Acc5;
            
            //Faculty of Engineering & Technology
            Account Acc1=STOB_TestDataFactory.CreateAccount('REVA Engineering College');
            Acc1.RecordTypeId=accRecTypeId;
            Acc1.Intake__c=1;
            Acc1.Intake_Per_Section__c=8;
            Acc1.Number_of_Batches__c=2;
            Acc1.Number_of_Semesters__c=2;
            Acc1.Program_Alias__c='1234AVC';
            Acc1.Program_Alias__c='AVCFD';
            Acc1.Program_Type__c='PG';
            Acc1.ParentId = Acc2.Id;
            Acc1.PG_Start_Date__c = system.today();
            Acc1.PG_End_Date__c = system.today();
            insert Acc1;
            
            Account Acc3=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 2');
            Acc3.RecordTypeId=accRecTypeId;
            Acc3.ParentId = Acc2.Id;
            insert Acc3;
            
             Account Acc6=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 5');
            Acc6.RecordTypeId=accRecTypeId;
            Acc6.ParentId = Acc2P.Id;
            insert Acc6;
            
            
            
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
            
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',Acc1.id,termRtId); 
            objTerm.Term_Number__c = 1;
            objTerm.hed__Start_Date__c = system.today()-10;
            objterm.IA_1_Start_date__c = system.today()+11;
            objterm.hed__End_Date__c =  system.today()+12;
            
            insert objTerm;
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++){
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, Acc1.Id, cat));
            }
            
            Insert list_Crs;
            
            date dt = system.today();
            
            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objterm.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = objTerm.Id;
          
            insert obj_Cour_Off;
            
            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            objProgPlan.hed__Account__c = Acc1.Id;
            objProgPlan.hed__Start_Date__c = system.today();
            objProgPlan.hed__End_Date__c = system.today();
            insert objProgPlan;
            
            //SYSTEM.debug('objProgPlan IN TEST '+objProgPlan);
            //hed__Program_Plan__c
            
            Id accRecTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            contact con=new Contact();
            con.Lastname='Test';
            con.Enrollment_Type__c='Regular Entry';
            con.hed__Gender__c='Male';
            con.Application_Number__c='123';
            con.MobilePhone='9393949785';            
            con.AccountId =Acc1.id;
            con.School__c=Acc2.id;
            con.Nationality__c='Austrian';
            con.RecordTypeId=accRecTypeId1;
            con.hed__WorkEmail__c='123@reva.edu.in';
            //con.AccountId=Acc2.id;
            con.Passport_Number__c='436646654656';
            con.Active_Semester__c =objTerm.id;
            con.Primary_Academic_Program__c = objProgPlan.hed__Account__c;
            con.Program_Batch__c = objProgPlan.Id;
            
            
            insert con; 
            
           
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
            
            hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',acc1.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            obj_Term.Term_Number__c = 1;
            Insert obj_Term;
            
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
            objUser.ContactId=con.id;                        
            insert objUser;
            
            hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                    Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                    hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                    Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
            system.debug('objProgen '+objProgen);
            objProgen.Requested_Program__c =  acc2.id;
            objProgen.Requested_School__c =acc5.Id;
            //objProgen.Program_Type__c = 'UG';
            //objProgen.Semester__c = obj_Term.Id;
            objProgen.SRN_Number__c = 'Srn1234';
            
            update  objProgen;             
        }
        system.runAs(objUser)
        {
            
            Test.startTest();
            system.runAs(adminUser){
                Account ac = [select id from account where name='Faculty of Engineering & Technology'  limit 1];
                contact con = [select id from contAct limit 1];
                //University Dep
                Account ac2 = [select id from account where name='University Dep'  limit 1];
                
                
                hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                        Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                        hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                        Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
                system.debug('objProgen '+objProgen);
                objProgen.Requested_Program__c =  ac.id;
                objProgen.Requested_School__c =ac2.Id;
                objProgen.Program_Type__c = 'UG';
                //update  objProgen; 
                
                Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
                hed__Course_Offering__c courseOff = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
                
                hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(Con.id, courseOff.Id);
                obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
                obj_Cour_Enroll.hed__Program_Enrollment__c = objProgen.id;
                obj_Cour_Enroll.hed__Course_Offering__c = courseOff.Id;
                obj_Cour_Enroll.hed__Contact__c=Con.id;
                Insert obj_Cour_Enroll;
                
                hed__Term__c  objTerm = [SELECT Id FROM hed__Term__c LIMIT 1 ];
                hed__Term_Grade__c resSmry = ASM_TestDataFactory.createResSummary(Con.id,objTerm.Id,courseOff.Id);
                Insert resSmry;
                
                hed__Term_Grade__c result = ASM_TestDataFactory.createResult(Con.id,objTerm.Id,obj_Cour_Enroll.Id,courseOff.Id);
                result.Result_Summary__c = resSmry.Id;
                result.hed__Result__c = 'Audit';
                
                insert result;
                
            }
            
            studentBranchTransferRequestCls.WrapperClass wrpr = studentBranchTransferRequestCls.getRecordDetail();           
            
            Test.stopTest();
        }
        
        
        
    }
    @isTest
    public static void stdntBranchMethodWrapper(){
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User objUser = new User();
        
        System.runAs(adminUser)
        {
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); 
            Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            Id accRecTypeId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(); 
            
            Account Acc2P=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology');
            Acc2P.RecordTypeId=accRecTypeId;
            Acc2P.UG_Start_date__c = system.today();
            Acc2P.UG_End_Date__c = system.today();
            insert Acc2P;

            
            Account Acc2=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology');
            Acc2.RecordTypeId=accRecTypeId;
            Acc2.ParentId = Acc2P.Id;
            insert Acc2;
            
            Account Acc5=STOB_TestDataFactory.CreateAccount('University Dep');
            Acc5.RecordTypeId=accRecTypeId2;
            Acc5.UG_Start_date__c = system.today();
            Acc5.UG_End_Date__c = system.today();
            insert Acc5;
            
            //Faculty of Engineering & Technology
            Account Acc1=STOB_TestDataFactory.CreateAccount('REVA Engineering College');
            Acc1.RecordTypeId=accRecTypeId;
            Acc1.Intake__c=1;
            Acc1.Intake_Per_Section__c=8;
            Acc1.Number_of_Batches__c=2;
            Acc1.Number_of_Semesters__c=2;
            Acc1.Program_Alias__c='1234AVC';
            Acc1.Program_Alias__c='AVCFD';
            Acc1.Program_Type__c='UG';
            Acc1.ParentId = Acc2.Id;
            Acc1.UG_Start_date__c = system.today();
            Acc1.UG_End_Date__c = system.today();
            insert Acc1;
            
            Account Acc3=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 2');
            Acc3.RecordTypeId=accRecTypeId;
            Acc3.ParentId = Acc2.Id;
            insert Acc3;
            
             Account Acc6=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 5');
            Acc6.RecordTypeId=accRecTypeId;
            Acc6.ParentId = Acc2P.Id;
            insert Acc6;
            
               
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
            
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',Acc1.id,termRtId);
            objTerm.Term_Number__c = 1;
            objTerm.hed__Start_Date__c = system.today()-10;
            objterm.IA_1_Start_date__c = system.today()+11;
            insert objTerm;
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++){
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, Acc1.Id, cat));
            }
            Insert list_Crs;
            

            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objterm.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = objTerm.Id;
            insert obj_Cour_Off;

            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            objProgPlan.hed__Account__c = Acc1.Id;
            objProgPlan.hed__Start_Date__c = system.today();
            objProgPlan.hed__End_Date__c = system.today();
            insert objProgPlan;
            
            
            hed__Program_Plan__c  objProgPlan2 =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan2.Provisionally_Admitted_Students__c = 20;
            objProgPlan2.Intake__c =20;
            objProgPlan2.Intake_Per_Section__c=5;
            objProgPlan2.hed__Account__c = Acc2.Id;
            objProgPlan2.hed__Start_Date__c = system.today();
            objProgPlan2.hed__End_Date__c = system.today();
            insert objProgPlan2;
            SYSTEM.debug('objProgPlan IN TEST '+objProgPlan);
            //hed__Program_Plan__c
            
            Id accRecTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            contact con=new Contact();
            con.Lastname='Test';
            con.Enrollment_Type__c='Regular Entry';
            con.hed__Gender__c='Male';
            con.Application_Number__c='123';
            con.MobilePhone='9393949785';            
            con.AccountId =Acc1.id;
            con.School__c=Acc2.id;
            con.Nationality__c='Austrian';
            con.RecordTypeId=accRecTypeId1;
            con.hed__WorkEmail__c='123@reva.edu.in';
            //con.AccountId=Acc2.id;
            con.Passport_Number__c='436646654656';
            con.Active_Semester__c =objTerm.id;
            con.Primary_Academic_Program__c = objProgPlan.hed__Account__c;
            con.Program_Batch__c = objProgPlan.Id;

            insert con; 
            
            
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
            
            hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',acc1.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            obj_Term.Term_Number__c = 1;
            obj_Term.IA_1_Start_date__c = system.today()+10;
            obj_Term.hed__Start_Date__c = system.today();
            obj_Term.hed__End_Date__c =system.today();
            Insert obj_Term;
            
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
            objUser.ContactId=con.id;                        
            insert objUser;

        hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                        Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                        hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                        Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
                system.debug('objProgen '+objProgen);
                objProgen.Requested_Program__c =  acc2.id;
                objProgen.Requested_School__c =acc5.Id;
                //objProgen.Program_Type__c = 'UG';
                objProgen.Semester__c = obj_Term.Id;            
            	objProgen.hed__Start_Date__c = system.today();
            	objProgen.hed__End_Date__c = system.today();
               
                update  objProgen;             
        }
        system.runAs(objUser)
        {

            Test.startTest();
            system.runAs(adminUser){
                Account ac = [select id from account where name='Faculty of Engineering & Technology'  limit 1];
                contact con = [select id from contAct limit 1];
                //University Dep
                Account ac2 = [select id from account where name='University Dep'  limit 1];
                
                
                hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                        Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                        hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                        Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
                system.debug('objProgen '+objProgen);
                objProgen.Requested_Program__c =  ac.id;
                objProgen.Requested_School__c =ac2.Id;
                objProgen.Program_Type__c = 'UG';
                //update  objProgen; 
                
                Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
                hed__Course_Offering__c courseOff = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
                
                hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(Con.id, courseOff.Id);
                obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
                obj_Cour_Enroll.hed__Program_Enrollment__c = objProgen.id;
                obj_Cour_Enroll.hed__Course_Offering__c = courseOff.Id;
                obj_Cour_Enroll.hed__Contact__c=Con.id;
                Insert obj_Cour_Enroll;
                
                hed__Term__c  objTerm = [SELECT Id FROM hed__Term__c LIMIT 1 ];
                hed__Term_Grade__c resSmry = ASM_TestDataFactory.createResSummary(Con.id,objTerm.Id,courseOff.Id);
                Insert resSmry;
                  
            }

            studentBranchTransferRequestCls.WrapperClass wrpr = studentBranchTransferRequestCls.getRecordDetail();
            system.debug('wrpr 6'+wrpr);
             
            
            system.runAs(adminUser){
                studentBranchTransferRequestCls.getUpdateEnrollment(wrpr);
              
            }
            
            
            Test.stopTest();
        }
    }
    @isTest
    public static void stdntBranchMethodMorethen5(){
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND isActive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User objUser = new User();
        
        System.runAs(adminUser)
        {
            Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId(); 
            Id accRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            Id accRecTypeId3 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId(); 
            
            Account Acc2P=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology');
            Acc2P.RecordTypeId=accRecTypeId;
            Acc2P.UG_Start_date__c = system.today();
            Acc2P.UG_End_Date__c = system.today();
            insert Acc2P;

            
            Account Acc2=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology');
            Acc2.RecordTypeId=accRecTypeId;
            Acc2.ParentId = Acc2P.Id;
            insert Acc2;
            
            Account Acc5=STOB_TestDataFactory.CreateAccount('University Dep');
            Acc5.RecordTypeId=accRecTypeId2;
            Acc5.UG_Start_date__c = system.today();
            Acc5.UG_End_Date__c = system.today();
            insert Acc5;
            
            //Faculty of Engineering & Technology
            Account Acc1=STOB_TestDataFactory.CreateAccount('REVA Engineering College');
            Acc1.RecordTypeId=accRecTypeId;
            Acc1.Intake__c=1;
            Acc1.Intake_Per_Section__c=8;
            Acc1.Number_of_Batches__c=2;
            Acc1.Number_of_Semesters__c=2;
            Acc1.Program_Alias__c='1234AVC';
            Acc1.Program_Alias__c='AVCFD';
            Acc1.Program_Type__c='UG';
            Acc1.ParentId = Acc2.Id;
            Acc1.UG_Start_date__c = system.today();
            Acc1.UG_End_Date__c = system.today();
            insert Acc1;
            
            Account Acc3=STOB_TestDataFactory.CreateAccount('Faculty of Engineering & Technology 2');
            Acc3.RecordTypeId=accRecTypeId;
            Acc3.ParentId = Acc2.Id;
            insert Acc3;
               
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
            
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',Acc1.id,termRtId);
            objTerm.Term_Number__c = 1;
            objTerm.hed__Start_Date__c = system.today()-10;
            objterm.IA_1_Start_date__c = system.today()+11;
            insert objTerm;
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++){
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, Acc1.Id, cat));
            }
            Insert list_Crs;
            

            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objterm.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = objTerm.Id;
            insert obj_Cour_Off;

            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.Provisionally_Admitted_Students__c = 20;
            objProgPlan.Intake__c =20;
            objProgPlan.Intake_Per_Section__c=5;
            objProgPlan.hed__Account__c = Acc1.Id;
            objProgPlan.hed__Start_Date__c = system.today();
            objProgPlan.hed__End_Date__c = system.today();
            insert objProgPlan;
            
            SYSTEM.debug('objProgPlan IN TEST '+objProgPlan);
            //hed__Program_Plan__c
            
            Id accRecTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
            contact con=new Contact();
            con.Lastname='Test';
            con.Enrollment_Type__c='Regular Entry';
            con.hed__Gender__c='Male';
            con.Application_Number__c='123';
            con.MobilePhone='9393949785';            
            con.AccountId =Acc1.id;
            con.School__c=Acc2.id;
            con.Nationality__c='Austrian';
            con.RecordTypeId=accRecTypeId1;
            con.hed__WorkEmail__c='123@reva.edu.in';
            //con.AccountId=Acc2.id;
            con.Passport_Number__c='436646654656';
            con.Active_Semester__c =objTerm.id;
            con.Primary_Academic_Program__c = objProgPlan.hed__Account__c;
            con.Program_Batch__c = objProgPlan.Id;
              
            //con.sc
            
            insert con; 
            
            
            
            Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Semester').getRecordTypeId();
            
            hed__Term__c obj_Term = ASM_TestDataFactory.createTerm('TermName',acc1.Id, termRecTypeId);
            obj_Term.RecordTypeId = termRecTypeId;
            obj_Term.Term_Number__c = 1;
            obj_Term.IA_1_Start_date__c = system.today();
            obj_Term.hed__Start_Date__c = system.today();
            Insert obj_Term;
            
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
            objUser.ContactId=con.id;                        
            insert objUser;

        hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                        Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                        hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                        Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
                system.debug('objProgen '+objProgen);
                objProgen.Requested_Program__c =  acc2.id;
                objProgen.Requested_School__c =acc5.Id;
                //objProgen.Program_Type__c = 'UG';
                objProgen.Semester__c = obj_Term.Id;
                //objProgen.
                update  objProgen;             
        }
        system.runAs(objUser)
        {

            Test.startTest();
            system.runAs(adminUser){
                Account ac = [select id from account where name='Faculty of Engineering & Technology'  limit 1];
                contact con = [select id from contAct limit 1];
                //University Dep
                Account ac2 = [select id from account where name='University Dep'  limit 1];
                
                
                hed__Program_Enrollment__c objProgen = [SELECT id,Semester__c,Semester__r.Name,Branch_Transfer_Flag__c,Branch_Transfer_Status__c, 
                                                        Semester__r.Term_Number__c,Semester__r.hed__Start_Date__c,Semester__r.IA_1_Start_date__c, 
                                                        hed__Account__c,hed__Account__r.Name,Requested_School__c,Requested_School__r.Name,
                                                        Requested_Program__c,Requested_Program__r.Name FROM hed__Program_Enrollment__c limit 1];
                system.debug('objProgen '+objProgen);
                objProgen.Requested_Program__c =  ac.id;
                objProgen.Requested_School__c =ac2.Id;
                objProgen.Program_Type__c = 'UG';
                //update  objProgen; 
                
                Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
                hed__Course_Offering__c courseOff = [SELECT Id FROM hed__Course_Offering__c LIMIT 1];
                
                hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(Con.id, courseOff.Id);
                obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
                obj_Cour_Enroll.hed__Program_Enrollment__c = objProgen.id;
                obj_Cour_Enroll.hed__Course_Offering__c = courseOff.Id;
                obj_Cour_Enroll.hed__Contact__c=Con.id;
                Insert obj_Cour_Enroll;
                
                hed__Term__c  objTerm = [SELECT Id FROM hed__Term__c LIMIT 1 ];
                hed__Term_Grade__c resSmry = ASM_TestDataFactory.createResSummary(Con.id,objTerm.Id,courseOff.Id);
                Insert resSmry;
              
            }
            
            studentBranchTransferRequestCls.WrapperClass wrpr = studentBranchTransferRequestCls.getRecordDetail();

            Test.stopTest();
        }
    }
}