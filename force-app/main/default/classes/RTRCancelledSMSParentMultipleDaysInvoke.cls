public class RTRCancelledSMSParentMultipleDaysInvoke {
@InvocableMethod(label='RTR Cancelled MultipleDays Parent SMS Notifications' description='RTR Cancelled MultipleDays Parent SMS Notifications')
    public static void cancelledSMSMultipleDaysParent(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRCancelledSMSParentMultipleDays smscancelledParent = new RTRCancelledSMSParentMultipleDays(recordIds);
            Id JobId = Database.executeBatch(smscancelledParent, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}