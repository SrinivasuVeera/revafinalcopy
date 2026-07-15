public class RTRRouteNumChangeEmailMulDaysInvoke {
@InvocableMethod(label='RTR Route Number Change Multiple day Email Notifications' description='RTR Route Number Change Multiple day Email Notifications')
    public static void routeChangeEmailMultipleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRRouteNumberChangeEmailMultipleDays RouteChangeEmailMultipleDay = new RTRRouteNumberChangeEmailMultipleDays(recordIds);
            Id JobId = Database.executeBatch(RouteChangeEmailMultipleDay, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}