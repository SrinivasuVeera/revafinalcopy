public class Push_Course_Logisys_whatsapp {
    
    @InvocableMethod
    public static void trsWhatsappNotification(list<list<String>> recordIds){  
        System.debug('RecordIds'+recordIds);
       if(recordIds.size()>0){            
            // makeCalloutAsync( recordIds);   
           Push_Course_Logisys_whatsapp_batch batch = new Push_Course_Logisys_whatsapp_batch(recordIds[0]);
           Database.executeBatch(batch,98);        
        }else{
            System.debug('RecordIds List is Empty');
        }        
        
    }
}