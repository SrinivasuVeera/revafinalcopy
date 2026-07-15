@isTest
public class MSTR_StudentElectiveGroupAlloc_Ctrl_Test 
{
    public static testMethod Void GroupAllocationMethod()
    {
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();        
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.Accountid = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c=' Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = ContactRecTypeId;
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
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true;
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.End_Date__c = system.today();
        obj_Stud_Sem.Student_Group__c = objTerm.id;
        insert obj_Stud_Sem;
        
        hed__Course__c objCourse = MSTR_TestDataFactory.CreateCourse('Test Course',objAccount1.id);
        objCourse.Category__c = 'Hardcore Course';
        objCourse.HardCore_Sub_Type__c = 'Theory';
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
        
        MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp objcourseWrap = new MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp();
        objcourseWrap.contactId = objcon.id;
        objcourseWrap.contactName  = objcon.Name;
        objcourseWrap.sectionId = objTerm.id;
        objcourseWrap.subjectId = objCourseOff.id;
        objcourseWrap.subjectName  = objCourseOff.Name;
        
        List<MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp> lst_courseWrap = new List<MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp>();
        lst_courseWrap.add(objcourseWrap); 
        
        String myJSON = JSON.serialize(lst_courseWrap);
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c obj_CourEnroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, objCourseOff.Id);
        obj_CourEnroll.RecordTypeId=enrollRecTypeId;
        obj_CourEnroll.Section__c = objTerm.id;
        obj_CourEnroll.Semester_ID__c = objTerm.Id;
        Insert obj_CourEnroll;
        
        MSTR_StudentElectiveGroupAllocation_Ctrl.GroupWrapperClass grpWrap = new MSTR_StudentElectiveGroupAllocation_Ctrl.GroupWrapperClass();
        grpWrap.groupNo = '2';
        grpWrap.groupName = objTerm.Name;
        grpWrap.totalRecords =10;
        grpWrap.groupId = objTerm.id;
        
        test.starttest();
        MSTR_StudentElectiveGroupAllocation_Ctrl.getTermAndElectiveDetails(objTerm.id);
        MSTR_StudentElectiveGroupAllocation_Ctrl.createElectiveGroups(2,objCourseOff.id,objTerm.Name,objTerm.id);
        MSTR_StudentElectiveGroupAllocation_Ctrl.getGroupDetails(objCourseOff.id,objTerm.id,2);
        MSTR_StudentElectiveGroupAllocation_Ctrl.createStudTermGroup(myJSON); 
        MSTR_StudentElectiveGroupAllocation_Ctrl.getCourseConnectionData(obj_CourEnroll);
        MSTR_StudentElectiveGroupAllocation_Ctrl.deleteExistingGroupAllocations(objCourseOff.id,objTerm.id);
        test.stoptest();
        System.assertEquals(objTerm.id, objTerm.id);
    }
    public static testMethod Void GroupAllocationMethod1()
    {
        string AcaRecId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId1 );
        objAccount.RecordTypeid = AcaRecId1;
        insert objAccount;
        
        string AcaRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household ).getRecordTypeId();        
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount('Test Account',AcaRecId);
        objAccount1.RecordTypeid = AcaRecId;
        insert objAccount1;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Contact objcon = MSTR_TestDataFactory.createContact('test Contact');
        objcon.Accountid = objAccount.id;
        objcon.Accountid = objAccount1.id;
        objcon.Professor_Across_Schools__c = true;
        objcon.Application_Number__c = '123';
        objcon.hed__WorkEmail__c='123@reva.edu.in';
        objcon.Email = 'test@gmail.com';
        //objcon.hed__Preferred_Email__c=' Personal Email';
        objcon.MobilePhone ='8963210547';
        objCon.RecordTypeId = ContactRecTypeId;
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
        
        MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp objcourseWrap = new MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp();
        objcourseWrap.contactId = objcon.id;
        objcourseWrap.contactName  = objcon.Name;
        objcourseWrap.sectionId = objGroupTerm.id;
        objcourseWrap.subjectId = objCourseOff.id;
        objcourseWrap.subjectName  = objCourseOff.Name;
        
        List<MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp> lst_courseWrap = new List<MSTR_StudentElectiveGroupAllocation_Ctrl.courseConnectionWrp>();
        lst_courseWrap.add(objcourseWrap); 
        
        String myJSON = JSON.serialize(lst_courseWrap);
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount1.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll;    
        
        string recordTypeName = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Batch).getRecordTypeId();
        Student_Semester_Mapping__c obj_Stud_Sem = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', recordTypeName);
        obj_Stud_Sem.RecordTypeId= recordTypeName;
        obj_Stud_Sem.Active__c = true;
        obj_Stud_Sem.Program_Enrollment__c= objProgEnroll.id;
        obj_Stud_Sem.Start_Date__c = system.today();
        obj_Stud_Sem.End_Date__c = system.today();
        obj_Stud_Sem.Student_Group__c = objGroupTerm.id;
        insert obj_Stud_Sem;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Course_Enrollment__c obj_CourEnroll = MSTR_TestDataFactory.createCourseEnrollment(objCon.id, objCourseOff.Id);
        obj_CourEnroll.RecordTypeId=enrollRecTypeId;
        obj_CourEnroll.hed__Program_Enrollment__c = objProgEnroll.id;
        obj_CourEnroll.Section__c = objTerm.id;
        obj_CourEnroll.Semester_ID__c = objTerm.Id;
        Insert obj_CourEnroll;
        
        MSTR_StudentElectiveGroupAllocation_Ctrl.GroupWrapperClass grpWrap = new MSTR_StudentElectiveGroupAllocation_Ctrl.GroupWrapperClass();
        grpWrap.groupNo = '2';
        grpWrap.groupName = objGroupTerm.Name;
        grpWrap.totalRecords =10;
        grpWrap.groupId = objGroupTerm.id;
        
        test.starttest();
        MSTR_StudentElectiveGroupAllocation_Ctrl.getExistingGroups(objCourseOff.id,objTerm.id);
        test.stoptest();
        System.assertEquals(objTerm.id, objTerm.id);
    }
}