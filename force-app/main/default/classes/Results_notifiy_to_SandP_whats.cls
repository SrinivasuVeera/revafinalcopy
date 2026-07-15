public class Results_notifiy_to_SandP_whats {
    
      @InvocableMethod
    public static void trsWhatsappNotification(list<String> recordIds){
        if(recordIds[0]!=null){
      //  makeCalloutAsync(recordIds);
           Results_notifiy_to_SandP_whats_batch batch = new Results_notifiy_to_SandP_whats_batch(recordIds[0]);
           Database.executeBatch(batch);
            
        }else{
            System.debug('RecordIds List is Empty');
        }
    }

}