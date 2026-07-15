public class UpdateContactActiveField {
    @future
    public static void ContactFieldUp(Map<Id,Boolean> userConIDMap) {
        List<Contact> updateConList = new List<Contact>();
        for(Contact con: [SELECT Id, Active__c FROM Contact WHERE ID IN: userConIDMap.keySet()]){
           con.Active__c = userConIDMap.get(con.Id);
            updateConList.add(Con);
        }
        if(!updateConList.isEmpty()){
            UPDATE updateConList;
        }
    }
}