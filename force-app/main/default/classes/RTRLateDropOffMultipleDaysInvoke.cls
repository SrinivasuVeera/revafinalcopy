public class RTRLateDropOffMultipleDaysInvoke {
	@InvocableMethod(label='RTR LateDropOff Multiple SMS Notifications' description='RTR LateDropOff Multiple SMS Notifications')
    public static void lateDropSMSMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropOffMultipleDays smsLateDropOffMultiple = new RTRLateDropOffMultipleDays(recordIds);
            Id JobId = Database.executeBatch(smsLateDropOffMultiple, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}