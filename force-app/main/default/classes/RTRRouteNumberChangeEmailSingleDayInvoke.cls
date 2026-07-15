public class RTRRouteNumberChangeEmailSingleDayInvoke {
	@InvocableMethod(label='RTR Route Number Change Single day Email Notifications' description='RTR Route Number Change Single day Email Notifications')
    public static void routeChangeEmailSingleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRRouteNumberChangeEmailSingleDay RouteChangeEmailSingleDay = new RTRRouteNumberChangeEmailSingleDay(recordIds);
            Id JobId = Database.executeBatch(RouteChangeEmailSingleDay, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}