public class Exam_Application_Form_whats {
    @InvocableMethod
    public static void trsWhatsappNotification(List<list<String>> recordIds){
        
        if(recordIds.size()>0){            
            // makeCalloutAsync( recordIds);   
            Exam_Application_Form_whats_batch batch = new Exam_Application_Form_whats_batch(recordIds[0]);
           Database.executeBatch(batch);        
        }else{
            System.debug('RecordIds List is Empty');
        }
        
    }

}