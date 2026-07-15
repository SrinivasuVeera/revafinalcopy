trigger CoursePlanTopic_Trigger on Course_Plan_Topic__c (after insert,before delete) 
{
    if(trigger.IsBefore)
    {
        if(trigger.IsDelete)
        {
          CP_CoursePlanTopicsSequenceHandler.generateTopicssequence(Trigger.Old);              
        }        
    }
    if(trigger.IsAfter)
    {
        if(trigger.IsInsert)
        {
            CP_CoursePlanTopicTriggerHandler.createTopicsDocuments(Trigger.New);
            CP_CoursePlanTopicTriggerHandler.updateTopicsSequence(Trigger.New);
        }
    }

}