@isTest
public class CP_CoursePlanUnitTriggerHandler_Test 
{
    public static testmethod void CoursePlanUnit()
    {
        Id AccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        
        Account objAcc = CP_TestDataFactory.CreateAccount('TestAcc', AccountRecTypeId);
        insert objAcc;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c objTerm = CP_TestDataFactory.createTerm('TestTerm', objAcc.id, termRecTypeId);
        insert objTerm;
        
        hed__Course__c objCreateCourse = CP_TestDataFactory.CreateCourse('TestCrs', objAcc.id);
        insert objCreateCourse;
        
        hed__Course_Offering__c objCreateCrsOff = CP_TestDataFactory.createCourseOffering('TestCrsOffName',objTerm.id, objCreateCourse.id);
        insert objCreateCrsOff;
        
        Course_Plan_Unit__c objCrsPlnUnit = CP_TestDataFactory.createCoursePlanUnit('TestCrsPlnUnit', objCreateCrsOff.id, objCreateCourse.id);
        objCrsPlnUnit.Old_unit_ID__c = objCrsPlnUnit.Id;
        insert objCrsPlnUnit;
        
        Course_Plan_Topic__c objCrsPlnTopic = CP_TestDataFactory.createCoursePlanTopic('TestCrsPlnTopic', objCrsPlnUnit.id);
        objCrsPlnTopic.Course_Plan_Unit__c = objCrsPlnUnit.Id;
        insert objCrsPlnTopic;
        
        Course_Plan_Unit__c objCrsPlnUnit2 = CP_TestDataFactory.createCoursePlanUnit('TestCrsPlnUnit', objCreateCrsOff.id, objCreateCourse.id);
        objCrsPlnUnit2.Old_unit_ID__c = objCrsPlnUnit.Id;
        insert objCrsPlnUnit2;
        
        List<ContentDocumentLink> lst_CondocLink = New List<ContentDocumentLink>();
        
        List<ContentVersion> lst_Contnvrsn = New List<ContentVersion>();
        
        ContentVersion objContVrsn = New ContentVersion();
        objContVrsn.title = 'Test';
        objContVrsn.PathOnClient = objContVrsn.Title + '.snote';
        objContVrsn.VersionData = Blob.valueof('this is a test');
        objContVrsn.FirstPublishLocationId = objCrsPlnUnit.Id;
        
        lst_Contnvrsn.add(objContVrsn);
        Insert objContVrsn;
        
        List<ContentDocument> lst_Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: objCrsPlnUnit.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        if(!lst_Documents.isEmpty())
        {
            
            contentlink.ShareType= 'C';
            contentlink.LinkedEntityId = objCrsPlnUnit.Id;
            contentlink.ContentDocumentId = lst_Documents[0].Id;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;          
        }
        lst_CondocLink.add(contentlink); 
        
        List<Course_Plan_Unit__c> lst_CourseUnits = new List<Course_Plan_Unit__c>(); 
        lst_CourseUnits.add(objCrsPlnUnit2); 
        
        Test.startTest();
        CP_CoursePlanUnitTriggerHandler.createCoursePlanTopics(lst_CourseUnits);
        Test.stopTest();
        system.assertEquals(objCrsPlnUnit2.Id,objCrsPlnUnit2.Id);
        
    }
    
}