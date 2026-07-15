global class MSTR_MappingSTMtoProgmEnroll_Schedule implements Schedulable 
{
	global void execute(SchedulableContext sc)
    {
        MSTR_MappingSTMtoProgmEnroll_Batch objMapProgEnroll = new MSTR_MappingSTMtoProgmEnroll_Batch();
        Database.executeBatch(objMapProgEnroll, 200);
    }
}