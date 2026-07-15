public class RTRBusCancelledEmailSingleDayInvoke {
    @InvocableMethod(label='RTR Cancelled Email Single Day Notifications' description='RTR Cancelled Email Single Day Notifications')
    public static void cancelledEmailSingleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusCancelledSingleDayEmail Emailcancelledsingleday = new RTRBusCancelledSingleDayEmail(recordIds);
            Id JobId = Database.executeBatch(Emailcancelledsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}