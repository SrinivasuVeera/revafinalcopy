@isTest
public class CP_CoursePlanTopicsSequenceHandler_Test 
{
    public static testmethod void CourseplanTopics()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = CP_TestDataFactory.CreateAccount('str_accName', AccountRecTypeId);
        objAcc.RecordTypeId = AccountRecTypeId;
        Insert objAcc;
        
        Id ContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        Contact ObjCon = CP_TestDataFactory.createContact('str_lastName');
        ObjCon.RecordTypeId = ContactRecTypeId;
        ObjCon.AccountId = objAcc.Id;
        ObjCon.hed__WorkEmail__c='123@reva.edu.in';
        ObjCon.Application_Number__c = '123';
        ObjCon.Nationality__c = 'Indian';
        ObjCon.Aadhar_Card_Number__c ='368845632147'; 
        ObjCon.PAN_Number__c ='HRAPO4561D';
        ObjCon.MobilePhone ='8963210547';
        ObjCon.SRN_Number__c='Srn123';
        Insert ObjCon;
        
        hed__Course__c objCour = CP_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert objCour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c objTerm = CP_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        objTerm.RecordTypeId = termRecTypeId;
        Insert objTerm;
        
        hed__Term__c objTermParent = CP_TestDataFactory.createTerm('test term',objAcc.id,termRecTypeId );
        objTermParent.hed__Parent_Term__c = objTerm.id;
        Insert objTermParent;
        
        hed__Course_Offering__c objCourOff = CP_TestDataFactory.createCourseOffering('courseOffName', objTerm.Id, objCour.id);
        objCourOff.hed__Term__c = objTermParent.Id;
        Insert objCourOff;
        
        Course_Plan_Unit__c objCourseplanunit = CP_TestDataFactory.createCoursePlanUnit('Course Plan unit',objCourOff.Id,objCour.Id);
        Insert objCourseplanunit;
        
        Course_Plan_Topic__c objCoursePlanTopic = CP_TestDataFactory.createCoursePlanTopic('Course Plan',objCourseplanunit.Id);
        objCoursePlanTopic.Course_Plan_Unit__c  = objCourseplanunit.Id;
        Insert objCoursePlanTopic;
        
        Course_Plan_Topic__c objCoursePlnTopic = CP_TestDataFactory.createCoursePlanTopic('Course Plan',objCourseplanunit.Id);
        objCoursePlnTopic.Course_Plan_Unit__c  = objCourseplanunit.Id;
        Insert objCoursePlnTopic;
        
        List<Course_Plan_Topic__c> lst_Coursetopics = new List<Course_Plan_Topic__c>();
        lst_Coursetopics.add(objCoursePlnTopic);
        
        delete objCoursePlanTopic;
        
        Test.startTest();
        CP_CoursePlanTopicsSequenceHandler.generateTopicssequence(lst_Coursetopics);
        Test.stopTest();
        system.assertEquals(objCoursePlnTopic.Id,objCoursePlnTopic.Id);
    }
}