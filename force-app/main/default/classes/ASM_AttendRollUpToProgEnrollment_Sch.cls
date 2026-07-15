global class ASM_AttendRollUpToProgEnrollment_Sch implements Schedulable
{
    global void execute(SchedulableContext Sc)
    {
        ASM_AttendRollUpToProgEnrollment schls = new ASM_AttendRollUpToProgEnrollment();
        Database.executeBatch(schls,200);
    }
}