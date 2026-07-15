public class RTR_WhatsappNotify_lateDropoff {
 @InvocableMethod(label='RTR Send WhatsApp Notifications To latedropoff Parent single day' description='RTR Send notifications via WhatsApp To latedropoff Parent single day')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
            //makeCalloutAsync(recordIds);
            
            RTRLateDropOffParentBatchNotify batch = new RTRLateDropOffParentBatchNotify(recordIds[0]);
           Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
}