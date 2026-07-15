public class RTR_WhatsappNotif_Bus_CancelMultiple {
 @InvocableMethod(label='RTR Send WhatsApp Notifications To Bus Cancelled' description='RTR Send notifications via WhatsApp To Bus Cancelled')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTRCanceledBatchwhatsappMultiple batch = new RTRCanceledBatchwhatsappMultiple(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}