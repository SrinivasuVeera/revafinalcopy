global class TT_AttendanceSMS_Batch_Sch implements Schedulable 
{
    global Set<Id> set_AttndEvtIds = new Set<Id>();
    global void execute(SchedulableContext sc)
    {
        TT_AttendanceSMS_Batch SchCls = new TT_AttendanceSMS_Batch(set_AttndEvtIds);
        DataBase.executeBatch(SchCls,50);
    }
}