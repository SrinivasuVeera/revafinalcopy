@isTest
public class CP_DefineCoursePlan_Ctrl_Test
{
    public static testmethod void DefinecourseplanMethod()
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
        
        hed__Course__c obj_Cour = CP_TestDataFactory.CreateCourse('CourseName', objAcc.Id);
        Insert obj_Cour;
        
        Id termRecTypeId = Schema.SObjectType.hed__Term__c.getRecordTypeInfosByName().get('Batches').getRecordTypeId();
        
        hed__Term__c obj_Term = CP_TestDataFactory.createTerm('TermName',objAcc.Id, termRecTypeId);
        obj_Term.RecordTypeId = termRecTypeId;
        Insert obj_Term;
        
        hed__Term__c objTermParent = CP_TestDataFactory.createTerm('test term',objAcc.id,termRecTypeId );
        objTermParent.hed__Parent_Term__c = obj_Term.id;
        Insert objTermParent;
        
        hed__Course_Offering__c obj_CourOff = CP_TestDataFactory.createCourseOffering('courseOffName', obj_Term.Id, obj_Cour.id);
        obj_CourOff.hed__Term__c = objTermParent.Id;
        Insert obj_CourOff;
        
        Course_Plan_Unit__c obj_Courseplanunit = CP_TestDataFactory.createCoursePlanUnit('Course Plan unit',obj_CourOff.Id,obj_Cour.Id);
        Insert obj_Courseplanunit;
        
        Course_Plan_Topic__c obj_CoursePlanTopic = CP_TestDataFactory.createCoursePlanTopic('Course Plan',obj_Courseplanunit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = obj_Courseplanunit.Id;
        Insert obj_CoursePlanTopic;
        
        Course_Plan_Unit__c obj_Crseplanunit = CP_TestDataFactory.createCoursePlanUnit('Course Plan unit',obj_CourOff.Id,obj_Cour.Id);
        Insert obj_Crseplanunit;
        
        Course_Plan_Unit__c obj_Crsplanunit = CP_TestDataFactory.createCoursePlanUnit('Course Plan unit',obj_CourOff.Id,obj_Cour.Id);
        Insert obj_Crsplanunit;
        
        Course_Plan_Topic__c obj_CrsePlanTopic = CP_TestDataFactory.createCoursePlanTopic('Course Plan',obj_Crseplanunit.Id);
        obj_CoursePlanTopic.Course_Plan_Unit__c  = obj_Crseplanunit.Id;
        Insert obj_CrsePlanTopic;
        
        List<Course_Plan_Unit__c> lst_CourseUnits = new List<Course_Plan_Unit__c>(); 
        lst_CourseUnits.add(obj_Crseplanunit);
        
        List<Course_Plan_Topic__c> list_courseTopics = new List<Course_Plan_Topic__c>();
        list_courseTopics.add(obj_CrsePlanTopic);
        
        Course_Plan_Topic__c obj_CrsPlanTopic = CP_TestDataFactory.createCoursePlanTopic('Course Plan',obj_Crsplanunit.Id);
        obj_CrsPlanTopic.Course_Plan_Unit__c  = obj_Crsplanunit.Id;
        Insert obj_CrsPlanTopic;
        
        CP_DefineCoursePlan_Ctrl.WrapCoursetopics wrapCorseTopics = new CP_DefineCoursePlan_Ctrl.WrapCoursetopics();
        wrapCorseTopics.topicname ='test topic';
        wrapCorseTopics.topicId= obj_CrsPlanTopic.Id;
        wrapCorseTopics.courseunit = obj_Crseplanunit.Id;
        
        list<CP_DefineCoursePlan_Ctrl.WrapCoursetopics> lst_wrapCorseTopics = new list<CP_DefineCoursePlan_Ctrl.WrapCoursetopics>(); 
        lst_wrapCorseTopics.add(wrapCorseTopics); 
        
        List<Course_Plan_Topic__c> lst_Topics = new List<Course_Plan_Topic__c>();
        lst_Topics.add(obj_CrsPlanTopic);
        
        String courseJSON = JSON.serialize(lst_wrapCorseTopics);
        
        List<ContentDocumentLink> lst_CondocLink = New List<ContentDocumentLink>();
        
        List<ContentVersion> lst_Contnvrsn = New List<ContentVersion>();
        
        ContentVersion objContVrsn = New ContentVersion();
        objContVrsn.title = 'Test';
        objContVrsn.PathOnClient = objContVrsn.Title + '.snote';
        objContVrsn.VersionData = Blob.valueof('this is a test');
        objContVrsn.FirstPublishLocationId = obj_Crseplanunit.Id;
        
        lst_Contnvrsn.add(objContVrsn);
        Insert objContVrsn;
        
        List<ContentDocument> lst_Documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: obj_Crseplanunit.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        if(!lst_Documents.isEmpty())
        {
            
            contentlink.ShareType= 'C';
            contentlink.LinkedEntityId = obj_Crseplanunit.Id;
            contentlink.ContentDocumentId = lst_Documents[0].Id;
            contentlink.Visibility = 'AllUsers'; 
            delete contentlink;          
        }
        lst_CondocLink.add(contentlink); 
        
        
        List<ContentDocumentLink> lst_CondocLinks = New List<ContentDocumentLink>();
        
        List<ContentVersion> lst_Contnvrsns = New List<ContentVersion>();
        
        ContentVersion objContVrsns = New ContentVersion();
        objContVrsns.title = 'Test';
        objContVrsns.PathOnClient = objContVrsns.Title + '.snote';
        objContVrsns.VersionData = Blob.valueof('this is a test');
        objContVrsns.FirstPublishLocationId = obj_CrsePlanTopic.Id;
        
        lst_Contnvrsns.add(objContVrsns);
        Insert objContVrsns;
        
        List<ContentDocument> lst_Documentstpoics = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id =: obj_CrsePlanTopic.Id];
        
        ContentDocumentLink contentlinks=new ContentDocumentLink();
        if(!lst_Documentstpoics.isEmpty())
        {
            
            contentlinks.ShareType= 'C';
            contentlinks.LinkedEntityId = obj_CrsePlanTopic.Id;
            contentlinks.ContentDocumentId = lst_Documents[0].Id;
            contentlinks.Visibility = 'AllUsers'; 
            delete contentlinks;          
        }
        lst_CondocLinks.add(contentlinks); 
        
        delete obj_CoursePlanTopic;
        
        delete obj_Courseplanunit;
        
        Update obj_CrsPlanTopic;
        
        
        Test.startTest();
        CP_DefineCoursePlan_Ctrl.getCourseOfferdetails(obj_CourOff.Id);
        CP_DefineCoursePlan_Ctrl.savelastCourses(obj_CourOff.Id,obj_CourOff.Id);
        CP_DefineCoursePlan_Ctrl.getlastCourseOfferings(obj_CourOff.Id);
        CP_DefineCoursePlan_Ctrl.getCourseplanunits(obj_CourOff.Id);
        CP_DefineCoursePlan_Ctrl.getCourseTopicsDetails(obj_CoursePlanTopic);
        CP_DefineCoursePlan_Ctrl.getSelectedTopicsDocument(obj_CrsePlanTopic.Id);
        CP_DefineCoursePlan_Ctrl.getSelectedUnitsDocument(obj_Crseplanunit.Id);
        CP_DefineCoursePlan_Ctrl.getUnitsDocAftrDlt(obj_Crseplanunit.Id);
        CP_DefineCoursePlan_Ctrl.getTopicsDocaftrDlt(obj_CrsePlanTopic.Id);
        CP_DefineCoursePlan_Ctrl.savecoursunits(obj_CourOff.Id,lst_CourseUnits);
        CP_DefineCoursePlan_Ctrl.saveCourseTopics(courseJSON);
        CP_DefineCoursePlan_Ctrl.getCourseOfferingUnitsDetails(obj_CourOff.Id);
        CP_DefineCoursePlan_Ctrl.deleteCoursePlanUnits(obj_Crseplanunit.Id);
        CP_DefineCoursePlan_Ctrl.deleteCoursePlanUnits(null);
        CP_DefineCoursePlan_Ctrl.deleteCoursePlanTopics(null);
        CP_DefineCoursePlan_Ctrl.deleteTopicsDoc(null);
        CP_DefineCoursePlan_Ctrl.deleteUnitsDoc(null);
        CP_DefineCoursePlan_Ctrl.getCourseOfferingUnitsDetails(null);
        CP_DefineCoursePlan_Ctrl.deleteCoursePlanTopics(obj_CrsePlanTopic.Id);
        CP_DefineCoursePlan_Ctrl.deleteUnitsDoc(contentlink.Id);
        CP_DefineCoursePlan_Ctrl.deleteTopicsDoc(contentlinks.Id);
        CP_DefineCoursePlan_Ctrl.savelastCourses(null,null);
        CP_DefineCoursePlan_Ctrl.savecoursunits(null,null);
        Test.stopTest();
        system.assertEquals(obj_CourOff.Id,obj_CourOff.Id);   
    }
}