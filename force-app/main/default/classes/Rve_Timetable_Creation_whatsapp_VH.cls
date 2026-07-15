public class Rve_Timetable_Creation_whatsapp_VH {
    
		@InvocableMethod(label=' Send WhatsApp Notifications To VH after creation of timetable' description='Send WhatsApp Notifications To VH after creation of timetable')
    public static void trsWhatsappNotification(list<list<String>> recordIds){
        
        if(recordIds.size()>0){            
            // makeCalloutAsync( recordIds);   
           Rve_Timetable_Creation_whatsapp_VH_Batch batch = new Rve_Timetable_Creation_whatsapp_VH_Batch(recordIds[0]);
           Database.executeBatch(batch,98);        
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
}