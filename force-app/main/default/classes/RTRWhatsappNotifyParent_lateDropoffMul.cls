public class RTRWhatsappNotifyParent_lateDropoffMul {
@InvocableMethod(label='RTR Send WhatsApp Notifications To latedropoff Parent Multiple Days' description='RTR Send notifications via WhatsApp To latedropoff Parent Multiple Days')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
            //makeCalloutAsync(recordIds);
            
            RTRLateDropBatchParentwhatsappMul batch = new RTRLateDropBatchParentwhatsappMul(recordIds[0]);
           Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
}