public class RTREarlyDropOffMultipleDaysInvoke {
@InvocableMethod(label='RTR EarlyDrop Off Multiple Days SMS Notifications' description='RTR EarlyDrop Off Multiple Days SMS Notifications')
    public static void EarlyDropOffMultipleDays(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTReEarlyDropOffMultipleDays smsearlyDropmultiple = new RTReEarlyDropOffMultipleDays(recordIds);
            Id JobId = Database.executeBatch(smsearlyDropmultiple, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}