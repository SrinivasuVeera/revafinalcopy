trigger iaMarksTrigger on IA_Marks__c (after insert, after update, after delete, after undelete) {
    if(Trigger.IsAfter){
        if(Trigger.IsInsert){
            ASM_IAMarksTrgHandler.rollupCounttoCourseOf(Trigger.new, null);
            ASM_IAMarksTrgHandler.rollupStudentPushedToLogisys(Trigger.New, null);
        }
        if(Trigger.IsUpdate){
            ASM_IAMarksTrgHandler.rollupCounttoCourseOf(Trigger.new, Trigger.oldMap);
            ASM_IAMarksTrgHandler.rollupStudentPushedToLogisys(Trigger.New, Trigger.oldMap);
            ASM_IAMarksTrgHandler.UncheckPushToLogisys(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.IsDelete){
            ASM_IAMarksTrgHandler.rollupCounttoCourseOf(Trigger.old, null);
            ASM_IAMarksTrgHandler.rollupStudentPushedToLogisys(Trigger.Old, null);
        }
        if(Trigger.IsUndelete){
            ASM_IAMarksTrgHandler.rollupCounttoCourseOf(Trigger.new, null);
            ASM_IAMarksTrgHandler.rollupStudentPushedToLogisys(Trigger.New, null);
        }
    }
}