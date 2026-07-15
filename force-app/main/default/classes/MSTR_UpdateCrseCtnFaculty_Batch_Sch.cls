global class MSTR_UpdateCrseCtnFaculty_Batch_Sch implements Schedulable
{
    global void execute (SchedulableContext sc)
    {
         MSTR_UpdateCourseConnectionFaculty_Batch  sch = New MSTR_UpdateCourseConnectionFaculty_Batch();
         Database.executeBatch(sch,1);
    }
}