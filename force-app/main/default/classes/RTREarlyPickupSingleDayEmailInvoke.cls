public class RTREarlyPickupSingleDayEmailInvoke {
    @InvocableMethod(label='RTR Early Pickup Email Single Day Notifications' description='RTR Early Pickup Email Single Day Notifications')
    public static void RTREarlyPickupSingleDayEmail(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyPickupSingleDayEmail EmailEarlyPickUpsingleday = new RTREarlyPickupSingleDayEmail(recordIds);
            Id JobId = Database.executeBatch(EmailEarlyPickUpsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}