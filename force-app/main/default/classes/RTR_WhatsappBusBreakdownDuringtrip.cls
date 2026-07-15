public class RTR_WhatsappBusBreakdownDuringtrip {
@InvocableMethod(label='RTR Send WhatsApp Notifications To BusBreakdownDuringtrip' description='RTR Send notifications via WhatsApp To BusBreakdownDuringtrip')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTR_BusBreakdownDuringtrip batch = new RTR_BusBreakdownDuringtrip(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}