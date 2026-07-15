public class RTR_WhatsappNotification_Bus_Cancelled {
 @InvocableMethod(label='RTR Send WhatsApp Notifications To Bus Cancelled' description='RTR Send notifications via WhatsApp To Bus Cancelled')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTRBusCancelledBatchNotification batch = new RTRBusCancelledBatchNotification(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}