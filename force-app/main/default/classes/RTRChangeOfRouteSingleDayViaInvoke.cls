public class RTRChangeOfRouteSingleDayViaInvoke {
@InvocableMethod(label='RTR Route Change single day via SMS Notifications' description='RTR Route Change single day via SMS Notifications')
    public static void routeChangeSMSSingleDayvia(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRChangeOfRouteSingleDayVia smsRouteChangeSingleDayvia = new RTRChangeOfRouteSingleDayVia(recordIds);
            Id JobId = Database.executeBatch(smsRouteChangeSingleDayvia, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}