public class RTRLateDropEmailMultipleDayInvoke {
	 @InvocableMethod(label='RTR Late Drop Email Multiple Day Notifications' description='RTR Late Drop Email Multiple Day Notifications')
    public static void RTRLateDropEmailMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropEmailMultipleDays EmailLateDropMultipleday = new RTRLateDropEmailMultipleDays(recordIds);
            Id JobId = Database.executeBatch(EmailLateDropMultipleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}