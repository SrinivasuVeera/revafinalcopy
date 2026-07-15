public class RTRLateDropSingleDayParentSMSInvoke {
    @InvocableMethod(label='RTR LateDrop single day parent SMS Notifications' description='RTR LateDrop single day parent SMS Notifications')
    public static void lateDropsingledayparentSMS(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropSingleDayParentSMS smsLateDropsingledayparent = new RTRLateDropSingleDayParentSMS(recordIds);
            Id JobId = Database.executeBatch(smsLateDropsingledayparent, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }

}