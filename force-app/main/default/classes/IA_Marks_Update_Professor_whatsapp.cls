public class IA_Marks_Update_Professor_whatsapp {
    
    @InvocableMethod(label=' Send WhatsApp Notifications To VH after creation of timetable' description='Send WhatsApp Notifications To VH after creation of timetable')
    public static void trsWhatsappNotification(list<list<String>> recordIds){
        System.debug('recordIds=> '+recordIds);
        // if(recordIds[0]!=null){ 
        if(recordIds.size()>0){ 
            IA_Marks_Update_Professor_whatsapp_batch batch = new IA_Marks_Update_Professor_whatsapp_batch(recordIds[0]);
            Database.executeBatch(batch,98);        
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
    
}