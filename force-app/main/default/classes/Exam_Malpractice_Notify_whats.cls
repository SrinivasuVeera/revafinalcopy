public class Exam_Malpractice_Notify_whats {
 @InvocableMethod
    public static void trsWhatsappNotification(list<String> recordIds){
        
        if(recordIds[0]!=null){            
            // makeCalloutAsync( recordIds);   
           Exam_Malpractice_Notify_whats_batch batch = new Exam_Malpractice_Notify_whats_batch(recordIds[0]);
           Database.executeBatch(batch);        
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }
}