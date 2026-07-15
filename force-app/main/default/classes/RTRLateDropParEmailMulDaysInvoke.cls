public class RTRLateDropParEmailMulDaysInvoke {
@InvocableMethod(label='RTR Late Drop Parent Email Multiple Day Notifications' description='RTR Late Drop Parent Email Multiple Day Notifications')
    public static void RTRLateDropParentEmailMultipleDay(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLateDropParentEmailMultipleDays EmailLateDropsingleday = new RTRLateDropParentEmailMultipleDays(recordIds);
            Id JobId = Database.executeBatch(EmailLateDropsingleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}