public class CP_CoursePlanUnitTriggerHandler 
{
    public static void createCoursePlanTopics(List<Course_Plan_Unit__c> lst_crseunits)
    {
        set<Id> set_OldunitsIds = new set<Id>();
        Map<String, List<Course_Plan_Topic__c>> map_CoursePlanTopics = new Map<String, List<Course_Plan_Topic__c>>();
        Map<String, List<ContentDocumentLink>> map_DocumentLinks = new Map<String, List<ContentDocumentLink>>();
        List<ContentDocumentLink> lst_unitdocumentlinks = new List<ContentDocumentLink>();
        List<Course_Plan_Topic__c> lst_crseTopics = new List<Course_Plan_Topic__c>();
        List<Course_Plan_Unit__c> lstNewCoursePlanUnit = new List<Course_Plan_Unit__c>();
        
        for(Course_Plan_Unit__c objcourseunits : lst_crseunits)
        {
            if(objcourseunits.Old_unit_ID__c != null)
            {
                set_OldunitsIds.add(objcourseunits.Old_unit_ID__c);
                lstNewCoursePlanUnit.add(objcourseunits);
            }
        }
        //system.debug('==== Set Old Units ===='+set_OldunitsIds);
        if(!set_OldunitsIds.IsEmpty())
        {
            for(Course_Plan_Topic__c objTopics :[select Id,Name,Old_Unit_ID__c,Old_Topic_ID__c,Course_Plan_Unit__c
                                                 from Course_Plan_Topic__c where Course_Plan_Unit__c In : set_OldunitsIds ])
            {
                if(map_CoursePlanTopics.get(objTopics.Course_Plan_Unit__c) == Null)
                {
                    map_CoursePlanTopics.put(objTopics.Course_Plan_Unit__c, new List<Course_Plan_Topic__c>());
                }
                map_CoursePlanTopics.get(objTopics.Course_Plan_Unit__c).add(objTopics);
            }
            
            
            for(ContentDocumentLink objContentDocumentLink : [SELECT ContentDocumentId, LinkedEntityId, ShareType FROM
                                                              ContentDocumentLink where LinkedEntityId =: set_OldunitsIds])
            {
                if(map_DocumentLinks.get(objContentDocumentLink.LinkedEntityId) == Null)
                {
                    map_DocumentLinks.put(objContentDocumentLink.LinkedEntityId, new List<ContentDocumentLink>());
                }
                map_DocumentLinks.get(objContentDocumentLink.LinkedEntityId).add(objContentDocumentLink);
            }
            
           
            for(Course_Plan_Unit__c objcourseunits : lstNewCoursePlanUnit)
            {
                 integer topicsequence = 0;
                if(map_CoursePlanTopics.get(objcourseunits.Old_unit_ID__c) != Null)
                {
                    for(Course_Plan_Topic__c objCoursePlanTopic : map_CoursePlanTopics.get(objcourseunits.Old_unit_ID__c))
                    {
                        topicsequence = topicsequence +1;
                        Course_Plan_Topic__c objCourseTopics = new Course_Plan_Topic__c();
                        objCourseTopics.Name = objCoursePlanTopic.Name;
                        objCourseTopics.Old_Unit_ID__c = objCoursePlanTopic.Old_Unit_ID__c;
                        objCourseTopics.Old_Topic_ID__c = objCoursePlanTopic.Id;
                        objCourseTopics.Course_Plan_Unit__c = objcourseunits.Id;
                        objCourseTopics.Sequence_No__c = topicsequence;
                        lst_crseTopics.add(objCourseTopics);
                        
                    }
                }
                //system.debug('==== List Topics ====='+lst_crseTopics);
                if(map_DocumentLinks.get(objcourseunits.Old_unit_ID__c) != Null)
                {
                    for(ContentDocumentLink objContentDocumentLink : map_DocumentLinks.get(objcourseunits.Old_unit_ID__c))
                    {
                        ContentDocumentLink objNewConDocLink = new ContentDocumentLink();
                        objNewConDocLink.ContentDocumentId = objContentDocumentLink.ContentDocumentId;
                        objNewConDocLink.LinkedEntityId = objcourseunits.Id;
                        objNewConDocLink.ShareType = objContentDocumentLink.ShareType;
                        lst_unitdocumentlinks.add(objNewConDocLink);
                    }
                }
            }
            if(!lst_crseTopics.IsEmpty())
            {
                Database.Upsert(lst_crseTopics, Course_Plan_Topic__c.Old_Topic_ID__c);  
            }
            
            if(!lst_unitdocumentlinks.IsEmpty())
            {
                Insert lst_unitdocumentlinks; 
            }
        }
    }
    
   
}