public class RTRCancelledSMSMultipleDaysInvoke {
    @InvocableMethod(label='RTR Cancelled MultipleDays SMS Notifications' description='RTR Cancelled MultipleDays SMS Notifications')
    public static void cancelledSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRCancelledSMSMultipleDays smscancelled = new RTRCancelledSMSMultipleDays(recordIds);
            Id JobId = Database.executeBatch(smscancelled, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}