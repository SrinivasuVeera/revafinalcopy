public class RTRChangeOfRouteMultipleDaysViaInvoke {
	@InvocableMethod(label='RTR Route Change Multiple day via SMS Notifications' description='RTR Route Change Multiple day via SMS Notifications')
    public static void routeChangeSMSMultipleDayvia(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRChangeOfRouteMultipleDaysVia smsRouteChangeMultipleDayvia = new RTRChangeOfRouteMultipleDaysVia(recordIds);
            Id JobId = Database.executeBatch(smsRouteChangeMultipleDayvia, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}