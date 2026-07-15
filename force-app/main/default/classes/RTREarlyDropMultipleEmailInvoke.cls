public class RTREarlyDropMultipleEmailInvoke {
@InvocableMethod(label='RTR Early Drop Email Multiple Day Notifications' description='RTR Early Drop Email Multiple Day Notifications')
    public static void RTREarlyDropMultipleDayEmail(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyDropMultipleDayEmail EmailEarlyDropMultipleday = new RTREarlyDropMultipleDayEmail(recordIds);
            Id JobId = Database.executeBatch(EmailEarlyDropMultipleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}