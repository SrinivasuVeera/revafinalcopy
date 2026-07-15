@isTest
public class ALU_TestDataFactory_Test 
{
    public static testMethod Void ALUTestMethod()
    {
        string UniversityRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_University_Department).getRecordTypeId();
        Account objAccount = ALU_TestDataFactory.CreateAccount('Test Account',UniversityRecId );
        contact objcon = ALU_TestDataFactory.createContact('test contact');
        hed__Program_Enrollment__c objProgEnrollment = ALU_TestDataFactory.createProgEnrollment(objcon.Id, objAccount.Id);
        Proxy_Attendance__c objproxy = ALU_TestDataFactory.CreateProxyAttendance(objcon.Id);
        string termRtId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get(Utility.Term_Object_RecType_Term).getRecordTypeId(); 
        hed__Term__c objterm = ALU_TestDataFactory.createTerm('test term',objAccount.Id,termRtId);
        hed__Course__c objcourse = ALU_TestDataFactory.CreateCourse('test course',objAccount.id);
        hed__Program_Plan__c objprogrplan = ALU_TestDataFactory.createProgramPlan('test');
        hed__Course_Offering__c objCourseOff = ALU_TestDataFactory.createCourseOffering('Test CourseOffering',objterm.id,objcourse.id);
        hed__Course_Offering_Schedule__c objCouSch = ALU_TestDataFactory.CreateCourseSchedule(objCourseOff.id,objterm.id);
        hed__Course_Enrollment__c obj_CourEnroll = ALU_TestDataFactory.createCourseEnrollment(objcon.Id, objCourseOff.Id);
        hed__Attendance_Event__c objAttEve = ALU_TestDataFactory.createAttendanceEvent(objCouSch.id,objcon.Id,obj_CourEnroll.id);  
        //Course_Plan_Unit__c  objCoursePlan = TT_TestDataFactory.createCoursePlanUnit('test course plan',objCourseOff.id,objcourse.id);
        //Course_Plan_Topic__c objPlanTopic = TT_TestDataFactory.createCoursePlanTopic('Plan Topic',objCoursePlan.id);  
        Alumni_Activities__c objAlumniActiv = ALU_TestDataFactory.createAlumniActivities(objcon.Id);
        Alumni_Event_Registrations__c objAlumniEventReg = ALU_TestDataFactory.createAlumniEventReg(objcon.Id, objAlumniActiv.id);
   Alumni_Payments__c objAluPayments = ALU_TestDataFactory.createPayments(objcon.Id);
    }   
}