public class RTR_WhatsappNotify_RouteChangeSingleVia {
@InvocableMethod(label='RTR Send WhatsApp Notifications To Route Change Via' description='RTR Send notifications via WhatsApp To Route Change Via')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTR_change_of_route_single_day_Via batch = new RTR_change_of_route_single_day_Via(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}