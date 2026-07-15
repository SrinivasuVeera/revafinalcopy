public class RTREarlyDropSingleEmailInvoke {
	@InvocableMethod(label='RTR Early Drop Email Single Day Notifications' description='RTR Early Drop Email Single Day Notifications')
    public static void RTREarlyDropSingleDayEmail(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyDropSingleDayEmail EmailEarlyDropsingleday = new RTREarlyDropSingleDayEmail(recordIds);
            Id JobId = Database.executeBatch(EmailEarlyDropsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}