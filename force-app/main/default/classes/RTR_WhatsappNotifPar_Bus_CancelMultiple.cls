public class RTR_WhatsappNotifPar_Bus_CancelMultiple {
 @InvocableMethod(label='RTR Send WhatsApp Parent Notifications To Bus Cancelled' description='RTR Send notifications Parent via WhatsApp To Bus Cancelled')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTR_bus_cancelled_multiple_days_parent batch = new RTR_bus_cancelled_multiple_days_parent(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}