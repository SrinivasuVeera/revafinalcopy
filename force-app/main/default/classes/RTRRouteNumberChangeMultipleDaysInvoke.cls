public class RTRRouteNumberChangeMultipleDaysInvoke {
@InvocableMethod(label='RTR Route Number Change Multiple day SMS Notifications' description='RTR Route Number Change Multiple day SMS Notifications')
    public static void routeChangeSMSMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRRouteNumberChangeMultipleDays smsRouteChangeMultiple = new RTRRouteNumberChangeMultipleDays(recordIds);
            Id JobId = Database.executeBatch(smsRouteChangeMultiple, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}