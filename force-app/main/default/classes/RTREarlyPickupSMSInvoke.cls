public class RTREarlyPickupSMSInvoke {
	@InvocableMethod(label='RTR EarlyPickup SMS Notifications' description='RTR EarlyPickup SMS Notifications')
    public static void earlyPickSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyPickUPSMS smsEarlyPick = new RTREarlyPickUPSMS(recordIds);
            Id JobId = Database.executeBatch(smsEarlyPick, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}