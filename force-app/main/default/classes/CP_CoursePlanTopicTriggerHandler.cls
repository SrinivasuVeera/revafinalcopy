public class CP_CoursePlanTopicTriggerHandler 
{
    public static void createTopicsDocuments(List<Course_Plan_Topic__c> lst_CourseTopics)
    {
        set<Id> set_TopicIds = new set<Id>();
        List<Course_Plan_Topic__c> list_filtrTopics = new List<Course_Plan_Topic__c>();
        Map<String, List<ContentDocumentLink>> map_DocumentLinks = new Map<String, List<ContentDocumentLink>>();
        List<ContentDocumentLink> lst_topicsdocumentlinks = new List<ContentDocumentLink>();
        
        for(Course_Plan_Topic__c objCrseTopics : lst_CourseTopics)
        {
            if(objCrseTopics.Old_Topic_ID__c != null)
            {
                set_TopicIds.add(objCrseTopics.Old_Topic_ID__c); 
                list_filtrTopics.add(objCrseTopics);
            }
        }
        
        if(!set_TopicIds.IsEmpty())
        {
            for(ContentDocumentLink objContentDocumentLink : [SELECT ContentDocumentId, LinkedEntityId, ShareType FROM
                                                              ContentDocumentLink where LinkedEntityId =: set_TopicIds])
            {
                if(map_DocumentLinks.get(objContentDocumentLink.LinkedEntityId) == Null)
                {
                    map_DocumentLinks.put(objContentDocumentLink.LinkedEntityId, new List<ContentDocumentLink>());
                }
                map_DocumentLinks.get(objContentDocumentLink.LinkedEntityId).add(objContentDocumentLink);
            }
            
            for(Course_Plan_Topic__c objCrsePlanTopics : list_filtrTopics)
            {
                if(map_DocumentLinks.get(objCrsePlanTopics.Old_Topic_ID__c) != null)
                {
                    for(ContentDocumentLink objContentDocumentLink : map_DocumentLinks.get(objCrsePlanTopics.Old_Topic_ID__c))
                    {
                        ContentDocumentLink objNewConDocLink = new ContentDocumentLink();
                        objNewConDocLink.ContentDocumentId = objContentDocumentLink.ContentDocumentId;
                        objNewConDocLink.LinkedEntityId = objCrsePlanTopics.Id;
                        objNewConDocLink.ShareType = objContentDocumentLink.ShareType;
                        lst_topicsdocumentlinks.add(objNewConDocLink);
                    }
                }
            }
            
            if(!lst_topicsdocumentlinks.IsEmpty())
            {
                Insert lst_topicsdocumentlinks;
            }
        }
    }
    public static void updateTopicsSequence(List<Course_Plan_Topic__c> lst_CourseTopics)
    {
        set<Id> set_UnitIds = new set<Id>();
        List<Course_Plan_Topic__c> lst_Topic = new List<Course_Plan_Topic__c>();
        for(Course_Plan_Topic__c objTopic : lst_CourseTopics)
        {
            set_UnitIds.add(objTopic.Course_Plan_Unit__c);
        }
        
        //system.debug('====>>>'+set_UnitIds);
        if(set_UnitIds.size() > 0)
        {
            for(Course_Plan_Unit__c objCoursePlanUnit : [select Id,(select id,Sequence_No__c from Course_Plan_Topics__r) from Course_Plan_Unit__c where Id IN: set_UnitIds order by Id])
            {
                integer topicsequence = 0;
                //system.debug('====>>>'+objCoursePlanUnit.Course_Plan_Topics__r);
                for(Course_Plan_Topic__c objTopic : objCoursePlanUnit.Course_Plan_Topics__r)
                {      
                    topicsequence = topicsequence+1;
                    objTopic.Sequence_No__c = topicsequence;     
                    //system.debug('====>>>'+objCoursePlanUnit.Course_Plan_Topics__r);
                    lst_Topic.add(objTopic);
                }
            }
        }       
       if(lst_Topic.size() > 0) update lst_Topic;
    }
}