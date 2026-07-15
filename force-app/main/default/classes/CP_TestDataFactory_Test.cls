@isTest
public class CP_TestDataFactory_Test
{
    public static testmethod void CPTestData()
    {
        string HouseholdRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Utility.Acc_RecType_Household).getRecordTypeId();
        Account objAccount = CP_TestDataFactory.CreateAccount('Test Account',HouseholdRecId);
        Contact  oBJCon = CP_TestDataFactory.createContact('Test Contact');
        hed__Program_Plan__c  objProgPlan = CP_TestDataFactory.createProgramPlan('Test programPlan');
        hed__Plan_Requirement__c objPlanReq = CP_TestDataFactory.createPlanRequirement('Test Plan Requirement');
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        hed__Term__c  objTerm = CP_TestDataFactory.createTerm('Test Term',objAccount.Id,termRecTypeId);
        hed__Course__c  objCourse = CP_TestDataFactory.CreateCourse('Test Course',objAccount.Id);
        hed__Course_Offering__c  objCourseOffering = CP_TestDataFactory.createCourseOffering('Test Course Offering',objTerm.Id,objCourse.Id);
        Course_Plan_Unit__c objcourseUnit = CP_TestDataFactory.createCoursePlanUnit('Test Course Plan Unit',objCourseOffering.Id,objCourse.Id);
        Course_Plan_Topic__c objcourseTopic = CP_TestDataFactory.createCoursePlanTopic('Test Course Plan Topic',objcourseUnit.Id);
    
    }
}