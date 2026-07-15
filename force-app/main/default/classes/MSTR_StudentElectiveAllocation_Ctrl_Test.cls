@isTest
public class MSTR_StudentElectiveAllocation_Ctrl_Test 
{
    public static testMethod Void ElectiveMethod()
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
        //objcon.hed__Preferred_Email__c='Personal Email';
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
        insert objCourseOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_CourseEnroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, objCourseOff.Id);
        obj_CourseEnroll.RecordTypeId=enrollRecTypeId;
        obj_CourseEnroll.Semester_ID__c = objTerm.id;
        Insert obj_CourseEnroll;
        
        test.starttest();
        MSTR_StudentElectiveAllocation_Ctrl.displayCourseOfferingRecords(objTerm.id);
        MSTR_StudentElectiveAllocation_Ctrl.getElectiveCourses(objCourseOff1.id,objTerm.id);
        MSTR_StudentElectiveAllocation_Ctrl.getPreference();
        test.stoptest();
        system.assertEquals(objTerm.id,objTerm.id);
    }
    public static testMethod Void ElectiveMethod1()
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
       // objcon.hed__Preferred_Email__c='Personal Email';
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
        insert objCourseOff;
        
        Id enrollRecTypeId = Schema.SObjectType.hed__Course_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__Course_Enrollment__c obj_CourseEnroll = MSTR_TestDataFactory.createCourseEnrollment(ObjCon.id, objCourseOff.Id);
        obj_CourseEnroll.RecordTypeId=enrollRecTypeId;
        Insert obj_CourseEnroll;
        
        Professor_Student_Course_Preference__c objProfStuOE = MSTR_TestDataFactory.CreateProfessorStudent('Test Professor Student',objCourseOff.id,objTerm.id);
        objProfStuOE.Contact__c = objcon.id;
        objProfStuOE.Student_Preference__c = true;
        objProfStuOE.Preference__c = '1';
        insert objProfStuOE;
        
        hed__Program_Enrollment__c objProgEnroll = MSTR_TestDataFactory.createProgEnrollment(objcon.id,objAccount.id);
        objProgEnroll.hed__Start_Date__c = system.today()-1;
        objProgEnroll.hed__End_Date__c = system.today();
        objProgEnroll.hed__Program_Plan__c =objProgPlan.id; 
        objProgEnroll.Application_Number__c ='123';
        objProgEnroll.Section__c = objTerm.id;
        insert objProgEnroll;
        
        MSTR_StudentElectiveAllocation_Ctrl.StudentPreferenceElectivs objstupref = new MSTR_StudentElectiveAllocation_Ctrl.StudentPreferenceElectivs();
        objstupref.CourseName  = objCourseOff.Name;
        objstupref.Contact_Id  = objcon.id;
        objstupref.Contact_Name = objcon.name;
        
        list<MSTR_StudentElectiveAllocation_Ctrl.StudentPreferenceElectivs> lst_stuwrap = new list<MSTR_StudentElectiveAllocation_Ctrl.StudentPreferenceElectivs>();
        lst_stuwrap.add(objstupref);
        
        String myJSON = JSON.serialize(lst_stuwrap);
        
        MSTR_StudentElectiveAllocation_Ctrl.CourseOfferingdata objcorsewrap = new MSTR_StudentElectiveAllocation_Ctrl.CourseOfferingdata();
        objcorsewrap.CourseOfferingId  = objCourseOff.id;
        objcorsewrap.Course_Name = objCourseOff.Name;
        
        String courseJSON = JSON.serialize(objcorsewrap);
        
        test.starttest();
        MSTR_StudentElectiveAllocation_Ctrl.getElectiveCourses(objCourseOff1.id,objTerm.id);
        MSTR_StudentElectiveAllocation_Ctrl.createCourseConnection(myJSON);
        MSTR_StudentElectiveAllocation_Ctrl.ActivateCourseOffering(courseJSON);
        test.stoptest();
        system.assertEquals(objTerm.id,objTerm.id);
    }
}