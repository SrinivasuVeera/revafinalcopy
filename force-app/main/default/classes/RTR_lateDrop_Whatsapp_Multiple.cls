public class RTR_lateDrop_Whatsapp_Multiple {
      @InvocableMethod(label='RTR Send WhatsApp Notifications To latedropoff' description='RTR Send notifications via WhatsApp To latedropoff')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
            //makeCalloutAsync(recordIds);
            
            RTRLateDropBatchwhatsappMultiple batch = new RTRLateDropBatchwhatsappMultiple(recordIds[0]);
           Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }

}