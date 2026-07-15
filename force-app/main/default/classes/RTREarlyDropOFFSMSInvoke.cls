public class RTREarlyDropOFFSMSInvoke {
	@InvocableMethod(label='RTR Early Drop Off SMS Notifications' description='RTR Early Drop Off SMS Notifications')
    public static void EarlyDropOffSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyDropOffSMS smslatePick = new RTREarlyDropOffSMS(recordIds);
            Id JobId = Database.executeBatch(smslatePick, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}