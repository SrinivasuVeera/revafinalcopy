public class RTR_WhatsappNotifyParent_Bus_Cancelled {
 @InvocableMethod(label='RTR Send WhatsApp Notifications To Bus Cancelled Parent' description='RTR Send notifications via WhatsApp To Bus Cancelled Parent')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTRbus_cancelled_for_single_day_parent1 batch = new RTRbus_cancelled_for_single_day_parent1(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}