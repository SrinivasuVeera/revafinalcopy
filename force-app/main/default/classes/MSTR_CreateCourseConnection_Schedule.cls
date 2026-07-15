global class MSTR_CreateCourseConnection_Schedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        MSTR_CreateCourseConnection_Batch objCreateConn = new MSTR_CreateCourseConnection_Batch();
        Database.executeBatch(objCreateConn, 1);
    }
}