public class RTRLateDropSMSInvoke {
	@InvocableMethod(label='RTR LateDrop SMS Notifications' description='RTR LateDrop SMS Notifications')
    public static void lateDropSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropSMS smsLateDrop = new RTRLateDropSMS(recordIds);
            Id JobId = Database.executeBatch(smsLateDrop, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}