public class RTR_WhatsappNotification_lateDropoff {
    @InvocableMethod(label='RTR Send WhatsApp Notifications To latedropoff' description='RTR Send notifications via WhatsApp To latedropoff')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
            //makeCalloutAsync(recordIds);
            
            RTRLateDropOffBatchNotification batch = new RTRLateDropOffBatchNotification(recordIds[0]);
           Database.executeBatch(batch,100);
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }

}