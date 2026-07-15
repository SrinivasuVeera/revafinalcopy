global class MSTR_UpdateCourConBtch_Sch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        MSTR_UpdateCourseConnectionSRN_Batch objCourseConn = new MSTR_UpdateCourseConnectionSRN_Batch();
        Database.executeBatch(objCourseConn,1);
    }
}