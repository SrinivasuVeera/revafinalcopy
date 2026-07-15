public class RTRBusCancelledEmailMulDayParentInvoke {
	@InvocableMethod(label='RTR Cancelled Email Multiple Day Parent Notifications' description='RTR Cancelled Email Multiple Day Parent Notifications')
    public static void cancelledEmailMultipleDayParent(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusCancelledEmailMultipleDayParent EmailcancelledmultipledayParent = new RTRBusCancelledEmailMultipleDayParent(recordIds);
            Id JobId = Database.executeBatch(EmailcancelledmultipledayParent, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}