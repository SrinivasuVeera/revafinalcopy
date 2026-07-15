public class RTRCancelledSMSInvoke {
    @InvocableMethod(label='RTR Cancelled SMS Notifications' description='RTR Cancelled SMS Notifications')
    public static void cancelledSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRCancelledSMS smscancelled = new RTRCancelledSMS(recordIds);
            Id JobId = Database.executeBatch(smscancelled, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}