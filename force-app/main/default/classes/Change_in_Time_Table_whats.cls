public class Change_in_Time_Table_whats {
    
    		@InvocableMethod(label=' Send WhatsApp Notifications To VH after creation of timetable' description='Send WhatsApp Notifications To VH after creation of timetable')
    public static void trsWhatsappNotification(list<String> recordIds){
        
        if(recordIds[0]!=null){            
            // makeCalloutAsync( recordIds);   
           Change_in_Time_Table_whats_batch batch = new Change_in_Time_Table_whats_batch(recordIds[0]);
           Database.executeBatch(batch);        
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }

}