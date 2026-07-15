public class RTRLatePickupSingleDayEmailInvoke {
	 @InvocableMethod(label='RTR Late Pickup Email Single Day Notifications' description='RTR Late Pickup Email Single Day Notifications')
    public static void RTRLatePickupSingleDayEmail(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLatePickupSingleDayEmail EmailLatePickUpsingleday = new RTRLatePickupSingleDayEmail(recordIds);
            Id JobId = Database.executeBatch(EmailLatePickUpsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}