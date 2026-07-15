public class RTRRouteNumberChangeSingleDaySMSInvoke {
	@InvocableMethod(label='RTR Route Number Change Single day SMS Notifications' description='RTR Route Number Change Single day SMS Notifications')
    public static void routeChangeSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRRouteNumberChangeSingleday smsRouteChange = new RTRRouteNumberChangeSingleday(recordIds);
            Id JobId = Database.executeBatch(smsRouteChange, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}