public class RTR_WhatsappNotify_RouteChangeSingle {
@InvocableMethod(label='RTR Send WhatsApp Notifications To Route Change' description='RTR Send notifications via WhatsApp To Route Change')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTRchange_of_route_number_single_day batch = new RTRchange_of_route_number_single_day(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}