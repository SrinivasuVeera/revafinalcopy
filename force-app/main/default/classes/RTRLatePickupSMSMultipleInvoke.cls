public class RTRLatePickupSMSMultipleInvoke {
	@InvocableMethod(label='RTR LatePickupMultiple SMS Notifications' description='RTR LatePickupMultiple SMS Notifications')
    public static void LatePickupMultiple(List<String> recordIds){
        System.debug('recordIds' +recordIds);
        if(recordIds!=null){
            System.debug('Start');
            RTRLatePickupMultipleDays smslatePickmultiple = new RTRLatePickupMultipleDays(recordIds);
            Id JobId = Database.executeBatch(smslatePickmultiple, 200);
            System.debug('JobId-->> '+JobId);
            System.debug('End');
        }
    }
}