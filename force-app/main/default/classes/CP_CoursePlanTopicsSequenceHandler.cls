public class CP_CoursePlanTopicsSequenceHandler 
{
    public static void generateTopicssequence(List<Course_Plan_Topic__c> lst_Topics)
    {
        set<Id> set_UnitIds = new set<Id>();
        set<Id> set_TopicIds = new set<Id>();
        List<Course_Plan_Topic__c> list_Topics = new List<Course_Plan_Topic__c>();
        
        for(Course_Plan_Topic__c objCourseplanTopic :lst_Topics)
        {
            set_UnitIds.add(objCourseplanTopic.Course_Plan_Unit__c); 
            set_TopicIds.add(objCourseplanTopic.Id);
        }
        if(!set_UnitIds.IsEmpty())
        {
            Integer IntseqNum = 0;
            for(Course_Plan_Topic__c objCoursePlan :[select Id,Name,Sequence_No__c,Course_Plan_Unit__c from Course_Plan_Topic__c
                                                     where (Course_Plan_Unit__c In : set_UnitIds and Id Not In :set_TopicIds) order by Sequence_No__c])
            {              
                IntseqNum = IntseqNum+1;
                objCoursePlan.Sequence_No__c = IntseqNum;
                list_Topics.add(objCoursePlan);                
            }
        }
        if(!list_Topics.IsEmpty())
        {
            update list_Topics;
        }
    }
}