public class HallTicket_Published_whats {
      @InvocableMethod
    public static void trsWhatsappNotification(List<List<String>> recordIds){
        if(recordIds[0]!=null){
      //  makeCalloutAsync(recordIds);
           HallTicket_Published_whats_batch batch = new HallTicket_Published_whats_batch(recordIds[0]);
           Database.executeBatch(batch,1);
            
        }else{
            System.debug('RecordIds List is Empty');
        }

}
}
/*
code for execte List<List<string>> recids=new list<List<string>>{new list<String>{'a3BIl00000003amMAA'}};

HallTicket_Published_whats.trsWhatsappNotification(recids);
*/