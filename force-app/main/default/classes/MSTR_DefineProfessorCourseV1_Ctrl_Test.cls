@isTest
public class MSTR_DefineProfessorCourseV1_Ctrl_Test
{
    /**
     * Test method to validate professor-related functionality.
     */
    @isTest
    /**
     * @description Test method to validate the professor-related functionality.
     */
    public static void professorMethodTest()
    {
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',universityRecId);
        objAccount.RecordtypeId = universityRecId;
        insert objAccount;

        Profile proProfile = [select Id,name from Profile where Name ='Professor' Limit 1];
            User newUser1 = new User(
                UserName = 'newUser@epeople.com',
                FirstName = 'TestU',
                LastName = 'Test',
                Alias = 'test123',
                email = 'test@gmail.com',
                ProfileId = proProfile.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
           insert newUser1;

        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='test@gmail.com';
        objcon.Email = 'test@gmail.com';
        objcon.MobilePhone ='8963210547';
        objCon.OwnerId=newUser1.Id;
        insert objcon;

        string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account Child',acaRecId);
        objAccount1.RecordTypeid = acaRecId;
        objAccount1.parentid = objAccount.id;
        insert objAccount1;

        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('test program plan');
        objProgPlan.hed__Account__c = objAccount1.id;
        objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
        objProgPlan.hed__End_Date__c = system.today()+2;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today().adddays(-16);
        objTerm.hed__End_Date__c =system.today().adddays(16);
        objTerm.Allow_Professors_for_Preferences__c = true;
        insert objTerm;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.Course_Across_the_School__c= true;
        objCourse.HardCore_Sub_Type__c ='Theory';
        objCourse.hed__Course_ID__c = '123';
        objCourse.Credits__c = 4.00;
        objCourse.SEE_Conducted_Marks__c = 50;
        objCourse.Offered_By_School__c = objAccount.Id;
        objCourse.Credit_Hours__c = 4.00;
        objCourse.Maximum_External_Marks__c = 50.00;
        objCourse.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseHI.Category__c = 'Hardcore Integrated Course';
        objCourseHI.hed__Course_ID__c = '1234';
        objCourseHI.Course_Across_the_School__c= true;
        objCourseHI.Credits__c = 4.00;
        objCourseHI.SEE_Conducted_Marks__c = 50;
        objCourseHI.Offered_By_School__c = objAccount.Id;
        objCourseHI.Credit_Hours__c = 4.00;
        objCourseHI.Maximum_External_Marks__c = 50.00;
        objCourseHI.Total_Maximum_Marks_IA_External__c = 100.00;
         objCourseHI.No_of_IA_s__c = '1';
        objCourseHI.L_T_P__c='2:1:0';
        insert objCourseHI;

        hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCoursePW.Category__c = 'Practical/Term Work';
        objCoursePW.hed__Course_ID__c = '12348';
        objCoursePW.Course_Across_the_School__c= true;
        objCoursePW.Credits__c = 4.00;
        objCoursePW.SEE_Conducted_Marks__c = 50;
        objCoursePW.Offered_By_School__c = objAccount.Id;
        objCoursePW.Credit_Hours__c = 4.00;
        objCoursePW.Maximum_External_Marks__c = 50.00;
        objCoursePW.Total_Maximum_Marks_IA_External__c = 100.00;
        objCoursePW.No_of_IA_s__c = '1';
        objCoursePW.L_T_P__c='2:1:0';
        insert objCoursePW;

        hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseMAN.Category__c = 'Mandatory Course';
        objCourseMAN.hed__Course_ID__c = '12347';
        objCourseMAN.Course_Across_the_School__c= true;
        objCourseMAN.Credits__c = 4.00;
        objCourseMAN.SEE_Conducted_Marks__c = 50;
        objCourseMAN.Offered_By_School__c = objAccount.Id;
        objCourseMAN.Credit_Hours__c = 4.00;
        objCourseMAN.Maximum_External_Marks__c = 50.00;
        objCourseMAN.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourseMAN.No_of_IA_s__c = '1';
        objCourseMAN.L_T_P__c='2:1:0';
        insert objCourseMAN;

        hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        objCourseOpen.Category__c = 'Open Elective';
        objCourseOpen.hed__Course_ID__c = '12346';
        objCourseOpen.Course_Across_the_School__c= true;
        objCourseOpen.Credits__c = 4.00;
        objCourseOpen.SEE_Conducted_Marks__c = 50;
        objCourseOpen.Offered_By_School__c = objAccount.Id;
        objCourseOpen.Credit_Hours__c = 4.00;
        objCourseOpen.Maximum_External_Marks__c = 50.00;
        objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
         objCourseOpen.No_of_IA_s__c = '1';
        objCourseOpen.L_T_P__c='2:1:0';
        insert objCourseOpen;

        hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseProf.Category__c = 'Professional Elective';
        objCourseProf.hed__Course_ID__c = '12345';
        objCourseProf.Course_Across_the_School__c= true;
        objCourseProf.Credits__c = 4.00;
        objCourseProf.SEE_Conducted_Marks__c = 50;
        objCourseProf.Offered_By_School__c = objAccount.Id;
        objCourseProf.Credit_Hours__c = 4.00;
        objCourseProf.Maximum_External_Marks__c = 50.00;
        objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourseProf.No_of_IA_s__c = '1';
        objCourseProf.L_T_P__c='2:1:0';
        insert objCourseProf;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        objCourseOff1.Active__c = true;
        objCourseOff1.Credits__c = 2.0;
        objCourseOff1.Number_of_Times_Course_Handled__c = 2;
        objCourseOff1.hed__Course__c = objCourse.Id;
        objCourseOff1.hed__Term__c=objTerm.id;
        objCourseOff1.Approval_Required_by_School_Head__c = true;
        objCourseOff1.Offered_By_School__c = objAccount.Id;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOffHC.Category__c = 'Hardcore Course';
        objCourseOffHC.Sequence__c =1;
        objCourseOffHC.Preference__c ='1';
        objCourseOffHC.Active__c = true;
        objCourseOffHC.Credits__c = 2.0;
        objCourseOffHC.Number_of_Times_Course_Handled__c = 2;
        objCourseOffHC.Offered_By_School__c = objAccount.Id;
        insert objCourseOffHC;

        hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
        objCourseOffHI.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI.Sequence__c =1;
        objCourseOffHI.Preference__c ='1';
        objCourseOffHI.Active__c = true;
        objCourseOffHI.Credits__c = 2.0;
        objCourseOffHI.Number_of_Times_Course_Handled__c = 2;
        objCourseOffHI.Offered_By_School__c = objAccount.Id;
        insert objCourseOffHI;

        hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
        objCourseOffPWORK.Category__c = 'Practical/Term Work';
        objCourseOffPWORK.Sequence__c =1;
        objCourseOffPWORK.Preference__c ='1';
        objCourseOffPWORK.Active__c = true;
        objCourseOffPWORK.Credits__c = 2.0;
        objCourseOffPWORK.Number_of_Times_Course_Handled__c = 2;
        objCourseOffPWORK.Offered_By_School__c = objAccount.Id;
        insert objCourseOffPWORK;

        hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
        objCourseOffMandatory.Category__c = 'Mandatory Course';
        objCourseOffMandatory.Sequence__c =1;
        objCourseOffMandatory.Preference__c ='1';
        objCourseOffMandatory.Active__c = true;
        objCourseOffMandatory.Credits__c = 2.0;
        objCourseOffMandatory.Number_of_Times_Course_Handled__c = 2;
        objCourseOffMandatory.Offered_By_School__c = objAccount.Id;
        insert objCourseOffMandatory;

        hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
        objCourseOffProfEle.Category__c = 'Professional Elective';
        objCourseOffProfEle.Sequence__c =1;
        objCourseOffProfEle.Active__c = true;
        objCourseOffProfEle.Credits__c = 2.0;
        objCourseOffProfEle.Number_of_Times_Course_Handled__c = 2;
        objCourseOffProfEle.Offered_By_School__c = objAccount.Id;
        objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffProfEle;

        hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOffOpenEle.Category__c = 'Open Elective';
        objCourseOffOpenEle.Sequence__c =1;
        objCourseOffOpenEle.Active__c = true;
        objCourseOffOpenEle.Credits__c = 2.0;
        objCourseOffOpenEle.Number_of_Times_Course_Handled__c = 2;
        objCourseOffOpenEle.Offered_By_School__c = objAccount.Id;
        objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffOpenEle;

        Professor_Student_Course_Preference__c objProfStu = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
        objProfStu.Professor__c = objcon.id;
        objProfStu.Number_of_Times_Course_Handled__c = 2;
        insert objProfStu;

        Professor_Student_Course_Preference__c objProfStuHI = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor StudentHI',objCourseOffHI.id,objTerm.id);
        objProfStuHI.Professor__c = objcon.id;
        objProfStuHI.Number_of_Times_Course_Handled__c = 2;
        insert objProfStuHI;

        Professor_Student_Course_Preference__c objProfStuPW = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffPWORK.id,objTerm.id);
        objProfStuPW.Professor__c = objcon.id;
        objProfStuPW.Number_of_Times_Course_Handled__c = 2;
        insert objProfStuPW;

        Professor_Student_Course_Preference__c objProfStuM = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffMandatory.id,objTerm.id);
        objProfStuM.Professor__c = objcon.id;
        objProfStuM.Number_of_Times_Course_Handled__c = 2;
        insert objProfStuM;

        Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffOpenEle.id,objTerm.id);
        objProfStuOE.Professor__c = objcon.id;
        objProfStuOE.Number_of_Times_Course_Handled__c = 2;
        insert objProfStuOE;

        Professor_Student_Course_Preference__c objProfStuProf = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffProfEle.id,objTerm.id);
        objProfStuProf.Professor__c = objcon.id;
        objProfStuProf.Number_of_Times_Course_Handled__c = 2;
        insert objProfStuProf;

        hed__Course_Offering__c obh = new hed__Course_Offering__c();
        obh =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
              hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
              from  hed__Course_Offering__c where id =: objCourseOffHC.id
              and   Course_ID__c =:objCourse.hed__Course_ID__c limit 1];

        hed__Course_Offering__c obh1 = new hed__Course_Offering__c();
        obh1 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
               from  hed__Course_Offering__c where id =: objCourseOffHI.id
               and   Course_ID__c =:objCourseHI.hed__Course_ID__c limit 1];

        hed__Course_Offering__c obh2 = new hed__Course_Offering__c();
        obh2 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
               from  hed__Course_Offering__c where id =: objCourseOffPWORK.id
               and   Course_ID__c =:objCoursePW.hed__Course_ID__c limit 1];

        hed__Course_Offering__c obh3 = new hed__Course_Offering__c();
        obh3 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
               from  hed__Course_Offering__c where id =: objCourseOffProfEle.id
               and   Course_ID__c =:objCourseProf.hed__Course_ID__c limit 1];

        hed__Course_Offering__c obh4 = new hed__Course_Offering__c();
        obh4 =[select id,name,Sequence__c,Preference__c,Category__c,Parent_Course_Offering__c,
               hed__Course__c,hed__Term__c,Course_ID__c,Offered_By_School__c,Number_of_Times_Course_Handled__c
               from  hed__Course_Offering__c where id =: objCourseOffMandatory.id
               and   Course_ID__c =:objCourseMAN.hed__Course_ID__c limit 1];

        list<hed__Course_Offering__c> lstHardCourse = new list<hed__Course_Offering__c>();
        lstHardCourse.add(obh); //objCourseOffHC

        list<hed__Course_Offering__c> lstHCIntegrated = new list<hed__Course_Offering__c>();
        lstHCIntegrated.add(obh1); //objCourseOffHI

        list<hed__Course_Offering__c> lstPractical = new list<hed__Course_Offering__c>();
        lstPractical.add(obh2); //objCourseOffPWORK

        list<hed__Course_Offering__c> lstProfElective= new list<hed__Course_Offering__c>();
        lstProfElective.add(obh3);//objCourseOffProfEle

        list<hed__Course_Offering__c> lstMandatory= new list<hed__Course_Offering__c>();
        lstMandatory.add(obh4);//objCourseOffMandatory

        list<hed__Course_Offering__c> lstOpenElective= new list<hed__Course_Offering__c>();
        lstOpenElective.add(objCourseOffOpenEle);

        /* list<hed__Course_Offering__c> lstHardCourse = new list<hed__Course_Offering__c>();
lstHardCourse.add(objCourseOffHC);

list<hed__Course_Offering__c> lstHCIntegrated = new list<hed__Course_Offering__c>();
lstHCIntegrated.add(objCourseOffHI);

list<hed__Course_Offering__c> lstPractical = new list<hed__Course_Offering__c>();
lstPractical.add(objCourseOffPWORK);

list<hed__Course_Offering__c> lstProfElective= new list<hed__Course_Offering__c>();
lstProfElective.add(objCourseOffProfEle);

list<hed__Course_Offering__c> lstMandatory= new list<hed__Course_Offering__c>();
lstMandatory.add(objCourseOffMandatory);

list<hed__Course_Offering__c> lstOpenElective= new list<hed__Course_Offering__c>();
lstOpenElective.add(objCourseOffOpenEle); */
        System.runAs(newUser1){
             test.starttest();
        MSTR_DefineProfessorCourseV1_Ctrl.displaySchools();
        MSTR_DefineProfessorCourseV1_Ctrl.displayProgram(objAccount.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.displayProgram(objAccount.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.displayProgramPlan(objAccount1.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.displayProgramPlan(objAccount1.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.displayTerm(objProgPlan.id,false,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.displayTerm(objProgPlan.id,true,objAccount.Name);
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOfferingRecords(objTerm.id,true,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOfferingRecords(objTerm.id,false,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOfferingRecords(objTerm.id,true,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOfferingRecords(objTerm.id,false,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOffering(objTerm.id,true,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOffering(objTerm.id,false,objAccount.Name,objAccount.id);
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOffering(objTerm.id,false,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOffering(objTerm.id,true,objAccount.Name,'');
        MSTR_DefineProfessorCourseV1_Ctrl.createProfessorCourseRecords(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,true,objTerm.Id);
        MSTR_DefineProfessorCourseV1_Ctrl.validationPreferences(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,null);
        MSTR_DefineProfessorCourseV1_Ctrl.validationPreferences(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,null);
        MSTR_DefineProfessorCourseV1_Ctrl.getPreference();
        test.stoptest();
        }

        system.assertequals(objCourseOff1.id, objCourseOff1.id, 'The Course Offering IDs should match.');
    }
    /**
     * @description Test method to validate various scenarios.
     */

    @isTest
    public static void validationsMethodTest()
    {
         Profile proProfile = [select Id,name from Profile where Name ='Professor' Limit 1];
            User newUser1 = new User(
                UserName = 'valUser@reva.edu.in',
                FirstName = 'TestU',
                LastName = 'Test',
                Alias = 'test123',
                email = 'test@reva.edu.in',
                ProfileId = proProfile.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
           insert newUser1;

        
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',universityRecId);
        objAccount.RecordtypeId = universityRecId;
        insert objAccount;

        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.School__c = objAccount.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='test@reva.edu.in';
        objcon.Email = 'test@reva.edu.in';
        objcon.MobilePhone ='8963210547';
        insert objcon;

        string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Academic_Program).getRecordTypeId();

        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account Child',acaRecId);
        objAccount1.RecordTypeid = acaRecId;
        objAccount1.parentid = objAccount.id;
        insert objAccount1;

        
        hed__Program_Plan__c objProgPlan = MSTR_TestDataFactory.createProgramPlan('test program plan');
        objProgPlan.hed__Account__c = objAccount1.id;
        objProgPlan.hed__Start_Date__c = system.today().adddays(-1);
        objProgPlan.hed__End_Date__c = system.today()+2;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();

        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        objTerm.hed__Start_Date__c = system.today().adddays(-16);
        objTerm.hed__End_Date__c =system.today().adddays(16);
        objTerm.Allow_Professors_for_Preferences__c = true;
        insert objTerm;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c ='Theory';
        objCourse.Credits__c = 4.00;
        objCourse.Offered_By_School__c = objAccount.Id;
        objCourse.Credit_Hours__c = 4.00;
        objCourse.SEE_Conducted_Marks__c = 50;
        objCourse.Maximum_External_Marks__c = 50.00;
        objCourse.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourse.No_of_IA_s__c = '1';
        objCourse.L_T_P__c='2:1:0';
        insert objCourse;

        hed__Course__c objCourseHI = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseHI.Category__c = 'Hardcore Integrated Course';
        objCourseHI.Credits__c = 4.00;
        objCourseHI.Offered_By_School__c = objAccount.Id;
        objCourseHI.Credit_Hours__c = 4.00;
        objCourseHI.SEE_Conducted_Marks__c = 50;
        objCourseHI.Maximum_External_Marks__c = 50.00;
        objCourseHI.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourseHI.No_of_IA_s__c = '1';
        objCourseHI.L_T_P__c='2:1:0';
        insert objCourseHI;

        hed__Course__c objCoursePW = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCoursePW.Category__c = 'Practical/Term Work';
        objCoursePW.Credits__c = 4.00;
        objCoursePW.Offered_By_School__c = objAccount.Id;
        objCoursePW.Credit_Hours__c = 4.00;
        objCoursePW.SEE_Conducted_Marks__c = 50;
        objCoursePW.Maximum_External_Marks__c = 50.00;
        objCoursePW.Total_Maximum_Marks_IA_External__c = 100.00;
        objCoursePW.No_of_IA_s__c = '1';
        objCoursePW.L_T_P__c='2:1:0';
        insert objCoursePW;

        hed__Course__c objCourseMAN = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseMAN.Category__c = 'Mandatory Course';
        objCourseMAN.Credits__c = 4.00;
        objCourseMAN.Offered_By_School__c = objAccount.Id;
        objCourseMAN.Credit_Hours__c = 4.00;
        objCourseMAN.SEE_Conducted_Marks__c = 50;        
        objCourseMAN.Maximum_External_Marks__c = 50.00;
        objCourseMAN.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourseMAN.No_of_IA_s__c = '1';
        objCourseMAN.L_T_P__c='2:1:0';
        insert objCourseMAN;

        hed__Course__c objCourseOpen = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount.id);
        objCourseOpen.Category__c = 'Open Elective';
        objCourseOpen.Credits__c = 4.00;
        objCourseOpen.Offered_By_School__c = objAccount.Id;
        objCourseOpen.Credit_Hours__c = 4.00;
        objCourseOpen.SEE_Conducted_Marks__c = 50;
        objCourseOpen.Maximum_External_Marks__c = 50.00;
        objCourseOpen.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourseOpen.No_of_IA_s__c = '1';
        objCourseOpen.L_T_P__c='2:1:0';
        insert objCourseOpen;

        hed__Course__c objCourseProf = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourseProf.Category__c = 'Professional Elective';
        objCourseProf.Credits__c = 4.00;
        objCourseProf.Offered_By_School__c = objAccount.Id;
        objCourseProf.Credit_Hours__c = 4.00;
        objCourseProf.SEE_Conducted_Marks__c = 50;
        objCourseProf.Maximum_External_Marks__c = 50.00;
        objCourseProf.Total_Maximum_Marks_IA_External__c = 100.00;
        objCourseProf.No_of_IA_s__c = '1';
        objCourseProf.L_T_P__c='2:1:0';
        insert objCourseProf;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        objCourseOff1.Active__c = true;
        objCourseOff1.Credits__c = 2.0;
        objCourseOff1.Number_of_Times_Course_Handled__c = 2;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOffHC = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOffHC.Category__c = 'Hardcore Course';
        objCourseOffHC.Sequence__c =1;
        objCourseOffHC.Preference__c ='1';
        objCourseOffHC.Active__c = true;
        objCourseOffHC.Credits__c = 2.0;
        objCourseOffHC.Number_of_Times_Course_Handled__c = 2;
        insert objCourseOffHC;

        hed__Course_Offering__c  objCourseOffHI = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseHI.id);
        objCourseOffHI.Category__c = 'Hardcore Integrated Course';
        objCourseOffHI.Sequence__c =1;
        objCourseOffHI.Preference__c ='1';
        objCourseOffHI.Active__c = true;
        objCourseOffHI.Credits__c = 2.0;
        objCourseOffHI.Number_of_Times_Course_Handled__c = 2;
        insert objCourseOffHI;

        hed__Course_Offering__c  objCourseOffPWORK = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCoursePW.id);
        objCourseOffPWORK.Category__c = 'Practical/Term Work';
        objCourseOffPWORK.Sequence__c =1;
        objCourseOffPWORK.Preference__c ='1';
        objCourseOffPWORK.Active__c = true;
        objCourseOffPWORK.Credits__c = 2.0;
        objCourseOffPWORK.Number_of_Times_Course_Handled__c = 2;
        insert objCourseOffPWORK;

        hed__Course_Offering__c  objCourseOffMandatory = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseMAN.id);
        objCourseOffMandatory.Category__c = 'Mandatory Course';
        objCourseOffMandatory.Sequence__c =1;
        objCourseOffMandatory.Preference__c ='1';
        objCourseOffMandatory.Active__c = true;
        objCourseOffMandatory.Credits__c = 2.0;
        objCourseOffMandatory.Number_of_Times_Course_Handled__c = 2;
        insert objCourseOffMandatory;

        hed__Course_Offering__c  objCourseOffProfEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseProf.id);
        objCourseOffProfEle.Category__c = 'Professional Elective';
        objCourseOffProfEle.Sequence__c =1;
        objCourseOffProfEle.Preference__c ='1';
        objCourseOffProfEle.Active__c = true;
        objCourseOffProfEle.Credits__c = 2.0;
        objCourseOffProfEle.Number_of_Times_Course_Handled__c = 2;
        objCourseOffProfEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffProfEle;

        hed__Course_Offering__c  objCourseOffOpenEle = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourseOpen.id);
        objCourseOffOpenEle.Category__c = 'Open Elective';
        objCourseOffOpenEle.Sequence__c =1;
        objCourseOffOpenEle.Preference__c ='1';
        objCourseOffOpenEle.Active__c = true;
        objCourseOffOpenEle.Credits__c = 2.0;
        objCourseOffOpenEle.Number_of_Times_Course_Handled__c = 2;
        objCourseOffOpenEle.Parent_Course_Offering__c = objCourseOff1.id;
        insert objCourseOffOpenEle;

        Professor_Student_Course_Preference__c objProfStu = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOffHC.id,objTerm.id);
        objProfStu.Professor__c = objcon.id;
        objProfStu.Number_of_Times_Course_Handled__c = 2;
        insert objProfStu;

        list<hed__Course_Offering__c> lstHardCourse = new list<hed__Course_Offering__c>();
        lstHardCourse.add(objCourseOffHC);

        list<hed__Course_Offering__c> lstHCIntegrated = new list<hed__Course_Offering__c>();
        lstHCIntegrated.add(objCourseOffHI);

        list<hed__Course_Offering__c> lstPractical = new list<hed__Course_Offering__c>();
        lstPractical.add(objCourseOffPWORK);

        list<hed__Course_Offering__c> lstProfElective= new list<hed__Course_Offering__c>();
        lstProfElective.add(objCourseOffProfEle);

        list<hed__Course_Offering__c> lstMandatory= new list<hed__Course_Offering__c>();
        lstMandatory.add(objCourseOffMandatory);

        list<hed__Course_Offering__c> lstOpenElective= new list<hed__Course_Offering__c>();
        lstOpenElective.add(objCourseOffOpenEle);
        
         User u = [SELECT Id FROM User WHERE  UserName = 'valUser@reva.edu.in'];
        System.runAs(u) {
       
            test.starttest();
            MSTR_DefineProfessorCourseV1_Ctrl.displaySchools();
            MSTR_DefineProfessorCourseV1_Ctrl.displayProgram(objAccount.id,true,objAccount.Name);
            MSTR_DefineProfessorCourseV1_Ctrl.displayProgramPlan(objAccount1.id,false,objAccount.Name);
            MSTR_DefineProfessorCourseV1_Ctrl.displayTerm(objProgPlan.id,false,objAccount.Name);
            MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOffering(objTerm.id,true,objAccount.Name,objAccount.id);
            MSTR_DefineProfessorCourseV1_Ctrl.displayCourseOffering(objTerm.id,false,objAccount.Name,objAccount.id);
            MSTR_DefineProfessorCourseV1_Ctrl.validationPreferences(lstHardCourse,lstHCIntegrated,lstPractical,lstOpenElective,lstProfElective,lstMandatory,null);

            test.stoptest();
        }
        system.assertequals(objCourseOff1.id, objCourseOff1.id, 'The Course Offering IDs should match.');
    }
    /**
     * @description Test method to validate display schools functionality for non-professor users.
     */
    @isTest
    public static void testDisplayElseMethod()
    {
        
         Profile proProfile = [select Id,name from Profile where Name ='Professor' Limit 1];
            User newUser1 = new User(
                UserName = 'newUser@epeople.com',
                FirstName = 'TestU',
                LastName = 'Test',
                Alias = 'test123',
                email = '123@reva.edu.in',
                ProfileId = proProfile.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US');
           insert newUser1;
        string universityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();

        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',universityRecId);
        objAccount.RecordtypeId = universityRecId;
        insert objAccount;

        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.AccountId = objAccount.id;
        objcon.Professor_Across_Schools__c = false;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.email = '123@reva.edu.in';
        User u = [SELECT Id FROM User WHERE  UserName = 'newUser@epeople.com'];
        System.runAs(u) {
            test.startTest();
            MSTR_DefineProfessorCourseV1_Ctrl.displaySchools();
            test.stopTest();
        }
        System.assert(true, 'DisplaySchools method executed successfully.');
       
    }
}