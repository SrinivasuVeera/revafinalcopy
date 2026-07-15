public class RTR_WhatsappNotify_RouteChangeMultiple {
@InvocableMethod(label='RTR Send WhatsApp Notifications To Route Change' description='RTR Send notifications via WhatsApp To Route Change')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTR_route_number_change_multiple_days batch = new RTR_route_number_change_multiple_days(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}