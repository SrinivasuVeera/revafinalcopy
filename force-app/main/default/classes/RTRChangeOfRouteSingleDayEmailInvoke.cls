public class RTRChangeOfRouteSingleDayEmailInvoke {
	@InvocableMethod(label='RTR Change of Route Single day Email Notifications' description='RTR Change of Route Single day Email Notifications')
    public static void routeChangeEmailSingleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRChangeOfRouteSingleDayEmail RouteChangeEmailSingleDay = new RTRChangeOfRouteSingleDayEmail(recordIds);
            Id JobId = Database.executeBatch(RouteChangeEmailSingleDay, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}