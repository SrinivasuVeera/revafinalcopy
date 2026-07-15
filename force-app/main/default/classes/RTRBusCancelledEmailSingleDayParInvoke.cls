public class RTRBusCancelledEmailSingleDayParInvoke {
	@InvocableMethod(label='RTR Cancelled Email Single Day Parent Notifications' description='RTR Cancelled Email Single Day Parent Notifications')
    public static void cancelledEmailSingleDayParent(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusCancelledSingleDayParent EmailcancelledsingledayParent = new RTRBusCancelledSingleDayParent(recordIds);
            Id JobId = Database.executeBatch(EmailcancelledsingledayParent, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}