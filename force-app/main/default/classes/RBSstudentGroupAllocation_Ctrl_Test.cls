@isTest
public class RBSstudentGroupAllocation_Ctrl_Test {
    @isTest
    public static Void groupAllocationMethod()
    {
        string acaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId1 );
        objAccount.RecordTypeid = acaRecId1;
        insert objAccount;

        string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId);
        objAccount1.RecordTypeid = acaRecId;
        insert objAccount1;

        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.Accountid = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c=' Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = contactRecTypeId;
        insert objcon;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount1.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id;
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll;

        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        Student_Semester_Mapping__c objStudSem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        objStudSem.RecordTypeId= recordTypeName;
        objStudSem.Active__c = true;
        objStudSem.Program_Enrollment__c= objProgEnroll.id;
        objStudSem.Start_Date__c = system.today();
        objStudSem.End_Date__c = system.today();
        objStudSem.Student_Group__c = objTerm.id;
        insert objStudSem;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c = 'Theory';
        objCourse.Credits__c=4;
        objCourse.Offered_By_School__c=objAccount.Id;
        objCourse.Credit_Hours__c=11;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 30;
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Open Elective';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        objCourseOff.Active__c =true;
        objCourseOff.Assigned__c = 2;
        insert objCourseOff;

        RBSstudentGroupAllocation_Ctrl.courseConnectionWrp objcourseWrap = new RBSstudentGroupAllocation_Ctrl.courseConnectionWrp();
        objcourseWrap.contactId = objcon.id;
        objcourseWrap.contactName  = objcon.Name;
        objcourseWrap.sectionId = objTerm.id;
        objcourseWrap.subjectId = objCourseOff.id;
        objcourseWrap.subjectName  = objCourseOff.Name;

        List<RBSstudentGroupAllocation_Ctrl.courseConnectionWrp> lstCourseWrap = new List<RBSstudentGroupAllocation_Ctrl.courseConnectionWrp>();
        lstCourseWrap.add(objcourseWrap);

        String myJSON = JSON.serialize(lstCourseWrap);

        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c objCourEnroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, objCourseOff.Id);
        objCourEnroll.RecordTypeId=enrollRecTypeId;
        objCourEnroll.Section__c = objTerm.id;
        objCourEnroll.Semester_ID__c = objTerm.Id;
        Insert objCourEnroll;

        RBSstudentGroupAllocation_Ctrl.GroupWrapperClass grpWrap = new RBSstudentGroupAllocation_Ctrl.GroupWrapperClass();
        grpWrap.groupNo = '2';
        grpWrap.groupName = objTerm.Name;
        grpWrap.totalRecords =10;
        grpWrap.groupId = objTerm.id;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;
        System.runAs(testUser) {
        test.starttest();
        RBSstudentGroupAllocation_Ctrl.getTermAndRBSCourseDetails(objTerm.id);
        RBSstudentGroupAllocation_Ctrl.createRBSGroups(2,objCourseOff.id,objTerm.Name,objTerm.id);
        RBSstudentGroupAllocation_Ctrl.getGroupDetails(objCourseOff.id,objTerm.id,2);
        RBSstudentGroupAllocation_Ctrl.createStudTermGroupRBS(myJSON,true ,new List<String>{objProgEnroll.Id});
        RBSstudentGroupAllocation_Ctrl.CourseConnectionWrp co = RBSstudentGroupAllocation_Ctrl.getCourseConnectionData(objCourEnroll);
            System.debug('co----'+co);
        RBSstudentGroupAllocation_Ctrl.deleteExistingGroupAllocations(objCourseOff.id,objTerm.id);
        test.stoptest();
        System.assertEquals(objCourEnroll.Id, co.courseOfferId,'Semester Connection should be equal');

        }
    }

    @isTest
     public static  Void groupAllocationMethodForRBS()
    {
        string acaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId1 );
        objAccount.RecordTypeid = acaRecId1;
        insert objAccount;

         string rbsSpclRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RBS Specialization').getRecordTypeId();
        Account objAccount3 = MSTR_TestDataFactory.CreateAccount('Test RBS Spcl',rbsSpclRecordType );
        objAccount3.RecordTypeid = rbsSpclRecordType;
        objAccount3.ParentId = objAccount.Id;
        insert objAccount3;

        string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId);
        objAccount1.RecordTypeid = acaRecId;
        insert objAccount1;

        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.Accountid = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c=' Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = contactRecTypeId;
        insert objcon;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount3.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount1.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id;
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'RBS Specialization';
        objCourse.HardCore_Sub_Type__c = 'Theory';
        objCourse.Credits__c=4;
        objCourse.Offered_By_School__c=objAccount.Id;
        objCourse.hed__Account__c = objAccount.Id;
        objCourse.Credit_Hours__c=11;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 30;
        insert objCourse;


        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'RBS Specialization';
        objCourseOff.Sequence__c =1;
        objCourseOff.Specialization__c = objAccount3.id;
        objCourseOff.Active__c =true;
        objCourseOff.Assigned__c = 2;
        insert objCourseOff;

        RBSstudentGroupAllocation_Ctrl.courseConnectionWrp objcourseWrap = new RBSstudentGroupAllocation_Ctrl.courseConnectionWrp();
        objcourseWrap.contactId = objcon.id;
        objcourseWrap.contactName  = objcon.Name;
        objcourseWrap.sectionId = objTerm.id;
        objcourseWrap.subjectId = objCourseOff.id;
        objcourseWrap.subjectName  = objCourseOff.Name;

        List<RBSstudentGroupAllocation_Ctrl.courseConnectionWrp> lstCourseWrap = new List<RBSstudentGroupAllocation_Ctrl.courseConnectionWrp>();
        lstCourseWrap.add(objcourseWrap);

        String myJSON = JSON.serialize(lstCourseWrap);

        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c objCourEnroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, objCourseOff.Id);
        objCourEnroll.RecordTypeId=enrollRecTypeId;
        objCourEnroll.Section__c = objTerm.id;
        objCourEnroll.Semester_ID__c = objTerm.Id;
        Insert objCourEnroll;

        RBSstudentGroupAllocation_Ctrl.GroupWrapperClass grpWrap = new RBSstudentGroupAllocation_Ctrl.GroupWrapperClass();
        grpWrap.groupNo = '2';
        grpWrap.groupName = objTerm.Name;
        grpWrap.totalRecords =10;
        grpWrap.groupId = objTerm.id;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;
        System.runAs(testUser) {

        test.starttest();
        RBSstudentGroupAllocation_Ctrl.DetailsWrp wrpData = RBSstudentGroupAllocation_Ctrl.getTermAndRBSCourseDetails(objTerm.id);
        test.stoptest();
        System.assertEquals(objTerm.id,wrpData.objTerm.id );
        }
    }

    @isTest
    public static  Void groupAllocationMethod1()
    {
        string acaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId1 );
        objAccount.RecordTypeid = acaRecId1;
        insert objAccount;

        string acaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',acaRecId);
        objAccount1.RecordTypeid = acaRecId;
        insert objAccount1;

        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.Accountid = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c=' Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = contactRecTypeId;
        insert objcon;

        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        objProgPlan.Provisionally_Admitted_Students__c = 20;
        objProgPlan.Intake__c =20;
        objProgPlan.Intake_Per_Section__c=5;
        insert objProgPlan;

        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        objTerm.Program_Batch__c  = objProgPlan.id;
        insert objTerm;

        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c = 'Theory';
        objCourse.Credits__c=4;
        objCourse.Offered_By_School__c=objAccount.Id;
        objCourse.Credit_Hours__c=11;
        objCourse.Maximum_External_Marks__c = 50;
        objCourse.Total_Maximum_Marks_IA_External__c = 30;
        insert objCourse;

        hed__Course_Offering__c  objCourseOff1 = MSTR_TestDataFactory.createCourseOffering('Parent CourseOffering',objTerm.id,objCourse.id);
        objCourseOff1.Category__c = 'Open Elective';
        objCourseOff1.Sequence__c =1;
        insert objCourseOff1;

        hed__Course_Offering__c  objCourseOff = MSTR_TestDataFactory.createCourseOffering('test CourseOffering',objTerm.id,objCourse.id);
        objCourseOff.Category__c = 'Open Elective';
        objCourseOff.Sequence__c =1;
        objCourseOff.Parent_Course_Offering__c = objCourseOff1.id;
        objCourseOff.Active__c =true;
        objCourseOff.Assigned__c = 2;
        insert objCourseOff;

        string sectiontermRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_RecType_Group).getRecordTypeId();
        hed__Term__c objGroupTerm = MSTR_TestDataFactory.createTerm('test term1',objAccount.id,sectiontermRtId);
        objGroupTerm.Program_Batch__c  = objProgPlan.id;
        objGroupTerm.Course_Offering__c = objCourseOff.id;
        objGroupTerm.hed__Parent_Term__c = objTerm.id;
        objGroupTerm.Group_Number__c =2;
        insert objGroupTerm;

        RBSstudentGroupAllocation_Ctrl.courseConnectionWrp objcourseWrap = new RBSstudentGroupAllocation_Ctrl.courseConnectionWrp();
        objcourseWrap.contactId = objcon.id;
        objcourseWrap.contactName  = objcon.Name;
        objcourseWrap.sectionId = objGroupTerm.id;
        objcourseWrap.subjectId = objCourseOff.id;
        objcourseWrap.subjectName  = objCourseOff.Name;

        List<RBSstudentGroupAllocation_Ctrl.courseConnectionWrp> lstCourseWrap = new List<RBSstudentGroupAllocation_Ctrl.courseConnectionWrp>();
        lstCourseWrap.add(objcourseWrap);

        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount1.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id;
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll;

        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        Student_Semester_Mapping__c objStudSem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        objStudSem.RecordTypeId= recordTypeName;
        objStudSem.Active__c = true;
        objStudSem.Program_Enrollment__c= objProgEnroll.id;
        objStudSem.Start_Date__c = system.today();
        objStudSem.End_Date__c = system.today();
        objStudSem.Student_Group__c = objGroupTerm.id;
        insert objStudSem;

        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c objCourEnroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, objCourseOff.Id);
        objCourEnroll.RecordTypeId=enrollRecTypeId;
        objCourEnroll.hed__Program_Enrollment__c = objProgEnroll.id;
        objCourEnroll.Section__c = objTerm.id;
        objCourEnroll.Semester_ID__c = objTerm.Id;
        Insert objCourEnroll;

        RBSstudentGroupAllocation_Ctrl.GroupWrapperClass grpWrap = new RBSstudentGroupAllocation_Ctrl.GroupWrapperClass();
        grpWrap.groupNo = '2';
        grpWrap.groupName = objGroupTerm.Name;
        grpWrap.totalRecords =10;
        grpWrap.groupId = objGroupTerm.id;

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Vertical Head' LIMIT 1];

        User testUser = new User(
            Username = 'sysadminuser@test.com',
            Email = 'sysadminuser@email.com',
            Alias = 'sysadmin',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            FirstName = 'Test System Admin',
            LastName = 'User'
        );
        insert testUser;
        System.runAs(testUser) {

        test.starttest();
        RBSstudentGroupAllocation_Ctrl.WrapperClass wrpclass = RBSstudentGroupAllocation_Ctrl.getExistingGroups(objCourseOff.id,objTerm.id);
        test.stoptest();
        System.assertNotEquals(null ,wrpclass);
        }
    }
}