public class RTR_Whatsappbusservicedisruptiontrip {
@InvocableMethod(label='RTR Send WhatsApp Notifications To busservicedisruptionbeforetrip' description='RTR Send notifications via WhatsApp To busservicedisruptionbeforetrip')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTR_busservicedisruptionbeforetrip batch = new RTR_busservicedisruptionbeforetrip(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}