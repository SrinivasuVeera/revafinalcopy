public class RTRLateDropMultipleDaysParentInvoke {
@InvocableMethod(label='RTR LateDrop Multiple Days Parent SMS Notifications' description='RTR LateDrop Multiple Days Parent SMS Notifications')
    public static void lateDropsingledayparentSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropOffMultipleDaysParentSMS smsLateDropmultipledayparent = new RTRLateDropOffMultipleDaysParentSMS(recordIds);
            Id JobId = Database.executeBatch(smsLateDropmultipledayparent, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}