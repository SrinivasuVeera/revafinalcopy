public class RTREarlyPickupMultipleDayEmailInvoke {
		 @InvocableMethod(label='RTR Early Pickup Email Multiple Day Notifications' description='RTR Early Pickup Email Multiple Day Notifications')
    public static void RTREarlyPickUPEmailMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTREarlyPickUPEmailMultiple EmailEarlyPickUpMultipleday = new RTREarlyPickUPEmailMultiple(recordIds);
            Id JobId = Database.executeBatch(EmailEarlyPickUpMultipleday, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}