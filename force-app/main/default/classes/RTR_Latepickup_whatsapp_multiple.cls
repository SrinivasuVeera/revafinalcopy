public class RTR_Latepickup_whatsapp_multiple {
 
     @InvocableMethod(label='RTR Send WhatsApp Notifications To late pickup' description='RTR Send notifications via WhatsApp To late pickup')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            //makeCalloutAsync(recordIds);
            RTRlatepickupBatchWhatsappMultiple batch = new RTRlatepickupBatchWhatsappMultiple(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
    }
}