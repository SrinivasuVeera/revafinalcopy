@isTest
public class ASM_HallTicketCtrlTest 
{
    
    static testmethod void testsearchStudents(){
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        Contact con = new Contact();
        con.FirstName = 'suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = programbatch.Id;
        con.SRN_Number__c='SA001';
        con.Active__c=true;
        insert con;
        
        Test.startTest();
        ASM_HallTicketCtrl.searchStudents('suraj');
        Test.stopTest();
        
    }
    
    ///////////////////////////////////////////////////////////////
     static testmethod void testupdateContact(){
        Account acc = new Account(Name='TestAcc');
        insert acc;
        
        hed__Program_Plan__c ProgramBatch = new hed__Program_Plan__c();
        ProgramBatch.Name = 'TestProgramBatch';
        ProgramBatch.hed__Account__c = acc.Id;
        insert ProgramBatch;
        
        Contact con = new Contact();
        con.FirstName = 'suraj';
        con.LastName = 'Madala';
        con.Program_Batch__c = programbatch.Id;
        con.SRN_Number__c='SA001';
        con.Active__c=true;
        insert con;
        
        Test.startTest();
        ASM_HallTicketCtrl.updateContact(con.id,'testing for test class','true');
        Test.stopTest();
        
    }
    ///////////////////////////////////////////////////////////////
    
    static testmethod void Testmethod1()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
      //  UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
       // adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User newUser1 = new user();
        List<contact> createcon = new List<contact>();
        
        system.runAs(adminUser){    
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
             hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
            objProgPlan.hed__End_Date__c = system.today().addyears(+1);
            objProgPlan.hed__Account__c = objAcc.id;
            insert objProgPlan;
            
            ID RID=   [SELECT Id, Name, SObjectType FROM RecordType WHERE SObjectType = 'hed__Term__c' and Name='Semester'].Id;
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.Id,RID);
            objTerm.Term_Number__c = 2;
            objTerm.Program_Batch__c  = objProgPlan.id;
            insert objTerm;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            for(Integer i=1;i<=2;i++){
                contact objCon = new contact();
                objCon = ASM_TestDataFactory.createContact(i,objAcc.Id);
                objCon.MobilePhone ='9090909090';
                objCon.Aadhar_Card_Number__c ='098765435612';
                objCon.RecordTypeId = StudentRecId;
                objCon.AccountId = objAcc.Id;
                objcon.Application_Number__c = 'test123'+i;
                objcon.SRN_Number__c ='123'+i;
                objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
                objcon.Nationality__c ='Indian';
                objcon.Active_Semester__c=objTerm.Id;
                objcon.Active_Section__c = objTerm.Id;
                objcon.Exam_Approval__c = true;
                objcon.Date_of_Approval__c=System.today();
                objcon.Total_average_current_sem_attendance__c = 78;
                createcon.add(objcon);
            }
             insert createcon;
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = createcon[0].id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            
            Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            Account objAcc1 = ASM_TestDataFactory.createAcc(12);
            objAcc1.ParentId= objAcc.id;
            insert objAcc1;
            
            List<hed__Course__c> list_Crs = new List<hed__Course__c>();
            for(integer i=1;i<=3;i++){
                String cat = (i == 1) ? 'Hardcore Integrated Course' : (i == 2) ? 'Practical/Term Work' : '';
                list_Crs.add(ASM_TestDataFactory.CreateCourse(i, objAcc.Id, cat));
            }
            Insert list_Crs;
            
             hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan2');
            objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
            objProgPlan.hed__End_Date__c = system.today().addyears(+1);
            objProgPlan.hed__Account__c = objAcc.id;
            insert objProgPlan;
            
            string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Sections).getRecordTypeId();
            hed__Term__c objTerm = ASM_TestDataFactory.createTerm('test term',objAcc.Id,termRtId);
            objTerm.Term_Number__c = 2;
            objTerm.Program_Batch__c  = objProgPlan.id;
            insert objTerm;
                        
            hed__Term__c objTermParent = ASM_TestDataFactory.createTerm('test term',objAcc.id,termRtId);
            
            objTermParent.hed__Parent_Term__c = objTerm.id;
            insert objTermParent;
            
            hed__Program_Enrollment__c objProgenroll = ASM_TestDataFactory.createProgramEnrollment(createcon[0].Id,objProgPlan.id);
            objProgenroll.hed__Start_Date__c = system.today();
            objProgenroll.hed__End_Date__c = system.today();
            objProgenroll.Issue_Hall_Ticket__c=true;
            Insert objProgenroll;
            
            hed__Course_Offering__c obj_Cour_Off =ASM_TestDataFactory.createCourseOffering('Test Course', objTerm.Id, list_Crs[0].id);
            obj_Cour_Off.Category__c ='Hardcore Course'; 
            obj_Cour_Off.hed__Term__c = objTerm.Id;
            obj_Cour_Off.hed__Term__c = objTermParent.Id;
            insert obj_Cour_Off;
            
            Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get(Utility.CC_Stud_RecType).getRecordTypeId();
            
            hed__Course_Enrollment__c obj_Cour_Enroll = ASM_TestDataFactory.createCourseEnrollment(createcon[0].id, obj_Cour_Off.Id);
            obj_Cour_Enroll.RecordTypeId=enrollRecTypeId;
          //  obj_Cour_Enroll.Active_Connection__c = true;
            obj_Cour_Enroll.hed__Program_Enrollment__c = objProgEnroll.id;
            obj_Cour_Enroll.hed__Course_Offering__c = obj_Cour_Off.Id;
            obj_Cour_Enroll.hed__Contact__c= createcon[0].id;
            obj_Cour_Enroll.Total_Classes_Attended__c = 40.00;
            obj_Cour_Enroll.Total_Classes_Completed__c = 50.00;
            obj_Cour_Enroll.section__c = createcon[0].Active_Section__c;
            Insert obj_Cour_Enroll; 
            List<Student_Fee__c> sfList= new List<Student_Fee__c>();
            for(integer i=0 ;i<10;i++){
            Student_Fee__c sf= new Student_Fee__c();
                sf.name='test student';
            sf.Amount_Pending__c=40;
            sf.Due_Date__c = system.today()-5;
            sf.Fee_Year__c = '1st year';
            sf.Contact__c = createcon[0].id;
            sfList.add(sf);
            Student_Fee__c sf1= new Student_Fee__c();
                sf1.name='test student1';
            sf1.Amount_Pending__c=40;
            sf1.Due_Date__c = system.today()-5;
            sf1.Fee_Year__c = '1st year';
            sf1.Contact__c = createcon[1].id;
            sfList.add(sf1);
            }
            insert sfList;
            Test.startTest();
            ASM_HallTicketCtrl.GetStudentDetails();
            Test.stopTest();
        }
    }
    /////////////2nd Method//////////////////////////
    static testmethod void Testmethod2()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
      //  UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
      //  adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            hed__Term__c term = new hed__Term__c(
            Name = 'Fall 2024',
            hed__Start_Date__c = Date.today().addMonths(-1),
            hed__End_Date__c = Date.today().addMonths(5),
            IA_1_Start_date__c = Date.today().adddays(3),
            IA_1_End_date__c = Date.today(),
            IA_2_End_date__c = Date.today(),
            hed__Account__c = objAcc.Id,
                Term_Number__c = 2
        );
        insert term;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = ASM_TestDataFactory.createContact(2,objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            objcon.Active_Semester__c = term.Id;
            objCon.Checking_Eligibility_for_Exam__c = 'Eligible';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objcon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            Account objAcc1 = ASM_TestDataFactory.createAcc(12);
            objAcc1.ParentId= objAcc.id;
            insert objAcc1;
            
            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
            objProgPlan.hed__End_Date__c = system.today().addyears(+1);
            objProgPlan.hed__Account__c = objAcc1.id;
            insert objProgPlan;
            
            hed__Program_Enrollment__c objProgenroll = ASM_TestDataFactory.createProgramEnrollment(objCon.Id,objProgPlan.id);
            objProgenroll.hed__Start_Date__c = system.today();
            objProgenroll.Issue_Hall_Ticket__c = true;
            objProgenroll.hed__End_Date__c = system.today();
            Insert objProgenroll;
            
            Test.startTest();
            ASM_HallTicketCtrl.GetStudentDetails();
            Test.stopTest();
        }
    }
    /////////////////////////3rd Method//////////////////////////////////////
    static testmethod void Testmethod3()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
      //  UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
     //   adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = ASM_TestDataFactory.createContact(2,objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            objCon.Checking_Eligibility_for_Exam__c = 'Eligible';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objcon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            Account objAcc1 = ASM_TestDataFactory.createAcc(12);
            objAcc1.ParentId= objAcc.id;
            insert objAcc1;
            
            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
            objProgPlan.hed__End_Date__c = system.today().addyears(+1);
            objProgPlan.hed__Account__c = objAcc1.id;
            insert objProgPlan;
            
            hed__Program_Enrollment__c objProgenroll = ASM_TestDataFactory.createProgramEnrollment(objCon.Id,objProgPlan.id);
            objProgenroll.hed__Start_Date__c = system.today();
            objProgenroll.SRN_Number__c = objCon.SRN_Number__c;
            //objProgenroll.SRN_Number__c = 'RU10001';	
            objProgenroll.hed__End_Date__c = system.today();
            Insert objProgenroll;
            
            ASM_MockCallout TestMock = new ASM_MockCallout(200,'{"status":"success","data":{"resdata":[{"url":"SRN0001"}]}}','Failed');
            Test.setMock(HttpCalloutMock.class,TestMock);
            Test.startTest();
            ASM_HallTicketCtrl.GetStudentDetails();
            ASM_HallTicketCtrl.DowloadHallTicket(objProgenroll.SRN_Number__c);
            Test.stopTest();
        }
    }
    ////////////////////////////////////////////////////4th Method/////////////////////////////////////////////
    static testmethod void Testmethod4()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
     //   UserRole userrole = [Select Id, DeveloperName From UserRole  Limit 1];
        string userId = userinfo.getUserId();
        User adminUser = [Select Id, UserRoleId From User Where id =:userId  Limit 1];
     //   adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        User newUser1 = new user();
        contact objCon = new contact();
        
        system.runAs(adminUser){    
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.Recordtypeid = HouseholdRecId;
            Insert objAcc;
            
            string StudentRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Utility.Contact_RecType_Student).getRecordTypeId();
            objCon = ASM_TestDataFactory.createContact(2,objAcc.Id);
            objCon.MobilePhone ='9090909090';
            objCon.Aadhar_Card_Number__c ='098765435612';
            objCon.RecordTypeId = StudentRecId;
            objCon.AccountId = objAcc.Id;
            objcon.Application_Number__c = 'test123';
            objcon.SRN_Number__c ='123';
            objcon.hed__WorkEmail__c  = 'test123@reva.edu.in';
            objcon.Nationality__c ='Indian';
            objCon.Checking_Eligibility_for_Exam__c = 'Eligible';
            Insert objCon; 
            
            Profile p = [select Id,name from Profile where Name ='Student Portal Profile' limit 1];
            system.debug('p '+p);
            newUser1 = new User(
                profileId = p.Id,
                username = 'newUser@epeople.com',
                email = 'pb@f.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = objcon.id
                //   UserRoleId = userrole.Id
            );
            insert newUser1;
        }
        system.runAs(newUser1){        
            Fee_Payment_Criteria__c objFeeCriteria = ASM_TestDataFactory.createFeePaymentCriteria1('Full Payment');
            objFeeCriteria.Merchant_ID_Billdesk__c ='MIDB232323';
            objFeeCriteria.Merchant_ID_Eazypay__c ='MIDE121212';
            objFeeCriteria.Merchant_ID_Paytm__c ='MIDP343434';
            objFeeCriteria.Merchant_ID_Razorpay__c='MIDR4454545';
            Insert objFeeCriteria;
            
            Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            
            Account objAcc = ASM_TestDataFactory.createAcc(1);
            objAcc.RecordTypeId = AccountRecTypeId;
            insert objAcc;
            
            Account objAcc1 = ASM_TestDataFactory.createAcc(12);
            objAcc1.ParentId= objAcc.id;
            insert objAcc1;
            
            hed__Program_Plan__c  objProgPlan =  ASM_TestDataFactory.createProgramPlan('Test Program Plan');
            objProgPlan.hed__Start_Date__c = system.today().addyears(-1);
            objProgPlan.hed__End_Date__c = system.today().addyears(+1);
            objProgPlan.hed__Account__c = objAcc1.id;
            insert objProgPlan;
            
            hed__Program_Enrollment__c objProgenroll = ASM_TestDataFactory.createProgramEnrollment(objCon.Id,objProgPlan.id);
            objProgenroll.hed__Start_Date__c = system.today();
            //objProgenroll.SRN_Number__c = 'RU10001';
            objProgenroll.SRN_Number__c = objCon.SRN_Number__c;
            objProgenroll.hed__End_Date__c = system.today();
            Insert objProgenroll;
            
            ASM_MockCallout url = new ASM_MockCallout(500,'{"status":"success","data":{"resdata":[{"url":"SRN0001"}]}}','Failed');
            Test.setMock(HttpCalloutMock.class,url);
            Test.startTest();
            ASM_HallTicketCtrl.GetStudentDetails();
            ASM_HallTicketCtrl.DowloadHallTicket(objProgenroll.SRN_Number__c);
            Test.stopTest();
        }
    }
}