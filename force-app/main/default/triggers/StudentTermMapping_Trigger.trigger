trigger StudentTermMapping_Trigger on Student_Semester_Mapping__c (after insert) 
{
    if(Trigger.IsAfter)
    {
        if(Trigger.Isinsert)
        {
            MSTR_StudentTermMapping_Handler.deactiveSTM(Trigger.new);
            //MSTR_StudentTermMapping_Handler.mapStmToPrgmEnroll(Trigger.new);
            //MSTR_StudentTermMapping_Handler.CreateConSection(Trigger.New);
            //MSTR_StudentTermMapping_Handler.CreateConBatch(Trigger.New);
            //MSTR_StudentTermMapping_Handler.CreateConGroup(Trigger.New);
        }
    }
}