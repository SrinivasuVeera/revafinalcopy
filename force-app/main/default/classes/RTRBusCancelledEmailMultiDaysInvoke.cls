public class RTRBusCancelledEmailMultiDaysInvoke {
@InvocableMethod(label='RTR Cancelled Email Multiple Day Notifications' description='RTR Cancelled Email Multiple Day Notifications')
    public static void cancelledEmailMultipleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusCancelledEmailMultipleDays Emailcancelledmultipleday = new RTRBusCancelledEmailMultipleDays(recordIds);
            Id JobId = Database.executeBatch(Emailcancelledmultipleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}