public class RTREarlyPickupMultipleSMSInvoke {
@InvocableMethod(label='RTR EarlyPickup Multiple SMS Notifications' description='RTR EarlyPickup Multiple SMS Notifications')
    public static void earlyPickSMSMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyPickUPSMSMultiple smsEarlyPickMultiple = new RTREarlyPickUPSMSMultiple(recordIds);
            Id JobId = Database.executeBatch(smsEarlyPickMultiple, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}