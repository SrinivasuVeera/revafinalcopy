@isTest
public class STOB_TestDataFactory_Test
{
    public static testMethod Void testDataMethod()
    {
        Account objAccount = STOB_TestDataFactory.CreateAccount('Test Account');
        Contact objCon = STOB_TestDataFactory.createContact('Test Contact');
        hed__Education_History__c objEdhis = STOB_TestDataFactory.createEducationHistory(objCon.Id);
        hed__Program_Plan__c  objProgPlan =  STOB_TestDataFactory.createProgramPlan('Test Program Plan');
        hed__Program_Enrollment__c objProgEroll = STOB_TestDataFactory.createprogramEnrollment(objProgPlan.Id);
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();
       
        hed__Term__c objTerm = STOB_TestDataFactory.createTerm('test term',objAccount.id,termRtId);
        hed__Course__c objcourse = STOB_TestDataFactory.CreateCourse('test course',objAccount.id);
        hed__Course_Offering__c objCourseOff = STOB_TestDataFactory.createCourseOffering('Test CourseOffering',objTerm.id,objcourse.id);
       // Professor_Student_Course_Preference__c  objProfcourse = STOB_TestDataFactory.CreateProfessorStudent('Test Professor',objCourseOff.Id,objTerm.Id);
    }

}