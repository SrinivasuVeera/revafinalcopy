public class RTRBusServiceDisruptionSMSInvoke {
@InvocableMethod(label='RTR Bus Service disruption During Trip SMS Notifications' description='RTR Bus Service disruption During Trip SMS Notifications')
    public static void busdisrptionSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRBusServiceDisruptionSMS smsRouteChange = new RTRBusServiceDisruptionSMS(recordIds);
            Id JobId = Database.executeBatch(smsRouteChange, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}