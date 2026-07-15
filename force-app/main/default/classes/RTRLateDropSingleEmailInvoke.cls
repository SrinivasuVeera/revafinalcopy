public class RTRLateDropSingleEmailInvoke {
	@InvocableMethod(label='RTR Late Drop Email Single Day Notifications' description='RTR Late Drop Email Single Day Notifications')
    public static void RTRLateDropSingleDayEmail(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropSignleDayEmail EmailLateDropsingleday = new RTRLateDropSignleDayEmail(recordIds);
            Id JobId = Database.executeBatch(EmailLateDropsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}