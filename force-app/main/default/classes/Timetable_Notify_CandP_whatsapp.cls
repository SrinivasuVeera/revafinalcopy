public class Timetable_Notify_CandP_whatsapp {
    
    
		@InvocableMethod
    public static void trsWhatsappNotification(list<String> recordIds){
        
        if(recordIds[0]!=null){            
            // makeCalloutAsync( recordIds);   
           Timetable_Notify_CandP_whatsapp_batch batch = new Timetable_Notify_CandP_whatsapp_batch(recordIds[0]);
           Database.executeBatch(batch,24);        
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }

}