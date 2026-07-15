public class RTR_WhatsappNotification_Earlypickup {
     @InvocableMethod(label='RTR Send WhatsApp Notifications To early pick up' description='RTR Send notifications via WhatsApp To earlypickup')
    public static void trsWhatsappNotification(list<String> recordIds){
        if(recordIds[0]!=null){
      //  makeCalloutAsync(recordIds);
           RTREarlypickupBatchNotification batch = new RTREarlypickupBatchNotification(recordIds[0]);
           Database.executeBatch(batch);
            
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }   
}