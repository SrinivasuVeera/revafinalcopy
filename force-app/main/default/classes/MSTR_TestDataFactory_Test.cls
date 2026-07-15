@isTest
public class MSTR_TestDataFactory_Test 
{
    public static testMethod Void TestDatMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = MSTR_TestDataFactory.CreateAccount('Test Account',UniversityRecId );
        Account objAccount1 = MSTR_TestDataFactory.CreateAccount1('Test Account1');
        hed__Program_Plan__c  objProgPlan =  MSTR_TestDataFactory.createProgramPlan('Test Program Plan');
        contact objcon = MSTR_TestDataFactory.createContact('test contact');
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();       
        hed__Term__c objTerm = MSTR_TestDataFactory.createTerm('test term',objAccount.id,termRtId);        
        hed__Plan_Requirement__c objPlanReq1 = MSTR_TestDataFactory.createPlanRequirement('test plan requirement1');
        hed__Course__c objcourse = MSTR_TestDataFactory.CreateCourse('test course',objAccount.id);
        hed__Program_Enrollment__c objProgEnrollment = MSTR_TestDataFactory.createProgEnrollment(objcon.Id, objAccount.Id);
        hed__Course_Offering__c objCourseOff = MSTR_TestDataFactory.createCourseOffering('Test CourseOffering',objTerm.id,objcourse.id);
        hed__Course_Enrollment__c obj_Cour_Enroll = MSTR_TestDataFactory.createCourseEnrollment(objcon.Id, objCourseOff.Id);
        string studMaptId = Schema.SObjectType.Student_Semester_Mapping__c.getRecordTypeInfosByName().get(Utility.STM_RecType_Group).getRecordTypeId();       
        Student_Semester_Mapping__c objStuMapping = MSTR_TestDataFactory.createStudenttermMapping('StuTermName', studMaptId);
        Professor_Student_Course_Preference__c objProf = MSTR_TestDataFactory.CreateProfessorStudent('test prof',objCourseOff.id,objTerm.id); 
    }
}