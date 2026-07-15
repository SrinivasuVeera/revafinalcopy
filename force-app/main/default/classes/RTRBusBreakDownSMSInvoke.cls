public class RTRBusBreakDownSMSInvoke {
@InvocableMethod(label='RTR Bus break down SMS Notifications' description='RTR Bus break down During Trip SMS Notifications')
    public static void busbreakdownSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusBreakDownSMS smsRouteChange = new RTRBusBreakDownSMS(recordIds);
            Id JobId = Database.executeBatch(smsRouteChange, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}