trigger CoursePlanUnit_Trigger on Course_Plan_Unit__c (before insert,after insert,before delete) 
{
    if(trigger.IsBefore)
    {
        if(trigger.IsDelete)
        {
           CP_CoursePlanUnitSequenceHandler.generatecourseplanunitsequence(Trigger.old); 
        }
    }
    if(trigger.IsAfter)
    {
       if(trigger.IsInsert)
       {
           CP_CoursePlanUnitTriggerHandler.createCoursePlanTopics(Trigger.New);
       }
    }
    

}