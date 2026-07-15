public class RTRLatePickupSMSInvoke {
	@InvocableMethod(label='RTR LatePickup SMS Notifications' description='RTR LatePickup SMS Notifications')
    public static void latePickSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLatePickupSMS smslatePick = new RTRLatePickupSMS(recordIds);
            Id JobId = Database.executeBatch(smslatePick, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}