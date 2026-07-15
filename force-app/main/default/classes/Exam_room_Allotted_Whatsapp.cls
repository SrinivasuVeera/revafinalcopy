public class Exam_room_Allotted_Whatsapp {
    @InvocableMethod
    public static void trsWhatsappNotification(list<list<String>> recordIds){
        
        if(recordIds.size()>0){            
            // makeCalloutAsync( recordIds);   
           Exam_room_Allotted_Whatsapp_batch1 batch = new Exam_room_Allotted_Whatsapp_batch1(recordIds[0]);
           Integer batchSize = (Test.isrunningtest()) ? 100 : 1;
            Database.executeBatch(batch,batchSize);        
        }else{
            System.debug('RecordIds List is Empty');
        }        
    }

}

























/*public class Exam_room_Allotted_Whatsapp {
    @InvocableMethod
    public static void trsWhatsappNotification(List<List<String>> recordIds){
        List<String> allottedRecordIds = new List<String>();
        for (List<String> innerList : recordIds) {
            allottedRecordIds.addAll(innerList);
        }
        
        if (!allottedRecordIds.isEmpty()) {
            Exam_room_Allotted_Whatsapp_batch1 batch = new Exam_room_Allotted_Whatsapp_batch1(allottedRecordIds);
            Database.executeBatch(batch);        
        } else {
            System.debug('RecordIds List is Empty');
        }
    }
}
*/