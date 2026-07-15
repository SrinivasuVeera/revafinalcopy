public class RTRWhatsappNotify_RouteChageMultipleVia {
@InvocableMethod(label='RTR Send WhatsApp Notifications To Route Change Multiple Via' description='RTR Send notifications via WhatsApp To Route Change Multiple Via')
    public static void trsWhatsappNotification(List<String> recordIds){
        if(recordIds[0]!=null){
            
           // makeCalloutAsync(recordIds);
            
            RTRchange_of_route_for_mul_day_Via batch = new RTRchange_of_route_for_mul_day_Via(recordIds[0]);
            Database.executeBatch(batch);
        }else{
            System.debug('RecordIds List is Empty');
        }
}
}