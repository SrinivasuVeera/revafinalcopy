@isTest
public class TT_TestDataFactory_Test 
{
    public static testMethod Void TestDataMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = TT_TestDataFactory.CreateAccount('Test Account',UniversityRecId );
        contact objcon = TT_TestDataFactory.createContact('test contact');
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId();       
        hed__Term__c objTerm = TT_TestDataFactory.createTerm('test term',objAccount.id,termRtId);        
        hed__Course__c objcourse = TT_TestDataFactory.CreateCourse('test course',objAccount.id);
        hed__Course_Offering__c objCourseOff = TT_TestDataFactory.createCourseOffering('Test CourseOffering',objTerm.id,objcourse.id);
        hed__Course_Enrollment__c obj_Cour_Enroll = TT_TestDataFactory.createCourseEnrollment(objcon.Id, objCourseOff.Id);
        hed__Course_Offering_Schedule__c objCouSch = TT_TestDataFactory.CreateCourseSchedule(objCourseOff.id,objTerm.id);
        hed__Attendance_Event__c objAttEve = TT_TestDataFactory.createAttendanceEvent(objCouSch.id,objcon.Id,obj_Cour_Enroll.id);  
        Course_Plan_Unit__c  objCoursePlan = TT_TestDataFactory.createCoursePlanUnit('test course plan',objCourseOff.id,objcourse.id);
        Course_Plan_Topic__c objPlanTopic = TT_TestDataFactory.createCoursePlanTopic('Plan Topic',objCoursePlan.id);
         hed__Program_Plan__c  objProgPlan = CP_TestDataFactory.createProgramPlan('Test programPlan');
    }
}