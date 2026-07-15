public class RTRLateDropParentSingleEmailInvoke {
@InvocableMethod(label='RTR Late Drop Parent Email Single Day Notifications' description='RTR Late Drop Parent Email Single Day Notifications')
    public static void RTRLateDropSingleDayParent(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropSingleDayParent EmailLateDropsingleday = new RTRLateDropSingleDayParent(recordIds);
            Id JobId = Database.executeBatch(EmailLateDropsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}