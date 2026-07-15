public class RTR_Whatsapp_early_PickUpMultiple {
 @InvocableMethod(label='RTR Send WhatsApp Notifications To early drop off' description='RTR Send notifications via WhatsApp To early drop off')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTREarlyPickUpMultipleBatchNotification batch = new RTREarlyPickUpMultipleBatchNotification(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
}