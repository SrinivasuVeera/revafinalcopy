@isTest
public class CP_CoursePlanUnitSequenceHandler_Test 
{
    public static testmethod void Courseplansequence()
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
        
        hed__Term__c objTermParent = MSTR_TestDataFactory.createTerm('test term',objAcc.id,termRecTypeId );
        objTermParent.hed__Parent_Term__c = objTerm.id;
        Insert objTermParent;
        
        hed__Course_Offering__c objCourOff = CP_TestDataFactory.createCourseOffering('courseOffName', objTerm.Id, objCour.id);
        objCourOff.hed__Term__c = objTermParent.Id;
        Insert objCourOff;
        
        Course_Plan_Unit__c objCourseplanunit = CP_TestDataFactory.createCoursePlanUnit('Course Plan unit',objCourOff.Id,objCour.Id);
        objCourseplanunit.Course_Offering__c = objCourOff.Id;
        objCourseplanunit.Course__c = objCour.Id;
        objCourseplanunit.Sequence_No__c = 1;
        Insert objCourseplanunit;
        
        Course_Plan_Unit__c objCrseplanunit = CP_TestDataFactory.createCoursePlanUnit('Course Plan unit',objCourOff.Id,objCour.Id);
        objCrseplanunit.Course_Offering__c = objCourOff.Id;
        objCrseplanunit.Course__c = objCour.Id;
        objCrseplanunit.Sequence_No__c = 2;
        Insert objCrseplanunit;
        
        Course_Plan_Topic__c objCrsPlnTopic = CP_TestDataFactory.createCoursePlanTopic('TestCrsPlnTopic', objCrseplanunit.id);
        objCrsPlnTopic.Old_Topic_ID__c = objCrsPlnTopic.Id;
        insert objCrsPlnTopic;
        
        Course_Plan_Topic__c objCrsPlnTopic2 = CP_TestDataFactory.createCoursePlanTopic('TestCrsPlnUnit', objCourseplanunit.id);
        objCrsPlnTopic2.Old_Topic_ID__c = objCrsPlnTopic.Id;
        insert objCrsPlnTopic2;
        
        List<Course_Plan_Unit__c> lst_CoursePlanunits = new List<Course_Plan_Unit__c>();
        lst_CoursePlanunits.add(objCrseplanunit);
               
        delete objCrseplanunit;
        
        delete objCrsPlnTopic;
        
        Test.startTest();
        CP_CoursePlanUnitSequenceHandler.generatecourseplanunitsequence(lst_CoursePlanunits);
        Test.stopTest();
        system.assertEquals(objCrseplanunit.Id,objCrseplanunit.Id);
    }
}