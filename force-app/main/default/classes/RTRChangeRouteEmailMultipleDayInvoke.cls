public class RTRChangeRouteEmailMultipleDayInvoke {
	@InvocableMethod(label='RTR Change Route Multiple day Email Notifications' description='RTR Change Route Multiple day Email Notifications')
    public static void routeChangeEmailMultipleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRChangeRouteEmailMultipleDayEmail RouteChangeEmailMultipleDay = new RTRChangeRouteEmailMultipleDayEmail(recordIds);
            Id JobId = Database.executeBatch(RouteChangeEmailMultipleDay, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}