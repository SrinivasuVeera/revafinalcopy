trigger UserTrigger on User (after insert, after update) {
    /*if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        Map<Id,Boolean> userConIDMap = new Map<Id,Boolean>();
        for (User user : Trigger.new) {
            if(Trigger.isInsert || user.isActive !=Trigger.oldMap.get(user.Id).IsActive){
                userConIDMap.put(user.ContactId,user.IsActive);
            } 
        }
        if (!userConIDMap.keyset().isEmpty()) {
            UpdateContactActiveField.ContactFieldUp(userConIDMap);
        }
    }
*/
}