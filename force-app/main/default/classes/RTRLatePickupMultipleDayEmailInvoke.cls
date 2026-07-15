public class RTRLatePickupMultipleDayEmailInvoke {
 @InvocableMethod(label='RTR Early Pickup Email Multiple Day Notifications' description='RTR Early Pickup Email Multiple Day Notifications')
    public static void RTRLatePickUPEmailMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLatePickUPEmailMultiple EmailLatePickUpMultipleday = new RTRLatePickUPEmailMultiple(recordIds);
            Id JobId = Database.executeBatch(EmailLatePickUpMultipleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}