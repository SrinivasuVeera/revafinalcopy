@isTest
public class ATT_TestDataFactory_Test 
{
    public static testMethod Void AttTestMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ATT_TestDataFactory.CreateAccount('Test Account',UniversityRecId );
        contact objcon = ATT_TestDataFactory.createContact('test contact');
        hed__Program_Enrollment__c objProgEnrollment = ATT_TestDataFactory.createProgEnrollment(objcon.Id, objAccount.Id);
        Proxy_Attendance__c objproxy = ATT_TestDataFactory.CreateProxyAttendance(objcon.Id);
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId(); 
        hed__Term__c objterm = ATT_TestDataFactory.createTerm('test term',objAccount.Id,termRtId);
        hed__Course__c objcourse = ATT_TestDataFactory.CreateCourse('test course',objAccount.id);
        hed__Program_Plan__c objprogrplan = ATT_TestDataFactory.createProgramPlan('test');
        hed__Course_Offering__c objCourseOff = ATT_TestDataFactory.createCourseOffering('Test CourseOffering',objterm.id,objcourse.id);
        hed__Course_Offering_Schedule__c objCouSch = ATT_TestDataFactory.CreateCourseSchedule(objCourseOff.id,objterm.id);
        hed__Course_Enrollment__c obj_CourEnroll = ATT_TestDataFactory.createCourseEnrollment(objcon.Id, objCourseOff.Id);
        hed__Attendance_Event__c objAttEve = ATT_TestDataFactory.createAttendanceEvent(objCouSch.id,objcon.Id,obj_CourEnroll.id);  
        Course_Plan_Unit__c  objCoursePlan = ATT_TestDataFactory.createCoursePlanUnit('test course plan',objCourseOff.id,objcourse.id);
        Course_Plan_Topic__c objPlanTopic = ATT_TestDataFactory.createCoursePlanTopic('Plan Topic',objCoursePlan.id);      
    }   
}