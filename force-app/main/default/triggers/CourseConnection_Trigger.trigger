trigger CourseConnection_Trigger on hed__Course_Enrollment__c (after Insert,after Update,after Delete,after Undelete, before delete) 
{
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            MSTR_CourseConnection_TrigHandlr.RollupCourseConnection(Trigger.new,Null);
            ASM_CrsConnTrgHandler.rollupCounttoCourseOffer(Trigger.new,null);
        }
        else if(trigger.isUpdate)
        {
            MSTR_CourseConnection_TrigHandlr.RollupCourseConnection(Trigger.new,Trigger.oldMap);
            MSTR_CourseConnection_TrigHandlr.DeleteStudentSemester(Trigger.New, Trigger.OldMap);
            ASM_CrsConnTrgHandler.sendToLogisysUpdate(Trigger.New, Trigger.OldMap);
             ASM_CrsConnTrgHandler.rollupCounttoCourseOffer(Trigger.new,Trigger.OldMap);
        }
        else if(trigger.isDelete)
        {
            MSTR_CourseConnection_TrigHandlr.RollupCourseConnection(Trigger.Old,Null);  
            ASM_CrsConnTrgHandler.rollupCounttoCourseOffer(Trigger.old,null);
        }
        else if(trigger.isUndelete)
        {
            MSTR_CourseConnection_TrigHandlr.RollupCourseConnection(Trigger.new,Null);  
            ASM_CrsConnTrgHandler.rollupCounttoCourseOffer(Trigger.new,null);
        }
    }
    if(Trigger.IsBefore){
        if(trigger.isdelete){
            ASM_CrsConnTrgHandler.sendToLogisysDelete(Trigger.old);
        }
    }
}