public class RTRCancelledParentSingleDaySMSInvoke {
	@InvocableMethod(label='RTR Cancelled Single Day Parent SMS Notifications' description='RTR Cancelled Single Day Parent SMS Notifications')
    public static void cancelledSMSParent(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRCancelledParentSingleDaySMS smscancelledParentsms = new RTRCancelledParentSingleDaySMS(recordIds);
            Id JobId = Database.executeBatch(smscancelledParentsms, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}